extends CanvasLayer

const CJKFont := preload("res://scripts/core/cjk_font.gd")
const FrontEndContent := preload("res://scripts/core/front_end_content.gd")
const HanziLocalization := preload("res://scripts/core/hanzi_localization.gd")
const EVENT_LOG_LIMIT := 12
const EVENT_LOG_DESKTOP_VISIBLE := 6
const EVENT_LOG_COMPACT_VISIBLE := 3
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
	var fog_cell_size: float = 2.0
	var explored_cells: Dictionary = {}
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
		fog_cell_size = max(0.5, float(snapshot.get("fog_cell_size", fog_cell_size)))
		player_world = snapshot.get("player", Vector2.ZERO)
		player_heading = snapshot.get("player_heading", Vector2(0.0, -1.0))
		explored_cells.clear()
		static_markers.clear()
		enemy_markers.clear()
		for cell_variant in snapshot.get("explored_cells", []):
			if cell_variant is Vector2i:
				explored_cells[cell_variant] = true
			elif cell_variant is Vector2:
				var cell_vector := cell_variant as Vector2
				explored_cells[Vector2i(int(round(cell_vector.x)), int(round(cell_vector.y)))] = true
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
		_draw_fog_of_war()
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
			"chest":
				draw_rect(Rect2(point - Vector2(6.0, 4.6), Vector2(12.0, 9.2)), color, true)
				draw_line(point + Vector2(-6.0, -0.4), point + Vector2(6.0, -0.4), Color(0.12, 0.08, 0.04, 0.72), 1.4)
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

	func _draw_fog_of_war() -> void:
		var cells_per_axis := maxi(1, int(ceil(world_radius * 2.0 / max(fog_cell_size, 0.001))))
		var fog_color := Color(0.01, 0.02, 0.03, 0.84)
		var edge_color := Color(0.18, 0.24, 0.3, 0.14)
		var viewport_rect := Rect2(Vector2.ZERO, size)
		for cell_x in range(cells_per_axis):
			for cell_y in range(cells_per_axis):
				var cell := Vector2i(cell_x, cell_y)
				if explored_cells.has(cell):
					continue
				var cell_world_min := Vector2(
					-world_radius + float(cell_x) * fog_cell_size,
					-world_radius + float(cell_y) * fog_cell_size
				)
				var cell_world_max := cell_world_min + Vector2.ONE * fog_cell_size
				var point_a := _world_to_canvas(cell_world_min)
				var point_b := _world_to_canvas(cell_world_max)
				var top_left := Vector2(minf(point_a.x, point_b.x), minf(point_a.y, point_b.y))
				var cell_rect := Rect2(top_left, Vector2(absf(point_b.x - point_a.x), absf(point_b.y - point_a.y)))
				if not viewport_rect.intersects(cell_rect):
					continue
				draw_rect(cell_rect, fog_color, true)
				draw_rect(cell_rect, edge_color, false, 1.0)

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
signal chamber_interlude_selected(choice_id: String)
signal restart_requested
signal return_menu_requested
signal map_toggle_requested
signal test_next_wave_requested
signal battle_setting_changed(setting_key: String, value: Variant)

var ui_font: Font
var current_language := "zh"
var battle_hud_content: Dictionary = FrontEndContent.battle_hud_content()
var root_control: Control
var safe_content_root: Control
var left_column: VBoxContainer
var top_pills: GridContainer
var top_right_stack: VBoxContainer

var hero_label: Label
var hero_title_label: Label
var hero_focus_label: Label
var health_label: Label
var progress_label: Label
var status_label: Label
var radicals_label: Label
var skills_label: Label
var tip_label: Label
var soundtrack_panel: PanelContainer
var soundtrack_title_label: Label
var soundtrack_detail_label: Label
var banner_label: Label
var overlay_label: Label
var reveal_panel: PanelContainer
var reveal_kicker_label: Label
var reveal_glyph_label: Label
var reveal_title_label: Label
var reveal_detail_label: Label
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
var test_next_wave_button: Button
var fps_panel: PanelContainer
var fps_value_label: Label
var compact_summary_panel: PanelContainer
var compact_health_label: Label
var compact_progress_label: Label
var compact_status_label: Label
var compact_radicals_label: Label
var compact_tip_label: Label
var compact_health_bar: ProgressBar
var compact_xp_bar: ProgressBar
var compact_route_label: Label
var objective_panel: PanelContainer
var objective_route_title_label: Label
var objective_route_detail_label: Label
var objective_stage_label: Label
var objective_route_tags: HFlowContainer
var guidance_root: Control
var guidance_panel: PanelContainer
var guidance_arrow_label: Label
var guidance_text_label: Label
var callout_panel: PanelContainer
var callout_title_label: Label
var callout_text_label: Label
var callout_detail_label: Label
var skills_panel: PanelContainer
var compact_skill_panel: PanelContainer
var compact_skill_chip_container: HFlowContainer
var event_log_panel: PanelContainer
var event_log_list: VBoxContainer
var compact_event_panel: PanelContainer
var compact_event_list: VBoxContainer

var choice_overlay: Control
var choice_title_label: Label
var choice_hint_label: Label
var choice_buttons: Array[Button] = []
var choice_mode: String = ""
var state_overlay: Control
var state_title_label: Label
var state_body_label: Label
var state_preview_panel: PanelContainer
var state_preview_title_label: Label
var state_preview_line_labels: Array[Label] = []
var state_name_hint_label: Label
var state_name_row: BoxContainer
var state_name_status_label: Label
var state_name_input: LineEdit
var state_name_button: Button
var state_buttons_box: GridContainer
var state_primary_button: Button
var state_secondary_button: Button
var state_tertiary_button: Button
var state_quaternary_button: Button
var state_quinary_button: Button
var state_senary_button: Button
var state_mode: String = ""
var last_game_over_data: Dictionary = {}
var last_pause_summary: Dictionary = {}
var local_leaderboard_view: String = "manual"
var battle_settings: Dictionary = {}
var map_overlay: Control
var map_panel: PanelContainer
var map_content_box: BoxContainer
var map_side_panel: PanelContainer
var map_side_box: VBoxContainer
var map_side_spacer: Control
var map_canvas: BattleMapCanvas
var map_title_label: Label
var map_summary_label: Label
var map_zoom_label: Label
var map_zoom_row: BoxContainer
var map_zoom_buttons: Array[Button] = []
var map_close_button: Button
var map_legend_title_label: Label
var map_legend_rows: Array[Control] = []
var map_help_label: Label
var choice_panel: PanelContainer
var choice_cards_grid: GridContainer
var state_panel: PanelContainer
var choice_pending_count := 0

var banner_time := 0.0
var banner_color: Color = Color(1.0, 0.95, 0.84, 1.0)
var reveal_time := 0.0
var reveal_duration := 0.0
var callout_time := 0.0
var soundtrack_toast: PanelContainer
var soundtrack_toast_title_label: Label
var soundtrack_toast_detail_label: Label
var soundtrack_toast_time := 0.0
var test_tools_enabled := false
var compact_layout := false
var fps_update_timer := 0.0
var event_log_entries: Array[Dictionary] = []
var configured_hero_data: Dictionary = {}
var cached_radicals: Dictionary = {}
var cached_recipe_levels: Dictionary = {}
var cached_word_levels: Dictionary = {}
var cached_word_progress: Dictionary = {}
var cached_blade_level := 0
var cached_chamber_carry_state: Dictionary = {}


func _ready() -> void:
	ui_font = CJKFont.get_font()
	current_language = Session.get_launcher_language()
	battle_settings = Session.get_battle_settings()
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	get_viewport().size_changed.connect(_refresh_layout)
	_refresh_layout()
	call_deferred("_refresh_layout")
	set_process(true)


func _is_english() -> bool:
	return current_language == "en"


func _localize_text(text: String) -> String:
	if not _is_english():
		return text
	if text.begins_with("• "):
		return "• %s" % _localize_text(text.substr(2))
	return FrontEndContent.localize_battle_text(text, true)


func _battle_state_entry_text(entry_variant: Variant, fallback_zh: String, fallback_en: String = "") -> String:
	if entry_variant is Dictionary:
		var entry := entry_variant as Dictionary
		var fallback_text := fallback_en if _is_english() and not fallback_en.is_empty() else fallback_zh
		return String(entry.get("en" if _is_english() else "zh", fallback_text))
	if _is_english() and not fallback_en.is_empty():
		return fallback_en
	return fallback_zh


func _battle_state_text(state_content: Dictionary, key: String, fallback_zh: String, fallback_en: String = "") -> String:
	return _battle_state_entry_text(state_content.get(key, {}), fallback_zh, fallback_en)


func _localized_hero_data(hero_data: Dictionary) -> Dictionary:
	return HanziLocalization.localized_hero_data(String(hero_data.get("id", "")), current_language)


func _localized_recipe_data(recipe_id: String) -> Dictionary:
	return HanziLocalization.localized_recipe_data(recipe_id, current_language)


func _localized_word_data(word_id: String) -> Dictionary:
	return HanziLocalization.localized_word_data(word_id, current_language)


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

	if reveal_time > 0.0 and reveal_panel != null:
		reveal_time -= delta
		reveal_panel.visible = true
		var reveal_alpha: float = 1.0
		if reveal_duration > 0.0:
			var reveal_progress: float = clampf((reveal_duration - reveal_time) / reveal_duration, 0.0, 1.0)
			if reveal_progress < 0.12:
				reveal_alpha = clampf(reveal_progress / 0.12, 0.0, 1.0)
		if reveal_time < 0.48:
			reveal_alpha = minf(reveal_alpha, clampf(reveal_time / 0.48, 0.0, 1.0))
		reveal_panel.modulate = Color(1.0, 1.0, 1.0, reveal_alpha)
	elif reveal_panel != null:
		reveal_panel.visible = false

	if callout_time > 0.0 and callout_panel != null:
		callout_time -= delta
		callout_panel.visible = true
		var callout_alpha := 1.0
		if callout_time < 0.38:
			callout_alpha = clamp(callout_time / 0.38, 0.0, 1.0)
		callout_panel.modulate = Color(1.0, 1.0, 1.0, callout_alpha)
	elif callout_panel != null:
		callout_panel.visible = false

	if soundtrack_toast_time > 0.0:
		soundtrack_toast_time -= delta
		soundtrack_toast.visible = true
		var toast_alpha := 1.0
		if soundtrack_toast_time < 0.42:
			toast_alpha = clamp(soundtrack_toast_time / 0.42, 0.0, 1.0)
		soundtrack_toast.modulate = Color(1.0, 1.0, 1.0, toast_alpha)
	else:
		soundtrack_toast.visible = false

	if test_tools_enabled and fps_value_label != null:
		fps_update_timer = max(fps_update_timer - delta, 0.0)
		if fps_update_timer <= 0.0:
			fps_update_timer = 0.24
			fps_value_label.text = "FPS %d" % Engine.get_frames_per_second()


func configure(hero_data: Dictionary) -> void:
	configured_hero_data = hero_data.duplicate(true)
	var localized_hero := _localized_hero_data(hero_data)
	hero_label.text = "%s" % String(localized_hero["name"])
	hero_title_label.text = "%s  ·  %s" % [String(localized_hero["title"]), String(localized_hero["role_label"])]
	hero_focus_label.text = _build_hero_identity_line(localized_hero)
	_refresh_hero_tags(localized_hero)
	_refresh_controls_text()
	_refresh_route_focus()


func set_battle_settings(settings: Dictionary) -> void:
	battle_settings = settings.duplicate(true)
	if state_mode == "settings" and state_overlay != null and state_overlay.visible:
		_show_settings_menu()


func set_test_tools_enabled(enabled: bool) -> void:
	test_tools_enabled = enabled
	if test_next_wave_button != null:
		test_next_wave_button.visible = enabled
	if fps_panel != null:
		fps_panel.visible = enabled
	if fps_value_label != null:
		fps_value_label.text = "FPS %d" % Engine.get_frames_per_second() if enabled else "FPS --"
	fps_update_timer = 0.0
	_refresh_controls_text()
	_refresh_layout()


func is_pause_menu_open() -> bool:
	return state_mode == "pause" and state_overlay != null and state_overlay.visible


func is_chamber_transition_open() -> bool:
	return state_mode == "chamber_transition" and state_overlay != null and state_overlay.visible


func is_settings_menu_open() -> bool:
	return state_mode == "settings" and state_overlay != null and state_overlay.visible


func return_to_pause_menu() -> void:
	_return_to_pause_menu()


func set_health(current: float, maximum: float) -> void:
	var line := _battle_state_text(
		battle_hud_content,
		"health_format",
		"气血  %d / %d",
		"Vitality  %d / %d"
	) % [int(ceil(current)), int(ceil(maximum))]
	health_label.text = line
	health_bar.max_value = max(1.0, maximum)
	health_bar.value = clamp(current, 0.0, maximum)
	if compact_health_label != null:
		compact_health_label.text = line
	if compact_health_bar != null:
		compact_health_bar.max_value = max(1.0, maximum)
		compact_health_bar.value = clamp(current, 0.0, maximum)


func set_progress(level: int, current: int, target: int) -> void:
	var line := _battle_state_text(
		battle_hud_content,
		"progress_format",
		"字墨  Lv.%d   %d / %d",
		"Ink  Lv.%d   %d / %d"
	) % [level, current, target]
	progress_label.text = line
	xp_bar.max_value = max(1, target)
	xp_bar.value = clamp(current, 0, target)
	if compact_progress_label != null:
		compact_progress_label.text = line
	if compact_xp_bar != null:
		compact_xp_bar.max_value = max(1, target)
		compact_xp_bar.value = clamp(current, 0, target)


func set_status(elapsed: float, kills: int, threat: int) -> void:
	var total_seconds: int = int(floor(elapsed))
	var minutes: int = int(total_seconds / 60.0)
	var seconds: int = total_seconds % 60
	status_label.text = _battle_state_text(
		battle_hud_content,
		"status_multiline_format",
		"存活  %02d:%02d\n波次  %d\n击破  %d",
		"Time  %02d:%02d\nWave  %d\nKills  %d"
	) % [minutes, seconds, threat, kills]
	if compact_status_label != null:
		compact_status_label.text = _battle_state_text(
			battle_hud_content,
			"status_compact_format",
			"存活 %02d:%02d  ·  波次 %d  ·  击破 %d",
			"Time %02d:%02d  ·  Wave %d  ·  Kills %d"
		) % [minutes, seconds, threat, kills]


func set_radicals(radicals: Dictionary) -> void:
	cached_radicals = radicals.duplicate(true)
	if radical_chip_container == null:
		return

	for child in radical_chip_container.get_children():
		child.queue_free()

	var total_count: int = 0
	var compact_parts: Array[String] = []
	for radical_variant in Session.RADICAL_ORDER:
		var radical := String(radical_variant)
		var amount: int = int(radicals.get(radical, 0))
		total_count += amount
		if amount > 0:
			radical_chip_container.add_child(_make_radical_chip(radical, amount))
			if compact_parts.size() < 4:
				compact_parts.append("%s×%d" % [radical, amount])

	if total_count <= 0:
		radicals_label.text = _battle_state_text(
			battle_hud_content,
			"radicals_empty_detail",
			"当前尚未留存偏旁",
			"No radicals are currently stored."
		)
		radical_chip_container.add_child(
			_make_radical_chip(
				"字",
				0,
				Color(0.4, 0.54, 0.68, 1.0),
				_battle_state_text(battle_hud_content, "radicals_fully_fused_label", "全部化字", "Fully fused")
			)
		)
		if compact_radicals_label != null:
			compact_radicals_label.text = _battle_state_text(
				battle_hud_content,
				"radicals_compact_empty",
				"偏旁 0 枚  ·  当前全部化字",
				"Radicals 0  ·  fully fused"
			)
	else:
		radicals_label.text = _battle_state_text(
			battle_hud_content,
			"radicals_stored_detail_format",
			"当前留存 %d 枚偏旁，可继续合字或磨词",
			"Stored %d radicals. Keep fusing glyphs or bring them to the inkstone."
		) % total_count
		if compact_radicals_label != null:
			compact_radicals_label.text = _battle_state_text(
				battle_hud_content,
				"radicals_compact_format",
				"偏旁 %d 枚  ·  %s",
				"Radicals %d  ·  %s"
			) % [total_count, "  ".join(compact_parts)]

	_refresh_route_focus()


func set_skills(recipe_levels: Dictionary, word_levels: Dictionary, word_progress: Dictionary, blade_level: int, hero_id: String) -> void:
	cached_recipe_levels = recipe_levels.duplicate(true)
	cached_word_levels = word_levels.duplicate(true)
	cached_word_progress = word_progress.duplicate(true)
	cached_blade_level = blade_level
	if configured_hero_data.is_empty() or String(configured_hero_data.get("id", "")) != hero_id:
		configured_hero_data = Session.get_hero_data(hero_id)
	if skill_cards_box == null:
		return

	for child in skill_cards_box.get_children():
		child.queue_free()

	var cards: Array[Dictionary] = []
	for recipe_id_variant in Session.RECIPE_ORDER:
		var recipe_id := String(recipe_id_variant)
		var recipe: Dictionary = _localized_recipe_data(recipe_id)
		var recipe_level: int = int(recipe_levels.get(recipe_id, 0))
		var word_id: String = String(recipe.get("word_id", ""))
		var word: Dictionary = {}
		var word_level: int = 0
		if not word_id.is_empty():
			word = _localized_word_data(word_id)
			word_level = int(word_levels.get(word_id, 0))
		if word_level > 0 and not word.is_empty():
			cards.append({
				"glyph": String(word["display"]),
				"badge": _battle_state_text(battle_hud_content, "skill_badge_phrase_art", "成词技能", "Phrase Art"),
				"title": String(word["title"]),
				"detail": String(word["description"]),
				"recipe": "%s + %s" % [String(recipe["radicals"][0]), String(recipe["radicals"][1])],
				"level": "Lv.%d/%d" % [word_level, int(word["max_level"])],
				"color": Color(word["color"])
			})
		elif recipe_level > 0:
			var state_text := "Lv.%d/%d" % [recipe_level, int(recipe["max_level"])]
			if recipe_level >= int(recipe["max_level"]):
				if not word.is_empty():
					state_text = _battle_state_text(
						battle_hud_content,
						"skill_refine_format",
						"磨词 %d/%d",
						"Refine %d/%d"
					) % [int(word_progress.get(word_id, 0)), int(word["unlock_cost"])]
				else:
					state_text = _battle_state_text(battle_hud_content, "skill_complete", "已写满", "Complete")
			cards.append({
				"glyph": String(recipe["display"]),
				"badge": _battle_state_text(battle_hud_content, "skill_badge_glyph_skill", "成字技能", "Glyph Skill"),
				"title": String(recipe["title"]),
				"detail": String(recipe["description"]),
				"recipe": "%s + %s" % [String(recipe["radicals"][0]), String(recipe["radicals"][1])],
				"level": state_text,
				"color": Color(recipe["color"])
			})

	cards.append({
		"glyph": "刀" if hero_id == "xia" else "笔",
		"badge": _battle_state_text(battle_hud_content, "weapon_core_badge", "武器核心", "Weapon Core"),
		"title": _battle_state_text(
			battle_hud_content,
			"weapon_core_title_blade" if hero_id == "xia" else "weapon_core_title_brush",
			"刀势" if hero_id == "xia" else "笔锋",
			"Blade Arc" if hero_id == "xia" else "Brush Edge"
		),
		"detail": _battle_state_text(
			battle_hud_content,
			"weapon_core_detail",
			"独立强化主武器强度，和角色身份直接绑定。",
			"Directly strengthens the primary weapon and stays tied to this hero."
		),
		"recipe": "刂",
		"level": "Lv.%d" % blade_level,
		"color": Color(0.96, 0.54, 0.36, 1.0)
	})

	if cards.is_empty():
		skill_cards_box.add_child(_make_placeholder_card())
		_refresh_compact_skill_chips([])
		return

	for card in cards:
		skill_cards_box.add_child(_make_skill_card(card))
	_refresh_compact_skill_chips(cards)
	_refresh_route_focus()


