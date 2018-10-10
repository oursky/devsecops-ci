.PHONY: all build check 

all: build

build:
	@pip install -r requirements.txt

check: FORCE
	@./check.sh -d=$(TARGET_DIR) --verbose=$(VERBOSE)

FORCE:
