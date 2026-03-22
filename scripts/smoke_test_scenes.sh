#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_VERSION="${GODOT_VERSION:-4.6.1-stable}"
SMOKE_QUIT_AFTER="${HANZI_SCENE_SMOKE_QUIT_AFTER:-2}"

log() {
	printf '[smoke_test_scenes] %s\n' "$1"
}

fail() {
	printf '[smoke_test_scenes] %s\n' "$1" >&2
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

	fail "Need curl or wget to download the Godot editor."
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

	fail "Need unzip or python3 to extract the Godot editor archive."
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

	if [ ! -x "$DEFAULT_GODOT_BIN" ]; then
		log "Downloading Godot ${GODOT_VERSION} editor binary."
		download_file "$binary_url" "$binary_zip"
		extract_zip "$binary_zip" "$cache_root"
		chmod +x "$DEFAULT_GODOT_BIN"
	fi
}

prepare_darwin_godot() {
	DEFAULT_GODOT_BIN="/Applications/Godot.app/Contents/MacOS/Godot"
}

runtime_dir=""

cleanup() {
	if [ -n "$runtime_dir" ] && [ -d "$runtime_dir" ]; then
		rm -rf "$runtime_dir"
	fi
}

trap cleanup EXIT

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

runtime_dir="$(mktemp -d "${TMPDIR:-/tmp}/hanzi-godot-smoke.XXXXXX")"
export HOME="${runtime_dir}/home"
export XDG_DATA_HOME="${runtime_dir}/data"
export XDG_CONFIG_HOME="${runtime_dir}/config"
export XDG_CACHE_HOME="${runtime_dir}/cache"
mkdir -p "$HOME" "$XDG_DATA_HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME"

SCENES=()
while IFS= read -r scene; do
	SCENES+=("$scene")
done < <(cd "$ROOT_DIR" && find scenes -type f -name '*.tscn' | sort)
[ ${#SCENES[@]} -gt 0 ] || fail "No scenes found under ${ROOT_DIR}/scenes."

contains_errors() {
	local output_file="$1"
	local log_file="$2"
	local error_lines

	# Godot's editor build can emit this import-time snapshot warning in sandboxed runs
	# even when the project resources imported successfully.
	error_lines="$(grep -Eh '(^|[[:space:]])(SCRIPT )?ERROR:' "$output_file" "$log_file" || true)"
	error_lines="$(printf '%s\n' "$error_lines" | grep -Ev 'Could not create ObjectDB Snapshots directory' || true)"
	[ -n "$error_lines" ]
}

print_failure_details() {
	local output_file="$1"
	local log_file="$2"

	if [ -s "$output_file" ]; then
		printf '\n-- stdout/stderr --\n' >&2
		tail -n 40 "$output_file" >&2
	fi
	if [ -s "$log_file" ]; then
		printf '\n-- engine log --\n' >&2
		tail -n 40 "$log_file" >&2
	fi
}

import_output="${runtime_dir}/import.out"
import_log="${runtime_dir}/import.log"
log "Importing project assets."
if ! "$GODOT_BIN_PATH" --headless --path "$ROOT_DIR" --recovery-mode --import --quit --log-file "$import_log" >"$import_output" 2>&1; then
	print_failure_details "$import_output" "$import_log"
	fail "Initial project import failed."
fi
if contains_errors "$import_output" "$import_log"; then
	print_failure_details "$import_output" "$import_log"
	fail "Initial project import reported errors."
fi

failures=()
for scene in "${SCENES[@]}"; do
	scene_key="${scene//\//_}"
	scene_output="${runtime_dir}/${scene_key}.out"
	scene_log="${runtime_dir}/${scene_key}.log"
	log "Smoke loading ${scene}."
	if ! "$GODOT_BIN_PATH" --headless --quiet --path "$ROOT_DIR" --scene "$scene" --quit-after "$SMOKE_QUIT_AFTER" --log-file "$scene_log" >"$scene_output" 2>&1; then
		print_failure_details "$scene_output" "$scene_log"
		failures+=("$scene")
		continue
	fi
	if contains_errors "$scene_output" "$scene_log"; then
		print_failure_details "$scene_output" "$scene_log"
		failures+=("$scene")
	fi
done

if [ ${#failures[@]} -gt 0 ]; then
	printf '[smoke_test_scenes] Scenes with failures:\n' >&2
	for scene in "${failures[@]}"; do
		printf '  - %s\n' "$scene" >&2
	done
	exit 1
fi

log "Validated ${#SCENES[@]} scenes without scene-load errors."
