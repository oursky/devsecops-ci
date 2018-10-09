REQUIREMENTS:=$(patsubst %,-r %,$(wildcard $(TARGET_DIR)/require*.txt))

.PHONY: build check

build: FORCE
	@pip install -r requirements.txt

check:
	@echo "[ ] py-safety"
	@if [ -f $(TARGET_DIR)/devsecops-ci.conf ]; then \
	  safety check --cache \
	    `sed -e 's/[[:space:]]*\:[[:space:]]*/:/g' $(TARGET_DIR)/devsecops-ci.conf | sed -n '/^\[py-safety\]/,/^\[.*\]/p' | grep "^[[:space:]]*arguments[[:space:]]*:" | sed 's/.*\:[[:space:]]*//'` \
	    $(REQUIREMENTS); \
	else \
	  safety check --cache $(REQUIREMENTS); \
	fi

FORCE:
