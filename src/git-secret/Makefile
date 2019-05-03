.PHONY: all build check 

all: build
	@:

build:
	@pip install -r requirements.txt


check: FORCE
	@python main.py --conf-file="$(CONF_FILE)" --target-dir="$(TARGET_DIR)" --verbose="$(VERBOSE)" --commit-range="$(COMMIT_RANGE)"

FORCE:
