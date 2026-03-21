extends Control

const CJKFont := preload("res://scripts/core/cjk_font.gd")
const BASE_VIEWPORT := Vector2(2100.0, 1200.0)
const MIN_UI_SCALE := 0.6

var title_font: Font
var ui_scale := 1.0
var floating_symbols: Array[Dictionary] = []
var preview_motifs: Array[Dictionary] = []
var about_overlay: Control


func _ready() -> void:
	title_font = CJKFont.get_font()
	_build_floating_symbols()
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_rebuild_ui()
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	for symbol in floating_symbols:
		var velocity: Vector2 = symbol["velocity"]
		var position: Vector2 = symbol["position"]
		position += velocity * delta
		if position.x > viewport_size.x + 90.0:
			position.x = -90.0
		if position.y > viewport_size.y + 80.0:
			position.y = -80.0
		symbol["position"] = position

	for motif in preview_motifs:
		var phase: float = float(motif["phase"]) + delta * float(motif["speed"])
		motif["phase"] = phase

		var ring_a: Control = motif["ring_a"]
		var ring_b: Control = motif["ring_b"]
		var beam_left: Control = motif["beam_left"]
		var beam_right: Control = motif["beam_right"]
		var core: Control = motif["core"]
		var chips: Array = motif["chips"]

		ring_a.rotation = phase * 0.38
		ring_b.rotation = -phase * 0.26
		beam_left.rotation = -0.42 + sin(phase * 1.2) * 0.08
		beam_right.rotation = 0.54 + cos(phase * 1.1) * 0.08
		core.position.y = _f(56.0) + sin(phase * 1.6) * _f(6.0)

		for index in range(chips.size()):
			var chip: Control = chips[index]
			var chip_phase: float = phase * 1.4 + float(index) * 1.7
			chip.position.y = float(chip.get_meta("base_y")) + sin(chip_phase) * _f(8.0)
			chip.position.x = float(chip.get_meta("base_x")) + cos(chip_phase * 0.8) * _f(6.0)

	queue_redraw()


