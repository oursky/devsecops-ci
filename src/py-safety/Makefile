REQUIREMENTS:=$(wildcard $(TARGET_DIR)/require*.txt)

build:
	@pip install -r requirements.txt

check: $(REQUIREMENTS) FORCE
	@echo "[ ] py-safety - $(REQUIREMENTS)"

$(REQUIREMENTS): FORCE
	@echo "[ ] py-safety - $@"
	@safety check -r "$@"

FORCE:
