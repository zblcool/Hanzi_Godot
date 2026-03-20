extends CanvasLayer

const CJKFont := preload("res://scripts/core/cjk_font.gd")

class BattleMapCanvas:
	extends Control

	signal zoom_changed(zoom_value: float)

	const GRID_STEP := 4.0
	const MIN_ZOOM := 0.75
	const MAX_ZOOM := 2.6

	var world_radius: float = 28.0
	var zoom: float = 1.0
	var center_world: Vector2 = Vector2.ZERO
	var player_world: Vector2 = Vector2.ZERO
	var player_heading: Vector2 = Vector2(0.0, -1.0)
	var static_markers: Array[Dictionary] = []
	var enemy_markers: Array[Dictionary] = []
	var dragging: bool = false
	var drag_origin: Vector2 = Vector2.ZERO
	var drag_center_origin: Vector2 = Vector2.ZERO

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		clip_contents = true

	func _notification(what: int) -> void:
		if what == NOTIFICATION_RESIZED:
			center_world = _clamp_center(center_world)
			queue_redraw()

	func set_snapshot(snapshot: Dictionary) -> void:
		world_radius = max(18.0, float(snapshot.get("world_radius", world_radius)))
		player_world = snapshot.get("player", Vector2.ZERO)
		player_heading = snapshot.get("player_heading", Vector2(0.0, -1.0))
		static_markers.clear()
		enemy_markers.clear()
		for marker_variant in snapshot.get("markers", []):
			static_markers.append(marker_variant)
		for marker_variant in snapshot.get("enemies", []):
			enemy_markers.append(marker_variant)
		reset_view()

	func reset_view() -> void:
		dragging = false
		zoom = 1.0
		center_world = _clamp_center(player_world)
		queue_redraw()
		zoom_changed.emit(zoom)

	func adjust_zoom(delta: float) -> void:
		set_zoom(zoom + delta)

	func set_zoom(new_zoom: float) -> void:
		var clamped_zoom: float = clamp(new_zoom, MIN_ZOOM, MAX_ZOOM)
		if is_equal_approx(clamped_zoom, zoom):
			return
		zoom = clamped_zoom
		center_world = _clamp_center(center_world)
		queue_redraw()
		zoom_changed.emit(zoom)

	func cancel_drag() -> void:
		dragging = false

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton:
			var mouse_button := event as InputEventMouseButton
			if mouse_button.button_index == MOUSE_BUTTON_WHEEL_UP and mouse_button.pressed:
				set_zoom(zoom + 0.16)
				accept_event()
				return
			if mouse_button.button_index == MOUSE_BUTTON_WHEEL_DOWN and mouse_button.pressed:
				set_zoom(zoom - 0.16)
				accept_event()
				return
			if mouse_button.button_index == MOUSE_BUTTON_LEFT:
				dragging = mouse_button.pressed
				if dragging:
					drag_origin = mouse_button.position
					drag_center_origin = center_world
				accept_event()
				return

		if event is InputEventMouseMotion and dragging:
			var motion := event as InputEventMouseMotion
			var pixels_to_world: float = 1.0 / max(_pixels_per_world(), 0.001)
			var drag_delta: Vector2 = motion.position - drag_origin
			center_world = _clamp_center(
				drag_center_origin + Vector2(-drag_delta.x, drag_delta.y) * pixels_to_world
			)
			queue_redraw()
			accept_event()

	func _draw() -> void:
		if size.x <= 0.0 or size.y <= 0.0:
			return

		var rect := Rect2(Vector2.ZERO, size)
		draw_rect(rect, Color(0.03, 0.05, 0.07, 0.98), true)

		for grid_step in range(-int(world_radius), int(world_radius) + 1, int(GRID_STEP)):
			var x_color := Color(0.22, 0.28, 0.34, 0.18)
			var y_color := Color(0.22, 0.28, 0.34, 0.18)
			if grid_step == 0:
				x_color = Color(0.96, 0.72, 0.4, 0.32)
				y_color = Color(0.56, 0.84, 1.0, 0.3)
			draw_line(
				_world_to_canvas(Vector2(float(grid_step), -world_radius)),
				_world_to_canvas(Vector2(float(grid_step), world_radius)),
				x_color,
				1.0
			)
			draw_line(
				_world_to_canvas(Vector2(-world_radius, float(grid_step))),
				_world_to_canvas(Vector2(world_radius, float(grid_step))),
				y_color,
				1.0
			)

		var border_top_left := _world_to_canvas(Vector2(-world_radius, world_radius))
		var border_size := Vector2.ONE * world_radius * 2.0 * _pixels_per_world()
		draw_rect(
			Rect2(border_top_left, border_size),
			Color(0.94, 0.72, 0.4, 0.44),
			false,
			2.0
		)

		for marker_variant in static_markers:
			_draw_static_marker(marker_variant)
		for marker_variant in enemy_markers:
			_draw_enemy_marker(marker_variant)
		_draw_player_marker()

	func _draw_static_marker(marker: Dictionary) -> void:
		var point: Vector2 = _world_to_canvas(marker.get("position", Vector2.ZERO))
		if not _is_visible_point(point):
			return

		var color: Color = marker.get("color", Color(0.8, 0.8, 0.8, 1.0))
		match String(marker.get("kind", "")):
			"tree":
				draw_circle(point, 4.6, color)
			"bush":
				draw_arc(point, 6.2, 0.0, TAU, 20, color, 2.0)
			"inkstone":
				draw_rect(Rect2(point - Vector2(5.0, 5.0), Vector2(10.0, 10.0)), color, true)
			"stela":
				var diamond := PackedVector2Array([
					point + Vector2(0.0, -7.0),
					point + Vector2(6.0, 0.0),
					point + Vector2(0.0, 7.0),
					point + Vector2(-6.0, 0.0)
				])
				draw_polygon(diamond, PackedColorArray([color, color, color, color]))
			"scroll_rack":
				draw_rect(Rect2(point - Vector2(7.0, 3.0), Vector2(14.0, 6.0)), color, true)
			"ink_pool":
				draw_circle(point, 6.0, Color(color.r, color.g, color.b, 0.24))
				draw_arc(point, 6.0, 0.0, TAU, 22, color, 2.0)
			_:
				draw_circle(point, 4.0, color)

	func _draw_enemy_marker(marker: Dictionary) -> void:
		var point: Vector2 = _world_to_canvas(marker.get("position", Vector2.ZERO))
		if not _is_visible_point(point):
			return

		var color: Color = marker.get("color", Color(0.92, 0.42, 0.34, 1.0))
		if String(marker.get("kind", "")) == "boss":
			draw_rect(Rect2(point - Vector2(6.0, 6.0), Vector2(12.0, 12.0)), color, true)
			draw_arc(point, 9.5, 0.0, TAU, 24, Color(1.0, 0.92, 0.82, 0.85), 1.6)
		else:
			draw_circle(point, 3.6, color)

	func _draw_player_marker() -> void:
		var point := _world_to_canvas(player_world)
		var map_heading := Vector2(player_heading.x, -player_heading.y)
		if map_heading.length_squared() < 0.001:
			map_heading = Vector2(0.0, -1.0)
		map_heading = map_heading.normalized()
		var left := point + map_heading.rotated(2.42) * 8.0
		var tip := point + map_heading * 11.0
		var right := point + map_heading.rotated(-2.42) * 8.0
		draw_arc(point, 12.5, 0.0, TAU, 24, Color(1.0, 0.94, 0.82, 0.92), 2.0)
		draw_polygon(
			PackedVector2Array([tip, left, right]),
			PackedColorArray([
				Color(0.98, 0.78, 0.42, 1.0),
				Color(0.98, 0.78, 0.42, 1.0),
				Color(0.98, 0.78, 0.42, 1.0)
			])
		)

	func _world_to_canvas(point_world: Vector2) -> Vector2:
		var relative := point_world - center_world
		return size * 0.5 + Vector2(relative.x, -relative.y) * _pixels_per_world()

	func _pixels_per_world() -> float:
		return min(size.x, size.y) / max(world_radius * 2.0, 0.001) * zoom

	func _clamp_center(target: Vector2) -> Vector2:
		var pixels_per_world: float = max(_pixels_per_world(), 0.001)
		var half_world_width: float = size.x * 0.5 / pixels_per_world
		var half_world_height: float = size.y * 0.5 / pixels_per_world
		var max_x: float = max(0.0, world_radius - half_world_width)
		var max_y: float = max(0.0, world_radius - half_world_height)
		return Vector2(
			clamp(target.x, -max_x, max_x),
			clamp(target.y, -max_y, max_y)
		)

	func _is_visible_point(point: Vector2) -> bool:
		return Rect2(Vector2(-16.0, -16.0), size + Vector2.ONE * 32.0).has_point(point)

signal radical_choice_selected(radical: String)
signal word_choice_selected(word_id: String)
signal pause_requested
signal pause_resume_requested
signal restart_requested
signal return_menu_requested
signal map_toggle_requested

var ui_font: Font

var hero_label: Label
var hero_title_label: Label
var hero_focus_label: Label
var health_label: Label
var progress_label: Label
var status_label: Label
var radicals_label: Label
var skills_label: Label
var tip_label: Label
var banner_label: Label
var overlay_label: Label
var xp_bar: ProgressBar
var health_bar: ProgressBar
var controls_label: Label
var skill_cards_box: VBoxContainer
var hero_tag_row: HBoxContainer
var radical_chip_container: HFlowContainer
var boss_panel: PanelContainer
var boss_name_label: Label
var boss_detail_label: Label
var boss_bar: ProgressBar
var pause_button: Button
var map_button: Button

var choice_overlay: Control
var choice_title_label: Label
var choice_hint_label: Label
var choice_buttons: Array[Button] = []
var choice_mode: String = ""
var state_overlay: Control
var state_title_label: Label
var state_body_label: Label
var state_primary_button: Button
var state_secondary_button: Button
var state_tertiary_button: Button
var state_mode: String = ""
var map_overlay: Control
var map_canvas: BattleMapCanvas
var map_summary_label: Label
var map_zoom_label: Label

var banner_time := 0.0
var banner_color: Color = Color(1.0, 0.95, 0.84, 1.0)


func _ready() -> void:
	ui_font = CJKFont.get_font()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	set_process(true)


func _process(delta: float) -> void:
	if banner_time > 0.0:
		banner_time -= delta
		banner_label.visible = true
		var alpha: float = 1.0
		if banner_time < 0.45:
			alpha = clamp(banner_time / 0.45, 0.0, 1.0)
		banner_label.modulate = Color(banner_color.r, banner_color.g, banner_color.b, alpha)
	else:
		banner_label.visible = false


func configure(hero_data: Dictionary) -> void:
	hero_label.text = "%s" % String(hero_data["name"])
	hero_title_label.text = "%s  ·  %s" % [String(hero_data["title"]), String(hero_data["role_label"])]
	hero_focus_label.text = String(hero_data["focus"])
	_refresh_hero_tags(hero_data)
	controls_label.text = "WASD / 方向键移动\n自动朝最近敌人出手\n升级时三选一偏旁\n靠近砚台按 E 磨词\nM / Tab 地图，R 重开，Esc 返回菜单"


func set_health(current: float, maximum: float) -> void:
	health_label.text = "气血  %d / %d" % [int(ceil(current)), int(ceil(maximum))]
	health_bar.max_value = max(1.0, maximum)
	health_bar.value = clamp(current, 0.0, maximum)


func set_progress(level: int, current: int, target: int) -> void:
	progress_label.text = "字墨  Lv.%d   %d / %d" % [level, current, target]
	xp_bar.max_value = max(1, target)
	xp_bar.value = clamp(current, 0, target)


func set_status(elapsed: float, kills: int, threat: int) -> void:
	var total_seconds: int = int(floor(elapsed))
	var minutes: int = int(total_seconds / 60)
	var seconds: int = total_seconds % 60
	status_label.text = "存活  %02d:%02d\n波次  %d\n击破  %d" % [minutes, seconds, threat, kills]


func set_radicals(radicals: Dictionary) -> void:
	if radical_chip_container == null:
		return

	for child in radical_chip_container.get_children():
		child.queue_free()

	var total_count: int = 0
	for radical_variant in Session.RADICAL_ORDER:
		var radical := String(radical_variant)
		var amount: int = int(radicals.get(radical, 0))
		total_count += amount
		if amount > 0:
			radical_chip_container.add_child(_make_radical_chip(radical, amount))

	if total_count <= 0:
		radicals_label.text = "当前尚未留存偏旁"
		radical_chip_container.add_child(_make_radical_chip("字", 0, Color(0.4, 0.54, 0.68, 1.0), "全部化字"))
	else:
		radicals_label.text = "当前留存 %d 枚偏旁，可继续合字或磨词" % total_count


func set_skills(recipe_levels: Dictionary, word_levels: Dictionary, word_progress: Dictionary, blade_level: int, hero_id: String) -> void:
	if skill_cards_box == null:
		return

	for child in skill_cards_box.get_children():
		child.queue_free()

	var cards: Array[Dictionary] = []
	for recipe_id_variant in Session.RECIPE_ORDER:
		var recipe_id := String(recipe_id_variant)
		var recipe: Dictionary = Session.get_recipe_data(recipe_id)
		var recipe_level: int = int(recipe_levels.get(recipe_id, 0))
		var word_id: String = String(recipe["word_id"])
		var word: Dictionary = Session.get_word_data(word_id)
		var word_level: int = int(word_levels.get(word_id, 0))
		if word_level > 0:
			cards.append({
				"glyph": String(word["display"]),
				"badge": "成词技能",
				"title": String(word["title"]),
				"detail": String(word["description"]),
				"recipe": "%s + %s" % [String(recipe["radicals"][0]), String(recipe["radicals"][1])],
				"level": "Lv.%d/%d" % [word_level, int(word["max_level"])],
				"color": Color(word["color"])
			})
		elif recipe_level > 0:
			var state_text := "Lv.%d/%d" % [recipe_level, int(recipe["max_level"])]
			if recipe_level >= int(recipe["max_level"]):
				state_text = "磨词 %d/%d" % [int(word_progress.get(word_id, 0)), int(word["unlock_cost"])]
			cards.append({
				"glyph": String(recipe["display"]),
				"badge": "成字技能",
				"title": String(recipe["title"]),
				"detail": String(recipe["description"]),
				"recipe": "%s + %s" % [String(recipe["radicals"][0]), String(recipe["radicals"][1])],
				"level": state_text,
				"color": Color(recipe["color"])
			})

	cards.append({
		"glyph": "刀" if hero_id == "xia" else "笔",
		"badge": "武器核心",
		"title": "刀势" if hero_id == "xia" else "笔锋",
		"detail": "独立强化主武器强度，和角色身份直接绑定。",
		"recipe": "刂",
		"level": "Lv.%d" % blade_level,
		"color": Color(0.96, 0.54, 0.36, 1.0)
	})

	if cards.is_empty():
		skill_cards_box.add_child(_make_placeholder_card())
		return

	for card in cards:
		skill_cards_box.add_child(_make_skill_card(card))


func set_tip(text: String) -> void:
	tip_label.text = text


func show_banner(text: String, color: Color, duration: float = 2.4) -> void:
	banner_label.text = text
	banner_color = color
	banner_label.modulate = color
	banner_label.visible = true
	banner_time = duration


func show_boss(name: String, glyph: String, tint: Color, maximum: float) -> void:
	if boss_panel == null:
		return
	boss_panel.visible = true
	boss_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tint.r * 0.12, tint.g * 0.12, tint.b * 0.16, 0.96), Color(tint.r, tint.g, tint.b, 0.72), 24))
	boss_name_label.text = "%s  %s" % [glyph, name]
	boss_detail_label.text = "卷主降阵"
	boss_bar.add_theme_stylebox_override("fill", _make_fill_style(tint, 10))
	boss_bar.max_value = max(1.0, maximum)
	boss_bar.value = maximum


func set_boss_health(current: float, maximum: float) -> void:
	if boss_panel == null:
		return
	boss_panel.visible = true
	boss_bar.max_value = max(1.0, maximum)
	boss_bar.value = clamp(current, 0.0, maximum)
	boss_detail_label.text = "卷主降阵   %d / %d" % [int(ceil(current)), int(ceil(maximum))]


func hide_boss() -> void:
	if boss_panel != null:
		boss_panel.visible = false


func show_radical_choices(level: int, choices: Array[Dictionary], pending_count: int) -> void:
	choice_mode = "radical"
	choice_title_label.text = "字力突破  Lv.%d" % level
	choice_hint_label.text = "从三枚偏旁里选一枚。它会推进合字，满级后继续磨成词技。剩余待选：%d" % pending_count
	overlay_label.visible = false
	for index in range(choice_buttons.size()):
		var button: Button = choice_buttons[index]
		if index < choices.size():
			var choice: Dictionary = choices[index]
			_configure_choice_button(
				button,
				"%s  %s" % [String(choice["radical"]), String(choice["name"])],
				String(choice["headline"]),
				String(choice["description"]),
				Color(choice["color"]),
				"radical",
				String(choice["radical"])
			)
		else:
			button.visible = false
	choice_overlay.visible = true


func show_word_choices(choices: Array[Dictionary]) -> void:
	choice_mode = "word"
	choice_title_label.text = "砚台磨词"
	choice_hint_label.text = "把满级合字的余材磨成更高一层的词技。每次磨词会消耗一枚相关偏旁。"
	overlay_label.visible = false
	for index in range(choice_buttons.size()):
		var button: Button = choice_buttons[index]
		if index < choices.size():
			var choice: Dictionary = choices[index]
			_configure_choice_button(
				button,
				"%s  %s" % [String(choice["display"]), String(choice["title"])],
				String(choice["headline"]),
				String(choice["description"]),
				Color(choice["color"]),
				"word_id",
				String(choice["word_id"])
			)
		else:
			button.visible = false
	choice_overlay.visible = true


func hide_radical_choices() -> void:
	hide_choice_overlay()


func hide_choice_overlay() -> void:
	choice_mode = ""
	choice_overlay.visible = false


func show_pause_menu(elapsed: float, kills: int, threat: int, level: int) -> void:
	hide_choice_overlay()
	hide_map_overlay()
	overlay_label.visible = false
	state_mode = "pause"
	state_title_label.text = "墨阵暂歇"
	state_body_label.text = "当前进度\n存活 %s\n波次 %d   击破 %d   等级 Lv.%d\n\n按 E 或 Esc 继续，按 R 立即重开。" % [
		_format_time(elapsed),
		threat,
		kills,
		level
	]
	_configure_state_button(state_primary_button, "继续战斗", Callable(self, "_emit_pause_resume"))
	_configure_state_button(state_secondary_button, "重新开始", Callable(self, "_emit_restart"))
	_configure_state_button(state_tertiary_button, "返回菜单", Callable(self, "_emit_return_menu"))
	state_overlay.visible = true


func hide_state_overlay() -> void:
	state_mode = ""
	if state_overlay != null:
		state_overlay.visible = false


func set_game_over(summary: String, elapsed: float = 0.0, kills: int = 0, threat: int = 1, level: int = 1) -> void:
	hide_choice_overlay()
	hide_map_overlay()
	state_mode = "game_over"
	state_title_label.text = "字海沉没"
	state_body_label.text = "%s\n\n本轮残卷\n存活 %s\n波次 %d   击破 %d   等级 Lv.%d" % [
		summary,
		_format_time(elapsed),
		threat,
		kills,
		level
	]
	_configure_state_button(state_primary_button, "重新开始", Callable(self, "_emit_restart"))
	_configure_state_button(state_secondary_button, "返回菜单", Callable(self, "_emit_return_menu"))
	state_tertiary_button.visible = false
	overlay_label.visible = false
	state_overlay.visible = true


func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var left_column := VBoxContainer.new()
	left_column.position = Vector2(24.0, 24.0)
	left_column.size = Vector2(410.0, 940.0)
	left_column.add_theme_constant_override("separation", 16)
	root.add_child(left_column)

	var intro_panel := _make_panel(Color(0.05, 0.08, 0.1, 0.76), Color(0.93, 0.69, 0.38, 0.84), Vector2(410.0, 330.0))
	left_column.add_child(intro_panel)
	var intro_box := _panel_box(intro_panel)
	intro_box.add_child(_make_label("INK-BORN ROGUELITE DEMO", 17, Color(0.96, 0.82, 0.52, 0.86), 4.0))
	hero_label = _make_label("书生", 56, Color(1.0, 0.95, 0.86, 1.0))
	intro_box.add_child(hero_label)
	hero_title_label = _make_label("", 18, Color(0.96, 0.82, 0.54, 0.96))
	intro_box.add_child(hero_title_label)
	hero_focus_label = _make_label("", 17, Color(0.86, 0.91, 0.98, 0.94))
	intro_box.add_child(hero_focus_label)

	hero_tag_row = HBoxContainer.new()
	hero_tag_row.add_theme_constant_override("separation", 10)
	intro_box.add_child(hero_tag_row)

	health_label = _make_label("气血  0 / 0", 18, Color(0.96, 0.92, 0.87, 0.98))
	intro_box.add_child(health_label)
	health_bar = _make_bar(Color(0.82, 0.38, 0.31, 0.96))
	intro_box.add_child(health_bar)
	progress_label = _make_label("字墨  Lv.1   0 / 4", 18, Color(0.98, 0.91, 0.72, 1.0))
	intro_box.add_child(progress_label)
	xp_bar = _make_bar(Color(0.56, 0.84, 0.82, 0.96))
	intro_box.add_child(xp_bar)
	status_label = _make_label("存活  00:00\n波次  1\n击破  0", 20, Color(0.86, 0.92, 0.98, 0.98))
	intro_box.add_child(status_label)

	var radicals_panel := _make_panel(Color(0.05, 0.07, 0.09, 0.72), Color(0.38, 0.72, 0.78, 0.72), Vector2(410.0, 184.0))
	left_column.add_child(radicals_panel)
	var radicals_box := _panel_box(radicals_panel)
	radicals_box.add_child(_make_label("待合偏旁", 22, Color(0.96, 0.9, 0.8, 1.0)))
	radicals_label = _make_label("当前尚未留存偏旁", 17, Color(0.86, 0.9, 0.92, 0.94))
	radicals_box.add_child(radicals_label)
	radical_chip_container = HFlowContainer.new()
	radical_chip_container.add_theme_constant_override("h_separation", 10)
	radical_chip_container.add_theme_constant_override("v_separation", 10)
	radicals_box.add_child(radical_chip_container)

	var controls_panel := _make_panel(Color(0.05, 0.07, 0.09, 0.72), Color(0.92, 0.69, 0.38, 0.58), Vector2(410.0, 220.0))
	left_column.add_child(controls_panel)
	var controls_box := _panel_box(controls_panel)
	controls_box.add_child(_make_label("操作", 22, Color(0.96, 0.9, 0.8, 1.0)))
	controls_label = _make_label("", 18, Color(0.88, 0.9, 0.93, 0.94))
	controls_box.add_child(controls_label)

	var top_pills := HBoxContainer.new()
	top_pills.position = Vector2(1080.0, 24.0)
	top_pills.add_theme_constant_override("separation", 12)
	root.add_child(top_pills)
	map_button = _make_pill_button("地图", Callable(self, "_emit_map_toggle"))
	top_pills.add_child(map_button)
	pause_button = _make_pill_button("暂停", Callable(self, "_emit_pause"))
	top_pills.add_child(pause_button)
	top_pills.add_child(_make_pill("EN"))

	boss_panel = _make_panel(Color(0.08, 0.06, 0.06, 0.88), Color(0.84, 0.34, 0.24, 0.72), Vector2(520.0, 92.0))
	boss_panel.position = Vector2(700.0, 154.0)
	boss_panel.visible = false
	root.add_child(boss_panel)
	var boss_box := _panel_box(boss_panel)
	boss_name_label = _make_label("卷  卷主", 28, Color(1.0, 0.94, 0.86, 1.0))
	boss_detail_label = _make_label("卷主降阵", 16, Color(0.92, 0.84, 0.78, 0.92))
	boss_box.add_child(boss_name_label)
	boss_box.add_child(boss_detail_label)
	boss_bar = _make_bar(Color(0.88, 0.36, 0.28, 1.0))
	boss_box.add_child(boss_bar)

	var objective_panel := _make_panel(Color(0.05, 0.07, 0.09, 0.76), Color(0.94, 0.7, 0.4, 0.6), Vector2(340.0, 150.0))
	objective_panel.position = Vector2(1540.0, 24.0)
	root.add_child(objective_panel)
	var objective_box := _panel_box(objective_panel)
	objective_box.add_child(_make_label("当前目标", 20, Color(0.96, 0.82, 0.56, 0.98)))
	tip_label = _make_label("尚未收集，或已经全部化字。", 18, Color(0.88, 0.9, 0.93, 0.95))
	objective_box.add_child(tip_label)

	var skills_panel := _make_panel(Color(0.05, 0.07, 0.09, 0.74), Color(0.38, 0.74, 0.82, 0.62), Vector2(340.0, 860.0))
	skills_panel.position = Vector2(1540.0, 190.0)
	root.add_child(skills_panel)
	var skills_margin := MarginContainer.new()
	skills_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	skills_margin.add_theme_constant_override("margin_left", 18)
	skills_margin.add_theme_constant_override("margin_top", 18)
	skills_margin.add_theme_constant_override("margin_right", 18)
	skills_margin.add_theme_constant_override("margin_bottom", 18)
	skills_panel.add_child(skills_margin)

	var skills_layout := VBoxContainer.new()
	skills_layout.add_theme_constant_override("separation", 14)
	skills_margin.add_child(skills_layout)

	skills_label = _make_label("已成技能字", 22, Color(0.96, 0.9, 0.8, 1.0))
	skills_layout.add_child(skills_label)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	skills_layout.add_child(scroll)

	skill_cards_box = VBoxContainer.new()
	skill_cards_box.add_theme_constant_override("separation", 12)
	scroll.add_child(skill_cards_box)

	banner_label = _make_label("", 44, Color(1.0, 0.92, 0.78, 1.0))
	banner_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	banner_label.offset_left = 420.0
	banner_label.offset_right = -420.0
	banner_label.offset_top = 86.0
	banner_label.offset_bottom = 150.0
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.visible = false
	root.add_child(banner_label)

	overlay_label = _make_label("", 30, Color(1.0, 0.92, 0.84, 1.0))
	overlay_label.set_anchors_preset(Control.PRESET_CENTER)
	overlay_label.offset_left = -320.0
	overlay_label.offset_top = -70.0
	overlay_label.offset_right = 320.0
	overlay_label.offset_bottom = 70.0
	overlay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	overlay_label.visible = false
	root.add_child(overlay_label)

	_build_map_overlay(root)
	_build_choice_overlay(root)
	_build_state_overlay(root)


func show_map_overlay(snapshot: Dictionary) -> void:
	if map_overlay == null or map_canvas == null:
		return
	overlay_label.visible = false
	map_canvas.set_snapshot(snapshot)
	map_summary_label.text = String(snapshot.get("summary", "敌群 0  ·  砚台 0  ·  草丛 0"))
	_update_map_zoom_label()
	map_overlay.visible = true


func hide_map_overlay() -> void:
	if map_overlay == null:
		return
	map_overlay.visible = false
	if map_canvas != null:
		map_canvas.cancel_drag()


func _build_map_overlay(root: Control) -> void:
	map_overlay = Control.new()
	map_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	map_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	map_overlay.visible = false
	root.add_child(map_overlay)

	var scrim := ColorRect.new()
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.01, 0.02, 0.03, 0.82)
	map_overlay.add_child(scrim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -620.0
	panel.offset_top = -342.0
	panel.offset_right = 620.0
	panel.offset_bottom = 342.0
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.07, 0.09, 0.96), Color(0.94, 0.7, 0.4, 0.86), 28))
	map_overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(margin)

	var shell := VBoxContainer.new()
	shell.add_theme_constant_override("separation", 16)
	margin.add_child(shell)

	shell.add_child(_make_label("残卷地图", 38, Color(1.0, 0.95, 0.86, 1.0)))
	map_summary_label = _make_label("", 18, Color(0.88, 0.92, 0.96, 0.94))
	shell.add_child(map_summary_label)

	var content_row := HBoxContainer.new()
	content_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_row.add_theme_constant_override("separation", 18)
	shell.add_child(content_row)

	var map_frame := PanelContainer.new()
	map_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_frame.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.05, 0.06, 0.94), Color(0.34, 0.44, 0.52, 0.7), 22))
	content_row.add_child(map_frame)

	var map_margin := MarginContainer.new()
	map_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	map_margin.add_theme_constant_override("margin_left", 14)
	map_margin.add_theme_constant_override("margin_top", 14)
	map_margin.add_theme_constant_override("margin_right", 14)
	map_margin.add_theme_constant_override("margin_bottom", 14)
	map_frame.add_child(map_margin)

	map_canvas = BattleMapCanvas.new()
	map_canvas.custom_minimum_size = Vector2(760.0, 520.0)
	map_canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_canvas.zoom_changed.connect(_on_map_canvas_zoom_changed)
	map_margin.add_child(map_canvas)

	var side_panel := PanelContainer.new()
	side_panel.custom_minimum_size = Vector2(300.0, 0.0)
	side_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.06, 0.08, 0.1, 0.9), Color(0.34, 0.44, 0.52, 0.58), 22))
	content_row.add_child(side_panel)

	var side_margin := MarginContainer.new()
	side_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	side_margin.add_theme_constant_override("margin_left", 18)
	side_margin.add_theme_constant_override("margin_top", 18)
	side_margin.add_theme_constant_override("margin_right", 18)
	side_margin.add_theme_constant_override("margin_bottom", 18)
	side_panel.add_child(side_margin)

	var side_box := VBoxContainer.new()
	side_box.add_theme_constant_override("separation", 12)
	side_margin.add_child(side_box)

	side_box.add_child(_make_label("图例", 24, Color(1.0, 0.92, 0.8, 1.0)))
	side_box.add_child(_make_map_legend_row("▲", "执笔者", "当前角色朝向与位置。", Color(0.98, 0.78, 0.42, 1.0)))
	side_box.add_child(_make_map_legend_row("●", "敌群", "常规敌人正在逼近的位置。", Color(0.92, 0.42, 0.34, 1.0)))
	side_box.add_child(_make_map_legend_row("■", "卷主 / 砚台", "方块标出卷主与磨词砚台。", Color(0.98, 0.76, 0.54, 1.0)))
	side_box.add_child(_make_map_legend_row("○", "树丛 / 墨池", "圆形轮廓对应草丛与墨池。", Color(0.56, 0.84, 0.66, 1.0)))
	side_box.add_child(_make_map_legend_row("◆", "碑刻 / 卷架", "静态地标，便于定方位。", Color(0.62, 0.84, 1.0, 1.0)))

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side_box.add_child(spacer)

	side_box.add_child(_make_label("拖拽视野，滚轮或按钮缩放。按 Esc、Tab、M 或再次点地图收起。", 17, Color(0.88, 0.9, 0.93, 0.92)))
	map_zoom_label = _make_label("缩放  1.00x", 17, Color(0.96, 0.82, 0.56, 0.98))
	side_box.add_child(map_zoom_label)

	var zoom_row := HBoxContainer.new()
	zoom_row.add_theme_constant_override("separation", 10)
	side_box.add_child(zoom_row)

	var zoom_out_button := _make_pill_button("缩小", Callable(self, "_on_map_zoom_out_pressed"))
	zoom_out_button.custom_minimum_size = Vector2(86.0, 48.0)
	zoom_row.add_child(zoom_out_button)

	var zoom_in_button := _make_pill_button("放大", Callable(self, "_on_map_zoom_in_pressed"))
	zoom_in_button.custom_minimum_size = Vector2(86.0, 48.0)
	zoom_row.add_child(zoom_in_button)

	var zoom_reset_button := _make_pill_button("重置", Callable(self, "_on_map_zoom_reset_pressed"))
	zoom_reset_button.custom_minimum_size = Vector2(86.0, 48.0)
	zoom_row.add_child(zoom_reset_button)

	var close_button := _make_pill_button("收起地图", Callable(self, "_emit_map_toggle"))
	close_button.custom_minimum_size = Vector2(0.0, 50.0)
	side_box.add_child(close_button)


func _build_choice_overlay(root: Control) -> void:
	choice_overlay = Control.new()
	choice_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	choice_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	choice_overlay.visible = false
	root.add_child(choice_overlay)

	var scrim := ColorRect.new()
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.01, 0.02, 0.03, 0.76)
	choice_overlay.add_child(scrim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -500.0
	panel.offset_top = -250.0
	panel.offset_right = 500.0
	panel.offset_bottom = 250.0
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.06, 0.08, 0.1, 0.96), Color(0.94, 0.7, 0.4, 0.92), 24))
	choice_overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 26)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 26)
	margin.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)

	choice_title_label = _make_label("字力突破", 38, Color(1.0, 0.94, 0.86, 1.0))
	choice_hint_label = _make_label("", 18, Color(0.88, 0.92, 0.96, 0.96))
	box.add_child(choice_title_label)
	box.add_child(choice_hint_label)

	var cards_row := HBoxContainer.new()
	cards_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cards_row.add_theme_constant_override("separation", 16)
	box.add_child(cards_row)

	for index in range(3):
		var button := Button.new()
		button.custom_minimum_size = Vector2(0.0, 278.0)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_override("font", ui_font)
		button.add_theme_font_size_override("font_size", 22)
		button.add_theme_color_override("font_color", Color(0.08, 0.08, 0.08, 1.0))
		button.pressed.connect(_on_choice_button_pressed.bind(index))
		choice_buttons.append(button)
		cards_row.add_child(button)


func _build_state_overlay(root: Control) -> void:
	state_overlay = Control.new()
	state_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	state_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	state_overlay.visible = false
	root.add_child(state_overlay)

	var scrim := ColorRect.new()
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.01, 0.02, 0.03, 0.8)
	state_overlay.add_child(scrim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -360.0
	panel.offset_top = -220.0
	panel.offset_right = 360.0
	panel.offset_bottom = 220.0
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.06, 0.08, 0.1, 0.96), Color(0.94, 0.7, 0.4, 0.92), 24))
	state_overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)

	state_title_label = _make_label("", 42, Color(1.0, 0.94, 0.86, 1.0))
	state_body_label = _make_label("", 20, Color(0.88, 0.92, 0.96, 0.96), 2.0)
	box.add_child(state_title_label)
	box.add_child(state_body_label)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)

	var buttons_box := VBoxContainer.new()
	buttons_box.add_theme_constant_override("separation", 10)
	box.add_child(buttons_box)

	state_primary_button = _make_state_button()
	state_secondary_button = _make_state_button()
	state_tertiary_button = _make_state_button()
	buttons_box.add_child(state_primary_button)
	buttons_box.add_child(state_secondary_button)
	buttons_box.add_child(state_tertiary_button)


func _on_choice_button_pressed(index: int) -> void:
	if index < 0 or index >= choice_buttons.size():
		return
	var button: Button = choice_buttons[index]
	match choice_mode:
		"radical":
			if button.has_meta("radical"):
				radical_choice_selected.emit(String(button.get_meta("radical")))
		"word":
			if button.has_meta("word_id"):
				word_choice_selected.emit(String(button.get_meta("word_id")))


func _configure_choice_button(button: Button, title: String, headline: String, description: String, color: Color, meta_key: String, meta_value: String) -> void:
	button.visible = true
	button.text = "%s\n%s\n%s" % [title, headline, description]
	button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	button.set_meta(meta_key, meta_value)
	button.disabled = false
	button.add_theme_stylebox_override("normal", _make_button_style(color, 24))
	button.add_theme_stylebox_override("hover", _make_button_style(color.lightened(0.08), 24))
	button.add_theme_stylebox_override("pressed", _make_button_style(color.darkened(0.08), 24))


func _make_state_button() -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0.0, 52.0)
	button.add_theme_font_override("font", ui_font)
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_color_override("font_color", Color(0.08, 0.08, 0.08, 1.0))
	return button


func _configure_state_button(button: Button, text: String, callback: Callable) -> void:
	button.visible = true
	button.text = text
	var resume_callable := Callable(self, "_emit_pause_resume")
	var restart_callable := Callable(self, "_emit_restart")
	var menu_callable := Callable(self, "_emit_return_menu")
	if button.pressed.is_connected(resume_callable):
		button.pressed.disconnect(resume_callable)
	if button.pressed.is_connected(restart_callable):
		button.pressed.disconnect(restart_callable)
	if button.pressed.is_connected(menu_callable):
		button.pressed.disconnect(menu_callable)
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.92, 0.62, 0.28, 1.0), 18))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(0.98, 0.7, 0.34, 1.0), 18))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.84, 0.54, 0.22, 1.0), 18))
	button.pressed.connect(callback, CONNECT_ONE_SHOT)


func _make_map_legend_row(symbol_text: String, title: String, detail: String, color: Color) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)

	var icon := PanelContainer.new()
	icon.custom_minimum_size = Vector2(46.0, 46.0)
	icon.add_theme_stylebox_override("panel", _make_panel_style(Color(color.r * 0.16, color.g * 0.16, color.b * 0.18, 0.88), Color(color.r, color.g, color.b, 0.42), 18))
	row.add_child(icon)

	var icon_label := _make_label(symbol_text, 22, Color(0.98, 0.95, 0.88, 0.98))
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.add_child(icon_label)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 4)
	row.add_child(text_box)
	text_box.add_child(_make_label(title, 18, Color(1.0, 0.94, 0.86, 0.98)))
	text_box.add_child(_make_label(detail, 15, Color(0.86, 0.9, 0.94, 0.9)))
	return row


func _on_map_zoom_in_pressed() -> void:
	if map_canvas == null:
		return
	map_canvas.adjust_zoom(0.18)
	_update_map_zoom_label()


func _on_map_zoom_out_pressed() -> void:
	if map_canvas == null:
		return
	map_canvas.adjust_zoom(-0.18)
	_update_map_zoom_label()


func _on_map_zoom_reset_pressed() -> void:
	if map_canvas == null:
		return
	map_canvas.reset_view()
	_update_map_zoom_label()


func _on_map_canvas_zoom_changed(_zoom_value: float) -> void:
	_update_map_zoom_label()


func _update_map_zoom_label() -> void:
	if map_zoom_label == null or map_canvas == null:
		return
	map_zoom_label.text = "缩放  %.2fx" % map_canvas.zoom


func _emit_pause_resume() -> void:
	hide_state_overlay()
	pause_resume_requested.emit()


func _emit_map_toggle() -> void:
	if choice_overlay != null and choice_overlay.visible:
		return
	if state_overlay != null and state_overlay.visible:
		return
	map_toggle_requested.emit()


func _emit_pause() -> void:
	if choice_overlay != null and choice_overlay.visible:
		return
	if state_overlay != null and state_overlay.visible:
		return
	if map_overlay != null and map_overlay.visible:
		return
	pause_requested.emit()


func _emit_restart() -> void:
	restart_requested.emit()


func _emit_return_menu() -> void:
	return_menu_requested.emit()


func _format_time(elapsed: float) -> String:
	var total_seconds: int = int(floor(elapsed))
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]


func _make_panel(fill_color: Color, border_color: Color, size: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = size
	panel.add_theme_stylebox_override("panel", _make_panel_style(fill_color, border_color, 24))
	return panel


func _panel_box(panel: PanelContainer) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)
	return box


func _make_pill(text: String) -> PanelContainer:
	var pill := PanelContainer.new()
	pill.custom_minimum_size = Vector2(94.0, 52.0)
	pill.add_theme_stylebox_override("panel", _make_panel_style(Color(0.04, 0.06, 0.08, 0.8), Color(0.28, 0.34, 0.4, 0.6), 26))
	var label := _make_label(text, 17, Color(0.96, 0.9, 0.8, 0.98))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	pill.add_child(label)
	return pill


