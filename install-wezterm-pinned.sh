#!/bin/sh
set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
VERSION_FILE="${SCRIPT_DIR}/wezterm/VERSION"

if [ ! -f "$VERSION_FILE" ]; then
	printf '%s\n' "Error: missing version file: ${VERSION_FILE}"
	exit 1
fi

PINNED_VERSION=${WEZTERM_VERSION:-$(tr -d '[:space:]' <"$VERSION_FILE")}
if [ -z "$PINNED_VERSION" ]; then
	printf '%s\n' 'Error: pinned WezTerm version is empty.'
	exit 1
fi

for bin in curl awk dpkg-deb install; do
	if ! command -v "$bin" >/dev/null 2>&1; then
		printf '%s\n' "Error: required command not found: $bin"
		exit 1
	fi
done

TMP_DIR=$(mktemp -d)
cleanup() {
	rm -rf "$TMP_DIR"
}
trap cleanup EXIT HUP INT TERM

PACKAGES_URL='https://apt.fury.io/wez/dists/*/*/binary-amd64/Packages'
PACKAGES_FILE="${TMP_DIR}/Packages"
curl -fsSL "$PACKAGES_URL" -o "$PACKAGES_FILE"

DEB_FILENAME=$(awk -v target="$PINNED_VERSION" '
	/^Version: / { ver=$2 }
	/^Filename: / {
		if (ver == target) {
			print $2
			exit
		}
	}
' "$PACKAGES_FILE")

if [ -z "$DEB_FILENAME" ]; then
	printf '%s\n' "Error: version ${PINNED_VERSION} not found in wezterm-nightly apt metadata."
	exit 1
fi

DEB_URL="https://apt.fury.io/wez/${DEB_FILENAME}"
DEB_PATH="${TMP_DIR}/wezterm-nightly.deb"
curl -fsSL "$DEB_URL" -o "$DEB_PATH"

INSTALL_ROOT="${HOME}/.local/opt/wezterm-${PINNED_VERSION}"
mkdir -p "$INSTALL_ROOT"
dpkg-deb -x "$DEB_PATH" "$INSTALL_ROOT"

mkdir -p "${HOME}/.local/bin"
ln -sfn "${INSTALL_ROOT}/usr/bin/wezterm" "${HOME}/.local/bin/wezterm"
ln -sfn "${INSTALL_ROOT}/usr/bin/wezterm-gui" "${HOME}/.local/bin/wezterm-gui"
ln -sfn "${INSTALL_ROOT}/usr/bin/wezterm-mux-server" "${HOME}/.local/bin/wezterm-mux-server"

printf '%s\n' "Pinned Linux/WSL WezTerm installed: ${PINNED_VERSION}"
printf '%s\n' "  Binary: ${HOME}/.local/bin/wezterm"
printf '%s\n' ''

if grep -qi microsoft /proc/version 2>/dev/null && [ "${WEZTERM_SKIP_WINDOWS_FREEZE:-0}" != "1" ]; then
	if command -v powershell.exe >/dev/null 2>&1; then
		powershell.exe -NoLogo -NoProfile -Command \
			"if (Get-Command scoop -ErrorAction SilentlyContinue) { scoop hold wezterm | Out-Null }" >/dev/null 2>&1 || true

		powershell.exe -NoLogo -NoProfile -Command \
			"if (Get-Command winget -ErrorAction SilentlyContinue) { winget pin add --id wez.wezterm --blocking | Out-Null }" >/dev/null 2>&1 || true
	fi

	printf '%s\n' 'Windows update channels frozen (best effort): scoop hold + winget pin.'
fi

printf '%s\n' ''
printf '%s\n' 'Version check:'
"${HOME}/.local/bin/wezterm" -V || true
if [ -x "/mnt/c/Program Files/WezTerm/wezterm.exe" ]; then
	"/mnt/c/Program Files/WezTerm/wezterm.exe" -V || true
fi
