#!/usr/bin/make -f
# vim: set autoindent smartindent ts=4 sw=4 sts=4 noet filetype=make:
export DOTFILES := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
TGTDIR ?= $(HOME)
export TGTDIR := $(realpath $(TGTDIR))
ifneq ($(DEBUG),)
  DBG:=
else
  DBG:=@
endif
.DEFAULT: install

ifeq ($(COMSPEC)$(ComSpec),) # not on Windows?
SHELL := $(shell /usr/bin/env which bash)
APAYLOAD:=./append_payload
NPD:=--no-print-directory

.PHONY: all install install.script info test nodel-test setup clean rebuild help $(APAYLOAD) configure.gitconfig bashrc.link

ifeq ($(strip $(DBG)),)
endif
PAYLOAD  := dotfiles.tgz
SETUP    := dotfile_installer
SETUPS   := $(SETUP).sh $(SETUP).bin
ifdef WEBDIR
  PSETUPS:= $(patsubst %,$(WEBDIR)/%,$(SETUPS))
endif
SENTINEL := $(DOTFILES)/.hg/store/00changelog.i

install: install.script configure.gitconfig bashrc.link

install.script: $(DOTFILES)/install-dotfiles
	$(DBG)test -d "$(DOTFILES)/.hg" && cp hgrc.local "$(DOTFILES)/.hg/hgrc"
	$(DBG)cd $(DOTFILES) && env TGTDIR="$(TGTDIR)" ./install-dotfiles

ifndef WEBDIR
setup: $(APAYLOAD) $(SETUPS)
else
setup: $(APAYLOAD) $(PSETUPS)
	hg -R $(DOTFILES) tip|perl -ple 's/\s+<[^>]+>//g'|tee "$(WEBDIR)/tip.txt" && touch -r $(SENTINEL) "$(WEBDIR)/tip.txt"

$(WEBDIR)/%: %
	cp -a $< $@
endif

$(filter %.bin,$(SETUPS)): $(PAYLOAD) $(SENTINEL)
	$(APAYLOAD) -b "-i=$(notdir $(basename $@)).sh.in" "-o=$(notdir $@)" $(notdir $<)

$(filter %.sh,$(SETUPS)): $(PAYLOAD) $(SENTINEL)
	$(APAYLOAD) -u "-i=$(notdir $(basename $@)).sh.in" "-o=$(notdir $@)" $(notdir $<)

$(PAYLOAD): $(SENTINEL)
	hg -R $(DOTFILES) update
	@rm -f $(notdir $(SETUPS) $(PAYLOAD))
	tar -vC $(DOTFILES) --exclude-vcs -czf /tmp/$(notdir $@) . && mv /tmp/$(notdir $@) $@

$(APAYLOAD):
	$(APAYLOAD) canrun

.NOTPARALLEL: rebuild
rebuild: clean setup

nodel-test test: TGTDIR:=$(HOME)/dotfile-test
test:
	$(DBG)test -d "$(TGTDIR)" && rm -rf "$(TGTDIR)" || true
	$(DBG)test -d "$(TGTDIR)" || mkdir -p "$(TGTDIR)"
	$(DBG)$(strip $(MAKE) $(NPD)) TGTDIR="$(TGTDIR)" install

nodel-test:
	$(DBG)$(strip $(MAKE) $(NPD)) TGTDIR="$(TGTDIR)" install

clean:
	rm -f $(notdir $(SETUPS) $(PAYLOAD))

help:
	-@echo "USAGE:"
	-@echo ""
	-@echo "  Create the installer script with payload:"
	-@echo "    make setup"
	-@echo ""
	-@echo "  Install into TGTDIR [the default]:"
	-@echo "    make install"
	-@echo ""
	-@echo "    TGTDIR defaults to $$HOME unless you override it."
	-@echo ""
	-@echo "    Ways to override:"
	-@echo "      make TGTDIR=/target/dir install"
	-@echo "      TGTDIR=/target/dir make install"
	-@echo ""
	-@echo "  Install into $$HOME/dotfile-test instead of $$HOME:"
	-@echo "    make test"
	-@echo ""
	-@echo "  Install into $$HOME/dotfile-test instead of $$HOME:"
	-@echo "    make nodel-test"
	-@echo ""
	-@echo "    This will not remove $$HOME/dotfile-test prior to 'make install'"
	-@echo ""
	-@echo "* TO DEBUG: set the variable DEBUG to a non-empty value"
	-@echo ""
	-@echo "Alternative one method to install:"
	-@echo ""
	-@echo "hg clone https://hg.code.sf.net/p/assarbad-dotfiles/code ~/.dotfiles && make -C ~/.dotfiles install"

