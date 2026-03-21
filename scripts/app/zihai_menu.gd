extends Control

const CJKFont := preload("res://scripts/core/cjk_font.gd")
const BASE_VIEWPORT := Vector2(2100.0, 1200.0)
const MIN_UI_SCALE := 0.6

var ui_font: Font
var ui_scale := 1.0
var floating_symbols: Array[Dictionary] = []
var preview_motifs: Array[Dictionary] = []
var selected_hero := "scholar"

var hero_panels: Dictionary = {}
var detail_name_label: Label
var detail_desc_label: Label
var detail_weapon_label: Label
var detail_focus_label: Label
var detail_role_label: Label
var detail_preview_core: PanelContainer
var detail_preview_glyph: Label
var detail_tags_row: HBoxContainer
var detail_stat_widgets: Dictionary = {}
var character_archive_overlay: Control
var character_archive_body_label: Label
var recipe_atlas_overlay: Control
var recipe_atlas_body_label: Label
var enemy_archive_overlay: Control
var enemy_archive_body_label: Label
var leaderboard_overlay: Control
var leaderboard_body_label: Label
var transition_overlay: Control
var transition_glyph_label: Label
var transition_title_label: Label
var transition_subtitle_label: Label
var transition_busy: bool = false


func _ready() -> void:
	ui_font = CJKFont.get_font()
	selected_hero = Session.selected_hero
	_build_floating_symbols()
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_rebuild_ui()
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

	for motif in preview_motifs:
		var phase: float = float(motif["phase"]) + delta * float(motif["speed"])
		motif["phase"] = phase
		var ring_a: Control = motif["ring_a"]
		var ring_b: Control = motif["ring_b"]
		var core: Control = motif["core"]
		var shards: Array = motif["shards"]

		ring_a.rotation = phase * 0.42
		ring_b.rotation = -phase * 0.28
		core.position.y = float(motif["base_y"]) + sin(phase * 1.5) * _f(5.0)
		for index in range(shards.size()):
			var shard: Control = shards[index]
			shard.position.y = float(shard.get_meta("base_y")) + sin(phase * 1.8 + float(index) * 1.2) * _f(6.0)
	queue_redraw()


func _draw() -> void:
	var rect: Rect2 = get_viewport_rect()
	draw_rect(rect, Color(0.03, 0.05, 0.07, 1.0), true)
	draw_circle(Vector2(rect.size.x * 0.24, rect.size.y * 0.22), 210.0, Color(0.86, 0.58, 0.3, 0.07))
	draw_circle(Vector2(rect.size.x * 0.76, rect.size.y * 0.2), 240.0, Color(0.42, 0.74, 0.88, 0.06))
	draw_circle(Vector2(rect.size.x * 0.56, rect.size.y * 0.72), 300.0, Color(0.9, 0.72, 0.34, 0.04))

	for index in range(6):
		var x: float = rect.size.x * (0.06 + float(index) * 0.16)
		draw_line(Vector2(x, 0.0), Vector2(x + 180.0, rect.size.y), Color(0.18, 0.24, 0.28, 0.08), 1.0)

	for symbol in floating_symbols:
		var position: Vector2 = symbol["position"]
		var color: Color = symbol["color"]
		draw_string(
			ui_font,
			position,
			String(symbol["glyph"]),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1.0,
			int(symbol["size"]),
			color
		)


func _rebuild_ui() -> void:
	ui_scale = _compute_ui_scale()
	preview_motifs.clear()
	hero_panels.clear()
	detail_stat_widgets.clear()
	detail_name_label = null
	detail_desc_label = null
	detail_weapon_label = null
	detail_focus_label = null
	detail_role_label = null
	detail_preview_core = null
	detail_preview_glyph = null
	detail_tags_row = null
	character_archive_overlay = null
	character_archive_body_label = null
	recipe_atlas_overlay = null
	recipe_atlas_body_label = null
	enemy_archive_overlay = null
	enemy_archive_body_label = null
	leaderboard_overlay = null
	leaderboard_body_label = null
	transition_overlay = null
	transition_glyph_label = null
	transition_title_label = null
	transition_subtitle_label = null
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_build_ui()
	_refresh_selection()


func _on_viewport_size_changed() -> void:
	var new_scale := _compute_ui_scale()
	if absf(new_scale - ui_scale) > 0.02:
		_rebuild_ui()


func _compute_ui_scale() -> float:
	var viewport_size := get_viewport_rect().size
	return clamp(min(viewport_size.x / BASE_VIEWPORT.x, viewport_size.y / BASE_VIEWPORT.y), MIN_UI_SCALE, 1.0)


func _f(value: float) -> float:
	return value * ui_scale


func _i(value: float) -> int:
	return maxi(1, int(round(value * ui_scale)))


func _v(x: float, y: float) -> Vector2:
	return Vector2(_f(x), _f(y))


