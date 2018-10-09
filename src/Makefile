MODULES:=$(patsubst %/,%,$(sort $(dir $(wildcard */))))

.PHONY: build check

build:
	@for module in $(MODULES); do \
	  $(MAKE) --no-print-directory $@ -C $$module; \
	done

check:
	@for module in $(MODULES); do \
	  if ! $(MAKE) --no-print-directory $@ -C $$module; then \
	    echo "[E] Issues found on $$module"; \
	    if [ -f "$$module/suppress.txt" ]; then \
	      echo "#########################################"; \
	      cat "$$module/suppress.txt"; \
	      echo "#########################################"; \
	    fi; \
	    exit 1; \
	  fi; \
	done
