TESTCASES:=$(wildcard testcase/*)

.PHONY: all build test clean

all: build

build:
	docker build -t devsecops-ci .

clean:
	@-docker rmi devsecops-ci 2>&1 > /dev/null

test:
	@for dir in $(TESTCASES); do \
	  echo "[ ] $$dir"; \
	  if docker run -it --rm -v "`pwd`/$$dir:/target:ro" devsecops-ci ./run.sh -d=/target > /dev/null; then \
	    echo "Check should fail $$dir."; \
	    exit 1; \
	  fi \
	done

