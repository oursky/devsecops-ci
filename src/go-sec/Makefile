.PHONY: all build check 

all: build

build:
	@wget -O - -q https://raw.githubusercontent.com/securego/gosec/master/install.sh | sh -s 1.1.0

check: FORCE
	@./check.sh --verbose="$(VERBOSE)" --conf-file="$(CONF_FILE)" --target-dir="$(TARGET_DIR)"

FORCE:
