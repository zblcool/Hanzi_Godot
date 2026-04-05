extends RefCounted

const FONT_PATH := "res://assets/fonts/cjk-symbols-fallback.ttc"

static var cached_font: Font


static func get_font() -> Font:
	if cached_font != null:
		return cached_font

	var font_bytes: PackedByteArray = FileAccess.get_file_as_bytes(FONT_PATH)
	if font_bytes.is_empty():
		return ThemeDB.fallback_font

	var font_file: FontFile = FontFile.new()
	font_file.data = font_bytes
	cached_font = font_file
	return cached_font
