extends CanvasLayer

var root: Control
var title_label: Label
var health_label: Label
var progress_label: Label
var runtime_label: Label
var tip_label: Label
var message_label: Label

var message_time := 0.0
var persistent_message := false


func _ready() -> void:
	_build_ui()
	set_process(true)


func _process(delta: float) -> void:
	if persistent_message:
		return

	if message_time > 0.0:
		message_time -= delta
		message_label.visible = true
		var alpha: float = clamp(message_time / 0.4, 0.0, 1.0)
		if message_time > 0.4:
			alpha = 1.0
		message_label.modulate = Color(1.0, 0.97, 0.9, alpha)
	else:
		message_label.visible = false


func set_health(current: float, maximum: float) -> void:
	if health_label == null:
		return
	health_label.text = "气血  %d / %d" % [int(ceil(current)), int(ceil(maximum))]


func set_progress(current: int, target: int, level: int) -> void:
	if progress_label == null:
		return
	progress_label.text = "字力  Lv.%d   %d / %d" % [level, current, target]


func set_runtime(elapsed: float, kills: int) -> void:
	if runtime_label == null:
		return
	var total_seconds := int(floor(elapsed))
	var minutes := int(total_seconds / 60)
	var seconds := total_seconds % 60
	var wave := 1 + int(elapsed / 30.0)
	runtime_label.text = "波次  %d   存活  %02d:%02d   斩字  %d" % [wave, minutes, seconds, kills]


func set_tip(text: String) -> void:
	if tip_label != null:
		tip_label.text = text


func show_message(text: String, duration: float = 2.5) -> void:
	persistent_message = false
	message_time = duration
	message_label.text = text
	message_label.visible = true
	message_label.modulate = Color(1.0, 0.97, 0.9, 1.0)


func set_game_over(enabled: bool) -> void:
	persistent_message = enabled
	if enabled:
		message_label.text = "墨潮将你吞没了。按 R 重新开局。"
		message_label.visible = true
		message_label.modulate = Color(1.0, 0.9, 0.84, 1.0)
		tip_label.text = "本轮结束。下一步可以扩成真正的升级选择、词语组合和 Boss 关。"


func _build_ui() -> void:
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var panel := PanelContainer.new()
	panel.position = Vector2(18.0, 18.0)
	panel.size = Vector2(360.0, 168.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	root.add_child(panel)

	var padding := MarginContainer.new()
	padding.set_anchors_preset(Control.PRESET_FULL_RECT)
	padding.add_theme_constant_override("margin_left", 14)
	padding.add_theme_constant_override("margin_top", 12)
	padding.add_theme_constant_override("margin_right", 14)
	padding.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(padding)

	var stats_box := VBoxContainer.new()
	stats_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	stats_box.add_theme_constant_override("separation", 6)
	padding.add_child(stats_box)

	title_label = _make_label("字海求生", 28, Color(1.0, 0.92, 0.76))
	health_label = _make_label("气血  100 / 100", 18, Color(0.96, 0.9, 0.86))
	progress_label = _make_label("字力  Lv.1   0 / 6", 18, Color(0.86, 0.93, 1.0))
	runtime_label = _make_label("波次  1   存活  00:00   斩字  0", 18, Color(0.92, 0.86, 0.8))
	tip_label = _make_label("WASD / 方向键移动，系统会自动瞄准最近的字灵。", 15, Color(0.83, 0.84, 0.9))

	stats_box.add_child(title_label)
	stats_box.add_child(health_label)
	stats_box.add_child(progress_label)
	stats_box.add_child(runtime_label)
	stats_box.add_child(tip_label)

	message_label = _make_label("", 24, Color(1.0, 0.97, 0.9))
	message_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	message_label.offset_left = 180.0
	message_label.offset_right = -180.0
	message_label.offset_top = 22.0
	message_label.offset_bottom = 70.0
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.visible = false
	root.add_child(message_label)


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text

	var settings := LabelSettings.new()
	settings.font_size = font_size
	settings.font_color = color
	label.label_settings = settings
	return label


func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.07, 0.1, 0.78)
	style.border_color = Color(0.88, 0.63, 0.32, 0.88)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	return style

