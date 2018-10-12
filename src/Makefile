MODULES:=$(patsubst %/,%,$(sort $(dir $(wildcard */))))

.PHONY: build check

build:
	@for module in $(MODULES); do \
	  $(MAKE) --no-print-directory $@ -C $$module; \
	done

check:
	@rc=0; count=0; \
	for module in $(MODULES); do \
	  if ! $(MAKE) --no-print-directory $@ -C $$module; then \
	    rc=`expr $$rc + 1`; \
	    echo "[E] Issues found on $$module"; \
	    if [ -f "$$module/suppress.txt" ]; then \
	      echo "#########################################"; \
	      cat "$$module/suppress.txt"; \
	      echo "#########################################"; \
	    fi; \
	  fi; \
	  count=`expr $$count + 1`; \
	done; \
	echo -e "\n\nTest Summary:\nTests executed: $$count  Tests failed: $$rc"; \
	if [ "$$rc" != "0" ]; then false; fi