func _build_ui() -> void:
	var root := MarginContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", _i(40))
	root.add_theme_constant_override("margin_top", _i(30))
	root.add_theme_constant_override("margin_right", _i(40))
	root.add_theme_constant_override("margin_bottom", _i(28))
	add_child(root)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	var layout := VBoxContainer.new()
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_theme_constant_override("separation", _i(18))
	scroll.add_child(layout)

	var top_bar := HBoxContainer.new()
	top_bar.add_theme_constant_override("separation", _i(12))
	layout.add_child(top_bar)

	var back_button := _make_pill_button("返回启动器", _v(168.0, 54.0), Callable(self, "_on_back_pressed"))
	top_bar.add_child(back_button)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(spacer)

	top_bar.add_child(_make_pill_button("人物志", _v(148.0, 54.0), Callable(self, "_on_character_archive_pressed")))
	top_bar.add_child(_make_pill_button("合字图谱", _v(164.0, 54.0), Callable(self, "_on_recipe_atlas_pressed")))
	top_bar.add_child(_make_pill_button("怪物图鉴", _v(164.0, 54.0), Callable(self, "_on_enemy_archive_pressed")))
	top_bar.add_child(_make_pill_button("查看排行榜", _v(172.0, 54.0), Callable(self, "_on_leaderboard_pressed")))
	var start_pill := _make_pill_button("直接开始", _v(152.0, 54.0), Callable(self, "_on_start_pressed"))
	top_bar.add_child(start_pill)
	top_bar.add_child(_make_static_pill("EN", _v(74.0, 54.0)))

	var shell_panel := PanelContainer.new()
	shell_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shell_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.08, 0.1, 0.76), Color(0.24, 0.3, 0.36, 0.62)))
	layout.add_child(shell_panel)

	var shell_margin := MarginContainer.new()
	shell_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	shell_margin.add_theme_constant_override("margin_left", _i(28))
	shell_margin.add_theme_constant_override("margin_top", _i(24))
	shell_margin.add_theme_constant_override("margin_right", _i(28))
	shell_margin.add_theme_constant_override("margin_bottom", _i(24))
	shell_panel.add_child(shell_margin)

	var shell_box := VBoxContainer.new()
	shell_box.add_theme_constant_override("separation", _i(18))
	shell_margin.add_child(shell_box)

	var header_panel := PanelContainer.new()
	header_panel.custom_minimum_size = _v(0.0, 174.0)
	header_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.04, 0.07, 0.09, 0.9), Color(0.2, 0.26, 0.32, 0.42)))
	shell_box.add_child(header_panel)
	var header_margin := MarginContainer.new()
	header_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	header_margin.add_theme_constant_override("margin_left", _i(30))
	header_margin.add_theme_constant_override("margin_top", _i(24))
	header_margin.add_theme_constant_override("margin_right", _i(30))
	header_margin.add_theme_constant_override("margin_bottom", _i(24))
	header_panel.add_child(header_margin)
	var header_box := VBoxContainer.new()
	header_box.add_theme_constant_override("separation", _i(8))
	header_margin.add_child(header_box)
	header_box.add_child(_make_label("INK-BORN ROGUELITE", 18, Color(0.96, 0.82, 0.54, 0.86)))
	header_box.add_child(_make_label("字海残卷", 70, Color(1.0, 0.95, 0.86, 1.0)))
	header_box.add_child(_make_label("先进入残卷，再决定谁来执笔。每名角色都会把同一套偏旁系统，写成完全不同的战斗节奏。", 19, Color(0.88, 0.91, 0.96, 0.95)))

	var content_row := HBoxContainer.new()
	content_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_row.add_theme_constant_override("separation", _i(18))
	shell_box.add_child(content_row)

	var cards_column := VBoxContainer.new()
	cards_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_column.add_theme_constant_override("separation", _i(14))
	content_row.add_child(cards_column)

	var section_label := _make_label("可选执笔者", 28, Color(1.0, 0.92, 0.8, 1.0))
	cards_column.add_child(section_label)

	for hero_variant in Session.HERO_ORDER:
		var hero_id := String(hero_variant)
		var hero_data: Dictionary = Session.get_hero_data(hero_id)
		var hero_card := _make_hero_card(hero_id, hero_data)
		hero_panels[hero_id] = hero_card
		cards_column.add_child(hero_card)

	var detail_panel := PanelContainer.new()
	detail_panel.custom_minimum_size = _v(468.0, 0.0)
	detail_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.07, 0.09, 0.11, 0.9), Color(0.36, 0.72, 0.82, 0.56)))
	content_row.add_child(detail_panel)

	var detail_margin := MarginContainer.new()
	detail_margin.add_theme_constant_override("margin_left", _i(20))
	detail_margin.add_theme_constant_override("margin_top", _i(18))
	detail_margin.add_theme_constant_override("margin_right", _i(20))
	detail_margin.add_theme_constant_override("margin_bottom", _i(18))
	detail_panel.add_child(detail_margin)

	var detail_box := VBoxContainer.new()
	detail_box.add_theme_constant_override("separation", _i(12))
	detail_margin.add_child(detail_box)
	detail_box.add_child(_make_label("执笔者档案", 26, Color(1.0, 0.92, 0.8, 1.0)))

	var preview_panel := PanelContainer.new()
	preview_panel.custom_minimum_size = _v(0.0, 220.0)
	preview_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.1, 0.14, 0.18, 0.7), Color(0.44, 0.76, 0.84, 0.24)))
	detail_box.add_child(preview_panel)
	_build_detail_preview(preview_panel)

	detail_name_label = _make_label("", 40, Color(1.0, 0.94, 0.86, 1.0))
	detail_role_label = _make_label("", 18, Color(0.96, 0.82, 0.54, 0.96))
	detail_weapon_label = _make_label("", 18, Color(0.86, 0.91, 0.98, 0.95))
	detail_desc_label = _make_label("", 18, Color(0.9, 0.92, 0.95, 0.96))
	detail_focus_label = _make_label("", 17, Color(0.82, 0.9, 1.0, 0.96))
	detail_box.add_child(detail_name_label)
	detail_box.add_child(detail_role_label)
	detail_box.add_child(detail_weapon_label)
	detail_box.add_child(detail_desc_label)
	detail_box.add_child(detail_focus_label)

	detail_tags_row = HBoxContainer.new()
	detail_tags_row.add_theme_constant_override("separation", _i(10))
	detail_box.add_child(detail_tags_row)

	var stats_panel := PanelContainer.new()
	stats_panel.custom_minimum_size = _v(0.0, 232.0)
	stats_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.72), Color(0.28, 0.36, 0.42, 0.46)))
	detail_box.add_child(stats_panel)

	var stats_margin := MarginContainer.new()
	stats_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	stats_margin.add_theme_constant_override("margin_left", _i(16))
	stats_margin.add_theme_constant_override("margin_top", _i(16))
	stats_margin.add_theme_constant_override("margin_right", _i(16))
	stats_margin.add_theme_constant_override("margin_bottom", _i(16))
	stats_panel.add_child(stats_margin)

	var stats_box := VBoxContainer.new()
	stats_box.add_theme_constant_override("separation", _i(10))
	stats_margin.add_child(stats_box)
	stats_box.add_child(_make_label("战斗轮廓", 22, Color(1.0, 0.92, 0.8, 1.0)))
	detail_stat_widgets["move_speed"] = _make_stat_row(stats_box, "机动")
	detail_stat_widgets["max_health"] = _make_stat_row(stats_box, "气血")
	detail_stat_widgets["attack_damage"] = _make_stat_row(stats_box, "伤害")
	detail_stat_widgets["attack_range"] = _make_stat_row(stats_box, "射程")

	_build_character_archive_overlay()
	_build_recipe_atlas_overlay()
	_build_enemy_archive_overlay()
	_build_leaderboard_overlay()
	_build_transition_overlay()


