extends Control

const CJKFont := preload("res://scripts/core/cjk_font.gd")

var title_font: Font
var floating_symbols: Array[Dictionary] = []


func _ready() -> void:
	title_font = CJKFont.get_font()
	_build_floating_symbols()
	_build_ui()
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	for symbol in floating_symbols:
		var velocity: Vector2 = symbol["velocity"]
		var position: Vector2 = symbol["position"]
		position += velocity * delta
		if position.x > viewport_size.x + 80.0:
			position.x = -80.0
		if position.y > viewport_size.y + 60.0:
			position.y = -60.0
		symbol["position"] = position

	queue_redraw()


func _draw() -> void:
	var rect: Rect2 = get_viewport_rect()
	draw_rect(rect, Color(0.03, 0.05, 0.07, 1.0), true)
	draw_circle(Vector2(rect.size.x * 0.24, rect.size.y * 0.18), 220.0, Color(0.86, 0.56, 0.28, 0.07))
	draw_circle(Vector2(rect.size.x * 0.72, rect.size.y * 0.22), 260.0, Color(0.42, 0.74, 0.88, 0.06))
	draw_circle(Vector2(rect.size.x * 0.54, rect.size.y * 0.66), 320.0, Color(0.84, 0.72, 0.34, 0.04))

	for index in range(6):
		var size := 78.0 + float(index) * 18.0
		var center := Vector2(
			rect.size.x * (0.08 + float(index) * 0.16),
			rect.size.y * (0.12 + float(index % 3) * 0.24)
		)
		var diamond := PackedVector2Array([
			center + Vector2(0.0, -size),
			center + Vector2(size * 0.74, 0.0),
			center + Vector2(0.0, size),
			center + Vector2(-size * 0.74, 0.0),
			center + Vector2(0.0, -size)
		])
		draw_polyline(diamond, Color(0.52, 0.62, 0.72, 0.12), 2.0)

	for symbol in floating_symbols:
		var position: Vector2 = symbol["position"]
		var glyph := String(symbol["glyph"])
		var size := int(symbol["size"])
		var color: Color = symbol["color"]
		draw_string(title_font, position, glyph, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)


func _build_ui() -> void:
	var root := MarginContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 44)
	root.add_theme_constant_override("margin_top", 34)
	root.add_theme_constant_override("margin_right", 44)
	root.add_theme_constant_override("margin_bottom", 32)
	add_child(root)

	var layout := VBoxContainer.new()
	layout.set_anchors_preset(Control.PRESET_FULL_RECT)
	layout.add_theme_constant_override("separation", 22)
	root.add_child(layout)

	var top_bar := HBoxContainer.new()
	top_bar.alignment = BoxContainer.ALIGNMENT_END
	top_bar.add_theme_constant_override("separation", 12)
	layout.add_child(top_bar)
	top_bar.add_child(_make_pill("关于游戏"))
	top_bar.add_child(_make_pill("EN"))

	var header_panel := PanelContainer.new()
	header_panel.custom_minimum_size = Vector2(0.0, 190.0)
	header_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.06, 0.08, 0.1, 0.78), Color(0.22, 0.28, 0.34, 0.72)))
	layout.add_child(header_panel)

	var header_margin := MarginContainer.new()
	header_margin.add_theme_constant_override("margin_left", 34)
	header_margin.add_theme_constant_override("margin_top", 28)
	header_margin.add_theme_constant_override("margin_right", 34)
	header_margin.add_theme_constant_override("margin_bottom", 28)
	header_panel.add_child(header_margin)

	var header_box := VBoxContainer.new()
	header_box.add_theme_constant_override("separation", 10)
	header_margin.add_child(header_box)
	header_box.add_child(_make_label("HANZI GAME LAUNCHER", 18, Color(0.96, 0.82, 0.54, 0.88)))
	header_box.add_child(_make_label("汉字游戏启动器", 84, Color(1.0, 0.95, 0.86, 1.0)))

	var main_row := HBoxContainer.new()
	main_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_row.add_theme_constant_override("separation", 20)
	layout.add_child(main_row)

	main_row.add_child(_make_game_card(
		"字海残卷",
		"偏旁收集 -> 自动合字 -> 词技生长",
		"当前可进入",
		Color(0.9, 0.43, 0.22, 1.0),
		"进入字海",
		Callable(self, "_on_enter_zihai_pressed"),
		true
	))
	main_row.add_child(_make_game_card(
		"仓颉之路",
		"字形组合直接进入卡牌构筑",
		"等待迁移",
		Color(0.38, 0.56, 0.9, 1.0),
		"后续接入",
		Callable(),
		false
	))

	var about_panel := PanelContainer.new()
	about_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	about_panel.custom_minimum_size = Vector2(0.0, 150.0)
	about_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.09, 0.08, 0.08, 0.74), Color(0.94, 0.7, 0.42, 0.72)))
	layout.add_child(about_panel)

	var about_margin := MarginContainer.new()
	about_margin.add_theme_constant_override("margin_left", 18)
	about_margin.add_theme_constant_override("margin_top", 16)
	about_margin.add_theme_constant_override("margin_right", 18)
	about_margin.add_theme_constant_override("margin_bottom", 16)
	about_panel.add_child(about_margin)

	var about_box := VBoxContainer.new()
	about_box.add_theme_constant_override("separation", 9)
	about_margin.add_child(about_box)

	about_box.add_child(_make_label("迁移重点", 24, Color(1.0, 0.9, 0.78, 1.0)))
	about_box.add_child(_make_label("1. 保留 web 端的墨色玻璃 UI 和启动器 -> 二级菜单 -> 战斗 层级。", 17, Color(0.93, 0.92, 0.88, 0.95)))
	about_box.add_child(_make_label("2. 字海残卷继续坚持 3D 俯视角，不退回纯占位原型。", 17, Color(0.93, 0.92, 0.88, 0.95)))
	about_box.add_child(_make_label("3. 汉字结构、敌人轮廓和场景氛围会一起往 web 端气质对齐。", 17, Color(0.93, 0.92, 0.88, 0.95)))


func _make_game_card(title: String, tagline: String, status: String, accent: Color, button_text: String, callback: Callable, enabled: bool) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0.0, 360.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.12, accent.g * 0.13, accent.b * 0.18, 0.92), Color(accent.r, accent.g, accent.b, 0.62)))

	var padding := MarginContainer.new()
	padding.add_theme_constant_override("margin_left", 22)
	padding.add_theme_constant_override("margin_top", 20)
	padding.add_theme_constant_override("margin_right", 22)
	padding.add_theme_constant_override("margin_bottom", 20)
	card.add_child(padding)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	padding.add_child(box)

	var preview := PanelContainer.new()
	preview.custom_minimum_size = Vector2(0.0, 138.0)
	preview.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.18, accent.g * 0.15, accent.b * 0.12, 0.34), Color(accent.r, accent.g, accent.b, 0.18)))
	box.add_child(preview)
	var preview_label := _make_label("字" if title == "字海残卷" else "仓", 68, Color(1.0, 0.94, 0.84, 0.96))
	preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	preview_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	preview.add_child(preview_label)

	box.add_child(_make_label("Action Roguelite" if title == "字海残卷" else "Deckbuilder Climb", 14, Color(0.96, 0.82, 0.54, 0.86)))
	box.add_child(_make_label(title, 34, Color(1.0, 0.95, 0.86, 1.0)))
	box.add_child(_make_label(tagline, 18, Color(0.88, 0.92, 0.97, 0.96)))
	box.add_child(_make_label(status, 16, accent))

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, 34.0)
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)

	var button := Button.new()
	button.text = button_text
	button.disabled = not enabled
	button.custom_minimum_size = Vector2(0.0, 54.0)
	button.add_theme_font_override("font", title_font)
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_color_override("font_color", Color(0.08, 0.07, 0.07, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.52, 0.52, 0.52, 1.0))
	button.add_theme_stylebox_override("normal", _make_button_style(accent, 1.0))
	button.add_theme_stylebox_override("hover", _make_button_style(accent.lightened(0.1), 1.0))
	button.add_theme_stylebox_override("pressed", _make_button_style(accent.darkened(0.08), 1.0))
	button.add_theme_stylebox_override("disabled", _make_button_style(Color(0.32, 0.32, 0.34, 0.85), 0.75))
	if enabled:
		button.pressed.connect(callback)
	box.add_child(button)

	return card


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var settings := LabelSettings.new()
	settings.font = title_font
	settings.font_size = font_size
	settings.font_color = color
	label.label_settings = settings
	return label


func _make_panel_style(fill_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = border_color
	style.corner_radius_top_left = 28
	style.corner_radius_top_right = 28
	style.corner_radius_bottom_left = 28
	style.corner_radius_bottom_right = 28
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.18)
	style.shadow_size = 12
	return style


func _make_button_style(fill_color: Color, alpha: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(fill_color.r, fill_color.g, fill_color.b, alpha)
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	return style


func _make_pill(text: String) -> PanelContainer:
	var pill := PanelContainer.new()
	pill.custom_minimum_size = Vector2(120.0 if text == "关于游戏" else 74.0, 54.0)
	pill.add_theme_stylebox_override("panel", _make_panel_style(Color(0.04, 0.06, 0.08, 0.76), Color(0.2, 0.26, 0.32, 0.56)))
	var label := _make_label(text, 20, Color(0.98, 0.92, 0.82, 0.98))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	pill.add_child(label)
	return pill


func _build_floating_symbols() -> void:
	var glyphs := ["字", "海", "卷", "偏", "旁", "明", "休", "海", "刂", "墨", "阵", "词", "技"]
	var colors := [
		Color(1.0, 0.76, 0.42, 0.18),
		Color(0.52, 0.85, 1.0, 0.16),
		Color(0.9, 0.48, 0.32, 0.14),
		Color(0.76, 0.9, 0.58, 0.16)
	]
	var viewport_size: Vector2 = get_viewport_rect().size

	for index in range(18):
		var glyph := String(glyphs[index % glyphs.size()])
		var symbol := {
			"glyph": glyph,
			"position": Vector2(
				randf_range(-40.0, viewport_size.x + 20.0),
				randf_range(-40.0, viewport_size.y + 20.0)
			),
			"velocity": Vector2(randf_range(6.0, 20.0), randf_range(4.0, 16.0)),
			"size": randi_range(36, 88),
			"color": colors[index % colors.size()]
		}
		floating_symbols.append(symbol)


func _on_enter_zihai_pressed() -> void:
	get_tree().change_scene_to_file(Session.ZIHAI_MENU_SCENE)