func _make_pill_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(94.0, 52.0)
	button.add_theme_font_override("font", ui_font)
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", Color(0.96, 0.9, 0.8, 0.98))
	var normal_style := _make_panel_style(Color(0.04, 0.06, 0.08, 0.8), Color(0.28, 0.34, 0.4, 0.6), 26)
	var hover_style := _make_panel_style(Color(0.08, 0.11, 0.14, 0.88), Color(0.92, 0.69, 0.38, 0.72), 26)
	var pressed_style := _make_panel_style(Color(0.1, 0.12, 0.16, 0.92), Color(0.94, 0.7, 0.4, 0.86), 26)
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("focus", hover_style)
	button.text = text
	button.pressed.connect(callback)
	return button


func _make_bar(fill_color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.value = 0.0
	bar.custom_minimum_size = Vector2(0.0, 16.0)
	bar.show_percentage = false
	bar.add_theme_stylebox_override("background", _make_fill_style(Color(0.14, 0.16, 0.2, 0.72), 10))
	bar.add_theme_stylebox_override("fill", _make_fill_style(fill_color, 10))
	return bar


func _make_radical_chip(radical: String, amount: int, override_color: Color = Color(-1.0, -1.0, -1.0, -1.0), override_text: String = "") -> PanelContainer:
	var chip_color: Color = override_color
	if chip_color.r < 0.0:
		chip_color = Session.RADICAL_COLORS.get(radical, Color(0.44, 0.58, 0.72, 1.0))

	var chip := PanelContainer.new()
	chip.custom_minimum_size = Vector2(90.0, 44.0)
	chip.add_theme_stylebox_override("panel", _make_panel_style(Color(chip_color.r * 0.16, chip_color.g * 0.16, chip_color.b * 0.18, 0.92), Color(chip_color.r, chip_color.g, chip_color.b, 0.46), 18))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 8)
	chip.add_child(margin)

	var label := _make_label("%s  %s" % [radical, override_text if not override_text.is_empty() else "×%d" % amount], 16, Color(0.98, 0.95, 0.88, 0.98))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	margin.add_child(label)
	return chip


func _make_skill_card(data: Dictionary) -> PanelContainer:
	var color: Color = data["color"]
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0.0, 156.0)
	card.add_theme_stylebox_override("panel", _make_panel_style(Color(color.r * 0.16, color.g * 0.16, color.b * 0.2, 0.92), Color(color.r, color.g, color.b, 0.58), 24))

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	card.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	margin.add_child(row)

	var badge := PanelContainer.new()
	badge.custom_minimum_size = Vector2(64.0, 64.0)
	badge.add_theme_stylebox_override("panel", _make_panel_style(Color(0.12, 0.16, 0.2, 0.76), Color(color.r, color.g, color.b, 0.36), 22))
	row.add_child(badge)

	var badge_label := _make_label(String(data["glyph"]), 34, Color(0.96, 0.94, 0.88, 1.0))
	badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	badge.add_child(badge_label)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.add_theme_constant_override("separation", 6)
	row.add_child(text_col)

	text_col.add_child(_make_label(String(data["badge"]), 14, Color(0.9, 0.86, 0.8, 0.74), 3.0))
	text_col.add_child(_make_label(String(data["title"]), 24, Color(1.0, 0.95, 0.86, 1.0)))
	text_col.add_child(_make_label(String(data["detail"]), 17, Color(0.88, 0.9, 0.93, 0.92)))
	text_col.add_child(_make_label(String(data["recipe"]), 15, Color(0.94, 0.82, 0.56, 0.86)))

	var level_pill := PanelContainer.new()
	level_pill.custom_minimum_size = Vector2(76.0, 48.0)
	level_pill.add_theme_stylebox_override("panel", _make_panel_style(Color(color.r * 0.25, color.g * 0.28, color.b * 0.32, 0.88), Color(color.r, color.g, color.b, 0.44), 24))
	row.add_child(level_pill)

	var level_label := _make_label(String(data["level"]), 18, Color(0.95, 0.95, 0.92, 0.98))
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	level_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	level_pill.add_child(level_label)

	return card


func _make_placeholder_card() -> PanelContainer:
	return _make_skill_card({
		"glyph": "字",
		"badge": "等待成字",
		"title": "尚未成型",
		"detail": "先通过偏旁三选一推进合字，再把满级合字带去砚台磨成词技。",
		"recipe": "日 + 月 / 亻 + 木 / 氵 + 每",
		"level": "预备",
		"color": Color(0.44, 0.58, 0.72, 1.0)
	})


func _make_label(text: String, font_size: int, color: Color, spacing: float = 0.0) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var settings := LabelSettings.new()
	settings.font = ui_font
	settings.font_size = font_size
	settings.font_color = color
	settings.outline_size = 1
	settings.outline_color = Color(0.02, 0.03, 0.04, 0.32)
	settings.shadow_size = 1
	settings.shadow_color = Color(0.0, 0.0, 0.0, 0.18)
	settings.line_spacing = spacing
	label.label_settings = settings
	return label


func _refresh_hero_tags(hero_data: Dictionary) -> void:
	if hero_tag_row == null:
		return
	for child in hero_tag_row.get_children():
		child.queue_free()

	var accent: Color = hero_data["accent"]
	for tag_text in hero_data["tags"]:
		var tag := PanelContainer.new()
		tag.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.16, accent.g * 0.16, accent.b * 0.18, 0.88), Color(accent.r, accent.g, accent.b, 0.42), 18))
		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 8)
		tag.add_child(margin)
		margin.add_child(_make_label(String(tag_text), 15, Color(0.98, 0.95, 0.88, 0.98)))
		hero_tag_row.add_child(tag)


func _make_panel_style(fill_color: Color, border_color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = border_color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.18)
	style.shadow_size = 10
	return style


func _make_fill_style(fill_color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	return style


func _make_button_style(fill_color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	return style
