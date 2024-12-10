# vim: set autoindent smartindent ts=4 sw=4 sts=4 filetype=sh:
[[ -f "$HOME/.common_profile" ]] && source "$HOME/.common_profile"
# Lines configured by zsh-newuser-install
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall

[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"
if type -p uv > /dev/null 2>&1; then
	eval "$(uv generate-shell-completion bash)"
fi
