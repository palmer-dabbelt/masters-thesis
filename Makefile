CONFIGURATIONS = saed32-rocketchip-DefaultConfig

# Find some tools
ifneq (,$(wildcard /usr/bin/tek))
TEK_BIN = /usr/bin/tek
else
TEK_BIN = obj/install/tek/bin/tek
endif

# The whole point of this repository is to build a thesis.  This builds the
# thesis using tek, builds tek using pconfigure, and uses PLSI to build
# pconfigure.
thesis: paper/masters-thesis.pdf

paper/masters-thesis.pdf: \
		$(TEK_BIN) \
		$(patsubst %,paper/results/%.qor,$(CONFIGURATIONS)) \
		paper/Makefile
	$(MAKE) PATH="$(abspath $(dir $<)):$(PATH)" -C $(dir $@) $(notdir $@)
	touch --no-create $@

paper/Makefile: \
		$(TEK_BIN) \
		$(wildcard paper/*.tex)
	cd $(dir $@) && $(abspath $<)

obj/install/tek/bin/tek: obj/build/tek/Makefile
	$(MAKE) -C $(dir $<) install
	touch -c $@

obj/build/tek/Makefile: \
		plsi/obj/tools/install/pconfigure/bin/pconfigure \
		$(shell find src/tek -type f)
	@mkdir -p $(dir $@)
	cd $(dir $@) && $(abspath $<) --srcpath "$(abspath src/tek)" "PREFIX = $(abspath obj/install/tek)"

plsi/obj/tools/install/pconfigure/bin/pconfigure:
	$(MAKE) -C plsi obj/tools/install/pconfigure/bin/pconfigure

# This pattern rule builds a single configuration.  There's also some rules to pull
results/%/stamp:
	$(MAKE) -C plsi TECHNOLOGY=$(word 1,$(subst -, ,$(patsubst results/%/stamp,%,$@))) CORE_GENERATOR=$(word 2,$(subst -, ,$(patsubst results/%/stamp,%,$@))) CORE_CONFIG=$(word 3,$(subst -, ,$(patsubst results/%/stamp,%,$@))) par-verilog
	date > $@

paper/results/%.qor: results/%/stamp
	touch -c $@