func _make_hero_card(hero_id: String, hero_data: Dictionary) -> PanelContainer:
	var accent: Color = hero_data["accent"]
	var panel := PanelContainer.new()
	panel.custom_minimum_size = _v(0.0, 230.0)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_card_style(false, accent))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(18))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(18))
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", _i(16))
	margin.add_child(row)

	var preview := PanelContainer.new()
	preview.custom_minimum_size = _v(176.0, 0.0)
	preview.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.14, accent.g * 0.14, accent.b * 0.16, 0.58), Color(accent.r, accent.g, accent.b, 0.24)))
	row.add_child(preview)
	_build_card_preview(preview, hero_data)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.add_theme_constant_override("separation", _i(8))
	row.add_child(text_col)

	text_col.add_child(_make_label("%s  ·  %s" % [String(hero_data["name"]), String(hero_data["title"])], 30, Color(1.0, 0.95, 0.86, 1.0)))
	text_col.add_child(_make_label(String(hero_data["role_label"]), 18, accent))
	text_col.add_child(_make_label(String(hero_data["description"]), 17, Color(0.91, 0.92, 0.9, 0.95)))

	var tag_row := HBoxContainer.new()
	tag_row.add_theme_constant_override("separation", 8)
	text_col.add_child(tag_row)
	for tag_text in hero_data["tags"]:
		tag_row.add_child(_make_tag(String(tag_text), Color(accent.r * 0.16, accent.g * 0.16, accent.b * 0.2, 0.88), Color(0.98, 0.95, 0.9, 0.96)))

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_col.add_child(spacer)

	var select_button := _make_action_button("选择 %s" % String(hero_data["name"]), accent)
	select_button.pressed.connect(func() -> void:
		_on_select_hero(hero_id)
	)
	text_col.add_child(select_button)

	return panel


func _build_card_preview(panel: PanelContainer, hero_data: Dictionary) -> void:
	var accent: Color = hero_data["accent"]
	var stage := Control.new()
	stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(stage)

	var ring_a := PanelContainer.new()
	ring_a.size = _v(108.0, 108.0)
	ring_a.position = _v(34.0, 24.0)
	ring_a.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.12, accent.g * 0.12, accent.b * 0.16, 0.12), Color(accent.r, accent.g, accent.b, 0.24)))
	stage.add_child(ring_a)

	var ring_b := PanelContainer.new()
	ring_b.size = _v(72.0, 72.0)
	ring_b.position = _v(52.0, 42.0)
	ring_b.add_theme_stylebox_override("panel", _make_panel_style(Color(0.12, 0.16, 0.2, 0.0), Color(accent.r, accent.g, accent.b, 0.18)))
	stage.add_child(ring_b)

	var core := PanelContainer.new()
	core.size = _v(84.0, 84.0)
	core.position = _v(46.0, 50.0)
	core.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.24, accent.g * 0.2, accent.b * 0.16, 0.94), Color(accent.r, accent.g, accent.b, 0.24)))
	stage.add_child(core)

	var glyph := _make_label(String(hero_data["glyph"]), 46, Color(1.0, 0.95, 0.86, 1.0))
	glyph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph.set_anchors_preset(Control.PRESET_FULL_RECT)
	core.add_child(glyph)

	var shards: Array = []
	for index in range(2):
		var shard := ColorRect.new()
		shard.color = Color(accent.r, accent.g, accent.b, 0.86)
		shard.size = _v(28.0, 7.0)
		shard.position = _v(18.0 + float(index) * 92.0, 118.0 - float(index) * 24.0)
		shard.rotation = -0.48 + float(index) * 0.86
		shard.set_meta("base_y", shard.position.y)
		stage.add_child(shard)
		shards.append(shard)

	preview_motifs.append({
		"ring_a": ring_a,
		"ring_b": ring_b,
		"core": core,
		"shards": shards,
		"phase": randf() * TAU,
		"speed": 0.86,
		"base_y": core.position.y
	})


func _build_detail_preview(panel: PanelContainer) -> void:
	var stage := Control.new()
	stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(stage)

	var ring_a := PanelContainer.new()
	ring_a.size = _v(168.0, 168.0)
	ring_a.position = _v(84.0, 16.0)
	ring_a.add_theme_stylebox_override("panel", _make_panel_style(Color(0.14, 0.16, 0.18, 0.12), Color(0.86, 0.64, 0.34, 0.22)))
	stage.add_child(ring_a)

	var ring_b := PanelContainer.new()
	ring_b.size = _v(118.0, 118.0)
	ring_b.position = _v(109.0, 41.0)
	ring_b.add_theme_stylebox_override("panel", _make_panel_style(Color(0.12, 0.14, 0.16, 0.0), Color(0.34, 0.72, 0.82, 0.22)))
	stage.add_child(ring_b)

	detail_preview_core = PanelContainer.new()
	detail_preview_core.size = _v(110.0, 110.0)
	detail_preview_core.position = _v(114.0, 58.0)
	detail_preview_core.add_theme_stylebox_override("panel", _make_panel_style(Color(0.26, 0.2, 0.16, 0.94), Color(0.88, 0.64, 0.34, 0.26)))
	stage.add_child(detail_preview_core)

	detail_preview_glyph = _make_label("书", 58, Color(1.0, 0.95, 0.86, 1.0))
	detail_preview_glyph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_preview_glyph.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	detail_preview_glyph.set_anchors_preset(Control.PRESET_FULL_RECT)
	detail_preview_core.add_child(detail_preview_glyph)

	var shards: Array = []
	for index in range(3):
		var shard := ColorRect.new()
		shard.color = Color(0.92, 0.68, 0.42, 0.86)
		shard.size = _v(48.0, 8.0)
		shard.position = _v(58.0 + float(index) * 74.0, 66.0 + float(index % 2) * 58.0)
		shard.rotation = -0.4 + float(index) * 0.36
		shard.set_meta("base_y", shard.position.y)
		stage.add_child(shard)
		shards.append(shard)

	preview_motifs.append({
		"ring_a": ring_a,
		"ring_b": ring_b,
		"core": detail_preview_core,
		"shards": shards,
		"phase": randf() * TAU,
		"speed": 0.72,
		"base_y": detail_preview_core.position.y
	})


