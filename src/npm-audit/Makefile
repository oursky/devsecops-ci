.PHONY: all build check 

all: build

build:
	@apk add --update nodejs nodejs-npm
	@npm install -g npm

check: FORCE
	@./check.sh --verbose="$(VERBOSE)" --conf-file="$(CONF_FILE)" --target-dir="$(TARGET_DIR)"

FORCE:
