#!/usr/bin/env bash
set -euo pipefail

runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
socket="$runtime_dir/wezterm/sock"
pidfile="$runtime_dir/wezterm/pid"

if [[ -S "$socket" ]] && ! timeout 2 wezterm cli --prefer-mux --no-auto-start list >/dev/null 2>&1; then
	pid="$(cat "$pidfile" 2>/dev/null || true)"
	case "$pid" in
		""|*[!0-9]*) ;;
		*) kill "$pid" >/dev/null 2>&1 || true ;;
	esac
	rm -f "$socket" "$pidfile"
fi

if [[ ! -S "$socket" ]]; then
	rm -f "$pidfile"
	wezterm-mux-server --daemonize >/dev/null 2>&1 || true
fi

for _ in 1 2 3 4 5 6 7 8 9 10; do
	if [[ -S "$socket" ]] && timeout 2 wezterm cli --prefer-mux --no-auto-start list >/dev/null 2>&1; then
		exec socat - UNIX-CONNECT:"$socket"
	fi
	sleep 0.2
done

echo "wezterm WSL mux socket is not responsive: $socket" >&2
exit 1
