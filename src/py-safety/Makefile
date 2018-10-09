REQUIREMENTS:=$(shell find $(TARGET_DIR)/ -type f -name 'require*.txt')
REQUIREMENTS_FLAGS=$(patsubst %,-r %,$(REQUIREMENTS))

.PHONY: all build check 

all: build

build:
	@pip install -r requirements.txt

check: FORCE
	@echo "[ ] py-safety"
	@if [ -f $(TARGET_DIR)/devsecops-ci.conf ]; then \
	  safety check --cache \
	    `sed -e 's/[[:space:]]*\:[[:space:]]*/:/g' $(TARGET_DIR)/devsecops-ci.conf | sed -n '/^\[py-safety\]/,/^\[.*\]/p' | grep "^[[:space:]]*arguments[[:space:]]*:" | sed 's/.*\:[[:space:]]*//'` \
	    $(REQUIREMENTS_FLAGS); \
	else \
	  safety check --cache $(REQUIREMENTS_FLAGS); \
	fi

FORCE:
