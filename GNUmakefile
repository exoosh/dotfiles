#!/usr/bin/make -f

TGTDIR ?= $(HOME)
TGTDIR := $(realpath $(TGTDIR))

.PHONY: install setup clean rebuild

SRCFILES := .multitailrc .vimrc .tmux.conf .hgrc .bashrc .bash_aliases .vim $(shell find .bashrc.d -type f)

define make_single_rule
install: $(TGTDIR)/$(1)
$(TGTDIR)/$(1): $(realpath $(1))
	-@test -L $$@ && rm -f $$@ || true
	-@test -d $$(dir $$@) || mkdir -p $$(dir $$@)
	@echo "Linking/copying: $$(notdir $$^) -> $$(dir $$@)"
	@cp -lfr $$^ $$@ 2>/dev/null || cp -fr $$^ $$@
endef

DOTFILES := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
PAYLOAD  := dotfiles.tgz
SETUP    := dotfile_installer
SETUPS   := $(SETUP).sh $(SETUP).bin

setup: $(SETUPS)

$(SETUP).bin: $(PAYLOAD)
	./append_payload -b "-i=$(notdir $(basename $@)).sh.in" "-o=$(notdir $@)" $(notdir $^)

$(SETUP).sh: $(PAYLOAD)
	./append_payload -u "-i=$(notdir $(basename $@)).sh.in" "-o=$(notdir $@)" $(notdir $^)

$(PAYLOAD): $(filter-out $(addprefix %/,$(SETUPS) $(PAYLOAD)),$(wildcard $(DOTFILES)/*) $(wildcard $(DOTFILES)/.bashrc.d/*))
	@rm -f $(notdir $(SETUPS) $(PAYLOAD))
	@test -d .hg && rm -f .hg/rm -f hg-bundle-*
	tar -C $(DOTFILES) --exclude='.hg/hgrc' --transform 's|hgrc.dotfiles|.hg/hgrc|' -czf /tmp/$(notdir $@) . && mv /tmp/$(notdir $@) $@

.NOTPARALLEL: rebuild
rebuild: clean setup

clean:
	rm -f $(notdir $(SETUPS) $(PAYLOAD))

.INTERMEDIATE: $(PAYLOAD)

$(foreach goal,$(sort $(SRCFILES)),$(eval $(call make_single_rule,$(goal))))
