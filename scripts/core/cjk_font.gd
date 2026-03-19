extends RefCounted

const PROJECT_FONT_PATHS := [
	"res://assets/fonts/ui-zh.ttf",
	"res://assets/fonts/ui-zh.otf",
	"res://assets/fonts/ui-zh.ttc"
]
const SYSTEM_FONT_PATHS := [
	"/System/Library/Fonts/Hiragino Sans GB.ttc",
	"/System/Library/Fonts/STHeiti Medium.ttc",
	"/System/Library/Fonts/PingFang.ttc"
]
const FALLBACK_FONT_PATH := "res://assets/fonts/cjk-symbols-fallback.ttc"

static var cached_font: Font


static func get_font() -> Font:
	if cached_font != null:
		return cached_font

	for font_path_variant in PROJECT_FONT_PATHS:
		var font_path := String(font_path_variant)
		var project_font := _load_project_font(font_path)
		if project_font != null:
			cached_font = project_font
			return cached_font

	for font_path_variant in SYSTEM_FONT_PATHS:
		var font_path := String(font_path_variant)
		var system_font := _load_font(font_path)
		if system_font != null:
			cached_font = system_font
			return cached_font

	var fallback_font := _load_project_font(FALLBACK_FONT_PATH)
	if fallback_font != null:
		cached_font = fallback_font
		return cached_font

	cached_font = ThemeDB.fallback_font
	return cached_font


static func _load_font(font_path: String) -> Font:
	if not FileAccess.file_exists(font_path):
		return null

	var font_bytes: PackedByteArray = FileAccess.get_file_as_bytes(font_path)
	if font_bytes.is_empty():
		return null

	var font_file := FontFile.new()
	font_file.data = font_bytes
	return font_file


static func _load_project_font(font_path: String) -> Font:
	if not ResourceLoader.exists(font_path):
		return null

	var font_resource = load(font_path)
	if font_resource is Font:
		return font_resource
	return null
