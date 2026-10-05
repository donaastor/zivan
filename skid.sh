_skid_one() {
	local i f p file url
	for ((i=1;i<=${#1};i++)); do
		[[ ${1:i} =~ ^-[^a-zA-Z]*$ ]] && break
	done
	f="${1:0:1}"; p="${1:0:i}"; file="${1}-${2}.pkg.tar.zst"
	url="https://archive.archlinux.org/packages/$f/$p/$file"
	if curl -fsL -C - -o "$file" "$url"; then
		printf ' \033[38;5;28mPASS\033[0m '"($2)"; else
		printf ' \033[38;5;88mFAIL\033[0m '"($2)"; return 1; fi
}

skid() {
	local x
	for x in "$@"; do
		printf '%s ...' "$x"
		[[ -e "${x}-x86_64.pkg.tar.zst" ]] &&
			{ printf ' \033[38;5;224mSKIP\033[0m\n'; continue; }
		[[ -e "${x}-any.pkg.tar.zst" ]] &&
			{ printf ' \033[38;5;224mSKIP\033[0m (any)\n'; continue; }
		_skid_one "$x" x86_64 || _skid_one "$x" any
		printf '\n'
	done
}
