extends CanvasLayer

const CJKFont := preload("res://scripts/core/cjk_font.gd")

@export var pause_engine_while_visible := false
@export var title_text := "请横屏游玩"
@export_multiline var body_text := "手机竖屏会挡住战场与操作区。请将设备旋转到横向后继续。"

var overlay: Control
var guard_visible := false
var time_scale_locked := false
var saved_time_scale := 1.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	_build_overlay()
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_refresh_guard_state()


func _exit_tree() -> void:
	if time_scale_locked:
		_unlock_time_scale()


func _build_overlay() -> void:
	var ui_font: Font = CJKFont.get_font()

	overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var blocker := ColorRect.new()
	blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
	blocker.color = Color(0.02, 0.04, 0.06, 0.92)
	overlay.add_child(blocker)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(center)

	var shell := MarginContainer.new()
	shell.add_theme_constant_override("margin_left", 28)
	shell.add_theme_constant_override("margin_top", 28)
	shell.add_theme_constant_override("margin_right", 28)
	shell.add_theme_constant_override("margin_bottom", 28)
	center.add_child(shell)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(280.0, 0.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	shell.add_child(panel)

	var panel_margin := MarginContainer.new()
	panel_margin.add_theme_constant_override("margin_left", 32)
	panel_margin.add_theme_constant_override("margin_top", 28)
	panel_margin.add_theme_constant_override("margin_right", 32)
	panel_margin.add_theme_constant_override("margin_bottom", 28)
	panel.add_child(panel_margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel_margin.add_child(box)

	var badge := Label.new()
	badge.text = "MOBILE LANDSCAPE"
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_theme_font_override("font", ui_font)
	badge.add_theme_font_size_override("font_size", 18)
	badge.add_theme_color_override("font_color", Color(0.96, 0.82, 0.54, 0.92))
	box.add_child(badge)

	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_override("font", ui_font)
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(1.0, 0.95, 0.88, 1.0))
	box.add_child(title)

	var body := Label.new()
	body.text = body_text
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_override("font", ui_font)
	body.add_theme_font_size_override("font_size", 18)
	body.add_theme_color_override("font_color", Color(0.88, 0.92, 0.97, 0.96))
	box.add_child(body)

	var hint := Label.new()
	hint.text = "旋转设备后会自动继续。"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_override("font", ui_font)
	hint.add_theme_font_size_override("font_size", 17)
	hint.add_theme_color_override("font_color", Color(0.62, 0.82, 0.95, 0.92))
	box.add_child(hint)


func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.11, 0.15, 0.94)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.35, 0.68, 0.82, 0.52)
	style.corner_radius_top_left = 26
	style.corner_radius_top_right = 26
	style.corner_radius_bottom_right = 26
	style.corner_radius_bottom_left = 26
	style.shadow_size = 18
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.28)
	return style


func _on_viewport_size_changed() -> void:
	_refresh_guard_state()


func _refresh_guard_state() -> void:
	var should_show := _should_block_portrait()
	overlay.visible = should_show
	if should_show == guard_visible:
		return

	guard_visible = should_show
	if pause_engine_while_visible:
		if guard_visible:
			_lock_time_scale()
		else:
			_unlock_time_scale()


func _should_block_portrait() -> bool:
	if not _is_mobile_like_device():
		return false

	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return false

	return viewport_size.y > viewport_size.x


func _is_mobile_like_device() -> bool:
	return OS.has_feature("mobile") or DisplayServer.is_touchscreen_available()


func _lock_time_scale() -> void:
	if time_scale_locked:
		return
	saved_time_scale = Engine.time_scale
	Engine.time_scale = 0.0
	time_scale_locked = true


func _unlock_time_scale() -> void:
	if not time_scale_locked:
		return
	Engine.time_scale = saved_time_scale
	time_scale_locked = false