func set_chamber_carry_state(carry_state: Dictionary) -> void:
	cached_chamber_carry_state = carry_state.duplicate(true)
	if state_overlay == null or not state_overlay.visible:
		return
	if state_mode == "pause" and not last_pause_summary.is_empty():
		state_body_label.text = _build_pause_state_body(
			float(last_pause_summary.get("elapsed", 0.0)),
			int(last_pause_summary.get("kills", 0)),
			int(last_pause_summary.get("threat", 1)),
			int(last_pause_summary.get("level", 1))
		)
	elif state_mode == "game_over" and not last_game_over_data.is_empty():
		state_body_label.text = _build_game_over_state_body(
			String(last_game_over_data.get("summary", "")),
			float(last_game_over_data.get("elapsed", 0.0)),
			int(last_game_over_data.get("kills", 0)),
			int(last_game_over_data.get("threat", 1)),
			int(last_game_over_data.get("level", 1)),
			String(last_game_over_data.get("leaderboard_view", "manual"))
		)


func set_tip(text: String) -> void:
	tip_label.text = _localize_text(text)
	if compact_tip_label != null:
		compact_tip_label.text = _localize_text(text)


func show_guidance_indicator(screen_position: Vector2, text: String, accent: Color, arrow_rotation: float, on_screen: bool = false) -> void:
	if guidance_root == null or guidance_panel == null:
		return

	var panel_size := Vector2(168.0, 48.0) if on_screen else Vector2(180.0, 48.0)
	var root_size := panel_size if on_screen else Vector2(panel_size.x, panel_size.y + 28.0)
	guidance_root.visible = true
	guidance_root.position = screen_position - root_size * 0.5
	guidance_root.size = root_size
	guidance_panel.custom_minimum_size = panel_size
	guidance_panel.size = panel_size
	guidance_panel.position = Vector2.ZERO if on_screen else Vector2(0.0, 24.0)
	guidance_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(
			Color(accent.r * 0.1, accent.g * 0.12, accent.b * 0.16, 0.92),
			Color(accent.r, accent.g, accent.b, 0.72),
			20
		)
	)
	if guidance_text_label != null:
		guidance_text_label.text = text
		guidance_text_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.9, 0.98))
	if guidance_arrow_label != null:
		guidance_arrow_label.visible = not on_screen
		guidance_arrow_label.rotation = arrow_rotation
		guidance_arrow_label.position = Vector2(root_size.x * 0.5 - 22.0, 0.0)
		guidance_arrow_label.add_theme_color_override("font_color", Color(accent.r * 0.28 + 0.7, accent.g * 0.24 + 0.72, accent.b * 0.2 + 0.72, 0.98))


func hide_guidance_indicator() -> void:
	if guidance_root != null:
		guidance_root.visible = false


func _refresh_route_focus() -> void:
	if configured_hero_data.is_empty():
		return
	var localized_hero := _localized_hero_data(configured_hero_data)
	var accent := Color(localized_hero.get("accent", Color(0.86, 0.68, 0.38, 1.0)))
	var summary := _build_route_focus_summary(localized_hero)
	if objective_route_title_label != null:
		objective_route_title_label.text = String(summary.get("title", ""))
	if objective_route_detail_label != null:
		objective_route_detail_label.text = String(summary.get("detail", ""))
	if objective_stage_label != null:
		objective_stage_label.text = String(summary.get("stage", ""))
	if compact_route_label != null:
		compact_route_label.text = String(summary.get("compact", ""))
	if objective_route_tags != null:
		for child in objective_route_tags.get_children():
			child.queue_free()
		var tags_variant: Variant = summary.get("tags", [])
		if tags_variant is Array:
			for tag_variant in tags_variant:
				var tag_text := String(tag_variant).strip_edges()
				if tag_text.is_empty():
					continue
				objective_route_tags.add_child(_make_route_tag_chip(tag_text, accent))


func _build_hero_identity_line(hero_data: Dictionary) -> String:
	var writer_mark := String(hero_data.get("trait_label", "")).strip_edges()
	if writer_mark.is_empty():
		writer_mark = String(hero_data.get("focus", hero_data.get("description", ""))).strip_edges()
	var route_seal := _build_primary_route_seal(hero_data)
	if route_seal.is_empty():
		return _battle_state_text(
			battle_hud_content,
			"identity_mark_format",
			"印记：%s",
			"Mark: %s"
		) % writer_mark if not writer_mark.is_empty() else ""
	if writer_mark.is_empty():
		return _battle_state_text(
			battle_hud_content,
			"identity_route_seal_format",
			"路印：%s",
			"Route Seal: %s"
		) % route_seal
	return _battle_state_text(
		battle_hud_content,
		"identity_mark_and_route_format",
		"印记：%s  ·  路印：%s",
		"Mark: %s  ·  Route Seal: %s"
	) % [writer_mark, route_seal]


func _build_primary_route_seal(hero_data: Dictionary) -> String:
	var route_cards_variant: Variant = hero_data.get("build_route_cards", [])
	if not (route_cards_variant is Array):
		return ""
	var route_cards := route_cards_variant as Array
	if route_cards.is_empty() or not route_cards[0] is Dictionary:
		return ""
	var route_card := route_cards[0] as Dictionary
	var glyph := String(route_card.get("glyph", "")).strip_edges()
	var title := String(route_card.get("title", "")).strip_edges()
	if glyph.is_empty():
		return title
	if title.is_empty():
		return glyph
	return "%s %s" % [glyph, title]


func _build_route_focus_summary(hero_data: Dictionary) -> Dictionary:
	var route_cards: Array[Dictionary] = []
	var route_cards_variant: Variant = hero_data.get("build_route_cards", [])
	if route_cards_variant is Array:
		for card_variant in route_cards_variant:
			if card_variant is Dictionary:
				route_cards.append(card_variant as Dictionary)

	var chosen_route: Dictionary = {}
	if not route_cards.is_empty():
		chosen_route = route_cards[0]
		var best_score := -INF
		for route_card in route_cards:
			var route_score := _score_route_card(route_card)
			if route_score > best_score:
				best_score = route_score
				chosen_route = route_card

	var stage_card := _resolve_route_stage_card(hero_data)
	var route_glyph := String(chosen_route.get("glyph", ""))
	var route_title := String(chosen_route.get("title", ""))
	var route_subtitle := String(chosen_route.get("subtitle", "")).strip_edges()
	var title_parts: Array[String] = []
	if not route_glyph.is_empty():
		title_parts.append(route_glyph)
	if not route_title.is_empty():
		title_parts.append(route_title)
	var title_text := "  ".join(title_parts)
	if not route_subtitle.is_empty():
		title_text += "  ·  %s" % route_subtitle

	var route_detail := String(chosen_route.get("description", "")).strip_edges()
	if route_detail.is_empty():
		route_detail = String(hero_data.get("route_hint", "")).strip_edges()
	if route_detail.is_empty():
		route_detail = _battle_state_text(
			battle_hud_content,
			"route_focus_fallback_detail",
			"让一条路线始终比其余分支领先，后续磨词才有清晰主线。",
			"Keep one route ahead of the other branches so later refinement still has a clear spine."
		)

	var stage_title := String(stage_card.get("title", "")).strip_edges()
	var stage_tags_text := " / ".join(_collect_string_array(stage_card.get("tags", [])))
	var stage_text := ""
	if not stage_title.is_empty():
		stage_text = _battle_state_text(
			battle_hud_content,
			"route_focus_stage_format",
			"当前阶段：%s",
			"Stage: %s"
		) % stage_title
		if not stage_tags_text.is_empty():
			stage_text += "  ·  %s" % stage_tags_text

	var compact_text := title_text
	if not stage_title.is_empty():
		compact_text = ("%s  ·  %s" % [title_text, stage_title]).strip_edges()

	return {
		"glyph": route_glyph,
		"route_title": route_title,
		"route_subtitle": route_subtitle,
		"title": title_text,
		"detail": route_detail,
		"stage": stage_text,
		"compact": compact_text,
		"tags": _collect_string_array(chosen_route.get("tags", []))
	}


func build_intro_identity_reveal() -> Dictionary:
	if configured_hero_data.is_empty():
		return {}

	var localized_hero := _localized_hero_data(configured_hero_data)
	var summary := _build_route_focus_summary(localized_hero)
	var excerpt := String(localized_hero.get("record_excerpt", localized_hero.get("focus", ""))).strip_edges()
	var source := String(localized_hero.get("record_source", "")).strip_edges()
	var detail_lines: Array[String] = []
	if not excerpt.is_empty():
		detail_lines.append("“%s”" % excerpt)

	var route_label := _build_route_hint_text({
		"glyph": String(summary.get("glyph", "")),
		"title": String(summary.get("route_title", "")),
		"subtitle": String(summary.get("route_subtitle", ""))
	})
	var opener := _build_intro_opening_label(String(localized_hero.get("id", "")))
	var route_parts: Array[String] = []
	if not route_label.is_empty():
		route_parts.append(
			_battle_state_text(
				battle_hud_content,
				"intro_route_seal_format",
				"主路线印：%s",
				"Route Seal: %s"
			) % route_label
		)
	if not opener.is_empty():
		route_parts.append(
			_battle_state_text(
				battle_hud_content,
				"intro_opening_format",
				"起笔：%s",
				"Opener: %s"
			) % opener
		)
	if not route_parts.is_empty():
		detail_lines.append("  ·  ".join(route_parts))

	if not source.is_empty():
		detail_lines.append(
			_battle_state_text(
				battle_hud_content,
				"intro_source_format",
				"出处 · %s",
				"Source · %s"
			) % source
		)

	var title := String(localized_hero.get("record_title", localized_hero.get("name", ""))).strip_edges()
	if title.is_empty():
		title = String(localized_hero.get("name", ""))

	return {
		"title": title,
		"detail": "\n".join(detail_lines),
		"glyph": String(summary.get("glyph", localized_hero.get("glyph", "")))
	}


func build_intro_callout_detail() -> String:
	if configured_hero_data.is_empty():
		return ""

	var localized_hero := _localized_hero_data(configured_hero_data)
	var detail_lines: Array[String] = []
	var identity_parts: Array[String] = []
	var writer_mark := String(localized_hero.get("trait_label", "")).strip_edges()
	if writer_mark.is_empty():
		writer_mark = String(localized_hero.get("focus", localized_hero.get("description", ""))).strip_edges()
	if not writer_mark.is_empty():
		identity_parts.append(
			_battle_state_text(
				battle_hud_content,
				"callout_mark_format",
				"印记 · %s",
				"Mark · %s"
			) % writer_mark
		)
	var route_seal := _build_primary_route_seal(localized_hero)
	if not route_seal.is_empty():
		identity_parts.append(
			_battle_state_text(
				battle_hud_content,
				"callout_route_format",
				"路印 · %s",
				"Route Seal · %s"
			) % route_seal
		)
	if not identity_parts.is_empty():
		detail_lines.append("  ·  ".join(identity_parts))

	var source := String(localized_hero.get("record_source", "")).strip_edges()
	if not source.is_empty():
		detail_lines.append(
			_battle_state_text(
				battle_hud_content,
				"intro_source_format",
				"出处 · %s",
				"Source · %s"
			) % source
		)
	return "\n".join(detail_lines)


func _build_intro_opening_label(hero_id: String) -> String:
	var starting_radicals: Array[String] = Session.get_hero_starting_radicals(hero_id)
	if starting_radicals.is_empty():
		return _battle_state_text(
			battle_hud_content,
			"no_fixed_opener",
			"无固定起手",
			"No fixed opener"
		)
	return " / ".join(starting_radicals)


func _build_route_hint_text(card: Dictionary) -> String:
	var glyph := String(card.get("glyph", "")).strip_edges()
	var title := String(card.get("title", "")).strip_edges()
	var subtitle := String(card.get("subtitle", "")).strip_edges()
	var label := title
	if not glyph.is_empty():
		label = ("%s %s" % [glyph, title]).strip_edges()
	if not subtitle.is_empty():
		if label.is_empty():
			label = subtitle
		else:
			label += " · %s" % subtitle
	return label


func _build_pause_state_body(elapsed: float, kills: int, threat: int, level: int) -> String:
	var state_content := FrontEndContent.battle_state_content()
	var lines: Array[String] = []
	var compact_copy := _should_use_micro_layout() or _should_use_web_tight_layout()
	if compact_copy:
		lines.append(_battle_state_text(state_content, "summary_title", "当前进度", "Current run"))
		lines.append(
			_battle_state_text(
				state_content,
				"summary_compact_format",
				"存活 %s  ·  波次 %d  ·  击破 %d  ·  Lv.%d",
				"Time %s  ·  W%d  ·  K%d  ·  Lv.%d"
			)
			% [_format_time(elapsed), threat, kills, level]
		)
	else:
		lines.append(_battle_state_text(state_content, "summary_title", "当前进度", "Current run"))
		lines.append(
			_battle_state_text(state_content, "summary_time_format", "存活 %s", "Time %s")
			% _format_time(elapsed)
		)
		lines.append(
			_battle_state_text(
				state_content,
				"summary_stats_format",
				"波次 %d   击破 %d   等级 Lv.%d",
				"Wave %d   Kills %d   Level Lv.%d"
			)
			% [threat, kills, level]
		)
	var route_lines := _build_route_focus_state_lines(compact_copy)
	if not route_lines.is_empty():
		lines.append("")
		lines.append_array(route_lines)
	var relic_lines := _build_relic_migration_state_lines(compact_copy)
	if not relic_lines.is_empty():
		lines.append("")
		lines.append_array(relic_lines)
	var carry_lines := _build_chamber_carry_state_lines(compact_copy)
	if not carry_lines.is_empty():
		lines.append("")
		lines.append_array(carry_lines)
	lines.append("")
	lines.append(
		_battle_state_text(
			state_content,
			"pause_controls_compact" if compact_copy else "pause_controls_full",
			"按 E / Esc 继续，R 重开" if compact_copy else "按 E 或 Esc 继续，按 R 立即重开。",
			"E / Esc resume · R restart" if compact_copy else "Press E or Esc to resume, or R to restart immediately."
		)
	)
	return "\n".join(lines)


func _build_game_over_state_body(summary: String, elapsed: float, kills: int, threat: int, level: int, leaderboard_view: String) -> String:
	var state_content := FrontEndContent.battle_state_content()
	var lines: Array[String] = []
	var compact_copy := _should_use_micro_layout() or _should_use_web_tight_layout()
	var leaderboard_content := FrontEndContent.local_leaderboard_content()
	var trimmed_summary := summary.strip_edges()
	if not trimmed_summary.is_empty():
		lines.append(trimmed_summary)
		lines.append("")
	lines.append(_localize_text(String(leaderboard_content.get("result_label_test" if leaderboard_view == "test" else "result_label_manual", "本轮试阵" if leaderboard_view == "test" else "本轮残卷"))))
	lines.append(
		(
			_battle_state_text(
				state_content,
				"summary_compact_format",
				"存活 %s  ·  波次 %d  ·  击破 %d  ·  Lv.%d",
				"Time %s  ·  W%d  ·  K%d  ·  Lv.%d"
			)
			if compact_copy
			else _battle_state_text(state_content, "summary_time_format", "存活 %s", "Time %s")
		)
		% ([_format_time(elapsed), threat, kills, level] if compact_copy else [_format_time(elapsed)])
	)
	if not compact_copy:
		lines.append(
			_battle_state_text(
				state_content,
				"summary_stats_format",
				"波次 %d   击破 %d   等级 Lv.%d",
				"Wave %d   Kills %d   Level Lv.%d"
			)
			% [threat, kills, level]
		)
	var route_lines := _build_route_focus_state_lines(compact_copy)
	if not route_lines.is_empty():
		lines.append("")
		lines.append_array(route_lines)
	var relic_lines := _build_relic_migration_state_lines(compact_copy)
	if not relic_lines.is_empty():
		lines.append("")
		lines.append_array(relic_lines)
	var carry_lines := _build_chamber_carry_state_lines(compact_copy)
	if not carry_lines.is_empty():
		lines.append("")
		lines.append_array(carry_lines)
	return "\n".join(lines)


func _build_route_focus_state_lines(compact_copy: bool = false) -> Array[String]:
	if configured_hero_data.is_empty():
		var empty_lines: Array[String] = []
		return empty_lines
	var localized_hero := _localized_hero_data(configured_hero_data)
	var summary := _build_route_focus_summary(localized_hero)
	var lines: Array[String] = []
	lines.append(_battle_state_text(battle_hud_content, "route_focus_state_title", "路线参考", "Route Focus"))
	var title_key := "compact" if compact_copy else "title"
	var title := String(summary.get(title_key, "")).strip_edges()
	if not title.is_empty():
		lines.append(_truncate_overlay_text(title, 54 if _is_english() else 24))
	if compact_copy:
		lines.append(_build_route_progress_text())
		return lines
	var stage := String(summary.get("stage", "")).strip_edges()
	if not stage.is_empty():
		lines.append(stage)
	lines.append(_build_route_progress_text())
	var detail := String(summary.get("detail", "")).strip_edges()
	if not detail.is_empty():
		lines.append(detail)
	return lines


func _build_relic_migration_state_lines(compact_copy: bool = false) -> Array[String]:
	var lines: Array[String] = []
	lines.append(_battle_state_text(battle_hud_content, "relic_migration_title", "遗物 / 神器", "Relics / Artifacts"))
	var detail := _battle_state_text(
		battle_hud_content,
		"relic_migration_compact" if compact_copy else "relic_migration_detail",
		"待迁回  ·  宝箱当前仍给即时补给" if compact_copy else "source 的暂停 / 结算会把已持遗物一起摊开。Godot 当前宝箱仍只掉即时补给，所以这条成长线还在迁移中。",
		"Pending port  ·  chests still grant direct pickups" if compact_copy else "The source pause/result views lay owned relics out alongside the build. Godot chests still grant direct pickups only, so this growth lane is still mid-migration."
	)
	lines.append(
		_truncate_overlay_text(detail, 60 if _is_english() else 28)
		if compact_copy
		else detail
	)
	return lines


func _build_chamber_carry_state_lines(compact_copy: bool = false) -> Array[String]:
	var modifier_id := String(cached_chamber_carry_state.get("modifier_id", "")).strip_edges()
	var lean_radicals := _build_chamber_carry_radicals()
	if modifier_id.is_empty() and lean_radicals.is_empty():
		var empty_lines: Array[String] = []
		return empty_lines

	var state_content := FrontEndContent.battle_state_content()
	var lines: Array[String] = []
	lines.append(_battle_state_text(state_content, "carry_state_title", "卷间余势", "Interlude Carry"))
	var modifier_line := _build_chamber_modifier_state_text(modifier_id, compact_copy)
	if not modifier_line.is_empty():
		lines.append(
			_truncate_overlay_text(modifier_line, 60 if _is_english() else 28)
			if compact_copy
			else modifier_line
		)
	if not lean_radicals.is_empty():
		var lean_line := _battle_state_text(
			state_content,
			"carry_lean_compact_format" if compact_copy else "carry_lean_format",
			"偏向：%s" if compact_copy else "偏旁偏向：%s",
			"Lean: %s" if compact_copy else "Draft lean: %s"
		) % " / ".join(lean_radicals)
		lines.append(
			_truncate_overlay_text(lean_line, 60 if _is_english() else 28)
			if compact_copy
			else lean_line
		)
	return lines


func _build_chamber_carry_radicals() -> Array[String]:
	var radicals: Array[String] = []
	var radicals_variant: Variant = cached_chamber_carry_state.get("draft_radicals", [])
	if radicals_variant is Array:
		for radical_variant in radicals_variant:
			var radical := String(radical_variant)
			if radical.is_empty() or radicals.has(radical):
				continue
			radicals.append(radical)
	return radicals


func _build_chamber_modifier_state_text(modifier_id: String, compact_copy: bool = false) -> String:
	if modifier_id.is_empty():
		return ""
	var state_content := FrontEndContent.battle_state_content()
	match modifier_id:
		"reward_supply":
			return _battle_state_text(
				state_content,
				"carry_modifier_reward_supply_compact" if compact_copy else "carry_modifier_reward_supply",
				"补给余势：敌群更易掉残纸 / 战印" if compact_copy else "补给余势：下一位卷主前，压境敌群更容易掉落残纸与战印。",
				"Supply carry: more paper and seal drops" if compact_copy else "Supply carry: until the next scroll lord, pressure enemies are more likely to drop paper scraps and seals."
			)
		"scroll_echo":
			return _battle_state_text(
				state_content,
				"carry_modifier_scroll_echo_compact" if compact_copy else "carry_modifier_scroll_echo",
				"残卷回响：敌群补残纸，精英可掉疾书令" if compact_copy else "残卷回响：下一位卷主前，压境敌群会额外回响残纸，精英也可能掉落疾书令。",
				"Scroll Echo: extra paper, elite Swift Edicts" if compact_copy else "Scroll Echo: until the next scroll lord, pressure enemies echo extra paper scraps and elites can drop Swift Edict."
			)
		"short_rest":
			return _battle_state_text(
				state_content,
				"carry_modifier_short_rest_compact" if compact_copy else "carry_modifier_short_rest",
				"歇笔余势：后续推进再补一口气" if compact_copy else "歇笔余势：下一位卷主前，后续字潮推进仍会回补一小口气。",
				"Recovery carry: later pushes echo healing" if compact_copy else "Recovery carry: until the next scroll lord, later wave pushes still echo a smaller heal."
			)
	return ""


func _build_route_progress_text() -> String:
	var radical_total := 0
	for radical_variant in Session.RADICAL_ORDER:
		radical_total += int(cached_radicals.get(String(radical_variant), 0))

	var formed_recipe_count := 0
	for recipe_id_variant in Session.RECIPE_ORDER:
		if int(cached_recipe_levels.get(String(recipe_id_variant), 0)) > 0:
			formed_recipe_count += 1

	var formed_word_count := 0
	for word_id_variant in Session.WORD_ORDER:
		if int(cached_word_levels.get(String(word_id_variant), 0)) > 0:
			formed_word_count += 1

	return _battle_state_text(
		battle_hud_content,
		"route_progress_format",
		"构筑进度：偏旁 %d  ·  成字 %d  ·  词技 %d",
		"Build: radicals %d  ·  glyphs %d  ·  phrases %d"
	) % [radical_total, formed_recipe_count, formed_word_count]


func _resolve_route_stage_card(hero_data: Dictionary) -> Dictionary:
	var cards: Array[Dictionary] = []
	var cards_variant: Variant = hero_data.get("progression_cards", [])
	if cards_variant is Array:
		for card_variant in cards_variant:
			if card_variant is Dictionary:
				cards.append(card_variant as Dictionary)
	if cards.is_empty():
		return {}

	var formed_recipe_count := 0
	var maxed_recipe_count := 0
	for recipe_id_variant in Session.RECIPE_ORDER:
		var recipe_id := String(recipe_id_variant)
		var recipe_level := int(cached_recipe_levels.get(recipe_id, 0))
		if recipe_level <= 0:
			continue
		formed_recipe_count += 1
		if recipe_level >= int(Session.get_recipe_data(recipe_id).get("max_level", 1)):
			maxed_recipe_count += 1

	var formed_word_count := 0
	var word_progress_total := 0
	for word_id_variant in Session.WORD_ORDER:
		var word_id := String(word_id_variant)
		var word_level := int(cached_word_levels.get(word_id, 0))
		if word_level > 0:
			formed_word_count += 1
		word_progress_total += int(cached_word_progress.get(word_id, 0))

	if formed_word_count > 0 or word_progress_total > 0 or maxed_recipe_count > 0:
		return cards[min(2, cards.size() - 1)]
	if formed_recipe_count > 0:
		return cards[min(1, cards.size() - 1)]
	return cards[0]


func _score_route_card(route_card: Dictionary) -> float:
	var score := 0.0
	var tags_variant: Variant = route_card.get("tags", [])
	if tags_variant is Array:
		for tag_variant in tags_variant:
			score += _score_route_tag(String(tag_variant))
	return score


func _score_route_tag(tag_text: String) -> float:
	var score := 0.0
	for token in _split_route_tokens(tag_text):
		score += _score_route_token(token)
	return score


func _split_route_tokens(tag_text: String) -> Array[String]:
	var normalized := tag_text.replace("／", "/").replace("、", "/").replace("，", "/").replace(",", "/")
	var tokens: Array[String] = []
	for piece in normalized.split("/"):
		var trimmed := piece.strip_edges()
		if not trimmed.is_empty():
			tokens.append(trimmed)
	return tokens


func _score_route_token(token: String) -> float:
	var score := 0.0
	var stored_count := int(cached_radicals.get(token, 0))
	if stored_count > 0:
		score += float(stored_count) * 1.1
	if token == "刂" and cached_blade_level > 0:
		score += float(cached_blade_level) * 1.15

	for recipe_id_variant in Session.RECIPE_ORDER:
		var recipe_id := String(recipe_id_variant)
		var recipe := Session.get_recipe_data(recipe_id)
		var recipe_level := int(cached_recipe_levels.get(recipe_id, 0))
		var word_id := String(recipe.get("word_id", ""))
		var word_level := int(cached_word_levels.get(word_id, 0))
		var word_progress := int(cached_word_progress.get(word_id, 0))
		var radicals := _collect_string_array(recipe.get("radicals", []))
		if recipe_level > 0:
			if token == String(recipe.get("display", "")):
				score += 2.0 + float(recipe_level) * 0.9
			if radicals.has(token):
				score += 0.7 + float(recipe_level) * 0.35
		if not word_id.is_empty() and word_level > 0:
			var word := Session.get_word_data(word_id)
			if token == String(word.get("display", "")):
				score += 3.0 + float(word_level)
			if token == String(recipe.get("display", "")):
				score += 1.35 + float(word_level) * 0.5
			if radicals.has(token):
				score += 0.95 + float(word_level) * 0.45
		elif not word_id.is_empty() and word_progress > 0 and recipe_level >= int(recipe.get("max_level", 1)):
			var pending_word := Session.get_word_data(word_id)
			if token == String(pending_word.get("display", "")):
				score += 1.35 + float(word_progress) * 0.45
	return score


func _collect_string_array(value: Variant) -> Array[String]:
	var items: Array[String] = []
	if value is Array:
		for item_variant in value:
			var text := String(item_variant).strip_edges()
			if not text.is_empty():
				items.append(text)
	return items


func push_event_log(text: String, color: Color = Color(0.88, 0.92, 0.97, 1.0)) -> void:
	var clean_text := text.strip_edges()
	if clean_text.is_empty():
		return

	event_log_entries.insert(0, {
		"text": clean_text,
		"color": color
	})
	while event_log_entries.size() > EVENT_LOG_LIMIT:
		event_log_entries.pop_back()
	_refresh_event_log_views()


func _refresh_event_log_views() -> void:
	if event_log_list == null and compact_event_list == null:
		return

	if event_log_list != null:
		for child in event_log_list.get_children():
			event_log_list.remove_child(child)
			child.queue_free()
	if compact_event_list != null:
		for child in compact_event_list.get_children():
			compact_event_list.remove_child(child)
			child.queue_free()

	if event_log_entries.is_empty():
		var hud_content := FrontEndContent.battle_hud_content()
		var placeholder_text := _battle_state_text(hud_content, "event_log_placeholder", "波次、卷主、合字和拾取会记在这里。", "Wave shifts, bosses, fused glyphs, and pickups will appear here.")
		if event_log_list != null:
			event_log_list.add_child(_make_event_log_row(placeholder_text, Color(0.52, 0.64, 0.76, 1.0), false, true))
		if compact_event_list != null:
			compact_event_list.add_child(_make_event_log_row(placeholder_text, Color(0.52, 0.64, 0.76, 1.0), true, true))
		if compact_event_panel != null:
			compact_event_panel.visible = compact_layout and not _should_hide_compact_event_panel()
		return

	if event_log_list != null:
		var desktop_visible: int = mini(event_log_entries.size(), EVENT_LOG_DESKTOP_VISIBLE)
		for index in range(desktop_visible):
			var entry: Dictionary = event_log_entries[index]
			event_log_list.add_child(
				_make_event_log_row(
					String(entry.get("text", "")),
					Color(entry.get("color", Color(0.88, 0.92, 0.97, 1.0))),
					false
				)
			)

	if compact_event_list != null:
		var compact_visible: int = mini(event_log_entries.size(), EVENT_LOG_COMPACT_VISIBLE)
		for index in range(compact_visible):
			var entry: Dictionary = event_log_entries[index]
			compact_event_list.add_child(
				_make_event_log_row(
					String(entry.get("text", "")),
					Color(entry.get("color", Color(0.88, 0.92, 0.97, 1.0))),
					true
				)
			)
	if compact_event_panel != null:
		compact_event_panel.visible = compact_layout and not _should_hide_compact_event_panel()


func _refresh_compact_skill_chips(cards: Array[Dictionary]) -> void:
	if compact_skill_chip_container == null:
		return

	for child in compact_skill_chip_container.get_children():
		child.queue_free()

	if cards.is_empty():
		compact_skill_chip_container.add_child(
			_make_compact_skill_chip(
				"字",
				_battle_state_text(battle_hud_content, "compact_skill_waiting_title", "待成字", "Waiting"),
				_battle_state_text(battle_hud_content, "compact_skill_waiting_level", "预备", "Ready"),
				Color(0.44, 0.58, 0.72, 1.0)
			)
		)
		return

	var visible_count: int = mini(cards.size(), 4)
	for index in range(visible_count):
		var card := cards[index]
		compact_skill_chip_container.add_child(
			_make_compact_skill_chip(
				String(card.get("glyph", "字")),
				String(card.get("title", "")),
				String(card.get("level", "")),
				Color(card.get("color", Color(0.44, 0.58, 0.72, 1.0)))
			)
		)
	var hidden_count: int = cards.size() - visible_count
	if hidden_count > 0:
		compact_skill_chip_container.add_child(
			_make_compact_skill_chip(
				"+",
				_battle_state_text(battle_hud_content, "compact_skill_more", "更多技能字", "More Skills"),
				"+%d" % hidden_count,
				Color(0.62, 0.78, 0.94, 1.0)
			)
		)


func show_banner(text: String, color: Color, duration: float = 2.4) -> void:
	banner_label.text = text
	banner_color = color
	banner_label.modulate = color
	banner_label.visible = true
	banner_time = duration


func show_reveal(kicker: String, title: String, detail: String, accent: Color, glyph: String = "", duration: float = 2.8) -> void:
	if reveal_panel == null:
		return

	reveal_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(
			Color(accent.r * 0.1, accent.g * 0.1, accent.b * 0.14, 0.9),
			Color(accent.r, accent.g, accent.b, 0.78),
			28
		)
	)
	if reveal_kicker_label != null:
		reveal_kicker_label.text = kicker
		reveal_kicker_label.add_theme_color_override("font_color", Color(accent.r * 0.24 + 0.72, accent.g * 0.22 + 0.72, accent.b * 0.18 + 0.72, 0.96))
	if reveal_glyph_label != null:
		reveal_glyph_label.text = glyph
		reveal_glyph_label.visible = not glyph.strip_edges().is_empty()
		reveal_glyph_label.add_theme_color_override("font_color", Color(accent.r * 0.34 + 0.64, accent.g * 0.3 + 0.64, accent.b * 0.22 + 0.64, 1.0))
	if reveal_title_label != null:
		reveal_title_label.text = title
		reveal_title_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.9, 0.98))
	if reveal_detail_label != null:
		reveal_detail_label.text = detail
		reveal_detail_label.visible = not detail.strip_edges().is_empty()
		reveal_detail_label.add_theme_color_override("font_color", Color(0.88, 0.93, 0.97, 0.96))
	reveal_panel.visible = true
	reveal_panel.modulate = Color(1.0, 1.0, 1.0, 1.0)
	reveal_duration = max(duration, 0.9)
	reveal_time = reveal_duration


func show_callout(title: String, text: String, accent: Color, duration: float = 3.0, detail: String = "") -> void:
	if callout_panel == null:
		return

	var trimmed_detail := detail.strip_edges()
	callout_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.14, accent.g * 0.14, accent.b * 0.18, 0.9), Color(accent.r, accent.g, accent.b, 0.54), 24))
	if callout_title_label != null:
		callout_title_label.text = title
		callout_title_label.add_theme_color_override("font_color", Color(accent.r * 0.34 + 0.66, accent.g * 0.3 + 0.66, accent.b * 0.26 + 0.66, 0.96))
	if callout_text_label != null:
		callout_text_label.text = text
		callout_text_label.add_theme_color_override("font_color", Color(0.98, 0.96, 0.91, 0.98))
	if callout_detail_label != null:
		callout_detail_label.visible = not trimmed_detail.is_empty()
		callout_detail_label.text = trimmed_detail
		callout_detail_label.add_theme_color_override("font_color", Color(accent.r * 0.18 + 0.72, accent.g * 0.18 + 0.76, accent.b * 0.16 + 0.78, 0.94))
	callout_panel.visible = true
	callout_panel.modulate = Color(1.0, 1.0, 1.0, 1.0)
	callout_time = max(duration, 0.8)
	_refresh_layout()


func set_soundtrack(title: String, mood: String, cue: String, accent: Color, announce: bool = false) -> void:
	var detail_text := mood.strip_edges()
	if not cue.strip_edges().is_empty():
		if detail_text.is_empty():
			detail_text = cue
		else:
			detail_text = "%s · %s" % [detail_text, cue]

	_apply_soundtrack_style(soundtrack_panel, accent, 0.92, 0.46)
	if soundtrack_title_label != null:
		soundtrack_title_label.text = title
	if soundtrack_detail_label != null:
		soundtrack_detail_label.text = detail_text

	if not announce or soundtrack_toast == null:
		return

	_apply_soundtrack_style(soundtrack_toast, accent, 0.96, 0.72)
	if soundtrack_toast_title_label != null:
		soundtrack_toast_title_label.text = title
	if soundtrack_toast_detail_label != null:
		soundtrack_toast_detail_label.text = detail_text
	soundtrack_toast.visible = true
	soundtrack_toast.modulate = Color(1.0, 1.0, 1.0, 1.0)
	soundtrack_toast_time = 3.0


func show_boss(boss_name: String, glyph: String, tint: Color, maximum: float) -> void:
	if boss_panel == null:
		return
	boss_panel.visible = true
	boss_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tint.r * 0.12, tint.g * 0.12, tint.b * 0.16, 0.96), Color(tint.r, tint.g, tint.b, 0.72), 24))
	boss_name_label.text = "%s  %s" % [glyph, boss_name]
	boss_detail_label.text = _battle_state_text(battle_hud_content, "boss_descends", "卷主降阵", "Boss Descends")
	boss_bar.add_theme_stylebox_override("fill", _make_fill_style(tint, 10))
	boss_bar.max_value = max(1.0, maximum)
	boss_bar.value = maximum


func set_boss_health(current: float, maximum: float) -> void:
	if boss_panel == null:
		return
	boss_panel.visible = true
	boss_bar.max_value = max(1.0, maximum)
	boss_bar.value = clamp(current, 0.0, maximum)
	boss_detail_label.text = _battle_state_text(
		battle_hud_content,
		"boss_descends_health_format",
		"卷主降阵   %d / %d",
		"Boss Descends   %d / %d"
	) % [int(ceil(current)), int(ceil(maximum))]


func hide_boss() -> void:
	if boss_panel != null:
		boss_panel.visible = false


func show_radical_choices(level: int, choices: Array[Dictionary], pending_count: int) -> void:
	choice_mode = "radical"
	choice_pending_count = pending_count
	choice_title_label.text = _battle_state_text(
		battle_hud_content,
		"choice_radical_title_format",
		"字力突破  Lv.%d",
		"Ink Breakthrough  Lv.%d"
	) % level
	choice_hint_label.text = _build_radical_choice_hint(pending_count)
	overlay_label.visible = false
	_hide_reveal()
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
	choice_pending_count = 0
	choice_title_label.text = _battle_state_text(
		battle_hud_content,
		"choice_word_title",
		"砚台磨词",
		"Inkstone Refinement"
	)
	choice_hint_label.text = _build_word_choice_hint()
	overlay_label.visible = false
	_hide_reveal()
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
	choice_pending_count = 0
	choice_overlay.visible = false


func show_pause_menu(elapsed: float, kills: int, threat: int, level: int) -> void:
	var state_content := FrontEndContent.battle_state_content()
	hide_choice_overlay()
	hide_map_overlay()
	overlay_label.visible = false
	_hide_reveal()
	_hide_state_name_editor()
	_hide_state_preview()
	_apply_state_overlay_theme(Color(0.94, 0.7, 0.4, 1.0))
	last_pause_summary = {
		"elapsed": elapsed,
		"kills": kills,
		"threat": threat,
		"level": level
	}
	state_mode = "pause"
	state_title_label.text = _battle_state_text(state_content, "pause_title", "墨阵暂歇", "Inkfield Interlude")
	state_body_label.text = _build_pause_state_body(elapsed, kills, threat, level)
	_configure_state_button(state_primary_button, _battle_state_text(state_content, "action_resume_battle", "继续战斗", "Resume Battle"), Callable(self, "_emit_pause_resume"))
	_configure_state_button(state_secondary_button, _battle_state_text(state_content, "action_open_settings", "战场布置", "Battle Setup"), Callable(self, "_show_settings_menu"))
	_configure_state_button(state_tertiary_button, _battle_state_text(state_content, "action_restart_run", "重新开始", "Restart Run"), Callable(self, "_emit_restart"))
	_configure_state_button(state_quaternary_button, _battle_state_text(state_content, "action_return_menu", "返回菜单", "Return to Menu"), Callable(self, "_emit_return_menu"))
	_hide_state_button(state_quinary_button)
	_hide_state_button(state_senary_button)
	state_overlay.visible = true


func show_chamber_transition(
	title: String,
	body: String,
	preview_lines: Array[String] = [],
	accent: Color = Color(0.94, 0.7, 0.4, 1.0)
) -> void:
	var state_content := FrontEndContent.battle_state_content()
	hide_choice_overlay()
	hide_map_overlay()
	overlay_label.visible = false
	_hide_state_name_editor()
	_apply_state_overlay_theme(accent)
	state_mode = "chamber_transition"
	state_title_label.text = title
	state_body_label.text = body
	_show_state_preview(
		_battle_state_text(battle_hud_content, "state_preview_title", "下一段预览", "Next Preview"),
		preview_lines
	)
	_configure_state_button(state_primary_button, _battle_state_text(state_content, "action_continue_deeper", "续卷入深层", "Continue Deeper"), Callable(self, "_emit_pause_resume"))
	_configure_state_button(state_secondary_button, _battle_state_text(state_content, "action_restart_run", "重新开始", "Restart Run"), Callable(self, "_emit_restart"))
	_configure_state_button(state_tertiary_button, _battle_state_text(state_content, "action_return_menu", "返回菜单", "Return to Menu"), Callable(self, "_emit_return_menu"))
	_hide_state_button(state_quaternary_button)
	_hide_state_button(state_quinary_button)
	_hide_state_button(state_senary_button)
	state_overlay.visible = true


func show_chamber_interlude(
	title: String,
	body: String,
	options: Array[Dictionary],
	preview_lines: Array[String] = [],
	accent: Color = Color(0.94, 0.7, 0.4, 1.0)
) -> void:
	var state_content := FrontEndContent.battle_state_content()
	hide_choice_overlay()
	hide_map_overlay()
	overlay_label.visible = false
	_hide_state_name_editor()
	_apply_state_overlay_theme(accent)
	state_mode = "chamber_interlude"
	state_title_label.text = title
	state_body_label.text = body
	_show_state_preview(
		_battle_state_text(battle_hud_content, "state_preview_title", "下一段预览", "Next Preview"),
		preview_lines
	)

	var option_buttons := [state_primary_button, state_secondary_button, state_tertiary_button]
	for index in range(option_buttons.size()):
		var option_button: Button = option_buttons[index]
		if index < options.size():
			var option: Dictionary = options[index]
			var option_id := String(option.get("id", ""))
			_configure_state_button(
				option_button,
				String(option.get("label", "")),
				Callable(self, "_emit_chamber_interlude_selection").bind(option_id)
			)
		else:
			_hide_state_button(option_button)

	_configure_state_button(state_quaternary_button, _battle_state_text(state_content, "action_restart_run", "重新开始", "Restart Run"), Callable(self, "_emit_restart"))
	_configure_state_button(state_quinary_button, _battle_state_text(state_content, "action_return_menu", "返回菜单", "Return to Menu"), Callable(self, "_emit_return_menu"))
	_hide_state_button(state_senary_button)
	state_overlay.visible = true


func hide_state_overlay() -> void:
	state_mode = ""
	if state_overlay != null:
		state_overlay.visible = false
	_hide_state_preview()
	_apply_state_overlay_theme(Color(0.94, 0.7, 0.4, 1.0))


func _show_settings_menu() -> void:
	var state_content := FrontEndContent.battle_state_content()
	state_mode = "settings"
	_apply_state_overlay_theme(Color(0.94, 0.7, 0.4, 1.0))
	state_title_label.text = _battle_state_text(state_content, "settings_title", "战场布置", "Battle Setup")
	state_body_label.text = _build_settings_body()
	_hide_state_name_editor()
	_hide_state_preview()
	overlay_label.visible = false
	_hide_reveal()
	_configure_state_button(state_primary_button, _battle_state_text(state_content, "settings_performance_format", "演出档：%s", "Performance: %s") % _performance_mode_label(), Callable(self, "_cycle_performance_mode"))
	_configure_state_button(state_secondary_button, _battle_state_text(state_content, "settings_visual_effects_format", "视觉字效：%s", "Glyph FX: %s") % _visual_effects_label(), Callable(self, "_toggle_visual_effects"))
	_configure_state_button(state_tertiary_button, _battle_state_text(state_content, "settings_enemy_health_bars_format", "敌方血条：%s", "Enemy Health Bars: %s") % _enemy_health_bar_label(), Callable(self, "_toggle_enemy_health_bars"))
	_configure_state_button(state_quaternary_button, _battle_state_text(state_content, "settings_ambient_density_format", "环境字影：%s", "Ambient Glyphs: %s") % _ambient_density_label(), Callable(self, "_cycle_ambient_density"))
	_configure_state_button(state_quinary_button, _battle_state_text(state_content, "settings_enemy_detail_format", "远敌细节：%s", "Distant Enemy Detail: %s") % _enemy_detail_label(), Callable(self, "_toggle_enemy_detail"))
	_configure_state_button(state_senary_button, _battle_state_text(state_content, "action_back_to_pause", "返回暂停", "Back to Pause"), Callable(self, "_return_to_pause_menu"))
	state_overlay.visible = true


func set_game_over(
	summary: String,
	elapsed: float = 0.0,
	kills: int = 0,
	threat: int = 1,
	level: int = 1,
	leaderboard_view: String = "manual"
) -> void:
	hide_choice_overlay()
	hide_map_overlay()
	var normalized_view := _normalize_local_leaderboard_view(leaderboard_view)
	_hide_state_preview()
	state_mode = "game_over"
	_apply_state_overlay_theme(Color(0.94, 0.7, 0.4, 1.0))
	last_game_over_data = {
		"summary": summary,
		"elapsed": elapsed,
		"kills": kills,
		"threat": threat,
		"level": level,
		"leaderboard_view": normalized_view
	}
	var leaderboard_content := FrontEndContent.local_leaderboard_content()
	state_title_label.text = _battle_state_text(FrontEndContent.battle_state_content(), "game_over_title", "字海沉没", "The Ink Sea Sinks")
	state_body_label.text = _build_game_over_state_body(summary, elapsed, kills, threat, level, normalized_view)
	var leaderboard_detail := _localize_text(String(leaderboard_content.get("game_over_alias_detail_manual", "本轮记录已经写入主卷榜。你可以直接改成想显示的名字；留空则保留玩家名帖里的默认署名。")))
	if normalized_view == "test":
		leaderboard_detail = _localize_text(String(leaderboard_content.get("game_over_alias_detail_test", "本轮试阵记录已经写入试阵榜，不会影响主卷榜排序。你可以直接改成想显示的名字；留空则保留玩家名帖里的默认署名。")))
	_show_state_name_editor(
		_localize_text(String(leaderboard_content.get("run_alias_title", "战绩署名"))),
		leaderboard_detail
	)
	var state_content := FrontEndContent.battle_state_content()
	_configure_state_button(state_primary_button, _battle_state_text(state_content, "action_restart_run", "重新开始", "Restart Run"), Callable(self, "_emit_restart"))
	_configure_state_button(state_secondary_button, _battle_state_text(state_content, "action_return_menu", "返回菜单", "Return to Menu"), Callable(self, "_emit_return_menu"))
	_configure_state_button(
		state_tertiary_button,
		_localize_text(String(leaderboard_content.get("view_board_format", "查看%s"))) % _localize_text(String(leaderboard_content.get("test_board" if normalized_view == "test" else "main_board", "试阵榜" if normalized_view == "test" else "主卷榜"))),
		Callable(self, "_show_local_leaderboard")
	)
	_hide_state_button(state_quaternary_button)
	_hide_state_button(state_quinary_button)
	_hide_state_button(state_senary_button)
	overlay_label.visible = false
	_hide_reveal()
	state_overlay.visible = true


func _show_game_over_summary() -> void:
	if last_game_over_data.is_empty():
		return
	set_game_over(
		String(last_game_over_data.get("summary", "")),
		float(last_game_over_data.get("elapsed", 0.0)),
		int(last_game_over_data.get("kills", 0)),
		int(last_game_over_data.get("threat", 1)),
		int(last_game_over_data.get("level", 1)),
		String(last_game_over_data.get("leaderboard_view", "manual"))
	)


func _show_local_leaderboard() -> void:
	var last_entry: Dictionary = Session.get_last_recorded_leaderboard_run()
	if not last_entry.is_empty():
		local_leaderboard_view = Session.get_local_leaderboard_view(last_entry)
	else:
		local_leaderboard_view = "manual"
	_refresh_local_leaderboard_overlay()


func _show_manual_leaderboard() -> void:
	local_leaderboard_view = "manual"
	_refresh_local_leaderboard_overlay()


func _show_test_leaderboard() -> void:
	local_leaderboard_view = "test"
	_refresh_local_leaderboard_overlay()


func _refresh_local_leaderboard_overlay() -> void:
	state_mode = "leaderboard"
	_hide_state_preview()
	_apply_state_overlay_theme(Color(0.94, 0.7, 0.4, 1.0))
	local_leaderboard_view = _normalize_local_leaderboard_view(local_leaderboard_view)
	var leaderboard_content := FrontEndContent.local_leaderboard_content()
	var manual_count := Session.get_local_leaderboard_count("manual")
	var test_count := Session.get_local_leaderboard_count("test")
	state_title_label.text = _localize_text(String(leaderboard_content.get("local_title_manual" if local_leaderboard_view == "manual" else "local_title_test", "本地主卷榜" if local_leaderboard_view == "manual" else "本地试阵榜")))
	state_body_label.text = _build_local_leaderboard_text(local_leaderboard_view)
	var leaderboard_detail := _localize_text(String(leaderboard_content.get("latest_alias_detail_manual", "这里显示最近写入主卷榜的那条战绩；如果刚结束的是试阵捷径，可以先切到试阵榜再改名。")))
	if local_leaderboard_view == "test":
		leaderboard_detail = _localize_text(String(leaderboard_content.get("latest_alias_detail_test", "这里显示最近写入试阵榜的那条战绩；试阵记录会和主卷榜分开保留。")))
	_show_state_name_editor(
		_localize_text(String(leaderboard_content.get("latest_alias_title", "最近一条战绩署名"))),
		leaderboard_detail
	)
	if local_leaderboard_view == "manual":
		_configure_state_button(state_primary_button, _localize_text(String(leaderboard_content.get("switch_to_test_format", "切到试阵榜 · %d"))) % test_count, Callable(self, "_show_test_leaderboard"))
	else:
		_configure_state_button(state_primary_button, _localize_text(String(leaderboard_content.get("switch_to_main_format", "切到主卷榜 · %d"))) % manual_count, Callable(self, "_show_manual_leaderboard"))
	_configure_state_button(state_secondary_button, _localize_text(String(leaderboard_content.get("back_to_summary", "返回结算"))), Callable(self, "_show_game_over_summary"))
	var state_content := FrontEndContent.battle_state_content()
	_configure_state_button(state_tertiary_button, _battle_state_text(state_content, "action_restart_run", "重新开始", "Restart Run"), Callable(self, "_emit_restart"))
	_configure_state_button(state_quaternary_button, _battle_state_text(state_content, "action_return_menu", "返回菜单", "Return to Menu"), Callable(self, "_emit_return_menu"))
	_hide_state_button(state_quinary_button)
	_hide_state_button(state_senary_button)
	overlay_label.visible = false
	_hide_reveal()
	state_overlay.visible = true


func _return_to_pause_menu() -> void:
	if last_pause_summary.is_empty():
		hide_state_overlay()
		return
	show_pause_menu(
		float(last_pause_summary.get("elapsed", 0.0)),
		int(last_pause_summary.get("kills", 0)),
		int(last_pause_summary.get("threat", 1)),
		int(last_pause_summary.get("level", 1))
	)


func _build_settings_body() -> String:
	var state_content := FrontEndContent.battle_state_content()
	return _battle_state_text(
		state_content,
		"settings_body_format",
		"对照 hanziHero 的 Performance / LOD 面板，当前战场布置已经补齐完整的低风险首轮矩阵。改动会立即生效，并写入本地运行设置。\n\n当前\n演出档：%s\n视觉字效：%s\n敌方血条：%s\n环境字影：%s\n远敌细节：%s",
		"Mirroring the hanziHero Performance / LOD panel, the Godot battlefield now keeps a complete first-pass set of safe presentation toggles. Changes apply immediately and are saved locally.\n\nCurrent\nPerformance: %s\nGlyph FX: %s\nEnemy Health Bars: %s\nAmbient Glyphs: %s\nDistant Enemy Detail: %s"
	) % [
		_performance_mode_label(),
		_visual_effects_label(),
		_enemy_health_bar_label(),
		_ambient_density_label(),
		_enemy_detail_label()
	]


func _performance_mode_label() -> String:
	var state_content := FrontEndContent.battle_state_content()
	match String(battle_settings.get("performance_mode", "balanced")):
		"performance":
			return _battle_state_text(state_content, "performance_mode_performance", "轻量", "Performance")
		"quality":
			return _battle_state_text(state_content, "performance_mode_quality", "质感", "Quality")
		_:
			return _battle_state_text(state_content, "performance_mode_balanced", "平衡", "Balanced")


func _enemy_health_bar_label() -> String:
	var state_content := FrontEndContent.battle_state_content()
	return (
		_battle_state_text(state_content, "toggle_show", "显示", "Show")
		if bool(battle_settings.get("enemy_health_bars", true))
		else _battle_state_text(state_content, "toggle_hide", "隐藏", "Hide")
	)


func _visual_effects_label() -> String:
	var state_content := FrontEndContent.battle_state_content()
	return (
		_battle_state_text(state_content, "toggle_enabled", "开启", "Enabled")
		if bool(battle_settings.get("visual_effects", true))
		else _battle_state_text(state_content, "toggle_reduced", "收束", "Reduced")
	)


func _ambient_density_label() -> String:
	var state_content := FrontEndContent.battle_state_content()
	match String(battle_settings.get("ambient_glyph_density", "medium")):
		"off":
			return _battle_state_text(state_content, "ambient_density_off", "关闭", "Off")
		"high":
			return _battle_state_text(state_content, "ambient_density_high", "浓", "Dense")
		_:
			return _battle_state_text(state_content, "ambient_density_medium", "疏", "Sparse")


func _enemy_detail_label() -> String:
	var state_content := FrontEndContent.battle_state_content()
	return (
		_battle_state_text(state_content, "enemy_detail_full", "完整", "Full")
		if bool(battle_settings.get("enemy_detail", true))
		else _battle_state_text(state_content, "enemy_detail_near_only", "近距", "Near Only")
	)


func _cycle_performance_mode() -> void:
	var current_mode := String(battle_settings.get("performance_mode", "balanced"))
	var current_index: int = Session.BATTLE_PERFORMANCE_MODES.find(current_mode)
	if current_index < 0:
		current_index = 0
	var next_mode := String(Session.BATTLE_PERFORMANCE_MODES[(current_index + 1) % Session.BATTLE_PERFORMANCE_MODES.size()])
	battle_settings = Session.set_battle_setting("performance_mode", next_mode)
	battle_setting_changed.emit("performance_mode", next_mode)
	_show_settings_menu()


func _toggle_visual_effects() -> void:
	var next_visible := not bool(battle_settings.get("visual_effects", true))
	battle_settings = Session.set_battle_setting("visual_effects", next_visible)
	battle_setting_changed.emit("visual_effects", next_visible)
	_show_settings_menu()


func _toggle_enemy_health_bars() -> void:
	var next_visible := not bool(battle_settings.get("enemy_health_bars", true))
	battle_settings = Session.set_battle_setting("enemy_health_bars", next_visible)
	battle_setting_changed.emit("enemy_health_bars", next_visible)
	_show_settings_menu()


func _cycle_ambient_density() -> void:
	var current_density := String(battle_settings.get("ambient_glyph_density", "medium"))
	var current_index: int = Session.BATTLE_AMBIENT_DENSITIES.find(current_density)
	if current_index < 0:
		current_index = 0
	var next_density := String(Session.BATTLE_AMBIENT_DENSITIES[(current_index + 1) % Session.BATTLE_AMBIENT_DENSITIES.size()])
	battle_settings = Session.set_battle_setting("ambient_glyph_density", next_density)
	battle_setting_changed.emit("ambient_glyph_density", next_density)
	_show_settings_menu()


func _toggle_enemy_detail() -> void:
	var next_enabled := not bool(battle_settings.get("enemy_detail", true))
	battle_settings = Session.set_battle_setting("enemy_detail", next_enabled)
	battle_setting_changed.emit("enemy_detail", next_enabled)
	_show_settings_menu()


func _build_local_leaderboard_text(view: String = "manual") -> String:
	var normalized_view := _normalize_local_leaderboard_view(view)
	var entries: Array[Dictionary] = Session.get_local_leaderboard(5, normalized_view)
	var leaderboard_content := FrontEndContent.local_leaderboard_content()
	if entries.is_empty():
		if normalized_view == "test":
			return _localize_text(String(leaderboard_content.get("empty_test", "当前还没有试阵记录。用第 10 / 20 波捷径打一轮后，这里会单独留下试阵榜。")))
		return _localize_text(String(leaderboard_content.get("empty_manual", "当前还没有可展示的主卷战绩。下一次从第 1 波真正开卷后，这里会留下你的记录。")))

	var lines: Array[String] = []
	if normalized_view == "test":
		lines.append(_localize_text(String(leaderboard_content.get("intro_test", "试阵榜会单独记录第 10 / 20 波捷径，不与主卷榜混排。"))))
	else:
		lines.append(_localize_text(String(leaderboard_content.get("intro_manual", "主卷榜只统计从第 1 波真正开卷的正式战绩。"))))
	lines.append("")
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		var run_label := _localize_text(String(leaderboard_content.get("test_run_format", "试阵 W%d"))) % int(entry.get("start_wave", 1))
		if normalized_view == "manual":
			run_label = _localize_text(String(leaderboard_content.get("manual_completed" if bool(entry.get("chapter_complete", false)) else "manual_scroll", "定卷" if bool(entry.get("chapter_complete", false)) else "残卷")))
		var bosses_label := _localize_text(String(leaderboard_content.get("bosses_label", "卷主")))
		var threat_label := _localize_text(String(leaderboard_content.get("wave_label", "波次")))
		var kills_label := _localize_text(String(leaderboard_content.get("kills_label", "击破")))
		var elapsed_label := _localize_text(String(leaderboard_content.get("time_label", "存活")))
		lines.append(
			String(leaderboard_content.get("entry_format", "%d. %s  %s  %s %d  %s %d  %s %d  %s %s")) % [
				index + 1,
				_format_leaderboard_identity(entry),
				run_label,
				bosses_label,
				int(entry.get("bosses", 0)),
				threat_label,
				int(entry.get("threat", 1)),
				kills_label,
				int(entry.get("kills", 0)),
				elapsed_label,
				_format_time(float(entry.get("elapsed", 0.0)))
			]
		)
		var detail_line := _build_local_leaderboard_detail_line(entry)
		if not detail_line.is_empty():
			lines.append(String(leaderboard_content.get("detail_prefix_format", "   %s")) % detail_line)
		var recorded_line := _build_local_leaderboard_recorded_line(entry)
		if not recorded_line.is_empty():
			lines.append(String(leaderboard_content.get("detail_prefix_format", "   %s")) % recorded_line)
		var time_zone_line := _build_local_leaderboard_time_zone_line(entry)
		if not time_zone_line.is_empty():
			lines.append(String(leaderboard_content.get("detail_prefix_format", "   %s")) % time_zone_line)
		lines.append("")
	while not lines.is_empty() and String(lines[lines.size() - 1]).is_empty():
		lines.remove_at(lines.size() - 1)
	return "\n".join(lines)


func _build_local_leaderboard_detail_line(entry: Dictionary) -> String:
	var leaderboard_content := FrontEndContent.local_leaderboard_content()
	var segments: Array[String] = []

	var radicals_text := _summarize_run_counts(entry.get("radicals", {}), Session.RADICAL_ORDER, "radical")
	if not radicals_text.is_empty():
		segments.append(_localize_text(String(leaderboard_content.get("detail_radicals", "偏旁 %s"))) % radicals_text)

	var recipes_text := _summarize_run_counts(entry.get("recipes", {}), Session.RECIPE_ORDER, "recipe")
	if not recipes_text.is_empty():
		segments.append(_localize_text(String(leaderboard_content.get("detail_glyphs", "成字 %s"))) % recipes_text)

	var words_text := _summarize_run_counts(entry.get("words", {}), Session.WORD_ORDER, "word")
	if not words_text.is_empty():
		segments.append(_localize_text(String(leaderboard_content.get("detail_phrases", "词技 %s"))) % words_text)

	var blade_level: int = int(entry.get("blade_level", 0))
	if blade_level > 0:
		var blade_key := "detail_blade_xia" if String(entry.get("hero_id", "scholar")) == "xia" else "detail_blade_scholar"
		var blade_label := _localize_text(String(leaderboard_content.get(blade_key, "")))
		segments.append(String(leaderboard_content.get("detail_blade_level_format", "%s Lv.%d")) % [blade_label, blade_level])

	var enemy_text := _summarize_enemy_kills(entry.get("enemy_kills", {}))
	if not enemy_text.is_empty():
		segments.append(_localize_text(String(leaderboard_content.get("detail_takedowns", "击倒 %s"))) % enemy_text)

	return String(leaderboard_content.get("detail_joiner", " | ")).join(segments)


func _build_local_leaderboard_time_zone_line(entry: Dictionary) -> String:
	var leaderboard_content := FrontEndContent.local_leaderboard_content()
	var time_zone_text := Session.format_leaderboard_time_zone(entry)
	if time_zone_text.is_empty():
		return ""
	return _localize_text(String(leaderboard_content.get("time_zone_format", "时区 %s"))) % time_zone_text


func _build_local_leaderboard_recorded_line(entry: Dictionary) -> String:
	var leaderboard_content := FrontEndContent.local_leaderboard_content()
	var recorded_date_text := Session.format_leaderboard_recorded_date(entry)
	if recorded_date_text.is_empty():
		return ""
	return _localize_text(String(leaderboard_content.get("recorded_on_format", "记录于 %s"))) % recorded_date_text


func _format_leaderboard_identity(entry: Dictionary) -> String:
	var leaderboard_content := FrontEndContent.local_leaderboard_content()
	var player_name := String(entry.get("player_name", "")).strip_edges()
	var hero_name := _localize_text(String(entry.get("hero_name", String(leaderboard_content.get("identity_hero_fallback", "书生")))).strip_edges())
	if player_name.is_empty():
		return hero_name
	if hero_name.is_empty():
		return player_name
	return _localize_text(String(leaderboard_content.get("identity_format", "%s · %s"))) % [player_name, hero_name]


func _normalize_local_leaderboard_view(view: String) -> String:
	return "test" if view == "test" else "manual"


func _summarize_run_counts(raw_counts: Variant, order: Array, category: String) -> String:
	if not (raw_counts is Dictionary):
		return ""

	var leaderboard_content := FrontEndContent.local_leaderboard_content()
	var counts := raw_counts as Dictionary
	var parts: Array[String] = []
	for key_variant in order:
		var key := String(key_variant)
		var amount: int = int(counts.get(key, 0))
		if amount <= 0:
			continue
		parts.append(_localize_text(String(leaderboard_content.get("detail_count_entry_format", "%s%d"))) % [_run_count_label(key, category), amount])
		if parts.size() >= 3:
			break
	return String(leaderboard_content.get("detail_count_joiner", " ")).join(parts)


func _run_count_label(key: String, category: String) -> String:
	match category:
		"recipe":
			return String(Session.get_recipe_data(key).get("display", key))
		"word":
			return String(Session.get_word_data(key).get("display", key))
		_:
			return key


func _summarize_enemy_kills(raw_counts: Variant) -> String:
	if not (raw_counts is Dictionary):
		return ""

	var leaderboard_content := FrontEndContent.local_leaderboard_content()
	var counts := raw_counts as Dictionary
	var ranked_enemies: Array[Dictionary] = []
	for enemy_id_variant in Session.ENEMY_ORDER:
		var enemy_id := String(enemy_id_variant)
		var amount: int = int(counts.get(enemy_id, 0))
		if amount <= 0:
			continue
		ranked_enemies.append({
			"id": enemy_id,
			"amount": amount
		})

	if ranked_enemies.is_empty():
		return ""

	ranked_enemies.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		var left_amount: int = int(left.get("amount", 0))
		var right_amount: int = int(right.get("amount", 0))
		if left_amount != right_amount:
			return left_amount > right_amount
		return Session.ENEMY_ORDER.find(String(left.get("id", ""))) < Session.ENEMY_ORDER.find(String(right.get("id", "")))
	)

	var parts: Array[String] = []
	var limit: int = mini(3, ranked_enemies.size())
	for index in range(limit):
		var item: Dictionary = ranked_enemies[index]
		var enemy_id := String(item.get("id", "basic"))
		parts.append(_localize_text(String(leaderboard_content.get("enemy_kill_entry_format", "%s%d"))) % [String(Session.get_enemy_data(enemy_id).get("glyph", enemy_id)), int(item.get("amount", 0))])
	return String(leaderboard_content.get("enemy_kill_joiner", " ")).join(parts)


func _build_ui() -> void:
	root_control = Control.new()
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)

	safe_content_root = Control.new()
	safe_content_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	safe_content_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_control.add_child(safe_content_root)

	left_column = VBoxContainer.new()
	left_column.position = Vector2.ZERO
	left_column.size = Vector2(320.0, 540.0)
	left_column.add_theme_constant_override("separation", 12)
	safe_content_root.add_child(left_column)

	var intro_panel := _make_panel(Color(0.05, 0.08, 0.1, 0.8), Color(0.93, 0.69, 0.38, 0.78), Vector2(320.0, 254.0))
	left_column.add_child(intro_panel)
	var intro_box := _panel_box(intro_panel)
	intro_box.add_child(_make_label("INK-BORN ROGUELITE DEMO", 17, Color(0.96, 0.82, 0.52, 0.86), 4.0))
	hero_label = _make_label("书生", 42, Color(1.0, 0.95, 0.86, 1.0))
	intro_box.add_child(hero_label)
	hero_title_label = _make_label("", 16, Color(0.96, 0.82, 0.54, 0.96))
	intro_box.add_child(hero_title_label)
	hero_focus_label = _make_label("", 15, Color(0.86, 0.91, 0.98, 0.94))
	intro_box.add_child(hero_focus_label)

	hero_tag_row = HBoxContainer.new()
	hero_tag_row.add_theme_constant_override("separation", 8)
	intro_box.add_child(hero_tag_row)

	health_label = _make_label("气血  0 / 0", 16, Color(0.96, 0.92, 0.87, 0.98))
	intro_box.add_child(health_label)
	health_bar = _make_bar(Color(0.82, 0.38, 0.31, 0.96))
	intro_box.add_child(health_bar)
	progress_label = _make_label("字墨  Lv.1   0 / 4", 16, Color(0.98, 0.91, 0.72, 1.0))
	intro_box.add_child(progress_label)
	xp_bar = _make_bar(Color(0.56, 0.84, 0.82, 0.96))
	intro_box.add_child(xp_bar)
	status_label = _make_label("存活  00:00\n波次  1\n击破  0", 17, Color(0.86, 0.92, 0.98, 0.98))
	intro_box.add_child(status_label)

	soundtrack_panel = _make_panel(Color(0.06, 0.09, 0.1, 0.92), Color(0.42, 0.66, 0.78, 0.44), Vector2(0.0, 82.0))
	soundtrack_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	intro_box.add_child(soundtrack_panel)
	var soundtrack_box := _panel_box(soundtrack_panel)
	soundtrack_box.add_theme_constant_override("separation", 4)
	soundtrack_box.add_child(_make_label("战场乐题", 14, Color(0.88, 0.94, 0.96, 0.72), 3.0))
	soundtrack_title_label = _make_label("待入曲", 18, Color(1.0, 0.95, 0.86, 1.0))
	soundtrack_box.add_child(soundtrack_title_label)
	soundtrack_detail_label = _make_label("战局开始后会同步当前曲名与气氛提示。", 14, Color(0.84, 0.9, 0.94, 0.92))
	soundtrack_box.add_child(soundtrack_detail_label)
	_apply_soundtrack_style(soundtrack_panel, Color(0.42, 0.66, 0.78, 1.0), 0.92, 0.44)

	var radicals_panel := _make_panel(Color(0.05, 0.07, 0.09, 0.74), Color(0.38, 0.72, 0.78, 0.62), Vector2(320.0, 154.0))
	left_column.add_child(radicals_panel)
	var radicals_box := _panel_box(radicals_panel)
	radicals_box.add_child(_make_label("偏旁存量", 20, Color(0.96, 0.9, 0.8, 1.0)))
	radicals_label = _make_label("当前尚未留存偏旁", 15, Color(0.86, 0.9, 0.92, 0.94))
	radicals_box.add_child(radicals_label)
	radical_chip_container = HFlowContainer.new()
	radical_chip_container.add_theme_constant_override("h_separation", 8)
	radical_chip_container.add_theme_constant_override("v_separation", 8)
	radicals_box.add_child(radical_chip_container)

	var controls_panel := _make_panel(Color(0.05, 0.07, 0.09, 0.66), Color(0.92, 0.69, 0.38, 0.42), Vector2(320.0, 132.0))
	left_column.add_child(controls_panel)
	var controls_box := _panel_box(controls_panel)
	controls_box.add_child(_make_label("战场速记", 18, Color(0.96, 0.9, 0.8, 1.0)))
	controls_label = _make_label("", 15, Color(0.88, 0.9, 0.93, 0.94))
	controls_box.add_child(controls_label)

	event_log_panel = _make_panel(Color(0.05, 0.07, 0.09, 0.74), Color(0.7, 0.8, 0.9, 0.42), Vector2(320.0, 214.0))
	left_column.add_child(event_log_panel)
	var event_log_box := _panel_box(event_log_panel)
	event_log_box.add_child(_make_label("战报", 18, Color(0.96, 0.9, 0.8, 1.0)))
	event_log_list = VBoxContainer.new()
	event_log_list.add_theme_constant_override("separation", 8)
	event_log_box.add_child(event_log_list)

	top_pills = GridContainer.new()
	top_pills.columns = 4
	top_pills.anchor_left = 1.0
	top_pills.anchor_right = 1.0
	top_pills.anchor_top = 0.0
	top_pills.anchor_bottom = 0.0
	top_pills.add_theme_constant_override("h_separation", 12)
	top_pills.add_theme_constant_override("v_separation", 10)
	safe_content_root.add_child(top_pills)
	map_button = _make_pill_button("地图", Callable(self, "_emit_map_toggle"))
	map_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_pills.add_child(map_button)
	pause_button = _make_pill_button("暂停", Callable(self, "_emit_pause"))
	pause_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_pills.add_child(pause_button)
	test_next_wave_button = _make_pill_button("下一波", Callable(self, "_emit_test_next_wave"))
	test_next_wave_button.custom_minimum_size = Vector2(112.0, 52.0)
	test_next_wave_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	test_next_wave_button.visible = false
	top_pills.add_child(test_next_wave_button)

	fps_panel = PanelContainer.new()
	fps_panel.custom_minimum_size = Vector2(116.0, 52.0)
	fps_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fps_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.04, 0.06, 0.08, 0.84), Color(0.4, 0.64, 0.72, 0.6), 26))
	fps_panel.visible = false
	top_pills.add_child(fps_panel)

	fps_value_label = _make_label("FPS --", 17, Color(0.9, 0.96, 1.0, 0.98))
	fps_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fps_value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fps_value_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	fps_panel.add_child(fps_value_label)

	boss_panel = _make_panel(Color(0.08, 0.06, 0.06, 0.88), Color(0.84, 0.34, 0.24, 0.72), Vector2(520.0, 92.0))
	boss_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	boss_panel.visible = false
	safe_content_root.add_child(boss_panel)
	var boss_box := _panel_box(boss_panel)
	boss_name_label = _make_label("卷  卷主", 28, Color(1.0, 0.94, 0.86, 1.0))
	boss_detail_label = _make_label("卷主降阵", 16, Color(0.92, 0.84, 0.78, 0.92))
	boss_box.add_child(boss_name_label)
	boss_box.add_child(boss_detail_label)
	boss_bar = _make_bar(Color(0.88, 0.36, 0.28, 1.0))
	boss_box.add_child(boss_bar)

	top_right_stack = VBoxContainer.new()
	top_right_stack.anchor_left = 1.0
	top_right_stack.anchor_right = 1.0
	top_right_stack.anchor_top = 0.0
	top_right_stack.anchor_bottom = 1.0
	top_right_stack.add_theme_constant_override("separation", 12)
	safe_content_root.add_child(top_right_stack)

	compact_summary_panel = _make_panel(Color(0.05, 0.07, 0.09, 0.84), Color(0.42, 0.74, 0.84, 0.62), Vector2(340.0, 188.0))
	compact_summary_panel.visible = false
	top_right_stack.add_child(compact_summary_panel)
	var compact_box := _panel_box(compact_summary_panel)
	compact_box.add_child(_make_label("战局摘要", 20, Color(0.96, 0.88, 0.72, 0.98)))
	compact_health_label = _make_label("气血  0 / 0", 17, Color(0.96, 0.92, 0.87, 0.98))
	compact_box.add_child(compact_health_label)
	compact_health_bar = _make_bar(Color(0.82, 0.38, 0.31, 0.96))
	compact_box.add_child(compact_health_bar)
	compact_progress_label = _make_label("字墨  Lv.1   0 / 4", 17, Color(0.98, 0.91, 0.72, 1.0))
	compact_box.add_child(compact_progress_label)
	compact_xp_bar = _make_bar(Color(0.56, 0.84, 0.82, 0.96))
	compact_box.add_child(compact_xp_bar)
	compact_status_label = _make_label("存活 00:00  ·  波次 1  ·  击破 0", 16, Color(0.86, 0.92, 0.98, 0.98))
	compact_box.add_child(compact_status_label)
	compact_radicals_label = _make_label("偏旁 0 枚  ·  当前全部化字", 15, Color(0.88, 0.9, 0.92, 0.94))
	compact_box.add_child(compact_radicals_label)
	var hud_content := FrontEndContent.battle_hud_content()
	compact_tip_label = _make_label(
		_battle_state_text(hud_content, "compact_tip_placeholder", "击倒字灵收集字力与补给。", "Defeat glyph spirits to collect ink power and supplies."),
		15,
		Color(0.92, 0.94, 0.96, 0.94)
	)
	compact_box.add_child(compact_tip_label)
	compact_route_label = _make_label(
		_battle_state_text(hud_content, "compact_route_placeholder", "墨守流  ·  开卷补笔", "Inkguard Route  ·  Opening Strokes"),
		13,
		Color(0.96, 0.82, 0.56, 0.9)
	)
	compact_box.add_child(compact_route_label)

	callout_panel = _make_panel(Color(0.05, 0.07, 0.09, 0.84), Color(0.92, 0.69, 0.38, 0.42), Vector2(340.0, 120.0))
	callout_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	callout_panel.visible = false
	top_right_stack.add_child(callout_panel)
	var callout_box := _panel_box(callout_panel)
	callout_box.add_theme_constant_override("separation", 4)
	callout_title_label = _make_label(
		_battle_state_text(hud_content, "callout_title", "战场呼应", "Battle Callout"),
		14,
		Color(0.96, 0.84, 0.6, 0.94),
		3.0
	)
	callout_box.add_child(callout_title_label)
	callout_text_label = _make_label(
		_battle_state_text(hud_content, "callout_placeholder", "字潮翻动时，呼应会在这里出现。", "Callouts will appear here when the glyph tide shifts."),
		16,
		Color(0.98, 0.96, 0.91, 0.98)
	)
	callout_box.add_child(callout_text_label)
	callout_detail_label = _make_label(
		_battle_state_text(hud_content, "callout_detail_placeholder", "印记 · 白纸起卷", "Mark · Blank Scroll Begins"),
		13,
		Color(0.9, 0.9, 0.96, 0.9),
		2.0
	)
	callout_detail_label.visible = false
	callout_box.add_child(callout_detail_label)

	objective_panel = _make_panel(Color(0.05, 0.07, 0.09, 0.76), Color(0.94, 0.7, 0.4, 0.6), Vector2(340.0, 150.0))
	top_right_stack.add_child(objective_panel)
	var objective_box := _panel_box(objective_panel)
	objective_box.add_child(
		_make_label(
			_battle_state_text(hud_content, "objective_title", "当前目标", "Current Objective"),
			20,
			Color(0.96, 0.82, 0.56, 0.98)
		)
	)
	tip_label = _make_label(
		_battle_state_text(hud_content, "objective_placeholder_tip", "尚未收集，或已经全部化字。", "Nothing left to collect, or everything has already fused."),
		18,
		Color(0.88, 0.9, 0.93, 0.95)
	)
	objective_box.add_child(tip_label)
	objective_box.add_child(
		_make_label(
			_battle_state_text(hud_content, "route_focus_title", "源稿路线参考", "Source Route Guide"),
			13,
			Color(0.96, 0.84, 0.6, 0.84),
			2.0
		)
	)
	objective_route_title_label = _make_label(
		_battle_state_text(hud_content, "route_focus_placeholder_title", "守  墨守流  ·  续航 / 站场", "Guard  Inkguard Route  ·  Sustain / Hold"),
		18,
		Color(0.98, 0.95, 0.88, 0.98)
	)
	objective_box.add_child(objective_route_title_label)
	objective_route_detail_label = _make_label(
		_battle_state_text(
			hud_content,
			"route_focus_placeholder_detail",
			"先把最稳的 build 主线写深，再让砚台磨词接手中盘。",
			"Push the steadiest build lane first, then let inkstone refinement take over the midgame."
		),
		15,
		Color(0.88, 0.9, 0.93, 0.92)
	)
	objective_box.add_child(objective_route_detail_label)
	objective_stage_label = _make_label(
		_battle_state_text(
			hud_content,
			"route_focus_placeholder_stage",
			"当前阶段：开卷补笔  ·  明 / 海 / 休",
			"Stage: Opening Strokes  ·  Ming / Hai / Xiu"
		),
		14,
		Color(0.84, 0.9, 1.0, 0.92)
	)
	objective_box.add_child(objective_stage_label)
	objective_route_tags = HFlowContainer.new()
	objective_route_tags.add_theme_constant_override("h_separation", 8)
	objective_route_tags.add_theme_constant_override("v_separation", 8)
	objective_box.add_child(objective_route_tags)

	guidance_root = Control.new()
	guidance_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	guidance_root.visible = false
	root_control.add_child(guidance_root)

	guidance_arrow_label = _make_label("▲", 26, Color(0.96, 0.84, 0.6, 0.98))
	guidance_arrow_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	guidance_arrow_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	guidance_arrow_label.position = Vector2(68.0, 0.0)
	guidance_arrow_label.size = Vector2(44.0, 28.0)
	guidance_root.add_child(guidance_arrow_label)

	guidance_panel = _make_panel(Color(0.05, 0.07, 0.09, 0.9), Color(0.94, 0.7, 0.4, 0.72), Vector2(180.0, 48.0))
	guidance_panel.position = Vector2(0.0, 24.0)
	guidance_root.add_child(guidance_panel)
	var guidance_box := _panel_box(guidance_panel)
	guidance_box.add_theme_constant_override("separation", 2)
	guidance_box.add_child(
		_make_label(
			_battle_state_text(battle_hud_content, "current_guide_title", "当前指引", "Active Guide"),
			13,
			Color(0.96, 0.84, 0.6, 0.78),
			2.0
		)
	)
	guidance_text_label = _make_label("Reward Beacon" if _is_english() else "卷间奖印", 16, Color(0.98, 0.95, 0.88, 0.98))
	guidance_box.add_child(guidance_text_label)

	skills_panel = _make_panel(Color(0.05, 0.07, 0.09, 0.74), Color(0.38, 0.74, 0.82, 0.62), Vector2(340.0, 860.0))
	skills_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	top_right_stack.add_child(skills_panel)
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

	compact_skill_panel = _make_panel(Color(0.05, 0.07, 0.09, 0.82), Color(0.38, 0.74, 0.82, 0.54), Vector2(560.0, 102.0))
	compact_skill_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	compact_skill_panel.visible = false
	safe_content_root.add_child(compact_skill_panel)
	var compact_skill_margin := MarginContainer.new()
	compact_skill_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	compact_skill_margin.add_theme_constant_override("margin_left", 16)
	compact_skill_margin.add_theme_constant_override("margin_top", 14)
	compact_skill_margin.add_theme_constant_override("margin_right", 16)
	compact_skill_margin.add_theme_constant_override("margin_bottom", 14)
	compact_skill_panel.add_child(compact_skill_margin)
	var compact_skill_box := VBoxContainer.new()
	compact_skill_box.add_theme_constant_override("separation", 8)
	compact_skill_margin.add_child(compact_skill_box)
	compact_skill_box.add_child(_make_label("已成技艺", 16, Color(0.96, 0.9, 0.8, 0.96)))
	compact_skill_chip_container = HFlowContainer.new()
	compact_skill_chip_container.add_theme_constant_override("h_separation", 8)
	compact_skill_chip_container.add_theme_constant_override("v_separation", 8)
	compact_skill_box.add_child(compact_skill_chip_container)

	compact_event_panel = _make_panel(Color(0.05, 0.07, 0.09, 0.82), Color(0.7, 0.8, 0.9, 0.36), Vector2(262.0, 124.0))
	compact_event_panel.visible = false
	safe_content_root.add_child(compact_event_panel)
	var compact_event_box := _panel_box(compact_event_panel)
	compact_event_box.add_child(_make_label("战报", 15, Color(0.96, 0.9, 0.8, 0.98)))
	compact_event_list = VBoxContainer.new()
	compact_event_list.add_theme_constant_override("separation", 6)
	compact_event_box.add_child(compact_event_list)

	banner_label = _make_label("", 44, Color(1.0, 0.92, 0.78, 1.0))
	banner_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	banner_label.offset_left = 420.0
	banner_label.offset_right = -420.0
	banner_label.offset_top = 86.0
	banner_label.offset_bottom = 150.0
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.visible = false
	root_control.add_child(banner_label)

	overlay_label = _make_label("", 30, Color(1.0, 0.92, 0.84, 1.0))
	overlay_label.set_anchors_preset(Control.PRESET_CENTER)
	overlay_label.offset_left = -320.0
	overlay_label.offset_top = -70.0
	overlay_label.offset_right = 320.0
	overlay_label.offset_bottom = 70.0
	overlay_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	overlay_label.visible = false
	root_control.add_child(overlay_label)

	reveal_panel = PanelContainer.new()
	reveal_panel.set_anchors_preset(Control.PRESET_CENTER)
	reveal_panel.offset_left = -360.0
	reveal_panel.offset_top = -164.0
	reveal_panel.offset_right = 360.0
	reveal_panel.offset_bottom = -16.0
	reveal_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reveal_panel.visible = false
	reveal_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.11, 0.14, 0.92), Color(0.96, 0.74, 0.44, 0.76), 28))
	root_control.add_child(reveal_panel)

	var reveal_margin := MarginContainer.new()
	reveal_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	reveal_margin.add_theme_constant_override("margin_left", 22)
	reveal_margin.add_theme_constant_override("margin_top", 18)
	reveal_margin.add_theme_constant_override("margin_right", 22)
	reveal_margin.add_theme_constant_override("margin_bottom", 18)
	reveal_panel.add_child(reveal_margin)

	var reveal_row := HBoxContainer.new()
	reveal_row.add_theme_constant_override("separation", 18)
	reveal_margin.add_child(reveal_row)

	reveal_glyph_label = _make_label(_battle_state_text(hud_content, "reveal_glyph_placeholder", "字", "Glyph"), 70, Color(1.0, 0.92, 0.78, 1.0), 4.0)
	reveal_glyph_label.custom_minimum_size = Vector2(104.0, 104.0)
	reveal_glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reveal_glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	reveal_row.add_child(reveal_glyph_label)

	var reveal_box := VBoxContainer.new()
	reveal_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reveal_box.add_theme_constant_override("separation", 6)
	reveal_row.add_child(reveal_box)

	reveal_kicker_label = _make_label(_battle_state_text(hud_content, "reveal_kicker_placeholder", "字境相变", "Realm Shift"), 15, Color(0.98, 0.84, 0.6, 0.9), 3.0)
	reveal_box.add_child(reveal_kicker_label)
	reveal_title_label = _make_label(_battle_state_text(hud_content, "reveal_title_placeholder", "碑林", "Stele Grove"), 34, Color(1.0, 0.96, 0.9, 1.0))
	reveal_box.add_child(reveal_title_label)
	reveal_detail_label = _make_label(_battle_state_text(hud_content, "reveal_detail_placeholder", "大字揭示会在这里提示合字、词技与字境变化。", "Big reveal cards here announce fused glyphs, phrase arts, and realm shifts."), 16, Color(0.88, 0.93, 0.97, 0.94), 2.0)
	reveal_box.add_child(reveal_detail_label)

	soundtrack_toast = _make_panel(Color(0.08, 0.11, 0.13, 0.96), Color(0.92, 0.69, 0.38, 0.64), Vector2(300.0, 100.0))
	soundtrack_toast.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	soundtrack_toast.offset_left = -690.0
	soundtrack_toast.offset_top = 88.0
	soundtrack_toast.offset_right = -390.0
	soundtrack_toast.offset_bottom = 188.0
	soundtrack_toast.visible = false
	safe_content_root.add_child(soundtrack_toast)
	var soundtrack_toast_box := _panel_box(soundtrack_toast)
	soundtrack_toast_box.add_theme_constant_override("separation", 4)
	soundtrack_toast_box.add_child(
		_make_label(
			_battle_state_text(battle_hud_content, "soundtrack_cue_title", "配乐提示", "Music Cue"),
			14,
			Color(0.96, 0.9, 0.82, 0.76),
			3.0
		)
	)
	soundtrack_toast_title_label = _make_label(
		_battle_state_text(battle_hud_content, "soundtrack_placeholder_title", "苔月幽林", "Mosslight Canopy"),
		24,
		Color(1.0, 0.95, 0.86, 1.0)
	)
	soundtrack_toast_box.add_child(soundtrack_toast_title_label)
	soundtrack_toast_detail_label = _make_label(
		_battle_state_text(
			battle_hud_content,
			"soundtrack_placeholder_detail",
			"16-bit 静夜丛林 · 入卷铺陈",
			"16-bit Quiet Forest · Scroll Opening"
		),
		15,
		Color(0.88, 0.92, 0.96, 0.92)
	)
	soundtrack_toast_box.add_child(soundtrack_toast_detail_label)
	_apply_soundtrack_style(soundtrack_toast, Color(0.92, 0.69, 0.38, 1.0), 0.96, 0.64)

	_refresh_event_log_views()

	_build_map_overlay(root_control)
	_build_choice_overlay(root_control)
	_build_state_overlay(root_control)


func _refresh_layout() -> void:
	if root_control == null:
		return

	compact_layout = _should_use_compact_layout()
	var viewport_rect := get_viewport().get_visible_rect()
	var viewport_size := viewport_rect.size
	var safe_insets := _safe_area_insets()
	var web_tight_layout := _should_use_web_tight_layout()
	var micro_layout := _should_use_micro_layout()
	var outer_padding := 12.0 if micro_layout else (16.0 if compact_layout else 22.0)
	if safe_content_root != null:
		safe_content_root.offset_left = float(safe_insets["left"]) + outer_padding
		safe_content_root.offset_top = float(safe_insets["top"]) + outer_padding
		safe_content_root.offset_right = -(float(safe_insets["right"]) + outer_padding)
		safe_content_root.offset_bottom = -(float(safe_insets["bottom"]) + outer_padding)

	if left_column != null:
		left_column.visible = not compact_layout
		left_column.position = Vector2.ZERO
		left_column.size = Vector2(300.0 if micro_layout else 320.0, maxf(336.0 if micro_layout else 360.0, viewport_rect.size.y - (56.0 if micro_layout else 64.0)))
	if event_log_panel != null:
		event_log_panel.visible = not compact_layout
	if compact_summary_panel != null:
		compact_summary_panel.visible = compact_layout
	if objective_panel != null:
		objective_panel.visible = not compact_layout
	if skills_panel != null:
		skills_panel.visible = not compact_layout
	if compact_skill_panel != null:
		compact_skill_panel.visible = compact_layout
	if compact_event_panel != null:
		compact_event_panel.visible = compact_layout and not _should_hide_compact_event_panel()

	var stack_width := 288.0 if compact_layout else 340.0
	if compact_layout:
		var usable_width := viewport_size.x - float(safe_insets["left"]) - float(safe_insets["right"])
		var compact_ratio := 0.3 if micro_layout else (0.32 if web_tight_layout else 0.34)
		stack_width = clamp(usable_width * compact_ratio, 196.0 if micro_layout else (212.0 if web_tight_layout else 228.0), 244.0 if micro_layout else (272.0 if web_tight_layout else 296.0))
	var right_margin := 0.0
	var top_margin := 0.0

	if compact_summary_panel != null:
		compact_summary_panel.custom_minimum_size = Vector2(stack_width, 182.0 if micro_layout else (198.0 if web_tight_layout else 218.0))
	if callout_panel != null:
		var callout_height := 78.0 if micro_layout else (84.0 if compact_layout else 88.0)
		if callout_detail_label != null and callout_detail_label.visible:
			callout_height += 28.0 if micro_layout else (32.0 if compact_layout else 36.0)
		callout_panel.custom_minimum_size = Vector2(stack_width, callout_height)
	if objective_panel != null:
		objective_panel.custom_minimum_size = Vector2(stack_width, 204.0 if web_tight_layout else 230.0)
	if skills_panel != null:
		skills_panel.custom_minimum_size = Vector2(
			stack_width,
			maxf(196.0 if micro_layout else 220.0, viewport_size.y - (196.0 if micro_layout else (220.0 if web_tight_layout else 240.0)))
		)
	if event_log_panel != null:
		event_log_panel.custom_minimum_size = Vector2(300.0 if micro_layout else 320.0, clamp(viewport_size.y * (0.2 if web_tight_layout else 0.24), 148.0 if micro_layout else 176.0, 204.0 if web_tight_layout else 228.0))
	if compact_skill_panel != null:
		var skill_usable_width := viewport_size.x - float(safe_insets["left"]) - float(safe_insets["right"])
		var side_reserve: float = clampf(skill_usable_width * (0.12 if micro_layout else (0.18 if web_tight_layout else 0.2)), 104.0 if micro_layout else 134.0, 200.0 if micro_layout else (240.0 if web_tight_layout else 260.0))
		compact_skill_panel.offset_left = side_reserve
		compact_skill_panel.offset_right = -side_reserve
		compact_skill_panel.offset_bottom = -82.0 if micro_layout else -96.0
		compact_skill_panel.offset_top = compact_skill_panel.offset_bottom - (92.0 if micro_layout else 108.0)
	if compact_event_panel != null:
		var event_usable_width := viewport_size.x - float(safe_insets["left"]) - float(safe_insets["right"])
		var event_width := clampf(event_usable_width * (0.24 if micro_layout else 0.26), 188.0 if micro_layout else 220.0, 232.0 if micro_layout else (260.0 if web_tight_layout else 272.0))
		var event_height := 110.0 if micro_layout else 132.0
		compact_event_panel.custom_minimum_size = Vector2(event_width, event_height)
		compact_event_panel.offset_left = 0.0
		compact_event_panel.offset_right = event_width
		compact_event_panel.offset_top = 50.0 if micro_layout else 58.0
		compact_event_panel.offset_bottom = compact_event_panel.offset_top + event_height

	var pill_height := 42.0 if micro_layout else (48.0 if compact_layout else 52.0)
	var pill_font_size := 15 if micro_layout else (16 if compact_layout else 17)
	if map_button != null:
		map_button.custom_minimum_size = Vector2(72.0 if micro_layout else (82.0 if compact_layout else 94.0), pill_height)
		map_button.add_theme_font_size_override("font_size", pill_font_size)
	if pause_button != null:
		pause_button.custom_minimum_size = Vector2(72.0 if micro_layout else (82.0 if compact_layout else 94.0), pill_height)
		pause_button.add_theme_font_size_override("font_size", pill_font_size)
	if test_next_wave_button != null:
		test_next_wave_button.custom_minimum_size = Vector2(86.0 if micro_layout else (94.0 if compact_layout else 112.0), pill_height)
		test_next_wave_button.add_theme_font_size_override("font_size", pill_font_size)
	if fps_panel != null:
		fps_panel.custom_minimum_size = Vector2(74.0 if micro_layout else (88.0 if compact_layout else 116.0), pill_height)
	if fps_value_label != null:
		_set_label_font_size(fps_value_label, pill_font_size)
	var visible_pill_count := 0
	for pill in [map_button, pause_button, test_next_wave_button, fps_panel]:
		if pill != null and pill.visible:
			visible_pill_count += 1
	var pill_columns := maxi(1, visible_pill_count)
	if micro_layout:
		pill_columns = mini(2, maxi(1, visible_pill_count))
	elif web_tight_layout and visible_pill_count > 3:
		pill_columns = 3
	var tool_bottom := top_margin + pill_height
	if top_pills != null:
		top_pills.columns = pill_columns
		top_pills.add_theme_constant_override("h_separation", 8 if micro_layout else 12)
		top_pills.add_theme_constant_override("v_separation", 8 if micro_layout else 10)
		var pill_width := maxf(top_pills.get_combined_minimum_size().x, 160.0 if micro_layout else 184.0)
		var pill_height_total := maxf(top_pills.get_combined_minimum_size().y, pill_height)
		top_pills.offset_left = -pill_width - right_margin
		top_pills.offset_right = -right_margin
		top_pills.offset_top = top_margin
		top_pills.offset_bottom = top_margin + pill_height_total
		tool_bottom = top_pills.offset_bottom
	var stack_top := tool_bottom + (8.0 if micro_layout else (10.0 if compact_layout else 20.0))
	var boss_bottom := tool_bottom

	if boss_panel != null:
		if compact_layout:
			var boss_left_margin := 0.0
			var boss_right_margin := stack_width + (10.0 if micro_layout else 14.0)
			boss_panel.offset_left = boss_left_margin
			boss_panel.offset_right = -boss_right_margin
			boss_panel.offset_top = tool_bottom + (8.0 if micro_layout else 10.0)
			boss_panel.offset_bottom = boss_panel.offset_top + (84.0 if micro_layout else 92.0)
		else:
			var boss_width := maxf(220.0 if micro_layout else 260.0, minf(460.0 if web_tight_layout else 520.0, viewport_size.x - (84.0 if micro_layout else (140.0 if compact_layout else 660.0))))
			var boss_margin := maxf(28.0 if micro_layout else 70.0, (viewport_size.x - boss_width) * 0.5)
			boss_panel.offset_left = boss_margin
			boss_panel.offset_right = -boss_margin
			boss_panel.offset_top = 102.0 if micro_layout else (118.0 if compact_layout else 154.0)
			boss_panel.offset_bottom = boss_panel.offset_top + 92.0
		boss_bottom = boss_panel.offset_bottom if boss_panel.visible else tool_bottom
	if boss_name_label != null:
		_set_label_font_size(boss_name_label, 22 if micro_layout else (24 if web_tight_layout else 28))
	if boss_detail_label != null:
		_set_label_font_size(boss_detail_label, 14 if micro_layout else 16)
	if boss_bar != null:
		boss_bar.custom_minimum_size = Vector2(0.0, 12.0 if micro_layout else 16.0)
	if top_right_stack != null:
		var effective_stack_top := stack_top
		if compact_layout and boss_panel != null and boss_panel.visible:
			effective_stack_top = maxf(effective_stack_top, boss_bottom + (8.0 if micro_layout else 10.0))
		top_right_stack.offset_left = -stack_width - right_margin
		top_right_stack.offset_right = -right_margin
		top_right_stack.offset_top = effective_stack_top
		top_right_stack.offset_bottom = -10.0

	if banner_label != null:
		_set_label_font_size(banner_label, 30 if micro_layout else (36 if web_tight_layout else 44))
		var banner_margin := 116.0 if micro_layout else (180.0 if compact_layout else 420.0)
		banner_label.offset_left = banner_margin
		banner_label.offset_right = -banner_margin
		var banner_top := 72.0 if micro_layout else (82.0 if compact_layout else 86.0)
		if compact_layout:
			banner_top = maxf(banner_top, boss_bottom + (10.0 if micro_layout else 12.0))
		else:
			banner_top = maxf(banner_top, tool_bottom + 12.0)
		banner_label.offset_top = banner_top
		banner_label.offset_bottom = banner_label.offset_top + 64.0

	if reveal_panel != null:
		var reveal_width := minf(viewport_size.x - (72.0 if micro_layout else 120.0), 520.0 if micro_layout else (600.0 if compact_layout else 720.0))
		var reveal_half_width := reveal_width * 0.5
		reveal_panel.offset_left = -reveal_half_width
		reveal_panel.offset_right = reveal_half_width
		reveal_panel.offset_top = -124.0 if micro_layout else (-146.0 if compact_layout else -164.0)
		reveal_panel.offset_bottom = -20.0 if micro_layout else (-30.0 if compact_layout else -16.0)

	if soundtrack_toast != null:
		var toast_width := 220.0 if micro_layout else (248.0 if compact_layout else 280.0)
		var toast_top := stack_top + 6.0
		if compact_layout:
			toast_top = maxf(toast_top, boss_bottom + (10.0 if micro_layout else 12.0))
			soundtrack_toast.anchor_left = 0.0
			soundtrack_toast.anchor_right = 0.0
			soundtrack_toast.offset_left = 0.0
			soundtrack_toast.offset_right = toast_width
		else:
			soundtrack_toast.anchor_left = 1.0
			soundtrack_toast.anchor_right = 1.0
			soundtrack_toast.offset_left = -toast_width
			soundtrack_toast.offset_right = 0.0
		soundtrack_toast.offset_top = toast_top
		soundtrack_toast.offset_bottom = soundtrack_toast.offset_top + (84.0 if micro_layout else 92.0)

	var overlay_margin_x := 14.0 if micro_layout else (18.0 if web_tight_layout else 24.0)
	var overlay_margin_y := 12.0 if micro_layout else (16.0 if web_tight_layout else 24.0)
	_set_overlay_panel_rect(map_panel, 940.0 if micro_layout else (1080.0 if web_tight_layout else 1240.0), 620.0 if micro_layout else (610.0 if web_tight_layout else 684.0), overlay_margin_x, overlay_margin_y)
	_set_overlay_panel_rect(choice_panel, 900.0 if micro_layout else (960.0 if web_tight_layout else 1000.0), 500.0 if micro_layout else (520.0 if web_tight_layout else 500.0), overlay_margin_x, overlay_margin_y)
	_set_overlay_panel_rect(state_panel, 640.0 if micro_layout else (700.0 if web_tight_layout else 760.0), 460.0 if micro_layout else (520.0 if web_tight_layout else 600.0), overlay_margin_x, overlay_margin_y)
	if map_content_box != null:
		map_content_box.vertical = micro_layout
		map_content_box.add_theme_constant_override("separation", 12 if micro_layout else 18)
	if map_canvas != null:
		map_canvas.custom_minimum_size = Vector2(0.0 if micro_layout else (640.0 if web_tight_layout else 760.0), 224.0 if micro_layout else (400.0 if web_tight_layout else 520.0))
	if map_side_panel != null:
		map_side_panel.custom_minimum_size = Vector2(0.0 if micro_layout else (272.0 if web_tight_layout else 300.0), 176.0 if micro_layout else 0.0)
	if map_side_box != null:
		map_side_box.add_theme_constant_override("separation", 10 if micro_layout else 12)
	if map_side_spacer != null:
		map_side_spacer.visible = not micro_layout
	if map_title_label != null:
		_set_label_font_size(map_title_label, 30 if micro_layout else (34 if web_tight_layout else 38))
	if map_summary_label != null:
		_set_label_font_size(map_summary_label, 16 if micro_layout else 18)
		if map_summary_label.has_meta("map_full_text"):
			map_summary_label.text = _format_map_summary_text(String(map_summary_label.get_meta("map_full_text", "")))
	if map_legend_title_label != null:
		_set_label_font_size(map_legend_title_label, 20 if micro_layout else (22 if web_tight_layout else 24))
	if map_zoom_label != null:
		_set_label_font_size(map_zoom_label, 15 if micro_layout else 17)
	if map_help_label != null:
		_set_label_font_size(map_help_label, 14 if micro_layout else (15 if web_tight_layout else 17))
		map_help_label.text = _build_map_help_text()
	if map_zoom_row != null:
		map_zoom_row.add_theme_constant_override("separation", 8 if micro_layout else 10)
	_refresh_map_legend_density()
	for zoom_button in map_zoom_buttons:
		if zoom_button == null:
			continue
		zoom_button.custom_minimum_size = Vector2(64.0 if micro_layout else (74.0 if web_tight_layout else 86.0), 42.0 if micro_layout else 48.0)
		zoom_button.add_theme_font_size_override("font_size", 14 if micro_layout else 16)
	if map_close_button != null:
		map_close_button.custom_minimum_size = Vector2(0.0, 46.0 if micro_layout else 50.0)
		map_close_button.add_theme_font_size_override("font_size", 15 if micro_layout else 17)
	if choice_title_label != null:
		_set_label_font_size(choice_title_label, 32 if micro_layout else (34 if web_tight_layout else 38))
	if choice_hint_label != null:
		_set_label_font_size(choice_hint_label, 16 if micro_layout else 18)
		if choice_mode == "radical":
			choice_hint_label.text = _build_radical_choice_hint(choice_pending_count)
		elif choice_mode == "word":
			choice_hint_label.text = _build_word_choice_hint()
	if choice_cards_grid != null:
		choice_cards_grid.columns = 2 if (micro_layout or web_tight_layout) else 3
		choice_cards_grid.add_theme_constant_override("h_separation", 10 if micro_layout else (12 if web_tight_layout else 16))
		choice_cards_grid.add_theme_constant_override("v_separation", 10 if micro_layout else 12)
	for choice_button in choice_buttons:
		if choice_button == null:
			continue
		choice_button.custom_minimum_size = Vector2(0.0, 136.0 if micro_layout else (156.0 if web_tight_layout else 278.0))
		choice_button.add_theme_font_size_override("font_size", 16 if micro_layout else (18 if web_tight_layout else 20))
		if choice_button.has_meta("choice_title"):
			choice_button.text = _format_choice_button_text(
				String(choice_button.get_meta("choice_title", "")),
				String(choice_button.get_meta("choice_headline", "")),
				String(choice_button.get_meta("choice_description", ""))
			)
	if state_title_label != null:
		_set_label_font_size(state_title_label, 34 if micro_layout else (38 if web_tight_layout else 42))
	if state_body_label != null:
		_set_label_font_size(state_body_label, 17 if micro_layout else (18 if web_tight_layout else 20))
	if state_preview_title_label != null:
		_set_label_font_size(state_preview_title_label, 15 if micro_layout else 16)
	for preview_line_label in state_preview_line_labels:
		if preview_line_label == null:
			continue
		_set_label_font_size(preview_line_label, 13 if micro_layout else 14)
	if state_name_hint_label != null:
		_set_label_font_size(state_name_hint_label, 14 if micro_layout else 16)
	if state_name_status_label != null:
		_set_label_font_size(state_name_status_label, 13 if micro_layout else 15)
	if state_name_row != null:
		state_name_row.vertical = micro_layout
		state_name_row.add_theme_constant_override("separation", 8 if micro_layout else 10)
	if state_name_input != null:
		state_name_input.custom_minimum_size = Vector2(0.0, 44.0 if micro_layout else 48.0)
		state_name_input.add_theme_font_size_override("font_size", 17 if micro_layout else (18 if web_tight_layout else 20))
	if state_name_button != null:
		state_name_button.custom_minimum_size = Vector2(0.0 if micro_layout else (146.0 if web_tight_layout else 160.0), 44.0 if micro_layout else 48.0)
		state_name_button.add_theme_font_size_override("font_size", 16 if micro_layout else 18)
		if state_name_button.has_meta("state_full_text"):
			state_name_button.text = _format_state_button_text(String(state_name_button.get_meta("state_full_text", "")))
	if state_buttons_box != null:
		state_buttons_box.columns = 2 if (micro_layout or web_tight_layout) else 1
		state_buttons_box.add_theme_constant_override("h_separation", 8 if micro_layout else 10)
		state_buttons_box.add_theme_constant_override("v_separation", 8 if micro_layout else 10)
	for state_button in [state_primary_button, state_secondary_button, state_tertiary_button, state_quaternary_button, state_quinary_button, state_senary_button]:
		if state_button == null:
			continue
		state_button.custom_minimum_size = Vector2(0.0, 44.0 if micro_layout else (48.0 if web_tight_layout else 52.0))
		state_button.add_theme_font_size_override("font_size", 18 if micro_layout else (20 if web_tight_layout else 22))
		if state_button.has_meta("state_full_text"):
			state_button.text = _format_state_button_text(String(state_button.get_meta("state_full_text", "")))

	_set_label_font_size(compact_health_label, 15 if micro_layout else 17)
	_set_label_font_size(compact_progress_label, 15 if micro_layout else 17)
	_set_label_font_size(compact_status_label, 14 if micro_layout else 16)
	_set_label_font_size(compact_radicals_label, 13 if micro_layout else 15)
	_set_label_font_size(compact_tip_label, 13 if micro_layout else 15)
	_set_label_font_size(compact_route_label, 12 if micro_layout else 13)
	_set_label_font_size(callout_title_label, 13 if micro_layout else 14)
	_set_label_font_size(callout_text_label, 14 if micro_layout else 16)
	_set_label_font_size(callout_detail_label, 11 if micro_layout else (12 if compact_layout else 13))
	_set_label_font_size(soundtrack_toast_title_label, 20 if micro_layout else (22 if web_tight_layout else 24))
	_set_label_font_size(soundtrack_toast_detail_label, 13 if micro_layout else 15)
	_set_label_font_size(tip_label, 16 if web_tight_layout else 18)
	_set_label_font_size(objective_route_title_label, 16 if web_tight_layout else 18)
	_set_label_font_size(objective_route_detail_label, 14 if web_tight_layout else 15)
	_set_label_font_size(objective_stage_label, 13 if web_tight_layout else 14)


func _should_use_compact_layout() -> bool:
	var viewport_size := get_viewport().get_visible_rect().size
	if _is_web_platform():
		return viewport_size.x <= 1680.0 or viewport_size.y <= 920.0
	return (
		viewport_size.x <= 1500.0 or
		viewport_size.y <= 820.0 or
		DisplayServer.is_touchscreen_available() or
		OS.has_feature("mobile") or
		OS.has_feature("android") or
		OS.has_feature("ios") or
		OS.has_feature("web_android") or
		OS.has_feature("web_ios")
	)


func _is_web_platform() -> bool:
	return OS.has_feature("web") or OS.has_feature("web_android") or OS.has_feature("web_ios")


func _should_use_web_tight_layout() -> bool:
	if not _is_web_platform():
		return false
	var viewport_size := get_viewport().get_visible_rect().size
	return viewport_size.x <= 1366.0 or viewport_size.y <= 760.0


func _should_use_micro_layout() -> bool:
	var viewport_size := get_viewport().get_visible_rect().size
	if _is_web_platform():
		return viewport_size.x <= 1180.0 or viewport_size.y <= 700.0
	return viewport_size.x <= 1080.0 or viewport_size.y <= 640.0


func _should_hide_compact_event_panel() -> bool:
	return _should_use_micro_layout() and event_log_entries.is_empty()


func _truncate_overlay_text(text: String, limit: int) -> String:
	var clean_text := text.strip_edges().replace("\n", " ")
	if limit <= 0 or clean_text.length() <= limit:
		return clean_text
	return "%s..." % clean_text.substr(0, maxi(limit - 3, 0))


func _build_radical_choice_hint(pending_count: int) -> String:
	if _should_use_micro_layout():
		return _battle_state_text(
			battle_hud_content,
			"radical_choice_hint_micro_format",
			"三选一偏旁。剩余：%d",
			"Pick 1 radical. Left: %d"
		) % pending_count
	if _should_use_web_tight_layout():
		return _battle_state_text(
			battle_hud_content,
			"radical_choice_hint_tight_format",
			"三选一偏旁，推进合字路线。剩余：%d",
			"Pick 1 radical to advance a glyph route. Left: %d"
		) % pending_count
	return _battle_state_text(
		battle_hud_content,
		"radical_choice_hint_full_format",
		"从三枚偏旁里选一枚。它会推进合字，满级后继续磨成词技。剩余待选：%d",
		"Pick one of the three radicals. It pushes a glyph route forward and later refines into a phrase art. Remaining picks: %d"
	) % pending_count


func _build_word_choice_hint() -> String:
	if _should_use_micro_layout():
		return _battle_state_text(
			battle_hud_content,
			"word_choice_hint_micro",
			"消耗 1 枚相关偏旁，磨成词技。",
			"Spend 1 linked radical to refine a phrase art."
		)
	if _should_use_web_tight_layout():
		return _battle_state_text(
			battle_hud_content,
			"word_choice_hint_tight",
			"消耗 1 枚相关偏旁，把满级合字磨成词技。",
			"Spend one linked radical to refine a maxed glyph into a phrase art."
		)
	return _battle_state_text(
		battle_hud_content,
		"word_choice_hint_full",
		"把满级合字的余材磨成更高一层的词技。每次磨词会消耗一枚相关偏旁。",
		"Use extra maxed-glyph stock to refine a higher phrase art. Each refinement spends one related radical."
	)


func _format_choice_button_text(title: String, headline: String, description: String) -> String:
	var clean_title := title.strip_edges()
	var clean_headline := headline.strip_edges()
	var clean_description := description.strip_edges()
	if _should_use_micro_layout():
		var micro_line := clean_headline if not clean_headline.is_empty() else clean_description
		micro_line = _truncate_overlay_text(micro_line, 30 if _is_english() else 14)
		return "%s\n%s" % [clean_title, micro_line] if not micro_line.is_empty() else clean_title
	if _should_use_web_tight_layout():
		var parts: Array[String] = [clean_title]
		if not clean_headline.is_empty():
			parts.append(_truncate_overlay_text(clean_headline, 34 if _is_english() else 18))
		if not clean_description.is_empty():
			parts.append(_truncate_overlay_text(clean_description, 44 if _is_english() else 22))
		return "\n".join(parts)
	return "%s\n%s\n%s" % [clean_title, clean_headline, clean_description]


func _format_map_summary_text(summary: String) -> String:
	var full_summary := summary.strip_edges()
	if full_summary.is_empty():
		return full_summary
	if not (_should_use_micro_layout() or _should_use_web_tight_layout()):
		return full_summary
	var compact_segments: Array[String] = []
	for segment_variant in full_summary.split("  ·  "):
		var segment := String(segment_variant).strip_edges()
		if segment.is_empty():
			continue
		compact_segments.append(_compact_map_summary_segment(segment))
	return "  ·  ".join(compact_segments)


func _compact_map_summary_segment(segment: String) -> String:
	var patterns := [
		["Enemies ", "E"],
		["Inkstones ", "I"],
		["Bushes ", "B"],
		["Landmarks ", "L"],
		["Explored ", "X"],
		["敌群 ", "敌"],
		["砚台 ", "砚"],
		["草丛 ", "草"],
		["地标 ", "标"],
		["探索 ", "探"]
	]
	for pattern in patterns:
		var prefix := String(pattern[0])
		var replacement := String(pattern[1])
		if segment.begins_with(prefix):
			return "%s%s" % [replacement, segment.trim_prefix(prefix)]
	return _truncate_overlay_text(segment, 12 if _should_use_micro_layout() else 18)


func _build_map_help_text() -> String:
	var hud_content := FrontEndContent.battle_hud_content()
	if _should_use_micro_layout():
		return _battle_state_text(hud_content, "map_help_micro", "拖拽查看，按钮缩放。Esc / M 收起。", "Drag to pan. Buttons zoom. Esc / M closes.")
	if _should_use_web_tight_layout():
		return _battle_state_text(hud_content, "map_help_tight", "拖拽查看，滚轮或按钮缩放。Esc / Tab / M 收起。", "Drag to pan. Wheel or buttons zoom. Esc / Tab / M closes.")
	return _battle_state_text(hud_content, "map_help_full", "拖拽视野，滚轮或按钮缩放。按 Esc、Tab、M 或再次点地图收起。", "Drag to pan. Use the wheel or buttons to zoom. Press Esc, Tab, M, or the map button again to close.")


func _refresh_map_legend_density() -> void:
	var micro_layout := _should_use_micro_layout()
	var web_tight_layout := _should_use_web_tight_layout()
	var visible_rows := 4 if micro_layout else (5 if web_tight_layout else map_legend_rows.size())
	var detail_rows := 2 if micro_layout else (3 if web_tight_layout else map_legend_rows.size())
	for index in range(map_legend_rows.size()):
		var row := map_legend_rows[index]
		if row == null:
			continue
		row.visible = index < visible_rows
		if row is HBoxContainer:
			(row as HBoxContainer).add_theme_constant_override("separation", 8 if micro_layout else 10)
		var icon_panel := row.get_meta("legend_icon_panel", null) as Control
		if icon_panel != null:
			icon_panel.custom_minimum_size = Vector2(40.0 if micro_layout else (42.0 if web_tight_layout else 46.0), 40.0 if micro_layout else (42.0 if web_tight_layout else 46.0))
		var icon_label := row.get_meta("legend_icon_label", null) as Label
		if icon_label != null:
			_set_label_font_size(icon_label, 18 if micro_layout else (20 if web_tight_layout else 22))
		var title_label := row.get_meta("legend_title_label", null) as Label
		if title_label != null:
			_set_label_font_size(title_label, 15 if micro_layout else (16 if web_tight_layout else 18))
			var full_title := String(row.get_meta("legend_full_title", title_label.text))
			title_label.tooltip_text = full_title
			title_label.text = _truncate_overlay_text(
				full_title,
				14 if micro_layout and _is_english() else (8 if micro_layout else (22 if web_tight_layout and _is_english() else (12 if web_tight_layout else 64)))
			)
		var detail_label := row.get_meta("legend_detail_label", null) as Label
		if detail_label != null:
			detail_label.visible = index < detail_rows
			_set_label_font_size(detail_label, 13 if micro_layout else 14)
			var full_detail := String(row.get_meta("legend_full_detail", detail_label.text))
			detail_label.tooltip_text = full_detail
			detail_label.text = _truncate_overlay_text(
				full_detail,
				26 if micro_layout and _is_english() else (12 if micro_layout else (42 if web_tight_layout and _is_english() else (20 if web_tight_layout else 96)))
			)


func _format_state_button_text(text: String) -> String:
	var compact_copy := _should_use_micro_layout() or _should_use_web_tight_layout()
	var full_text := text.strip_edges()
	if not compact_copy:
		return full_text
	if _is_english():
		var english_compact := full_text
		var english_prefixes := {
			"Performance: ": "Perf · ",
			"Glyph FX: ": "Glyph · ",
			"Enemy Health Bars: ": "HP Bars · ",
			"Ambient Glyphs: ": "Ambient · ",
			"Distant Enemy Detail: ": "Distant · ",
			"Switch to Test Board · ": "Test Board · ",
			"Switch to Main Board · ": "Main Board · "
		}
		for prefix in english_prefixes.keys():
			if english_compact.begins_with(prefix):
				return String(english_prefixes[prefix]) + english_compact.trim_prefix(prefix)
		match english_compact:
			"Resume Battle":
				return "Resume"
			"Battle Setup":
				return "Setup"
			"Restart Run":
				return "Restart"
			"Return to Menu":
				return "Menu"
			"Back to Pause":
				return "Back"
			"Back to Summary":
				return "Summary"
			"View Test Board":
				return "Test Board"
			"View Main Board":
				return "Main Board"
			"Save Alias":
				return "Save"
		return english_compact
	var chinese_compact := full_text
	var chinese_prefixes := {
		"演出档：": "演出：",
		"视觉字效：": "字效：",
		"敌方血条：": "血条：",
		"环境字影：": "环境：",
		"远敌细节：": "远敌：",
		"切到试阵榜 · ": "试阵榜 · ",
		"切到主卷榜 · ": "主卷榜 · ",
		"查看试阵榜": "试阵榜",
		"查看主卷榜": "主卷榜"
	}
	for prefix in chinese_prefixes.keys():
		if chinese_compact.begins_with(prefix):
			return String(chinese_prefixes[prefix]) + chinese_compact.trim_prefix(prefix)
	match chinese_compact:
		"继续战斗":
			return "继续"
		"战场布置":
			return "设置"
		"重新开始":
			return "重开"
		"返回菜单":
			return "菜单"
		"返回暂停":
			return "返回"
		"返回结算":
			return "结算"
		"保存署名":
			return "保存"
	return chinese_compact


func _safe_area_insets() -> Dictionary:
	var visible_rect := get_viewport().get_visible_rect()
	var safe_area: Rect2 = Rect2(DisplayServer.get_display_safe_area())
	if safe_area.size.x <= 0.0 or safe_area.size.y <= 0.0:
		return {"left": 0.0, "top": 0.0, "right": 0.0, "bottom": 0.0}

	var left := maxf(safe_area.position.x - visible_rect.position.x, 0.0)
	var top := maxf(safe_area.position.y - visible_rect.position.y, 0.0)
	var right := maxf(
		(visible_rect.position.x + visible_rect.size.x) - (safe_area.position.x + safe_area.size.x),
		0.0
	)
	var bottom := maxf(
		(visible_rect.position.y + visible_rect.size.y) - (safe_area.position.y + safe_area.size.y),
		0.0
	)
	return {"left": left, "top": top, "right": right, "bottom": bottom}


func _set_overlay_panel_rect(panel: Control, design_width: float, design_height: float, margin_x: float, margin_y: float) -> void:
	if panel == null:
		return
	var safe_insets := _safe_area_insets()
	var viewport_size := get_viewport().get_visible_rect().size
	var usable_position := Vector2(float(safe_insets["left"]) + margin_x, float(safe_insets["top"]) + margin_y)
	var usable_size := Vector2(
		maxf(240.0, viewport_size.x - float(safe_insets["left"]) - float(safe_insets["right"]) - margin_x * 2.0),
		maxf(220.0, viewport_size.y - float(safe_insets["top"]) - float(safe_insets["bottom"]) - margin_y * 2.0)
	)
	var panel_size := Vector2(minf(design_width, usable_size.x), minf(design_height, usable_size.y))
	panel.anchor_left = 0.0
	panel.anchor_top = 0.0
	panel.anchor_right = 0.0
	panel.anchor_bottom = 0.0
	panel.position = usable_position + (usable_size - panel_size) * 0.5
	panel.size = panel_size


func show_map_overlay(snapshot: Dictionary) -> void:
	if map_overlay == null or map_canvas == null:
		return
	overlay_label.visible = false
	_hide_reveal()
	map_canvas.set_snapshot(snapshot)
	var hud_content := FrontEndContent.battle_hud_content()
	var fallback_summary := _battle_state_text(
		hud_content,
		"map_summary_empty",
		"敌群 0  ·  砚台 0  ·  草丛 0",
		"Enemies 0  ·  Inkstones 0  ·  Bushes 0"
	)
	var full_summary := _localize_text(String(snapshot.get("summary", fallback_summary)))
	map_summary_label.set_meta("map_full_text", full_summary)
	map_summary_label.tooltip_text = full_summary
	map_summary_label.text = _format_map_summary_text(full_summary)
	_update_map_zoom_label()
	map_overlay.visible = true


func hide_map_overlay() -> void:
	if map_overlay == null:
		return
	map_overlay.visible = false
	if map_canvas != null:
		map_canvas.cancel_drag()


