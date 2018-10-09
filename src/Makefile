SUBDIRS:=$(wildcard */.)

.PHONY: build check

build:
	@for dir in $(SUBDIRS); do \
	  $(MAKE) --no-print-directory $@ -C $$dir; \
	done

check:
	@for dir in $(SUBDIRS); do \
	  $(MAKE) --no-print-directory $@ -C $$dir; \
	done
