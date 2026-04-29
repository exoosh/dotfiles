NVIM_TREESITTER ?= ../nvim-treesitter

try:
	nvim \
		--cmd 'set rtp+=.,$(NVIM_TREESITTER)' \
		--cmd 'filetype plugin indent on | syntax on' \
		-c 'lua require("ansible").setup()' \
		tests/playbook.yml

try-clean:
	nvim -u NONE \
		--cmd 'set rtp+=.,$(NVIM_TREESITTER)' \
		--cmd 'filetype plugin indent on | syntax on' \
		-c 'lua require("ansible").setup()' \
		tests/playbook.yml

test:
	nvim --headless -u NONE \
		--cmd 'set rtp+=.,$(NVIM_TREESITTER)' \
		--cmd 'filetype plugin indent on | syntax on' \
		-c 'lua require("ansible").setup()' \
		-c 'edit tests/playbook.yml' \
		-c 'set ft=ansible' \
		-c 'luafile tests/run_highlight_tests.lua'

.PHONY: try try-clean test
