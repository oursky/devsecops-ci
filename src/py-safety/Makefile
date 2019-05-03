.PHONY: all build check 

all: build
	@:

build:
	@pip install -r requirements.txt

check: FORCE
	@./check.sh --verbose="$(VERBOSE)" --conf-file="$(CONF_FILE)" --target-dir="$(TARGET_DIR)"

FORCE:
