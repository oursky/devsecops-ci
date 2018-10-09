.PHONY: all build check

all: build

build:
	@pip install -r requirements.txt

check: FORCE
	@echo "[ ] py-bandit"
	@if [ -f "$(TARGET_DIR)/devsecops-ci.conf" ]; then \
	  bandit --ini "$(TARGET_DIR)/devsecops-ci.conf" -r "$(TARGET_DIR)"; \
	else \
	  bandit -r "$(TARGET_DIR)"; \
	fi

FORCE:
