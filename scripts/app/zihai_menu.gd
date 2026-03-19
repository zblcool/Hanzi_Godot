extends Control

const CJKFont := preload("res://scripts/core/cjk_font.gd")

var ui_font: Font
var floating_symbols: Array[Dictionary] = []
var selected_hero := "scholar"

var hero_panels: Dictionary = {}
var detail_name_label: Label
var detail_desc_label: Label
var detail_weapon_label: Label


func _ready() -> void:
	ui_font = CJKFont.get_font()
	selected_hero = Session.selected_hero
	_build_floating_symbols()
	_build_ui()
	_refresh_selection()
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	for symbol in floating_symbols:
		var position: Vector2 = symbol["position"]
		var velocity: Vector2 = symbol["velocity"]
		position += velocity * delta
		if position.x < -90.0:
			position.x = viewport_size.x + 90.0
		if position.y > viewport_size.y + 80.0:
			position.y = -80.0
		symbol["position"] = position

	queue_redraw()


func _draw() -> void:
	var rect: Rect2 = get_viewport_rect()
	draw_rect(rect, Color(0.04, 0.05, 0.07, 1.0), true)
	draw_rect(Rect2(0.0, 0.0, rect.size.x, rect.size.y * 0.5), Color(0.09, 0.11, 0.15, 0.95), true)

	for symbol in floating_symbols:
		var position: Vector2 = symbol["position"]
		var glyph := String(symbol["glyph"])
		var size := int(symbol["size"])
		var color: Color = symbol["color"]
		draw_string(ui_font, position, glyph, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)


func _build_ui() -> void:
	var root := MarginContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 48)
	root.add_theme_constant_override("margin_top", 40)
	root.add_theme_constant_override("margin_right", 48)
	root.add_theme_constant_override("margin_bottom", 34)
	add_child(root)

	var layout := VBoxContainer.new()
	layout.set_anchors_preset(Control.PRESET_FULL_RECT)
	layout.add_theme_constant_override("separation", 20)
	root.add_child(layout)

	layout.add_child(_make_label("字海残卷", 46, Color(1.0, 0.93, 0.84, 1.0)))
	layout.add_child(_make_label("先选角色，再把首个 Godot 3D 战场跑起来。当前版本优先验证战斗循环、多兵种与偏旁合字。", 18, Color(0.88, 0.91, 0.96, 0.95)))

	var content_row := HBoxContainer.new()
	content_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_row.add_theme_constant_override("separation", 18)
	layout.add_child(content_row)

	var cards_column := VBoxContainer.new()
	cards_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_column.add_theme_constant_override("separation", 16)
	content_row.add_child(cards_column)

	var cards_row := HBoxContainer.new()
	cards_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_row.add_theme_constant_override("separation", 16)
	cards_column.add_child(cards_row)

	for hero_variant in Session.HERO_ORDER:
		var hero_id := String(hero_variant)
		var hero_data: Dictionary = Session.get_hero_data(hero_id)
		var hero_card := _make_hero_card(hero_id, hero_data)
		hero_panels[hero_id] = hero_card
		cards_row.add_child(hero_card)

	var buttons_row := HBoxContainer.new()
	buttons_row.add_theme_constant_override("separation", 12)
	cards_column.add_child(buttons_row)

	var start_button := _make_action_button("开始战斗", Color(0.92, 0.62, 0.28, 1.0))
	start_button.pressed.connect(_on_start_pressed)
	buttons_row.add_child(start_button)

	var back_button := _make_action_button("返回启动器", Color(0.39, 0.53, 0.87, 1.0))
	back_button.pressed.connect(_on_back_pressed)
	buttons_row.add_child(back_button)

	var detail_panel := PanelContainer.new()
	detail_panel.custom_minimum_size = Vector2(360.0, 0.0)
	detail_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.12, 0.09, 0.08, 0.9), Color(0.92, 0.67, 0.39, 0.95)))
	content_row.add_child(detail_panel)

	var detail_margin := MarginContainer.new()
	detail_margin.add_theme_constant_override("margin_left", 18)
	detail_margin.add_theme_constant_override("margin_top", 18)
	detail_margin.add_theme_constant_override("margin_right", 18)
	detail_margin.add_theme_constant_override("margin_bottom", 18)
	detail_panel.add_child(detail_margin)

	var detail_box := VBoxContainer.new()
	detail_box.add_theme_constant_override("separation", 10)
	detail_margin.add_child(detail_box)

	detail_box.add_child(_make_label("本轮保留的设计主轴", 24, Color(1.0, 0.92, 0.8, 1.0)))
	detail_name_label = _make_label("", 32, Color(1.0, 0.88, 0.74, 1.0))
	detail_weapon_label = _make_label("", 18, Color(0.96, 0.79, 0.52, 1.0))
	detail_desc_label = _make_label("", 18, Color(0.9, 0.92, 0.95, 0.96))
	detail_box.add_child(detail_name_label)
	detail_box.add_child(detail_weapon_label)
	detail_box.add_child(detail_desc_label)
	detail_box.add_child(_make_label("迁移中先落地：", 19, Color(0.82, 0.88, 1.0, 0.95)))
	detail_box.add_child(_make_label("1. 3D 俯视角自动战斗。", 17, Color(0.92, 0.91, 0.88, 0.95)))
	detail_box.add_child(_make_label("2. 偏旁掉落与自动合字。", 17, Color(0.92, 0.91, 0.88, 0.95)))
	detail_box.add_child(_make_label("3. 多兵种敌人，至少包含地面预警型阵师。", 17, Color(0.92, 0.91, 0.88, 0.95)))
	detail_box.add_child(_make_label("4. 地图里的树与草丛占位，为后续生态系统留口。", 17, Color(0.92, 0.91, 0.88, 0.95)))


func _make_hero_card(hero_id: String, hero_data: Dictionary) -> PanelContainer:
	var accent: Color = hero_data["accent"]
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0.0, 320.0)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_card_style(false, accent))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	box.add_child(_make_label(String(hero_data["name"]), 36, Color(1.0, 0.94, 0.86, 1.0)))
	box.add_child(_make_label(String(hero_data["title"]), 18, accent))
	box.add_child(_make_label(String(hero_data["weapon"]), 17, Color(0.86, 0.91, 0.98, 0.95)))
	box.add_child(_make_label(String(hero_data["description"]), 17, Color(0.91, 0.92, 0.9, 0.95)))

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0.0, 74.0)
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)

	var select_button := _make_action_button("选择 %s" % String(hero_data["name"]), accent)
	select_button.pressed.connect(func() -> void:
		_on_select_hero(hero_id)
	)
	box.add_child(select_button)

	return panel


func _make_action_button(text: String, accent: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0.0, 52.0)
	button.add_theme_font_override("font", ui_font)
	button.add_theme_font_size_override("font_size", 21)
	button.add_theme_color_override("font_color", Color(0.08, 0.07, 0.07, 1.0))
	button.add_theme_stylebox_override("normal", _make_button_style(accent))
	button.add_theme_stylebox_override("hover", _make_button_style(accent.lightened(0.1)))
	button.add_theme_stylebox_override("pressed", _make_button_style(accent.darkened(0.08)))
	return button


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var settings := LabelSettings.new()
	settings.font = ui_font
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
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	return style


func _make_card_style(selected: bool, accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(accent.r * 0.17, accent.g * 0.16, accent.b * 0.2, 0.93)
	style.border_width_left = 3 if selected else 2
	style.border_width_top = 3 if selected else 2
	style.border_width_right = 3 if selected else 2
	style.border_width_bottom = 3 if selected else 2
	style.border_color = accent if selected else Color(accent.r, accent.g, accent.b, 0.65)
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.2)
	style.shadow_size = 10
	return style


func _make_button_style(accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = accent
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	return style


func _build_floating_symbols() -> void:
	var glyphs := ["字", "海", "残", "卷", "阵", "树", "草", "明", "休", "海", "刂", "侠", "书"]
	var viewport_size: Vector2 = get_viewport_rect().size
	for index in range(20):
		floating_symbols.append({
			"glyph": String(glyphs[index % glyphs.size()]),
			"position": Vector2(
				randf_range(-40.0, viewport_size.x + 20.0),
				randf_range(-40.0, viewport_size.y + 20.0)
			),
			"velocity": Vector2(randf_range(-18.0, -6.0), randf_range(6.0, 16.0)),
			"size": randi_range(28, 78),
			"color": Color(0.85 + randf() * 0.15, 0.46 + randf() * 0.16, 0.24 + randf() * 0.1, 0.1 + randf() * 0.08)
		})


func _on_select_hero(hero_id: String) -> void:
	selected_hero = hero_id
	_refresh_selection()


func _refresh_selection() -> void:
	Session.select_hero(selected_hero)
	for hero_id_variant in hero_panels.keys():
		var hero_id := String(hero_id_variant)
		var panel: PanelContainer = hero_panels[hero_id]
		var hero_data: Dictionary = Session.get_hero_data(hero_id)
		panel.add_theme_stylebox_override("panel", _make_card_style(hero_id == selected_hero, hero_data["accent"]))

	var selected_data: Dictionary = Session.get_selected_hero()
	detail_name_label.text = "%s  ·  %s" % [String(selected_data["name"]), String(selected_data["title"])]
	detail_weapon_label.text = "武器特征：%s" % String(selected_data["weapon"])
	detail_desc_label.text = String(selected_data["description"])


func _on_start_pressed() -> void:
	Session.select_hero(selected_hero)
	get_tree().change_scene_to_file(Session.ZIHAI_BATTLE_SCENE)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(Session.LAUNCHER_SCENE)