func _make_stat_row(parent: VBoxContainer, title: String) -> Dictionary:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(6))
	parent.add_child(box)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", _i(8))
	box.add_child(row)

	var title_label := _make_label(title, 18, Color(0.98, 0.93, 0.84, 0.98))
	row.add_child(title_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)

	var value_label := _make_label("", 17, Color(0.9, 0.92, 0.96, 0.95))
	row.add_child(value_label)

	var bar := ProgressBar.new()
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.value = 0.0
	bar.show_percentage = false
	bar.custom_minimum_size = _v(0.0, 12.0)
	bar.add_theme_stylebox_override("background", _make_fill_style(Color(0.15, 0.18, 0.22, 0.82), 10))
	bar.add_theme_stylebox_override("fill", _make_fill_style(Color(0.9, 0.66, 0.36, 0.96), 10))
	box.add_child(bar)

	return {
		"label": value_label,
		"bar": bar
	}


func _make_action_button(text: String, accent: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = _v(0.0, 52.0)
	button.add_theme_font_override("font", ui_font)
	button.add_theme_font_size_override("font_size", _i(21))
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
	settings.font_size = _i(font_size)
	settings.font_color = color
	settings.outline_size = 1
	settings.outline_color = Color(0.02, 0.03, 0.04, 0.28)
	label.label_settings = settings
	return label


func _make_panel_style(fill_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_width_left = maxi(1, _i(2))
	style.border_width_top = maxi(1, _i(2))
	style.border_width_right = maxi(1, _i(2))
	style.border_width_bottom = maxi(1, _i(2))
	style.border_color = border_color
	style.corner_radius_top_left = _i(28)
	style.corner_radius_top_right = _i(28)
	style.corner_radius_bottom_left = _i(28)
	style.corner_radius_bottom_right = _i(28)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.18)
	style.shadow_size = _i(12)
	return style


func _make_card_style(selected: bool, accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(accent.r * 0.14, accent.g * 0.14, accent.b * 0.18, 0.94)
	style.border_width_left = 3 if selected else 2
	style.border_width_top = 3 if selected else 2
	style.border_width_right = 3 if selected else 2
	style.border_width_bottom = 3 if selected else 2
	style.border_color = accent if selected else Color(accent.r, accent.g, accent.b, 0.65)
	style.corner_radius_top_left = _i(28)
	style.corner_radius_top_right = _i(28)
	style.corner_radius_bottom_left = _i(28)
	style.corner_radius_bottom_right = _i(28)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.2)
	style.shadow_size = _i(12)
	return style


func _make_button_style(accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = accent
	style.corner_radius_top_left = _i(14)
	style.corner_radius_top_right = _i(14)
	style.corner_radius_bottom_left = _i(14)
	style.corner_radius_bottom_right = _i(14)
	return style


func _make_fill_style(fill_color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.corner_radius_top_left = _i(radius)
	style.corner_radius_top_right = _i(radius)
	style.corner_radius_bottom_left = _i(radius)
	style.corner_radius_bottom_right = _i(radius)
	return style


func _make_pill_button(text: String, size: Vector2, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = size
	button.add_theme_font_override("font", ui_font)
	button.add_theme_font_size_override("font_size", _i(19))
	button.add_theme_color_override("font_color", Color(0.98, 0.92, 0.82, 0.98))
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.04, 0.06, 0.08, 0.78), Color(0.2, 0.26, 0.32, 0.54)))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.08, 0.1, 0.12, 0.84), Color(0.92, 0.68, 0.42, 0.44)))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.08, 0.1, 0.12, 0.88), Color(0.92, 0.68, 0.42, 0.62)))
	button.pressed.connect(callback)
	return button


func _make_static_pill(text: String, size: Vector2) -> PanelContainer:
	var pill := PanelContainer.new()
	pill.custom_minimum_size = size
	pill.add_theme_stylebox_override("panel", _make_panel_style(Color(0.04, 0.06, 0.08, 0.78), Color(0.2, 0.26, 0.32, 0.54)))
	var label := _make_label(text, 18, Color(0.98, 0.92, 0.82, 0.98))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	pill.add_child(label)
	return pill