func _draw() -> void:
	var rect: Rect2 = get_viewport_rect()
	draw_rect(rect, Color(0.03, 0.05, 0.07, 1.0), true)
	draw_circle(Vector2(rect.size.x * 0.2, rect.size.y * 0.16), 240.0, Color(0.88, 0.58, 0.28, 0.08))
	draw_circle(Vector2(rect.size.x * 0.74, rect.size.y * 0.18), 280.0, Color(0.42, 0.74, 0.88, 0.06))
	draw_circle(Vector2(rect.size.x * 0.58, rect.size.y * 0.72), 360.0, Color(0.9, 0.74, 0.34, 0.04))

	for index in range(7):
		var x: float = rect.size.x * (0.08 + float(index) * 0.14)
		draw_line(Vector2(x, 0.0), Vector2(x - 120.0, rect.size.y), Color(0.18, 0.24, 0.28, 0.08), 1.0)

	for index in range(6):
		var size := 72.0 + float(index) * 20.0
		var center := Vector2(
			rect.size.x * (0.07 + float(index) * 0.16),
			rect.size.y * (0.14 + float(index % 3) * 0.24)
		)
		var diamond := PackedVector2Array([
			center + Vector2(0.0, -size),
			center + Vector2(size * 0.72, 0.0),
			center + Vector2(0.0, size),
			center + Vector2(-size * 0.72, 0.0),
			center + Vector2(0.0, -size)
		])
		draw_polyline(diamond, Color(0.52, 0.62, 0.72, 0.12), 2.0)

	for symbol in floating_symbols:
		var position: Vector2 = symbol["position"]
		var color: Color = symbol["color"]
		draw_string(
			title_font,
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
	about_overlay = null
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_build_ui()


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
	root.add_theme_constant_override("margin_left", _i(44))
	root.add_theme_constant_override("margin_top", _i(32))
	root.add_theme_constant_override("margin_right", _i(44))
	root.add_theme_constant_override("margin_bottom", _i(24))
	add_child(root)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	var layout := VBoxContainer.new()
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_theme_constant_override("separation", _i(20))
	scroll.add_child(layout)

	var top_bar := HBoxContainer.new()
	top_bar.add_theme_constant_override("separation", _i(12))
	layout.add_child(top_bar)

	var top_spacer := Control.new()
	top_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(top_spacer)
	top_bar.add_child(_make_pill_button("关于字海", _v(136.0, 54.0), Callable(self, "_show_about")))
	top_bar.add_child(_make_static_pill("EN", _v(78.0, 54.0)))

	var header_panel := PanelContainer.new()
	header_panel.custom_minimum_size = _v(0.0, 188.0)
	header_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.06, 0.08, 0.1, 0.8), Color(0.24, 0.3, 0.36, 0.72)))
	layout.add_child(header_panel)

	var header_margin := MarginContainer.new()
	header_margin.add_theme_constant_override("margin_left", _i(34))
	header_margin.add_theme_constant_override("margin_top", _i(26))
	header_margin.add_theme_constant_override("margin_right", _i(34))
	header_margin.add_theme_constant_override("margin_bottom", _i(26))
	header_panel.add_child(header_margin)

	var header_box := VBoxContainer.new()
	header_box.add_theme_constant_override("separation", _i(8))
	header_margin.add_child(header_box)
	header_box.add_child(_make_label("HANZI GAME LAUNCHER", 18, Color(0.96, 0.82, 0.54, 0.88)))
	header_box.add_child(_make_label("汉字游戏启动器", 72, Color(1.0, 0.95, 0.86, 1.0)))
	header_box.add_child(_make_label("从字形、部件到战斗系统，把汉字本身做成游戏的核心机制。", 18, Color(0.9, 0.92, 0.96, 0.94)))

	var mobile_row := HBoxContainer.new()
	mobile_row.add_theme_constant_override("separation", _i(18))
	layout.add_child(mobile_row)

	mobile_row.add_child(_make_info_panel(
		"微信内打开",
		[
			"如果是微信内置浏览器，尽量切到系统浏览器再进入。",
			"这样更容易拿到稳定的全屏、音频和触控体验。"
		],
		Color(0.5, 0.88, 0.66, 1.0)
	))
	mobile_row.add_child(_make_info_panel(
		"iPhone / iPad",
		[
			"可以用“分享 -> 添加到主屏幕”把启动器放到桌面。",
			"主屏幕入口会更接近独立应用的打开方式。"
		],
		Color(0.52, 0.8, 1.0, 1.0)
	))

	var main_row := HBoxContainer.new()
	main_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_row.add_theme_constant_override("separation", _i(20))
	layout.add_child(main_row)

	main_row.add_child(_make_game_card(
		"字海残卷",
		"Action Roguelite",
		"在墨阵里活下去，把偏旁一步步磨成成字与词技。",
		["3D 自动战斗", "偏旁三选一", "合字 -> 磨词"],
		Color(0.92, 0.54, 0.28, 1.0),
		"zihai",
		"进入字海残卷",
		Callable(self, "_on_enter_zihai_pressed"),
		true
	))
	main_row.add_child(_make_game_card(
		"仓颉之路",
		"Deckbuilder Climb",
		"把字形拆解、语义路线和出牌构筑压进同一条爬塔曲线。",
		["卡牌构筑", "字形拼装", "后续迁移"],
		Color(0.38, 0.58, 0.9, 1.0),
		"cangjie",
		"后续接入",
		Callable(),
		false
	))

	var roadmap_row := HBoxContainer.new()
	roadmap_row.add_theme_constant_override("separation", _i(18))
	layout.add_child(roadmap_row)

	roadmap_row.add_child(_make_info_panel(
		"迁移阶段",
		[
			"入口 -> 二级菜单 -> 战斗 的层级已经稳定。",
			"字海残卷保持 3D 俯视角，不回退到纯占位原型。",
			"敌人轮廓、字核和 UI 正在向 web 端气质统一。"
		],
		Color(0.92, 0.68, 0.4, 1.0)
	))
	roadmap_row.add_child(_make_info_panel(
		"当前目标",
		[
			"把偏旁、合字、词技做成真正的成长主线。",
			"让战斗里的字、墨、纸和敌人轮廓属于同一世界。",
			"把菜单和 HUD 提到可展示、可录像的完成度。"
		],
		Color(0.38, 0.74, 0.84, 1.0)
	))

	_build_about_overlay()


func _make_game_card(title: String, badge_text: String, tagline: String, tags: Array[String], accent: Color, preview_kind: String, button_text: String, callback: Callable, enabled: bool) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = _v(0.0, 418.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.12, accent.g * 0.12, accent.b * 0.16, 0.94), Color(accent.r, accent.g, accent.b, 0.64)))

	var padding := MarginContainer.new()
	padding.add_theme_constant_override("margin_left", _i(22))
	padding.add_theme_constant_override("margin_top", _i(20))
	padding.add_theme_constant_override("margin_right", _i(22))
	padding.add_theme_constant_override("margin_bottom", _i(20))
	card.add_child(padding)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	padding.add_child(box)

	var preview := PanelContainer.new()
	preview.custom_minimum_size = _v(0.0, 148.0)
	preview.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.16, accent.g * 0.15, accent.b * 0.16, 0.38), Color(accent.r, accent.g, accent.b, 0.24)))
	box.add_child(preview)
	_build_preview_stage(preview, preview_kind, accent)

	var badge := _make_tag(badge_text, Color(0.12, 0.18, 0.24, 0.78), Color(0.96, 0.82, 0.56, 0.96))
	box.add_child(badge)
	box.add_child(_make_label(title, 34, Color(1.0, 0.95, 0.86, 1.0)))
	box.add_child(_make_label(tagline, 17, Color(0.9, 0.92, 0.96, 0.95)))

	var tags_row := HBoxContainer.new()
	tags_row.add_theme_constant_override("separation", 8)
	box.add_child(tags_row)
	for tag_text in tags:
		tags_row.add_child(_make_tag(tag_text, Color(accent.r * 0.18, accent.g * 0.18, accent.b * 0.2, 0.88), Color(0.95, 0.94, 0.9, 0.96)))

	var spacer := Control.new()
	spacer.custom_minimum_size = _v(0.0, 14.0)
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)

	var button := Button.new()
	button.text = button_text
	button.disabled = not enabled
	button.custom_minimum_size = _v(0.0, 56.0)
	button.add_theme_font_override("font", title_font)
	button.add_theme_font_size_override("font_size", _i(22))
	button.add_theme_color_override("font_color", Color(0.08, 0.07, 0.07, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.56, 0.56, 0.56, 1.0))
	button.add_theme_stylebox_override("normal", _make_button_style(accent, 16))
	button.add_theme_stylebox_override("hover", _make_button_style(accent.lightened(0.1), 16))
	button.add_theme_stylebox_override("pressed", _make_button_style(accent.darkened(0.08), 16))
	button.add_theme_stylebox_override("disabled", _make_button_style(Color(0.3, 0.32, 0.35, 0.82), 16))
	if enabled and callback.is_valid():
		button.pressed.connect(callback)
	box.add_child(button)

	return card


