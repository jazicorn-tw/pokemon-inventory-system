# Top-level Makefile (loader)
MAKE_DIR := make

# Files
MAKE_CORE_1 := 00-kernel.mk
MAKE_CORE_2 := 10-presentation.mk
MAKE_CORE_3 := 20-configuration.mk

# Load foundations first (order matters)
include $(MAKE_DIR)/$(MAKE_CORE_1)
include $(MAKE_DIR)/$(MAKE_CORE_2)
include $(MAKE_DIR)/$(MAKE_CORE_3)

# Auto-include everything else in make/ (including 31-help-categories.mk)
MK_REST := $(filter-out \
  $(MAKE_DIR)/$(MAKE_CORE_1) \
  $(MAKE_DIR)/$(MAKE_CORE_2) \
  $(MAKE_DIR)/$(MAKE_CORE_3), \
  $(sort $(wildcard $(MAKE_DIR)/*.mk)) \
)

-include $(MK_REST)