func _make_tag(text: String, fill_color: Color, text_color: Color) -> PanelContainer:
	var tag := PanelContainer.new()
	tag.add_theme_stylebox_override("panel", _make_panel_style(fill_color, Color(text_color.r, text_color.g, text_color.b, 0.12)))
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(12))
	margin.add_theme_constant_override("margin_top", _i(8))
	margin.add_theme_constant_override("margin_right", _i(12))
	margin.add_theme_constant_override("margin_bottom", _i(8))
	tag.add_child(margin)
	var label := _make_label(text, 15, text_color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	margin.add_child(label)
	return tag


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


func _build_recipe_atlas_overlay() -> void:
	recipe_atlas_overlay = Control.new()
	recipe_atlas_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	recipe_atlas_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	recipe_atlas_overlay.visible = false
	add_child(recipe_atlas_overlay)

	var scrim := ColorRect.new()
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.02, 0.03, 0.04, 0.82)
	recipe_atlas_overlay.add_child(scrim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -_f(430.0)
	panel.offset_top = -_f(290.0)
	panel.offset_right = _f(430.0)
	panel.offset_bottom = _f(290.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.08, 0.1, 0.96), Color(0.92, 0.68, 0.42, 0.56)))
	recipe_atlas_overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", _i(28))
	margin.add_theme_constant_override("margin_top", _i(24))
	margin.add_theme_constant_override("margin_right", _i(28))
	margin.add_theme_constant_override("margin_bottom", _i(24))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(14))
	margin.add_child(box)

	box.add_child(_make_label("合字图谱", 36, Color(1.0, 0.95, 0.86, 1.0)))
	box.add_child(_make_label("把偏旁、成字与砚台磨词路线收进二级菜单，开局前就能快速确认成长链。", 18, Color(0.88, 0.92, 0.96, 0.95)))

	var summary_panel := PanelContainer.new()
	summary_panel.custom_minimum_size = _v(0.0, 92.0)
	summary_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.72), Color(0.28, 0.36, 0.42, 0.46)))
	box.add_child(summary_panel)
	var summary_margin := MarginContainer.new()
	summary_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	summary_margin.add_theme_constant_override("margin_left", _i(18))
	summary_margin.add_theme_constant_override("margin_top", _i(16))
	summary_margin.add_theme_constant_override("margin_right", _i(18))
	summary_margin.add_theme_constant_override("margin_bottom", _i(16))
	summary_panel.add_child(summary_margin)
	summary_margin.add_child(_make_label("当前先集中展示已经接入的偏旁、合字等级、词技等级与独立武器偏旁。真正的磨词仍然发生在战场砚台旁。", 17, Color(0.94, 0.82, 0.56, 0.94)))

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)

	recipe_atlas_body_label = _make_label("", 18, Color(0.9, 0.92, 0.95, 0.96))
	recipe_atlas_body_label.custom_minimum_size = _v(730.0, 0.0)
	recipe_atlas_body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	recipe_atlas_body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(recipe_atlas_body_label)

	var action_row := HBoxContainer.new()
	action_row.alignment = BoxContainer.ALIGNMENT_END
	action_row.add_theme_constant_override("separation", _i(12))
	box.add_child(action_row)
	action_row.add_child(_make_pill_button("收起图谱", _v(150.0, 52.0), Callable(self, "_hide_recipe_atlas_overlay")))


func _build_character_archive_overlay() -> void:
	character_archive_overlay = Control.new()
	character_archive_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	character_archive_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	character_archive_overlay.visible = false
	add_child(character_archive_overlay)

	var scrim := ColorRect.new()
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.02, 0.03, 0.04, 0.82)
	character_archive_overlay.add_child(scrim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -_f(430.0)
	panel.offset_top = -_f(290.0)
	panel.offset_right = _f(430.0)
	panel.offset_bottom = _f(290.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.08, 0.1, 0.96), Color(0.86, 0.62, 0.36, 0.56)))
	character_archive_overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", _i(28))
	margin.add_theme_constant_override("margin_top", _i(24))
	margin.add_theme_constant_override("margin_right", _i(28))
	margin.add_theme_constant_override("margin_bottom", _i(24))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(14))
	margin.add_child(box)

	box.add_child(_make_label("人物志", 36, Color(1.0, 0.95, 0.86, 1.0)))
	box.add_child(_make_label("把已经接入的执笔者档案收进二级菜单，进入残卷前先确认每名角色的身份与战斗轮廓。", 18, Color(0.88, 0.92, 0.96, 0.95)))

	var summary_panel := PanelContainer.new()
	summary_panel.custom_minimum_size = _v(0.0, 92.0)
	summary_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.72), Color(0.28, 0.36, 0.42, 0.46)))
	box.add_child(summary_panel)
	var summary_margin := MarginContainer.new()
	summary_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	summary_margin.add_theme_constant_override("margin_left", _i(18))
	summary_margin.add_theme_constant_override("margin_top", _i(16))
	summary_margin.add_theme_constant_override("margin_right", _i(18))
	summary_margin.add_theme_constant_override("margin_bottom", _i(16))
	summary_panel.add_child(summary_margin)
	summary_margin.add_child(_make_label("文本直接取自当前 Godot 迁移版的角色数据，不额外编造尚未落地的职业或成长线。", 17, Color(0.94, 0.82, 0.56, 0.94)))

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)

	character_archive_body_label = _make_label("", 18, Color(0.9, 0.92, 0.95, 0.96))
	character_archive_body_label.custom_minimum_size = _v(740.0, 0.0)
	character_archive_body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	character_archive_body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(character_archive_body_label)

	var action_row := HBoxContainer.new()
	action_row.alignment = BoxContainer.ALIGNMENT_END
	action_row.add_theme_constant_override("separation", _i(12))
	box.add_child(action_row)
	action_row.add_child(_make_pill_button("收起人物志", _v(170.0, 52.0), Callable(self, "_hide_character_archive_overlay")))


func _build_leaderboard_overlay() -> void:
	leaderboard_overlay = Control.new()
	leaderboard_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	leaderboard_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	leaderboard_overlay.visible = false
	add_child(leaderboard_overlay)

	var scrim := ColorRect.new()
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.02, 0.03, 0.04, 0.82)
	leaderboard_overlay.add_child(scrim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -_f(420.0)
	panel.offset_top = -_f(280.0)
	panel.offset_right = _f(420.0)
	panel.offset_bottom = _f(280.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.08, 0.1, 0.96), Color(0.38, 0.72, 0.82, 0.56)))
	leaderboard_overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", _i(28))
	margin.add_theme_constant_override("margin_top", _i(24))
	margin.add_theme_constant_override("margin_right", _i(28))
	margin.add_theme_constant_override("margin_bottom", _i(24))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(14))
	margin.add_child(box)

	box.add_child(_make_label("残卷战绩", 36, Color(1.0, 0.95, 0.86, 1.0)))
	box.add_child(_make_label("现在可以在二级菜单里直接查看本地排行榜，不必先打到结算页。", 18, Color(0.88, 0.92, 0.96, 0.95)))

	var summary_panel := PanelContainer.new()
	summary_panel.custom_minimum_size = _v(0.0, 88.0)
	summary_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.72), Color(0.28, 0.36, 0.42, 0.46)))
	box.add_child(summary_panel)
	var summary_margin := MarginContainer.new()
	summary_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	summary_margin.add_theme_constant_override("margin_left", _i(18))
	summary_margin.add_theme_constant_override("margin_top", _i(16))
	summary_margin.add_theme_constant_override("margin_right", _i(18))
	summary_margin.add_theme_constant_override("margin_bottom", _i(16))
	summary_panel.add_child(summary_margin)
	summary_margin.add_child(_make_label("记录仍保存在本地 cache。这里先沿用当前 Godot 迁移阶段已经存在的本地榜单。", 17, Color(0.94, 0.82, 0.56, 0.94)))

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)

	leaderboard_body_label = _make_label("", 18, Color(0.9, 0.92, 0.95, 0.96))
	leaderboard_body_label.custom_minimum_size = _v(720.0, 0.0)
	leaderboard_body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	leaderboard_body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(leaderboard_body_label)

	var action_row := HBoxContainer.new()
	action_row.alignment = BoxContainer.ALIGNMENT_END
	action_row.add_theme_constant_override("separation", _i(12))
	box.add_child(action_row)
	action_row.add_child(_make_pill_button("收起战绩", _v(150.0, 52.0), Callable(self, "_hide_leaderboard_overlay")))