func _build_map_overlay(root: Control) -> void:
	var hud_content := FrontEndContent.battle_hud_content()
	map_overlay = Control.new()
	map_zoom_buttons = []
	map_close_button = null
	map_content_box = null
	map_side_box = null
	map_side_spacer = null
	map_zoom_row = null
	map_legend_rows.clear()
	map_help_label = null
	map_legend_title_label = null
	map_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	map_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	map_overlay.visible = false
	root.add_child(map_overlay)

	var scrim := ColorRect.new()
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.01, 0.02, 0.03, 0.82)
	map_overlay.add_child(scrim)

	var panel := PanelContainer.new()
	map_panel = panel
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

	map_title_label = _make_label(_battle_state_text(hud_content, "map_title", "残卷地图", "Scroll Map"), 38, Color(1.0, 0.95, 0.86, 1.0))
	shell.add_child(map_title_label)
	map_summary_label = _make_label("", 18, Color(0.88, 0.92, 0.96, 0.94))
	shell.add_child(map_summary_label)

	map_content_box = BoxContainer.new()
	map_content_box.vertical = false
	map_content_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_content_box.add_theme_constant_override("separation", 18)
	shell.add_child(map_content_box)

	var map_frame := PanelContainer.new()
	map_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	map_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_frame.add_theme_stylebox_override("panel", _make_panel_style(Color(0.03, 0.05, 0.06, 0.94), Color(0.34, 0.44, 0.52, 0.7), 22))
	map_content_box.add_child(map_frame)

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
	map_side_panel = side_panel
	side_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side_panel.custom_minimum_size = Vector2(300.0, 0.0)
	side_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.06, 0.08, 0.1, 0.9), Color(0.34, 0.44, 0.52, 0.58), 22))
	map_content_box.add_child(side_panel)

	var side_margin := MarginContainer.new()
	side_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	side_margin.add_theme_constant_override("margin_left", 18)
	side_margin.add_theme_constant_override("margin_top", 18)
	side_margin.add_theme_constant_override("margin_right", 18)
	side_margin.add_theme_constant_override("margin_bottom", 18)
	side_panel.add_child(side_margin)

	map_side_box = VBoxContainer.new()
	map_side_box.add_theme_constant_override("separation", 12)
	side_margin.add_child(map_side_box)

	map_legend_title_label = _make_label(_battle_state_text(hud_content, "map_legend_title", "图例", "Legend"), 24, Color(1.0, 0.92, 0.8, 1.0))
	map_side_box.add_child(map_legend_title_label)
	var legend_rows_variant: Variant = hud_content.get("map_legend_rows", [])
	if legend_rows_variant is Array:
		for legend_data_variant in legend_rows_variant:
			if not (legend_data_variant is Dictionary):
				continue
			var legend_data := legend_data_variant as Dictionary
			var legend_row := _make_map_legend_row(
				String(legend_data.get("symbol", "")),
				_battle_state_entry_text(legend_data.get("title", {}), "执笔者", "Scribe"),
				_battle_state_entry_text(legend_data.get("detail", {}), "当前角色朝向与位置。", "Your current position and facing."),
				Color(legend_data.get("color", Color(0.58, 0.66, 0.76, 1.0)))
			)
			map_legend_rows.append(legend_row)
			map_side_box.add_child(legend_row)

	map_side_spacer = Control.new()
	map_side_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	map_side_box.add_child(map_side_spacer)

	map_help_label = _make_label(_build_map_help_text(), 17, Color(0.88, 0.9, 0.93, 0.92))
	map_side_box.add_child(map_help_label)
	map_zoom_label = _make_label(
		_battle_state_text(hud_content, "map_zoom_format", "缩放  %.2fx", "Zoom  %.2fx") % 1.0,
		17,
		Color(0.96, 0.82, 0.56, 0.98)
	)
	map_side_box.add_child(map_zoom_label)

	map_zoom_row = HBoxContainer.new()
	map_zoom_row.add_theme_constant_override("separation", 10)
	map_side_box.add_child(map_zoom_row)

	var zoom_out_button := _make_pill_button(_battle_state_text(hud_content, "map_zoom_out", "缩小", "Zoom Out"), Callable(self, "_on_map_zoom_out_pressed"))
	zoom_out_button.custom_minimum_size = Vector2(86.0, 48.0)
	map_zoom_row.add_child(zoom_out_button)
	map_zoom_buttons.append(zoom_out_button)

	var zoom_in_button := _make_pill_button(_battle_state_text(hud_content, "map_zoom_in", "放大", "Zoom In"), Callable(self, "_on_map_zoom_in_pressed"))
	zoom_in_button.custom_minimum_size = Vector2(86.0, 48.0)
	map_zoom_row.add_child(zoom_in_button)
	map_zoom_buttons.append(zoom_in_button)

	var zoom_reset_button := _make_pill_button(_battle_state_text(hud_content, "map_zoom_reset", "重置", "Reset"), Callable(self, "_on_map_zoom_reset_pressed"))
	zoom_reset_button.custom_minimum_size = Vector2(86.0, 48.0)
	map_zoom_row.add_child(zoom_reset_button)
	map_zoom_buttons.append(zoom_reset_button)

	map_close_button = _make_pill_button(_battle_state_text(hud_content, "map_close", "收起地图", "Close Map"), Callable(self, "_emit_map_toggle"))
	map_close_button.custom_minimum_size = Vector2(0.0, 50.0)
	map_side_box.add_child(map_close_button)


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
	choice_panel = panel
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

	choice_title_label = _make_label(
		_battle_state_text(battle_hud_content, "choice_radical_title_placeholder", "字力突破", "Ink Breakthrough"),
		38,
		Color(1.0, 0.94, 0.86, 1.0)
	)
	choice_hint_label = _make_label("", 18, Color(0.88, 0.92, 0.96, 0.96))
	box.add_child(choice_title_label)
	box.add_child(choice_hint_label)

	choice_cards_grid = GridContainer.new()
	choice_cards_grid.columns = 3
	choice_cards_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	choice_cards_grid.add_theme_constant_override("h_separation", 16)
	choice_cards_grid.add_theme_constant_override("v_separation", 12)
	box.add_child(choice_cards_grid)

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
		choice_cards_grid.add_child(button)


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
	state_panel = panel
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -380.0
	panel.offset_top = -300.0
	panel.offset_right = 380.0
	panel.offset_bottom = 300.0
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

	state_preview_panel = PanelContainer.new()
	state_preview_panel.visible = false
	state_preview_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.1, 0.12, 0.16, 0.94), Color(0.74, 0.84, 1.0, 0.46), 18))
	box.add_child(state_preview_panel)

	var preview_margin := MarginContainer.new()
	preview_margin.add_theme_constant_override("margin_left", 16)
	preview_margin.add_theme_constant_override("margin_top", 14)
	preview_margin.add_theme_constant_override("margin_right", 16)
	preview_margin.add_theme_constant_override("margin_bottom", 14)
	state_preview_panel.add_child(preview_margin)

	var preview_box := VBoxContainer.new()
	preview_box.add_theme_constant_override("separation", 6)
	preview_margin.add_child(preview_box)

	state_preview_title_label = _make_label(
		_battle_state_text(battle_hud_content, "state_preview_title", "下一段预览", "Next Preview"),
		16,
		Color(0.9, 0.96, 1.0, 0.98)
	)
	preview_box.add_child(state_preview_title_label)

	for _index in range(6):
		var preview_line := _make_label("", 14, Color(0.86, 0.92, 0.98, 0.92))
		preview_line.visible = false
		state_preview_line_labels.append(preview_line)
		preview_box.add_child(preview_line)

	state_name_hint_label = _make_label("", 16, Color(0.96, 0.82, 0.56, 0.96))
	box.add_child(state_name_hint_label)

	state_name_row = BoxContainer.new()
	state_name_row.vertical = false
	state_name_row.add_theme_constant_override("separation", 10)
	box.add_child(state_name_row)

	state_name_input = LineEdit.new()
	state_name_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	state_name_input.custom_minimum_size = Vector2(0.0, 48.0)
	state_name_input.placeholder_text = _battle_state_text(
		battle_hud_content,
		"alias_placeholder_keep_sigil",
		"留空则保留玩家名帖署名",
		"Leave blank to keep the Player Sigil alias"
	)
	state_name_input.clear_button_enabled = true
	state_name_input.add_theme_font_override("font", ui_font)
	state_name_input.add_theme_font_size_override("font_size", 20)
	state_name_input.text_submitted.connect(_on_state_name_submitted)
	state_name_row.add_child(state_name_input)

	state_name_button = _make_state_button()
	state_name_button.custom_minimum_size = Vector2(160.0, 48.0)
	state_name_button.set_meta(
		"state_full_text",
		_battle_state_text(battle_hud_content, "alias_save_text", "保存署名", "Save Alias")
	)
	state_name_button.tooltip_text = _battle_state_text(
		battle_hud_content,
		"alias_save_text",
		"保存署名",
		"Save Alias"
	)
	state_name_button.text = _format_state_button_text(String(state_name_button.get_meta("state_full_text", "")))
	state_name_button.add_theme_stylebox_override("normal", _make_button_style(Color(0.92, 0.62, 0.28, 1.0), 18))
	state_name_button.add_theme_stylebox_override("hover", _make_button_style(Color(0.98, 0.7, 0.34, 1.0), 18))
	state_name_button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.84, 0.54, 0.22, 1.0), 18))
	state_name_button.pressed.connect(_on_state_name_save_pressed)
	state_name_row.add_child(state_name_button)

	state_name_status_label = _make_label("", 15, Color(0.82, 0.9, 1.0, 0.92))
	box.add_child(state_name_status_label)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)

	state_buttons_box = GridContainer.new()
	state_buttons_box.columns = 1
	state_buttons_box.add_theme_constant_override("h_separation", 10)
	state_buttons_box.add_theme_constant_override("v_separation", 10)
	box.add_child(state_buttons_box)

	state_primary_button = _make_state_button()
	state_secondary_button = _make_state_button()
	state_tertiary_button = _make_state_button()
	state_quaternary_button = _make_state_button()
	state_quinary_button = _make_state_button()
	state_senary_button = _make_state_button()
	state_buttons_box.add_child(state_primary_button)
	state_buttons_box.add_child(state_secondary_button)
	state_buttons_box.add_child(state_tertiary_button)
	state_buttons_box.add_child(state_quaternary_button)
	state_buttons_box.add_child(state_quinary_button)
	state_buttons_box.add_child(state_senary_button)


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
	button.set_meta("choice_title", title)
	button.set_meta("choice_headline", headline)
	button.set_meta("choice_description", description)
	button.text = _format_choice_button_text(title, headline, description)
	button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	button.set_meta(meta_key, meta_value)
	button.disabled = false
	button.add_theme_stylebox_override("normal", _make_button_style(color, 24))
	button.add_theme_stylebox_override("hover", _make_button_style(color.lightened(0.08), 24))
	button.add_theme_stylebox_override("pressed", _make_button_style(color.darkened(0.08), 24))


func _make_state_button() -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0.0, 52.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_override("font", ui_font)
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_color_override("font_color", Color(0.08, 0.08, 0.08, 1.0))
	return button


func _configure_state_button(button: Button, text: String, callback: Callable) -> void:
	if button == null:
		return
	button.visible = true
	button.set_meta("state_full_text", text)
	button.tooltip_text = text
	button.text = _format_state_button_text(text)
	_clear_state_button_connections(button)
	button.add_theme_stylebox_override("normal", _make_button_style(Color(0.92, 0.62, 0.28, 1.0), 18))
	button.add_theme_stylebox_override("hover", _make_button_style(Color(0.98, 0.7, 0.34, 1.0), 18))
	button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.84, 0.54, 0.22, 1.0), 18))
	if callback.is_valid():
		button.pressed.connect(callback)


func _hide_state_button(button: Button) -> void:
	if button == null:
		return
	button.visible = false
	_clear_state_button_connections(button)


func _clear_state_button_connections(button: Button) -> void:
	for connection_variant in button.pressed.get_connections():
		var connection: Dictionary = connection_variant as Dictionary
		var callable: Callable = connection.get("callable", Callable())
		if button.pressed.is_connected(callable):
			button.pressed.disconnect(callable)


func _apply_state_overlay_theme(accent: Color) -> void:
	var preview_accent := accent.lerp(Color(0.82, 0.9, 1.0, 1.0), 0.34)
	if state_panel != null:
		state_panel.add_theme_stylebox_override(
			"panel",
			_make_panel_style(
				Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.96),
				Color(accent.r * 0.74 + 0.2, accent.g * 0.74 + 0.2, accent.b * 0.74 + 0.2, 0.92),
				24
			)
		)
	if state_preview_panel != null:
		state_preview_panel.add_theme_stylebox_override(
			"panel",
			_make_panel_style(
				Color(preview_accent.r * 0.12, preview_accent.g * 0.12, preview_accent.b * 0.16, 0.94),
				Color(preview_accent.r * 0.78 + 0.18, preview_accent.g * 0.78 + 0.18, preview_accent.b * 0.78 + 0.18, 0.5),
				18
			)
		)
	if state_preview_title_label != null:
		state_preview_title_label.add_theme_color_override(
			"font_color",
			Color(preview_accent.r * 0.22 + 0.72, preview_accent.g * 0.2 + 0.76, preview_accent.b * 0.18 + 0.78, 0.98)
		)


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
	var title_label := _make_label(title, 18, Color(1.0, 0.94, 0.86, 0.98))
	var detail_label := _make_label(detail, 15, Color(0.86, 0.9, 0.94, 0.9))
	text_box.add_child(title_label)
	text_box.add_child(detail_label)
	row.set_meta("legend_icon_panel", icon)
	row.set_meta("legend_icon_label", icon_label)
	row.set_meta("legend_title_label", title_label)
	row.set_meta("legend_detail_label", detail_label)
	row.set_meta("legend_full_title", title_label.text)
	row.set_meta("legend_full_detail", detail_label.text)
	title_label.tooltip_text = title_label.text
	detail_label.tooltip_text = detail_label.text
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
	map_zoom_label.text = _battle_state_text(
		battle_hud_content,
		"map_zoom_format",
		"缩放  %.2fx",
		"Zoom  %.2fx"
	) % map_canvas.zoom


func _show_state_name_editor(title_text: String, detail_text: String) -> void:
	if state_name_hint_label == null or state_name_row == null or state_name_input == null or state_name_button == null or state_name_status_label == null:
		return

	var last_entry: Dictionary = Session.get_last_recorded_leaderboard_run()
	if last_entry.is_empty():
		_hide_state_name_editor()
		return

	state_name_hint_label.visible = true
	state_name_hint_label.text = "%s\n%s" % [title_text, detail_text]
	state_name_row.visible = true
	state_name_input.visible = true
	state_name_input.text = String(last_entry.get("player_name", ""))
	state_name_button.visible = true
	state_name_button.disabled = false
	state_name_status_label.visible = true
	var leaderboard_content := FrontEndContent.local_leaderboard_content()
	state_name_status_label.text = _localize_text(String(leaderboard_content.get("alias_status_format", "当前署名：%s"))) % String(last_entry.get("player_name", ""))


func _hide_state_name_editor() -> void:
	if state_name_hint_label != null:
		state_name_hint_label.visible = false
		state_name_hint_label.text = ""
	if state_name_row != null:
		state_name_row.visible = false
	if state_name_input != null:
		state_name_input.visible = false
		state_name_input.text = ""
	if state_name_button != null:
		state_name_button.visible = false
		state_name_button.disabled = true
	if state_name_status_label != null:
		state_name_status_label.visible = false
		state_name_status_label.text = ""


func _on_state_name_submitted(_text: String) -> void:
	_save_state_name()


func _on_state_name_save_pressed() -> void:
	_save_state_name()


func _save_state_name() -> void:
	if state_name_input == null or state_name_status_label == null:
		return

	var resolved_name := Session.update_last_recorded_run_player_name(state_name_input.text)
	if resolved_name.is_empty():
		return

	state_name_input.text = resolved_name
	var leaderboard_content := FrontEndContent.local_leaderboard_content()
	state_name_status_label.text = _localize_text(String(leaderboard_content.get("alias_status_format", "当前署名：%s"))) % resolved_name
	if state_mode == "leaderboard":
		state_body_label.text = _build_local_leaderboard_text(local_leaderboard_view)


func _show_state_preview(title_text: String, lines: Array[String]) -> void:
	if state_preview_panel == null or state_preview_title_label == null:
		return
	var filtered_lines: Array[String] = []
	for line_variant in lines:
		var line_text := String(line_variant).strip_edges()
		if line_text.is_empty():
			continue
		filtered_lines.append(line_text)
	if filtered_lines.is_empty():
		_hide_state_preview()
		return
	state_preview_panel.visible = true
	state_preview_title_label.text = title_text
	for index in range(state_preview_line_labels.size()):
		var line_label := state_preview_line_labels[index]
		if line_label == null:
			continue
		if index < filtered_lines.size():
			line_label.visible = true
			line_label.text = filtered_lines[index]
		else:
			line_label.visible = false
			line_label.text = ""


func _hide_state_preview() -> void:
	if state_preview_panel != null:
		state_preview_panel.visible = false
	if state_preview_title_label != null:
		state_preview_title_label.text = ""
	for line_label in state_preview_line_labels:
		if line_label == null:
			continue
		line_label.visible = false
		line_label.text = ""


func _refresh_controls_text() -> void:
	if controls_label == null:
		return

	var lines := [
		_battle_state_text(battle_hud_content, "controls_move", "WASD / 方向键移动", "WASD / Arrow Keys move"),
		_battle_state_text(battle_hud_content, "controls_attack", "自动朝最近敌人出手", "Auto-attack the nearest enemy"),
		_battle_state_text(
			battle_hud_content,
			"controls_radical_choice",
			"升级时三选一偏旁",
			"Pick 1 of 3 radicals on level-up"
		),
		_battle_state_text(
			battle_hud_content,
			"controls_inkstone",
			"靠近砚台按 E 磨词",
			"Press E near the inkstone to refine phrases"
		),
		_battle_state_text(
			battle_hud_content,
			"controls_map_restart",
			"M / Tab 地图，R 重开，Esc 返回菜单",
			"M / Tab map, R restart, Esc return to menu"
		)
	]
	if test_tools_enabled:
		lines.append(
			_battle_state_text(
				battle_hud_content,
				"controls_test_tools",
				"试阵模式：右上可直接跳到下一波，并实时显示 FPS",
				"Test mode: jump to the next wave from the top-right and keep FPS visible"
			)
		)
	controls_label.text = "\n".join(lines)


func _emit_pause_resume() -> void:
	hide_state_overlay()
	pause_resume_requested.emit()


func _emit_chamber_interlude_selection(choice_id: String) -> void:
	hide_state_overlay()
	chamber_interlude_selected.emit(choice_id)


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


func _emit_test_next_wave() -> void:
	if not test_tools_enabled:
		return
	if choice_overlay != null and choice_overlay.visible:
		return
	if state_overlay != null and state_overlay.visible:
		return
	if map_overlay != null and map_overlay.visible:
		return
	test_next_wave_requested.emit()


func _emit_restart() -> void:
	restart_requested.emit()


func _emit_return_menu() -> void:
	return_menu_requested.emit()


func _format_time(elapsed: float) -> String:
	var total_seconds: int = int(floor(elapsed))
	var minutes: int = int(total_seconds / 60.0)
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
	button.text = _localize_text(text)
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


func _set_label_font_size(label: Label, font_size: int) -> void:
	if label == null or label.label_settings == null:
		return
	label.label_settings.font_size = font_size


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


func _make_compact_skill_chip(glyph: String, title: String, level: String, color: Color) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.custom_minimum_size = Vector2(90.0, 34.0)
	chip.tooltip_text = title if level.is_empty() else "%s · %s" % [title, level]
	chip.add_theme_stylebox_override("panel", _make_panel_style(Color(color.r * 0.16, color.g * 0.16, color.b * 0.18, 0.9), Color(color.r, color.g, color.b, 0.4), 16))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 4)
	chip.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	margin.add_child(row)

	var glyph_label := _make_label(glyph, 18, Color(0.98, 0.95, 0.88, 0.98))
	glyph_label.custom_minimum_size = Vector2(18.0, 0.0)
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(glyph_label)

	var level_label := _make_label(level, 12, Color(0.92, 0.94, 0.98, 0.9))
	level_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(level_label)
	return chip


func _make_route_tag_chip(text: String, accent: Color) -> PanelContainer:
	var chip := PanelContainer.new()
	chip.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.16, accent.g * 0.16, accent.b * 0.2, 0.9), Color(accent.r, accent.g, accent.b, 0.42), 16))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 6)
	chip.add_child(margin)

	var label := _make_label(text, 13, Color(0.98, 0.95, 0.88, 0.98))
	margin.add_child(label)
	return chip


func _make_event_log_row(text: String, color: Color, compact: bool = false, placeholder: bool = false) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0.0, 32.0 if compact else 38.0)
	var fill := Color(color.r * 0.13, color.g * 0.14, color.b * 0.16, 0.82)
	var border := Color(color.r, color.g, color.b, 0.34)
	if placeholder:
		fill = Color(0.08, 0.11, 0.14, 0.62)
		border = Color(0.42, 0.5, 0.6, 0.24)
	panel.add_theme_stylebox_override("panel", _make_panel_style(fill, border, 16))

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12 if compact else 14)
	margin.add_theme_constant_override("margin_top", 7 if compact else 8)
	margin.add_theme_constant_override("margin_right", 12 if compact else 14)
	margin.add_theme_constant_override("margin_bottom", 7 if compact else 8)
	panel.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8 if compact else 10)
	margin.add_child(row)

	var marker := ColorRect.new()
	marker.color = Color(0.55, 0.64, 0.72, 0.58) if placeholder else color
	marker.custom_minimum_size = Vector2(4.0, 14.0 if compact else 16.0)
	row.add_child(marker)

	var label := _make_label(
		text,
		12 if compact else 14,
		Color(0.8, 0.86, 0.92, 0.78) if placeholder else Color(0.95, 0.96, 0.92, 0.97)
	)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	return panel


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
		"badge": _battle_state_text(battle_hud_content, "skill_placeholder_badge", "等待成字", "Waiting to Form"),
		"title": _battle_state_text(battle_hud_content, "skill_placeholder_title", "尚未成型", "Not Formed Yet"),
		"detail": _battle_state_text(
			battle_hud_content,
			"skill_placeholder_detail",
			"先通过偏旁三选一推进合字，再把满级合字带去砚台磨成词技。",
			"Advance fusions through radical picks first, then bring maxed glyphs to the inkstone for phrase refinement."
		),
		"recipe": "日 + 月 / 亻 + 木 / 氵 + 每",
		"level": _battle_state_text(battle_hud_content, "skill_placeholder_level", "预备", "Readying"),
		"color": Color(0.44, 0.58, 0.72, 1.0)
	})


func _make_label(text: String, font_size: int, color: Color, spacing: float = 0.0) -> Label:
	var label := Label.new()
	label.text = _localize_text(text)
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


func _apply_soundtrack_style(panel: PanelContainer, accent: Color, fill_alpha: float, border_alpha: float) -> void:
	if panel == null:
		return
	panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(
			Color(accent.r * 0.14, accent.g * 0.14, accent.b * 0.18, fill_alpha),
			Color(accent.r, accent.g, accent.b, border_alpha),
			22
		)
	)


func _hide_reveal() -> void:
	reveal_time = 0.0
	reveal_duration = 0.0
	if reveal_panel != null:
		reveal_panel.visible = false
