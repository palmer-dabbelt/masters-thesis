# Find some tools
ifneq (,$(wildcard /usr/bin/tek))
TEK_BIN = /usr/bin/tek
else
TEK_BIN = obj/install/tek/bin/tek
endif

# The whole point of this repository is to build a thesis.
thesis: paper/masters-thesis.pdf

paper/masters-thesis.pdf: \
		$(TEK_BIN) \
		paper/Makefile
	$(MAKE) PATH="$(abspath $(dir $<)):$(PATH)" -C $(dir $@) $(notdir $@)
	touch --no-create $@

paper/Makefile: \
		$(TEK_BIN) \
		$(wildcard paper/*.tex)
	cd $(dir $@) && $(abspath $<)

obj/install/tek/bin/tek: obj/build/tek/Makefile
	$(MAKE) -C $(dir $<) install

obj/build/tek/Makefile: \
		plsi/obj/tools/install/pconfigure/bin/pconfigure \
		$(shell find src/tek -type f)
	@mkdir -p $(dir $@)
	cd $(dir $@) && $(abspath $<) --srcpath "$(abspath src/tek)" "PREFIX = $(abspath obj/install/tek)"
