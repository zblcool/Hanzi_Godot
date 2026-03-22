#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_VERSION="${GODOT_VERSION:-4.6.1-stable}"
SMOKE_FRAMES="${HANZI_SMOKE_FRAMES:-4}"
LOG_DIR="${HANZI_SMOKE_LOG_DIR:-${TMPDIR:-/tmp}/hanzi_godot_smoke_logs}"

SCENES=(
	"res://scenes/app/launcher.tscn"
	"res://scenes/app/zihai_menu.tscn"
	"res://scenes/battle/zihai_battle.tscn"
)

log() {
	printf '[check_scenes] %s\n' "$1"
}

fail() {
	printf '[check_scenes] %s\n' "$1" >&2
	exit 1
}

download_file() {
	local url="$1"
	local destination="$2"

	if command -v curl >/dev/null 2>&1; then
		curl -fsSL --retry 3 --retry-delay 1 -o "$destination" "$url"
		return
	fi

	if command -v wget >/dev/null 2>&1; then
		wget -qO "$destination" "$url"
		return
	fi

	fail "Need curl or wget to download Godot artifacts."
}

extract_zip() {
	local archive="$1"
	local destination="$2"

	mkdir -p "$destination"
	if command -v unzip >/dev/null 2>&1; then
		unzip -oq "$archive" -d "$destination"
		return
	fi

	if command -v python3 >/dev/null 2>&1; then
		python3 - "$archive" "$destination" <<'PY'
import pathlib
import sys
import zipfile

archive = pathlib.Path(sys.argv[1])
destination = pathlib.Path(sys.argv[2])
with zipfile.ZipFile(archive) as handle:
    handle.extractall(destination)
PY
		return
	fi

	fail "Need unzip or python3 to extract Godot artifacts."
}

find_godot_bin() {
	for candidate in \
		"${GODOT_BIN:-}" \
		"${DEFAULT_GODOT_BIN:-}" \
		"$(command -v godot 2>/dev/null || true)" \
		"$(command -v godot4 2>/dev/null || true)"
	do
		if [ -n "$candidate" ] && [ -x "$candidate" ]; then
			printf '%s\n' "$candidate"
			return
		fi
	done

	return 1
}

prepare_linux_godot() {
	local cache_root="${VERCEL_CACHE_DIR:-${HOME}/.cache}/hanzi-godot/${GODOT_VERSION}"
	local binary_zip="${cache_root}/Godot_v${GODOT_VERSION}_linux.x86_64.zip"
	local binary_url="https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64.zip"

	DEFAULT_GODOT_BIN="${cache_root}/Godot_v${GODOT_VERSION}_linux.x86_64"
	mkdir -p "$cache_root"
	mkdir -p "${XDG_DATA_HOME:-${HOME}/.local/share}/godot"

	if [ ! -x "$DEFAULT_GODOT_BIN" ]; then
		log "Downloading Godot ${GODOT_VERSION} editor binary."
		download_file "$binary_url" "$binary_zip"
		extract_zip "$binary_zip" "$cache_root"
		chmod +x "$DEFAULT_GODOT_BIN"
	fi
}

prepare_darwin_godot() {
	DEFAULT_GODOT_BIN="/Applications/Godot.app/Contents/MacOS/Godot"
	mkdir -p "${HOME}/Library/Application Support/Godot"
}

case "$(uname -s)" in
	Darwin)
		prepare_darwin_godot
		;;
	Linux)
		prepare_linux_godot
		;;
	*)
		fail "Unsupported platform: $(uname -s)"
		;;
esac

GODOT_BIN_PATH="$(find_godot_bin)" || fail "Could not find a usable Godot editor binary."
mkdir -p "$LOG_DIR"

log "Importing project assets."
"$GODOT_BIN_PATH" --headless --path "$ROOT_DIR" --log-file "$LOG_DIR/import.log" --import --quit

for scene_path in "${SCENES[@]}"; do
	scene_name="$(basename "${scene_path%.tscn}")"
	log "Checking ${scene_path}."
	"$GODOT_BIN_PATH" \
		--headless \
		--quiet \
		--path "$ROOT_DIR" \
		--log-file "$LOG_DIR/${scene_name}.log" \
		--scene "$scene_path" \
		--quit-after "$SMOKE_FRAMES"
done

log "Scene smoke checks complete."