info:
	-@$(foreach var,DEBUG NPD CURDIR SHELL TGTDIR DOTFILES PAYLOAD SETUP SETUPS SENTINEL,echo "$(var) = ${$(var)}";)

.NOTPARALLEL: install test nodel-test
.INTERMEDIATE: $(TGTDIR)/$(VIM_RMOLD) $(PAYLOAD)
.ONESHELL: help

bashrc.link:
	test -f $(TGTDIR)/.bashrc && rm -f -- $(TGTDIR)/.bashrc
	$$SHELL -c "cd '$(TGTDIR)' && ln --symbolic .bash_profile .bashrc"

else # on Windows

ifeq ($(SHELL),C:/Program Files/Git/usr/bin/sh.exe)
$(warning Converting paths to mixed form)
export HOME:=$(shell /usr/bin/env cygpath -m "$$HOME")
export DOTFILES:=$(shell /usr/bin/env cygpath -m "$$DOTFILES")
export TGTDIR:=$(shell /usr/bin/env cygpath -m "$$TGTDIR")
else
$(warning SHELL=$(SHELL))
endif
FILES_TO_CONSIDER:=\
	.bashrc.d/gpg \
	.config/flake8 \
	.config/starship.toml \
	$(wildcard .config/espanso/config/*.yml) \
	$(wildcard .config/espanso/match/*.yml) \
	$(wildcard .config/espanso/match/*.md) \
	$(wildcard .config/cookiecutter/*) \
	$(wildcard .config/rustfmt/*) \
	$(wildcard .config/alacritty/*) \
	.cargo/config.toml \
	$(wildcard .config/git/*) \
	.gnupg/gpg.conf \
	.gnupg/.no-pubkey-fetch \
	.bash_profile \
	.common_profile \
	.zshrc \
	.hgrc \
	.inputrc \
	.vimrc \
	Mercurial.ini
$(warning Installing from DOTFILES=$(DOTFILES) into TGTDIR=$(TGTDIR) with HOME=$(HOME))

clean-windows:
	if [[ -f "$(HOME)/.gitrc.d/gitconfig.LOCAL" && ! -f "$(HOME)/.config/git/gitconfig.LOCAL" ]]; then \
		( set -x; mv -- "$(HOME)/.gitrc.d/gitconfig.LOCAL" "$(HOME)/.config/git"/ ); \
	fi; \
	if [[ -f "$(HOME)/.gitrc.d/gitconfig.USER" && ! -f "$(HOME)/.config/git/gitconfig.USER" ]]; then \
		( set -x; mv -- "$(HOME)/.gitrc.d/gitconfig.USER" "$(HOME)/.config/git"/ ); \
	fi; \
	if [[ -d "$(HOME)/.gitrc.d" ]]; then \
		( set -x; rm -rf -- "$(HOME)/.gitrc.d" ); \
	fi; \
	if [[ -f "$(HOME)/.gitconfig" ]]; then \
		( set -x; rm -f -- "$(HOME)/.gitconfig" ); \
	fi; \
	if [[ -f "$(HOME)/.cargo/config" && ! -f "$(HOME)/.cargo/config.toml" ]]; then \
		( set -x; mv -- "$(HOME)/.cargo/config" "$(HOME)/.cargo/config.toml" ); \
	elif [[ -f "$(HOME)/.cargo/config" && -f "$(HOME)/.cargo/config.toml" ]]; then \
		( set -x; rm -f -- "$(HOME)/.cargo/config" ); \
	fi; \
	if [[ -f "$(HOME)/.bashrc" ]]; then \
		( set -x; rm -f -- "$(HOME)/.bashrc" ); \
	fi
	if [[ -f "$(HOME)/.bashrc.d/rust" ]]; then \
		( set -x; rm -f -- "$(HOME)/.bashrc.d/rust" ); \
	fi
	if [[ -f "$(HOME)/.config/git/gitconfig.gnupg4win" ]]; then \
		( set -x; rm -f -- "$(HOME)/.config/git/gitconfig.gnupg4win" ); \
	fi

install: clean-windows $(addprefix $(HOME)/,$(FILES_TO_CONSIDER)) configure.gitconfig

$(HOME)/%: %
	@test -d "$(dir $@)" || mkdir -p "$(dir $@)"
	cp -f "$<" "$@"

.PHONY: install $(HOME)/.config/git/gitconfig.LOCAL configure.gitconfig clean-windows bashrc.link

bashrc.link:
	cp -alf -- $(TGTDIR)/.bash_profile $(TGTDIR)/.bashrc

endif

configure.gitconfig: $(DOTFILES)/configure-gitconfig
	$(DBG)cd $(DOTFILES) && env TGTDIR="$(TGTDIR)" ./configure-gitconfig
