#!/usr/bin/env node
/**
 * scripts/git/semantic-release-impact.mjs
 *
 * Computes release impact using @semantic-release/commit-analyzer (same engine
 * semantic-release uses) and emits a best-effort explanation of the rule that
 * produced that impact.
 *
 * Output (key=value lines):
 *   impact=major|minor|patch|none
 *   rule_label=default|releaseRules[i]|releaseRules|unknown
 *   rule_detail=<short human text>
 *
 * Requirements (devDependencies):
 *   npm i -D semantic-release @semantic-release/commit-analyzer
 *
 * Optional (better config loading):
 *   npm i -D cosmiconfig
 */

import fs from "node:fs";
import path from "node:path";
import process from "node:process";

function readJson(filePath) {
  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch {
    return null;
  }
}

async function loadReleaseConfig(repoRoot) {
  // 1) package.json#release
  const pkgPath = path.join(repoRoot, "package.json");
  const pkg = readJson(pkgPath);
  if (pkg && pkg.release) return pkg.release;

  // 2) cosmiconfig (optional) for .releaserc, release.config.js, etc.
  try {
    const { cosmiconfig } = await import("cosmiconfig");
    const explorer = cosmiconfig("release");
    const result = await explorer.search(repoRoot);
    if (result && result.config) return result.config;
  } catch {
    // ignore
  }

  return {};
}

function normalizeAnalyzerConfig(releaseConfig) {
  // semantic-release allows plugins arrays like:
  // plugins: [
  //   "@semantic-release/commit-analyzer",
  //   ["@semantic-release/commit-analyzer", { preset, releaseRules, parserOpts }],
  // ]
  const plugins = releaseConfig?.plugins;
  if (!Array.isArray(plugins)) return {};

  for (const entry of plugins) {
    if (typeof entry === "string") {
      if (entry === "@semantic-release/commit-analyzer") return {};
      continue;
    }
    if (Array.isArray(entry) && entry.length >= 1) {
      const name = entry[0];
      const opts = entry[1] ?? {};
      if (name === "@semantic-release/commit-analyzer") return opts;
    }
  }
  return {};
}

/**
 * Minimal Conventional Commit parse to explain defaults and match releaseRules.
 */
function parseConventional(message) {
  const msg = message.replace(/\r/g, "");
  const header = msg.split("\n")[0] ?? "";
  const body = msg.split("\n").slice(1).join("\n");

  const isRevert = /^Revert\s+"/.test(header);

  const re = /^([a-zA-Z0-9]+)(\(([^)]+)\))?(!)?:\s+(.+)$/;
  const m = header.match(re);

  let type = null;
  let scope = null;
  let breaking = false;

  if (m) {
    type = (m[1] || "").toLowerCase();
    scope = m[3] || null;
    breaking = Boolean(m[4]);
  }

  if (/(^|\n)BREAKING[ -]CHANGE(\:|\s)/i.test(msg)) {
    breaking = true;
  }

  return { header, body, type, scope, breaking, revert: isRevert };
}

function ruleMatches(commit, rule) {
  // Rule keys we support: type, scope, breaking, revert
  for (const key of ["type", "scope", "breaking", "revert"]) {
    if (rule[key] === undefined) continue;

    if (key === "breaking" || key === "revert") {
      if (Boolean(rule[key]) !== Boolean(commit[key])) return false;
      continue;
    }

    if (rule[key] !== commit[key]) return false;
  }
  return true;
}

function describeRule(rule, idx) {
  const parts = [];
  if (rule.type) parts.push(`type=${rule.type}`);
  if (rule.scope) parts.push(`scope=${rule.scope}`);
  if (rule.breaking !== undefined) parts.push(`breaking=${String(rule.breaking)}`);
  if (rule.revert !== undefined) parts.push(`revert=${String(rule.revert)}`);
  const conds = parts.length ? parts.join(", ") : "any";
  return `releaseRules[${idx}] (${conds}) -> ${rule.release}`;
}

function explainDefaultRule(parsed, impact) {
  // Best-effort “exact rule” under default commit-analyzer behavior.
  if (impact === "none") return "no release (commit-analyzer returned null)";
  if (parsed.breaking) return "breaking change -> major";
  if (parsed.type === "feat") return "type=feat -> minor";
  if (parsed.type === "fix") return "type=fix -> patch";
  if (parsed.type === "perf") return "type=perf -> patch";
  // If commit-analyzer returns patch for something else, we avoid lying.
  if (parsed.type) return `type=${parsed.type} -> ${impact} (default mapping)`;
  return `${impact} (default rules)`;
}

async function main() {
  const repoRoot = process.argv[2] || process.cwd();
  const msgFile = process.argv[3];

  if (!msgFile || !fs.existsSync(msgFile)) {
    console.error("semantic-release-impact: commit message file missing.");
    process.exit(2);
  }

  const message = fs.readFileSync(msgFile, "utf8").replace(/\r/g, "");

  // Lazy import so hook remains fast if deps are missing.
  let analyzeCommits;
  try {
    const mod = await import("@semantic-release/commit-analyzer");
    analyzeCommits = mod.default || mod;
  } catch {
    // Keep it quiet; the bash script can fall back to heuristic.
    process.exit(3);
  }

  const releaseConfig = await loadReleaseConfig(repoRoot);
  const analyzerOpts = normalizeAnalyzerConfig(releaseConfig);

  const commits = [{ message, hash: "LOCAL", committerDate: new Date().toISOString() }];

  // analyzeCommits returns: "major" | "minor" | "patch" | null
  const result = await analyzeCommits({ cwd: repoRoot }, { commits, ...analyzerOpts });
  const impact = result ?? "none";

  const parsed = parseConventional(message);

  // Determine rule label/detail
  let ruleLabel = "default";
  let ruleDetail = explainDefaultRule(parsed, impact);

  const rules = analyzerOpts?.releaseRules;
  if (Array.isArray(rules) && rules.length > 0) {
    let found = null;
    let foundIdx = -1;

    for (let i = 0; i < rules.length; i += 1) {
      const r = rules[i];
      if (!r || typeof r !== "object") continue;
      if (!("release" in r)) continue;

      if (ruleMatches(parsed, r)) {
        found = r;
        foundIdx = i;
        // Prefer exact match with computed impact where possible
        if (String(r.release) === String(impact)) break;
      }
    }

    if (found) {
      ruleLabel = `releaseRules[${foundIdx}]`;
      ruleDetail = describeRule(found, foundIdx);
    } else {
      ruleLabel = "releaseRules";
      ruleDetail = "no matching rule found (defaults applied)";
    }
  }

  process.stdout.write(`impact=${impact}\n`);
  process.stdout.write(`rule_label=${ruleLabel}\n`);
  process.stdout.write(`rule_detail=${ruleDetail}\n`);
}

main().catch((err) => {
  console.error("semantic-release-impact: unexpected error.");
  console.error(err?.stack || String(err));
  process.exit(1);
});
