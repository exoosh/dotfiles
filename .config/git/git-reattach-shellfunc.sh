#!/usr/bin/env bash
# shellcheck disable=SC2059
# vim: set autoindent smartindent ts=4 sw=4 sts=4 noet filetype=sh:
set -e

# Preferred branch names, in priority order when multiple candidates exist.
PREFERRED_BRANCHES=(main master default stable release develop)

function git_reattach_impl
{
	if [[ ! -v WHENCE_CMD ]]; then
		local -a WHENCE_CMD
		if [[ -v BASH_VERSION ]]; then
			shopt -s extglob
			WHENCE_CMD=(builtin type -P)
		elif [[ -v ZSH_VERSION ]]; then
			setopt extendedglob ksharrays
			WHENCE_CMD=(builtin whence -p)
		fi
	fi
	if ! [[ -v cR && -v cG && -v cB && -v cY && -v cW && -v cR_ && -v cG_ && -v cB_ && -v cY_ && -v cW_ && -v cZ ]]; then
		local cR="" cG="" cB="" cY="" cW="" cR_="" cG_="" cB_="" cY_="" cW_="" cZ=""
		readonly cR cG cB cY cW cR_ cG_ cB_ cY_ cW_ cZ
	fi
	for tool in env git; do
		if ! "${WHENCE_CMD[@]}" "$tool" > /dev/null 2>&1; then
			printf "${cR}ERROR:${cZ} ${cW}%s${cZ} does not seem to be installed.\n" "$tool"
			return 1
		fi
	done
	local -a CANDIDATE_BRANCHES
	local STATUS_DETACHED_BRANCH
	if env LANG=C LC_ALL=C git symbolic-ref -q HEAD > /dev/null 2>&1; then # on a branch (not detached)?
		local BRANCH_NAME
		if BRANCH_NAME=$(env LANG=C LC_ALL=C git symbolic-ref -q HEAD); then
			BRANCH_NAME="${BRANCH_NAME##refs\/heads\/}"
			printf -- "Already on branch ${cW}%s${cZ}\n" "$BRANCH_NAME"
		fi
	else
		# Determine whether git status gives us the output "HEAD detached at refs/heads/..." and if so, return "..." (only first line of output!)
		STATUS_DETACHED_BRANCH=$(env LANG=C LC_ALL=C git status | awk 'NR==1 && /HEAD detached at refs\/heads\// {  sub(/^refs\/heads\//, "", $4); print $4 }')
		# Determine all candidate branches, for HEAD
		while IFS= read -r bname; do
			CANDIDATE_BRANCHES+=("$bname")
		done < <(env LANG=C LC_ALL=C git for-each-ref --format="%(refname:short)" --points-at HEAD refs/heads/)
		if (( ${#CANDIDATE_BRANCHES[@]} == 1 )); then
			if [[ -n "$STATUS_DETACHED_BRANCH" && "$STATUS_DETACHED_BRANCH" == "${CANDIDATE_BRANCHES[0]}" ]]; then
				printf -- "Unambiguously switching to ${cW}%s${cZ}\n" "$STATUS_DETACHED_BRANCH"
				( set -x; ${DRY:+"echo"} env LANG=C LC_ALL=C git switch "$STATUS_DETACHED_BRANCH" )
			else
				printf -- "Picking the single candidate branch and switching to ${cW}%s${cZ}\n" "${CANDIDATE_BRANCHES[0]}"
				( set -x; ${DRY:+"echo"} env LANG=C LC_ALL=C git switch "${CANDIDATE_BRANCHES[0]}" )
			fi
			return 0
		fi
		local preferred_branch selected_branch=""
		for preferred_branch in "${PREFERRED_BRANCHES[@]}"; do
			for bname in "${CANDIDATE_BRANCHES[@]}"; do
				if [[ "$bname" == "$preferred_branch" || "$bname" == */"$preferred_branch" ]]; then
					selected_branch="$bname"
					break 2
				fi
			done
		done
		if [[ -n "$selected_branch" ]]; then
			printf -- "Picking preferred branch name and switching to ${cW}%s${cZ}\n" "$selected_branch"
			( set -x; ${DRY:+"echo"} env LANG=C LC_ALL=C git switch "$selected_branch" )
		else
			printf -- "${cY}WARNING:${cZ} cannot reasonably decide which branch to switch to. Candidates:\n"
			for bname in "${CANDIDATE_BRANCHES[@]}"; do
				printf -- "    * ${cW}%s${cZ}\n" "$bname"
			done
		fi
	fi
}

git_reattach_impl "$@"