func _build_enemy_archive_overlay() -> void:
	enemy_archive_overlay = Control.new()
	enemy_archive_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	enemy_archive_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	enemy_archive_overlay.visible = false
	add_child(enemy_archive_overlay)

	var scrim := ColorRect.new()
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.02, 0.03, 0.04, 0.82)
	enemy_archive_overlay.add_child(scrim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -_f(440.0)
	panel.offset_top = -_f(300.0)
	panel.offset_right = _f(440.0)
	panel.offset_bottom = _f(300.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.08, 0.1, 0.96), Color(0.82, 0.44, 0.38, 0.58)))
	enemy_archive_overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", _i(28))
	margin.add_theme_constant_override("margin_top", _i(24))
	margin.add_theme_constant_override("margin_right", _i(28))
	margin.add_theme_constant_override("margin_bottom", _i(24))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(14))
	margin.add_child(box)

	box.add_child(_make_label("怪物图鉴", 36, Color(1.0, 0.95, 0.86, 1.0)))
	box.add_child(_make_label("把已经接入的敌人谱系收进二级菜单，开局前先记住预警和应对重点。", 18, Color(0.88, 0.92, 0.96, 0.95)))

	var summary_panel := PanelContainer.new()
	summary_panel.custom_minimum_size = _v(0.0, 92.0)
	summary_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.72), Color(0.28, 0.36, 0.42, 0.46)))
	box.add_child(summary_panel)
	var summary_margin := MarginContainer.new()
	summary_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	summary_margin.add_theme_constant_override("margin_left", _i(18))
	summary_margin.add_theme_constant_override("margin_top", _i(16))
	summary_margin.add_theme_constant_override("margin_right", _i(18))
	summary_margin.add_theme_constant_override("margin_bottom", _i(16))
	summary_panel.add_child(summary_margin)
	summary_margin.add_child(_make_label("图鉴文本直接对应当前 Godot 迁移版已经写进战斗脚本的敌人行为，不额外虚构未接入兵种。", 17, Color(0.94, 0.82, 0.56, 0.94)))

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)

	enemy_archive_body_label = _make_label("", 18, Color(0.9, 0.92, 0.95, 0.96))
	enemy_archive_body_label.custom_minimum_size = _v(760.0, 0.0)
	enemy_archive_body_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	enemy_archive_body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(enemy_archive_body_label)

	var action_row := HBoxContainer.new()
	action_row.alignment = BoxContainer.ALIGNMENT_END
	action_row.add_theme_constant_override("separation", _i(12))
	box.add_child(action_row)
	action_row.add_child(_make_pill_button("收起图鉴", _v(150.0, 52.0), Callable(self, "_hide_enemy_archive_overlay")))


func _build_transition_overlay() -> void:
	transition_overlay = Control.new()
	transition_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	transition_overlay.visible = false
	transition_overlay.modulate = Color(1.0, 1.0, 1.0, 0.0)
	add_child(transition_overlay)

	var scrim := ColorRect.new()
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.02, 0.03, 0.04, 0.88)
	transition_overlay.add_child(scrim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -_f(340.0)
	panel.offset_top = -_f(170.0)
	panel.offset_right = _f(340.0)
	panel.offset_bottom = _f(170.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.06, 0.08, 0.1, 0.96), Color(0.92, 0.68, 0.42, 0.72)))
	transition_overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", _i(30))
	margin.add_theme_constant_override("margin_top", _i(24))
	margin.add_theme_constant_override("margin_right", _i(30))
	margin.add_theme_constant_override("margin_bottom", _i(24))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(14))
	margin.add_child(box)

	var glyph_shell := PanelContainer.new()
	glyph_shell.custom_minimum_size = _v(0.0, 116.0)
	glyph_shell.add_theme_stylebox_override("panel", _make_panel_style(Color(0.14, 0.1, 0.08, 0.92), Color(0.92, 0.68, 0.42, 0.34)))
	box.add_child(glyph_shell)
	transition_glyph_label = _make_label("书", 62, Color(1.0, 0.95, 0.86, 1.0))
	transition_glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	transition_glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	transition_glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph_shell.add_child(transition_glyph_label)

	transition_title_label = _make_label("残卷一·入墨", 38, Color(1.0, 0.95, 0.86, 1.0))
	transition_subtitle_label = _make_label("执笔者正落字入卷。", 20, Color(0.9, 0.92, 0.96, 0.96))
	box.add_child(transition_title_label)
	box.add_child(transition_subtitle_label)
	box.add_child(_make_label("墨线正在收束，字潮即将开启。", 18, Color(0.96, 0.82, 0.54, 0.92)))


