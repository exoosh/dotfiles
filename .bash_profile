# vim: set autoindent smartindent ts=4 sw=4 sts=4 filetype=sh:
[[ -f "$HOME/.common_profile" ]] && source "$HOME/.common_profile"

[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"
if type -p uv > /dev/null 2>&1; then
	eval "$(uv generate-shell-completion bash)"
fi