func _build_preview_stage(preview: PanelContainer, preview_kind: String, accent: Color) -> void:
	var stage := Control.new()
	stage.set_anchors_preset(Control.PRESET_FULL_RECT)
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.add_child(stage)

	var ring_a := PanelContainer.new()
	ring_a.size = _v(118.0, 118.0)
	ring_a.position = _v(34.0, 10.0)
	ring_a.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.12, accent.g * 0.12, accent.b * 0.14, 0.12), Color(accent.r, accent.g, accent.b, 0.24)))
	stage.add_child(ring_a)

	var ring_b := PanelContainer.new()
	ring_b.size = _v(84.0, 84.0)
	ring_b.position = _v(51.0, 27.0)
	ring_b.add_theme_stylebox_override("panel", _make_panel_style(Color(0.1, 0.14, 0.18, 0.0), Color(accent.r, accent.g, accent.b, 0.2)))
	stage.add_child(ring_b)

	var beam_left := ColorRect.new()
	beam_left.color = Color(accent.r, accent.g, accent.b, 0.86)
	beam_left.position = _v(40.0, 70.0)
	beam_left.size = _v(38.0, 7.0)
	stage.add_child(beam_left)

	var beam_right := ColorRect.new()
	beam_right.color = Color(accent.r, accent.g, accent.b, 0.86)
	beam_right.position = _v(142.0, 78.0)
	beam_right.size = _v(42.0, 7.0)
	stage.add_child(beam_right)

	var core := PanelContainer.new()
	core.size = _v(78.0, 78.0)
	core.position = _v(57.0, 40.0)
	core.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.24, accent.g * 0.2, accent.b * 0.16, 0.94), Color(accent.r, accent.g, accent.b, 0.32)))
	stage.add_child(core)

	var glyph_label := _make_label("字" if preview_kind == "zihai" else "仓", 44, Color(1.0, 0.95, 0.86, 1.0))
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	core.add_child(glyph_label)

	var chips: Array = []
	var chip_texts := ["偏", "合", "词"] if preview_kind == "zihai" else ["仓", "颉", "路"]
	var chip_positions := [_v(186.0, 18.0), _v(196.0, 58.0), _v(168.0, 96.0)]
	for index in range(chip_texts.size()):
		var chip := _make_tag(String(chip_texts[index]), Color(accent.r * 0.16, accent.g * 0.18, accent.b * 0.22, 0.88), Color(1.0, 0.95, 0.86, 0.98))
		chip.custom_minimum_size = _v(58.0, 38.0)
		chip.position = chip_positions[index]
		chip.set_meta("base_x", chip.position.x)
		chip.set_meta("base_y", chip.position.y)
		stage.add_child(chip)
		chips.append(chip)

	preview_motifs.append({
		"ring_a": ring_a,
		"ring_b": ring_b,
		"beam_left": beam_left,
		"beam_right": beam_right,
		"core": core,
		"chips": chips,
		"phase": randf() * TAU,
		"speed": 0.95 if preview_kind == "zihai" else 0.72
	})


func _make_info_panel(title: String, lines: Array[String], accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = _v(0.0, 144.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.1, accent.g * 0.1, accent.b * 0.12, 0.82), Color(accent.r, accent.g, accent.b, 0.46)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(20))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(20))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(8))
	margin.add_child(box)
	box.add_child(_make_label(title, 26, Color(1.0, 0.92, 0.8, 1.0)))
	for line_text in lines:
		box.add_child(_make_label(line_text, 17, Color(0.9, 0.92, 0.95, 0.95)))
	return panel


func _build_about_overlay() -> void:
	about_overlay = Control.new()
	about_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	about_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	about_overlay.visible = false
	add_child(about_overlay)

	var scrim := ColorRect.new()
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.01, 0.02, 0.03, 0.74)
	about_overlay.add_child(scrim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -_f(560.0)
	panel.offset_top = -_f(318.0)
	panel.offset_right = _f(560.0)
	panel.offset_bottom = _f(318.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.08, 0.1, 0.96), Color(0.94, 0.7, 0.42, 0.9)))
	about_overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", _i(28))
	margin.add_theme_constant_override("margin_top", _i(24))
	margin.add_theme_constant_override("margin_right", _i(28))
	margin.add_theme_constant_override("margin_bottom", _i(24))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(16))
	margin.add_child(box)

	box.add_child(_make_tag("About The Games", Color(0.14, 0.18, 0.24, 0.88), Color(0.96, 0.82, 0.56, 0.98)))
	box.add_child(_make_label("关于汉字工坊", 44, Color(1.0, 0.95, 0.86, 1.0)))
	box.add_child(_make_label("这里先讲清这款游戏为什么会被做出来，再继续介绍当前已经迁进 Godot 的部分，以及还留在 web 原型里的目标。", 18, Color(0.9, 0.92, 0.96, 0.95)))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", _i(18))
	scroll.add_child(content)

	content.add_child(_make_about_story_panel([
		"作为生活在海外的中国人，多种文化之间的碰撞与交流，让我重新看见自己的母语。汉字像古老而仍然鲜活的图画，从甲骨文到小篆、从繁体到简体，每一次演变都藏着故事，也延续着几千年的文化脉络。",
		"一直以来，我都想做一款和中文有关的游戏。直到孩子出生，这个念头变得更具体了。身处英语环境，我开始更认真地想：能不能用游戏去点燃他，也点燃更多孩子，对汉字与中华文化的兴趣？对我来说，这既是一次实验，也是一个父亲的愿望。",
		"这个项目会持续借助 AI 参与开发，但归根结底，它更像是一封写给汉字、写给中文文化的情书。现在 Godot 主线先把《字海残卷》的启动器、二级菜单和 3D 战斗接牢，再继续把 web 原型里更完整的内容一项项迁回来。"
	]))

	var game_grid := GridContainer.new()
	game_grid.columns = 2
	game_grid.add_theme_constant_override("h_separation", _i(16))
	game_grid.add_theme_constant_override("v_separation", _i(16))
	content.add_child(game_grid)

	game_grid.add_child(_make_about_game_card(
		"Action Roguelite",
		"字海残卷",
		"自动攻击、生存走位、偏旁合字、词技磨成与字阵地图。像幸存者类，但核心成长来自汉字结构和语义。",
		["偏旁收集、合字成技、词技进阶", "波次、关键怪、卷主、地图地标", "移动端横屏保护与战斗适配"],
		Color(0.92, 0.54, 0.28, 1.0),
		"zihai"
	))
	game_grid.add_child(_make_about_game_card(
		"Deckbuilder Climb",
		"仓颉之路",
		"类杀戮尖塔的卡牌爬塔原型。每张牌同时是战斗动作与汉字学习卡，字形、语义和组合路线都能进入构筑。",
		["地图节点、卡牌战斗、奖励选牌", "中英双语辅助，更适合非中文母语玩家", "当前仍在 web 原型，等待 Godot 迁入"],
		Color(0.38, 0.58, 0.9, 1.0),
		"cangjie"
	))

	var notes_grid := GridContainer.new()
	notes_grid.columns = 3
	notes_grid.add_theme_constant_override("h_separation", _i(14))
	notes_grid.add_theme_constant_override("v_separation", _i(14))
	content.add_child(notes_grid)

	notes_grid.add_child(_make_about_note_card(
		"面向谁",
		"不仅面向会中文的人，也面向想通过游戏认识汉字结构、字义和词感的玩家。",
		Color(0.92, 0.68, 0.4, 1.0)
	))
	notes_grid.add_child(_make_about_note_card(
		"迁移重点",
		"Godot 主线优先补齐启动器、菜单、HUD 和战斗成长链，再追赶 web 端的音乐、设置、双语和仓颉玩法。",
		Color(0.38, 0.74, 0.84, 1.0)
	))
	notes_grid.add_child(_make_about_note_card(
		"下一步产品化",
		"先把 Godot 版做成稳定可展示的 vertical slice，再决定哪些内容继续留在网页 demo，哪些进入完整版本。",
		Color(0.58, 0.84, 0.62, 1.0)
	))

	var close_button := Button.new()
	close_button.text = "返回启动器"
	close_button.custom_minimum_size = _v(0.0, 52.0)
	close_button.add_theme_font_override("font", title_font)
	close_button.add_theme_font_size_override("font_size", _i(22))
	close_button.add_theme_color_override("font_color", Color(0.08, 0.07, 0.07, 1.0))
	close_button.add_theme_stylebox_override("normal", _make_button_style(Color(0.92, 0.62, 0.28, 1.0), 16))
	close_button.add_theme_stylebox_override("hover", _make_button_style(Color(0.98, 0.7, 0.34, 1.0), 16))
	close_button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.84, 0.54, 0.22, 1.0), 16))
	close_button.pressed.connect(_hide_about)
	box.add_child(close_button)


func _make_about_story_panel(paragraphs: Array[String]) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.11, 0.14, 0.84), Color(0.28, 0.36, 0.44, 0.42)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(22))
	margin.add_theme_constant_override("margin_top", _i(20))
	margin.add_theme_constant_override("margin_right", _i(22))
	margin.add_theme_constant_override("margin_bottom", _i(20))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(12))
	margin.add_child(box)
	box.add_child(_make_label("为什么做这两款游戏", 24, Color(1.0, 0.92, 0.8, 1.0)))

	for paragraph in paragraphs:
		box.add_child(_make_label(paragraph, 18, Color(0.9, 0.92, 0.95, 0.95)))

	return panel


func _make_about_game_card(kicker: String, title: String, copy: String, points: Array[String], accent: Color, preview_kind: String) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = _v(0.0, 420.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.1, accent.g * 0.1, accent.b * 0.14, 0.9), Color(accent.r, accent.g, accent.b, 0.52)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(20))
	margin.add_theme_constant_override("margin_top", _i(20))
	margin.add_theme_constant_override("margin_right", _i(20))
	margin.add_theme_constant_override("margin_bottom", _i(20))
	card.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(12))
	margin.add_child(box)

	var preview := PanelContainer.new()
	preview.custom_minimum_size = _v(0.0, 148.0)
	preview.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.16, accent.g * 0.15, accent.b * 0.16, 0.38), Color(accent.r, accent.g, accent.b, 0.24)))
	box.add_child(preview)
	_build_preview_stage(preview, preview_kind, accent)

	box.add_child(_make_tag(kicker, Color(0.12, 0.18, 0.24, 0.82), Color(0.96, 0.82, 0.56, 0.96)))
	box.add_child(_make_label(title, 32, Color(1.0, 0.95, 0.86, 1.0)))
	box.add_child(_make_label(copy, 17, Color(0.9, 0.92, 0.95, 0.94)))

	var points_box := VBoxContainer.new()
	points_box.add_theme_constant_override("separation", _i(8))
	box.add_child(points_box)
	for point in points:
		points_box.add_child(_make_label("• %s" % point, 16, Color(0.92, 0.94, 0.9, 0.95)))

	return card


func _make_about_note_card(title: String, body: String, accent: Color) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = _v(0.0, 152.0)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.88), Color(accent.r, accent.g, accent.b, 0.32)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(18))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(18))
	card.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(8))
	margin.add_child(box)
	box.add_child(_make_label(title, 22, Color(1.0, 0.92, 0.8, 1.0)))
	box.add_child(_make_label(body, 16, Color(0.9, 0.92, 0.95, 0.93)))
	return card


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var settings := LabelSettings.new()
	settings.font = title_font
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


func _make_button_style(fill_color: Color, radius: int) -> StyleBoxFlat:
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
	button.add_theme_font_override("font", title_font)
	button.add_theme_font_size_override("font_size", _i(20))
	button.add_theme_color_override("font_color", Color(0.98, 0.92, 0.82, 0.98))
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.04, 0.06, 0.08, 0.78), Color(0.2, 0.26, 0.32, 0.54)))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.08, 0.1, 0.12, 0.84), Color(0.92, 0.68, 0.42, 0.44)))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.08, 0.1, 0.12, 0.9), Color(0.92, 0.68, 0.42, 0.6)))
	button.pressed.connect(callback)
	return button


func _make_static_pill(text: String, size: Vector2) -> PanelContainer:
	var pill := PanelContainer.new()
	pill.custom_minimum_size = size
	pill.add_theme_stylebox_override("panel", _make_panel_style(Color(0.04, 0.06, 0.08, 0.76), Color(0.2, 0.26, 0.32, 0.56)))
	var label := _make_label(text, 20, Color(0.98, 0.92, 0.82, 0.98))
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
	var glyphs := ["字", "海", "卷", "偏", "旁", "明", "休", "海", "刂", "墨", "阵", "词", "技"]
	var colors := [
		Color(1.0, 0.76, 0.42, 0.18),
		Color(0.52, 0.85, 1.0, 0.16),
		Color(0.9, 0.48, 0.32, 0.14),
		Color(0.76, 0.9, 0.58, 0.16)
	]
	var viewport_size: Vector2 = get_viewport_rect().size

	for index in range(18):
		floating_symbols.append({
			"glyph": String(glyphs[index % glyphs.size()]),
			"position": Vector2(
				randf_range(-60.0, viewport_size.x + 20.0),
				randf_range(-50.0, viewport_size.y + 20.0)
			),
			"velocity": Vector2(randf_range(6.0, 20.0), randf_range(4.0, 16.0)),
			"size": randi_range(36, 88),
			"color": colors[index % colors.size()]
		})


func _show_about() -> void:
	if about_overlay != null:
		about_overlay.visible = true


func _hide_about() -> void:
	if about_overlay != null:
		about_overlay.visible = false


func _on_enter_zihai_pressed() -> void:
	get_tree().change_scene_to_file(Session.ZIHAI_MENU_SCENE)