func _build_recipe_atlas_text() -> String:
	var lines: Array[String] = [
		"偏旁先补齐成字，成字满级后再去砚台磨成词技。",
		"进入残卷前先看一眼路线，升级三选一时会更容易判断当前该补哪一笔。",
		""
	]
	for recipe_id_variant in Session.RECIPE_ORDER:
		var recipe_id := String(recipe_id_variant)
		var recipe: Dictionary = Session.get_recipe_data(recipe_id)
		var radicals: Array = recipe.get("radicals", [])
		var radical_texts: Array[String] = []
		for radical_variant in radicals:
			var radical := String(radical_variant)
			var radical_data: Dictionary = Session.get_radical_data(radical)
			radical_texts.append("%s %s" % [radical, String(radical_data.get("name", ""))])

		var word_id := String(recipe.get("word_id", ""))
		var word: Dictionary = {}
		if word_id != "":
			word = Session.get_word_data(word_id)

		lines.append("%s  %s" % [String(recipe.get("display", "")), " + ".join(radical_texts)])
		lines.append("成字：%s  Lv.%d" % [String(recipe.get("title", "")), int(recipe.get("max_level", 1))])
		lines.append("  %s" % String(recipe.get("description", "")))
		if not word.is_empty():
			lines.append("磨词：%s  Lv.%d  砚台消耗 %d" % [String(word.get("title", "")), int(word.get("max_level", 1)), int(word.get("unlock_cost", 0))])
			lines.append("  %s" % String(word.get("description", "")))
		lines.append("")

	var blade_data: Dictionary = Session.get_radical_data("刂")
	lines.append("独立偏旁")
	lines.append("刂  %s" % String(blade_data.get("name", "")))
	lines.append("  %s" % String(blade_data.get("description", "")))
	return "\n".join(lines)


func _build_character_archive_text() -> String:
	var lines: Array[String] = [
		"当前人物志对应已经接入的两名执笔者，方便在真正落字进战场前先确认谁更适合这一轮的打法。",
		""
	]
	for hero_id_variant in Session.HERO_ORDER:
		var hero_id := String(hero_id_variant)
		var hero: Dictionary = Session.get_hero_data(hero_id)
		var tag_texts: Array[String] = []
		for tag_variant in hero.get("tags", []):
			tag_texts.append(String(tag_variant))
		lines.append("%s  %s  ·  %s" % [
			String(hero.get("glyph", "")),
			String(hero.get("name", "")),
			String(hero.get("title", ""))
		])
		lines.append("  身份：%s" % String(hero.get("role_label", "")))
		lines.append("  武器：%s" % String(hero.get("weapon", "")))
		lines.append("  战斗轮廓：%s" % String(hero.get("description", "")))
		lines.append("  执笔焦点：%s" % String(hero.get("focus", "")))
		lines.append("  标签：%s" % " / ".join(tag_texts))
		lines.append("  面板：机动 %.1f  气血 %.0f  伤害 %.0f  射程 %.1f" % [
			float(hero.get("move_speed", 0.0)),
			float(hero.get("max_health", 0.0)),
			float(hero.get("attack_damage", 0.0)),
			float(hero.get("attack_range", 0.0))
		])
		lines.append("")
	return "\n".join(lines)


func _build_local_leaderboard_text() -> String:
	var entries: Array[Dictionary] = Session.get_local_leaderboard(8)
	if entries.is_empty():
		return "当前还没有可展示的本地战绩。下一次残卷沉没后，这里会留下你的记录。"

	var lines: Array[String] = ["按定卷、卷主击破、波次、击破数排序。", ""]
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		lines.append(
			"%d. %s  %s  卷主 %d  波次 %d  击破 %d  存活 %s" % [
				index + 1,
				_format_leaderboard_identity(entry),
				"定卷" if bool(entry.get("chapter_complete", false)) else "残卷",
				int(entry.get("bosses", 0)),
				int(entry.get("threat", 1)),
				int(entry.get("kills", 0)),
				_format_elapsed(float(entry.get("elapsed", 0.0)))
			]
		)
	return "\n".join(lines)


func _format_leaderboard_identity(entry: Dictionary) -> String:
	var player_name := String(entry.get("player_name", "")).strip_edges()
	var hero_name := String(entry.get("hero_name", "书生")).strip_edges()
	if player_name.is_empty():
		return hero_name
	if hero_name.is_empty():
		return player_name
	return "%s · %s" % [player_name, hero_name]


func _build_enemy_archive_text() -> String:
	var lines: Array[String] = [
		"以下条目对应当前残卷里已经接入的敌人谱系、预警方式与最实用的临场处理思路。",
		""
	]
	for enemy_id_variant in Session.ENEMY_ORDER:
		var enemy_id := String(enemy_id_variant)
		var enemy: Dictionary = Session.get_enemy_data(enemy_id)
		lines.append("%s  %s  ·  %s" % [
			String(enemy.get("glyph", "")),
			String(enemy.get("name", "")),
			String(enemy.get("title", ""))
		])
		lines.append("  %s" % String(enemy.get("summary", "")))
		lines.append("  预警：%s" % String(enemy.get("warning", "")))
		lines.append("  应对：%s" % String(enemy.get("counter", "")))
		lines.append("")
	return "\n".join(lines)


func _format_elapsed(seconds: float) -> String:
	var total_seconds := maxi(0, int(round(seconds)))
	var minutes := int(total_seconds / 60)
	var remaining_seconds := total_seconds % 60
	return "%02d:%02d" % [minutes, remaining_seconds]


func _show_recipe_atlas_overlay() -> void:
	if recipe_atlas_overlay == null:
		return
	_hide_character_archive_overlay()
	_hide_enemy_archive_overlay()
	_hide_leaderboard_overlay()
	recipe_atlas_body_label.text = _build_recipe_atlas_text()
	recipe_atlas_overlay.visible = true


func _hide_recipe_atlas_overlay() -> void:
	if recipe_atlas_overlay != null:
		recipe_atlas_overlay.visible = false


func _show_character_archive_overlay() -> void:
	if character_archive_overlay == null:
		return
	_hide_recipe_atlas_overlay()
	_hide_enemy_archive_overlay()
	_hide_leaderboard_overlay()
	character_archive_body_label.text = _build_character_archive_text()
	character_archive_overlay.visible = true


func _hide_character_archive_overlay() -> void:
	if character_archive_overlay != null:
		character_archive_overlay.visible = false


func _show_leaderboard_overlay() -> void:
	if leaderboard_overlay == null:
		return
	_hide_character_archive_overlay()
	_hide_recipe_atlas_overlay()
	_hide_enemy_archive_overlay()
	leaderboard_body_label.text = _build_local_leaderboard_text()
	leaderboard_overlay.visible = true


func _hide_leaderboard_overlay() -> void:
	if leaderboard_overlay != null:
		leaderboard_overlay.visible = false


func _show_enemy_archive_overlay() -> void:
	if enemy_archive_overlay == null:
		return
	_hide_character_archive_overlay()
	_hide_recipe_atlas_overlay()
	_hide_leaderboard_overlay()
	enemy_archive_body_label.text = _build_enemy_archive_text()
	enemy_archive_overlay.visible = true


func _hide_enemy_archive_overlay() -> void:
	if enemy_archive_overlay != null:
		enemy_archive_overlay.visible = false


func _hide_secondary_overlays() -> void:
	_hide_character_archive_overlay()
	_hide_recipe_atlas_overlay()
	_hide_enemy_archive_overlay()
	_hide_leaderboard_overlay()


func _is_secondary_overlay_visible() -> bool:
	return (
		character_archive_overlay != null and character_archive_overlay.visible
	) or (
		recipe_atlas_overlay != null and recipe_atlas_overlay.visible
	) or (
		enemy_archive_overlay != null and enemy_archive_overlay.visible
	) or (
		leaderboard_overlay != null and leaderboard_overlay.visible
	)


func _on_character_archive_pressed() -> void:
	if transition_busy:
		return
	_show_character_archive_overlay()


func _on_recipe_atlas_pressed() -> void:
	if transition_busy:
		return
	_show_recipe_atlas_overlay()


func _on_enemy_archive_pressed() -> void:
	if transition_busy:
		return
	_show_enemy_archive_overlay()


func _on_leaderboard_pressed() -> void:
	if transition_busy:
		return
	_show_leaderboard_overlay()


func _on_start_pressed() -> void:
	if transition_busy:
		return
	_hide_secondary_overlays()
	Session.select_hero(selected_hero)
	Session.prepare_battle_intro("zihai_menu")
	_start_battle_transition()


func _on_back_pressed() -> void:
	if transition_busy:
		return
	_hide_secondary_overlays()
	get_tree().change_scene_to_file(Session.LAUNCHER_SCENE)


func _refresh_selection() -> void:
	Session.select_hero(selected_hero)
	for hero_id_variant in hero_panels.keys():
		var hero_id := String(hero_id_variant)
		var panel: PanelContainer = hero_panels[hero_id]
		var hero_data: Dictionary = Session.get_hero_data(hero_id)
		panel.add_theme_stylebox_override("panel", _make_card_style(hero_id == selected_hero, hero_data["accent"]))

	var selected_data: Dictionary = Session.get_selected_hero()
	var accent: Color = selected_data["accent"]
	detail_name_label.text = "%s  ·  %s" % [String(selected_data["name"]), String(selected_data["title"])]
	detail_role_label.text = "%s  ·  %s" % [String(selected_data["role_label"]), String(selected_data["weapon"])]
	detail_weapon_label.text = "主战描述：%s" % String(selected_data["description"])
	detail_desc_label.text = "战斗焦点：%s" % String(selected_data["focus"])
	detail_focus_label.text = "进入残卷后，同样的偏旁路线会因为角色武器而产生不同输出手感。"

	detail_preview_core.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.24, accent.g * 0.2, accent.b * 0.16, 0.94), Color(accent.r, accent.g, accent.b, 0.26)))
	detail_preview_glyph.text = String(selected_data["glyph"])

	for child in detail_tags_row.get_children():
		child.queue_free()
	for tag_text in selected_data["tags"]:
		detail_tags_row.add_child(_make_tag(String(tag_text), Color(accent.r * 0.16, accent.g * 0.16, accent.b * 0.2, 0.88), Color(0.98, 0.95, 0.9, 0.96)))

	_set_stat_value("move_speed", float(selected_data["move_speed"]), 7.2, "%.1f")
	_set_stat_value("max_health", float(selected_data["max_health"]), 140.0, "%.0f")
	_set_stat_value("attack_damage", float(selected_data["attack_damage"]), 24.0, "%.0f")
	_set_stat_value("attack_range", float(selected_data["attack_range"]), 15.5, "%.1f")


func _set_stat_value(stat_id: String, value: float, max_value: float, format_text: String) -> void:
	if not detail_stat_widgets.has(stat_id):
		return
	var widget: Dictionary = detail_stat_widgets[stat_id]
	var label: Label = widget["label"]
	var bar: ProgressBar = widget["bar"]
	label.text = format_text % value
	bar.value = clamp(value / max_value * 100.0, 0.0, 100.0)


func _start_battle_transition() -> void:
	transition_busy = true
	_hide_secondary_overlays()
	var hero_data: Dictionary = Session.get_selected_hero()
	transition_glyph_label.text = String(hero_data["glyph"])
	transition_title_label.text = "残卷一·入墨"
	transition_subtitle_label.text = "%s 执笔，落字入卷。" % String(hero_data["name"])
	transition_overlay.visible = true
	transition_overlay.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween := create_tween()
	tween.tween_property(transition_overlay, "modulate:a", 1.0, 0.35)
	tween.tween_interval(0.3)
	tween.tween_callback(Callable(self, "_change_to_battle"))


func _on_select_hero(hero_id: String) -> void:
	selected_hero = hero_id
	_refresh_selection()


func _change_to_battle() -> void:
	get_tree().change_scene_to_file(Session.ZIHAI_BATTLE_SCENE)


func _unhandled_input(event: InputEvent) -> void:
	if not _is_secondary_overlay_visible():
		return
	if event.is_action_pressed("ui_cancel"):
		_hide_secondary_overlays()
		get_viewport().set_input_as_handled()
