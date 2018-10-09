.PHONY: all build check 

all: build

build:
	@pip install -r requirements.txt

check: FORCE
	@echo "[ ] py-safety"
	@if [ -f $(TARGET_DIR)/devsecops-ci.conf ]; then \
	  safety check --cache \
	    `sed -e 's/[[:space:]]*\:[[:space:]]*/:/g' $(TARGET_DIR)/devsecops-ci.conf | sed -n '/^\[py-safety\]/,/^\[.*\]/p' | grep "^[[:space:]]*arguments[[:space:]]*:" | sed 's/.*\:[[:space:]]*//'` \
	    `find $(TARGET_DIR)/ \
		  \`sed -e 's/[[:space:]]*\:[[:space:]]*/:/g' $(TARGET_DIR)/devsecops-ci.conf | sed -n '/^\[py-safety\]/,/^\[.*\]/p' | grep "^[[:space:]]*exclude[[:space:]]*:" | sed 's/.*\:[[:space:]]*//' | sed 's/,/ /g' | sed 's/.*/-type d -name & -prune -o/g'\` \
	          -type f -name 'require*.txt' -print | sed 's/.*/-r &/g'`; \
	else \
	  safety check --cache \
	    `find $(TARGET_DIR)/ -type f -name 'require*.txt' -print | sed 's/.*/-r &/g'`; \
	fi

FORCE:
