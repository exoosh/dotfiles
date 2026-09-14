# vim: set autoindent smartindent ts=4 sw=4 sts=4 filetype=sh:
# Lines configured by zsh-newuser-install
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename "${SHELLRCDIR:-$HOME}/.zshrc"

autoload -Uz compinit
compinit
# End of lines added by compinstall
[[ -f "${SHELLRCDIR:-$HOME}/.common_profile" ]] && source "${SHELLRCDIR:-$HOME}/.common_profile"
[[ -f "${SHELLRCDIR:-$HOME}/.local/bin/env" ]] && source "${SHELLRCDIR:-$HOME}/.local/bin/env"
