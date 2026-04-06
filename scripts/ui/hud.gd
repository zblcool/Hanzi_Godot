extends CanvasLayer

const CJKFont := preload("res://scripts/cjk_font.gd")

const RUNE_GLYPHS := {
	"fire": "火",
	"water": "水",
	"rain": "雨",
	"field": "田",
	"person": "人",
	"wood": "木",
	"mouth": "口",
	"heart": "心",
	"mountain": "山",
	"wind": "风"
}

var root: Control
var title_label: Label
var health_label: Label
var progress_label: Label
var runtime_label: Label
var room_label: Label
var route_label: Label
var modifier_label: Label
var tip_label: Label
var inventory_label: Label
var characters_label: Label
var word_skill_label: Label
var message_label: Label

var selection_panel: PanelContainer
var selection_title_label: Label
var selection_body_label: Label
var selection_options_box: VBoxContainer

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
		var alpha = clamp(message_time / 0.4, 0.0, 1.0)
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
	var total_seconds = int(floor(elapsed))
	var minutes = int(total_seconds / 60.0)
	var seconds = total_seconds % 60
	var room_number = 1 + int(elapsed / 45.0)
	runtime_label.text = "局时  %02d:%02d   斩字  %d   压力  %d" % [minutes, seconds, kills, room_number]


func set_room_info(room_name: String, objective_text: String, modifier_text: String = "") -> void:
	if room_label != null:
		room_label.text = "房间  %s\n目标  %s" % [room_name, objective_text]
	if modifier_label != null:
		modifier_label.text = "房况  %s" % modifier_text


func set_build_snapshot(snapshot: Dictionary) -> void:
	if route_label == null:
		return

	var route_name = str(snapshot.get("route_name", "未立"))
	var route_description = str(snapshot.get("route_description", "首轮通关后会先确立字路。"))
	if route_name == "":
		route_name = "未立"
	route_label.text = "字路  %s\n%s" % [route_name, route_description]

	var rune_counts: Dictionary = snapshot.get("runes", {})
	var rune_parts: Array[String] = []
	for rune_id in RUNE_GLYPHS.keys():
		var count = int(rune_counts.get(rune_id, 0))
		if count <= 0:
			continue
		rune_parts.append("%s×%d" % [RUNE_GLYPHS[rune_id], count])
	if rune_parts.is_empty():
		inventory_label.text = "偏旁库存  暂无"
	else:
		inventory_label.text = "偏旁库存  %s" % "  ".join(rune_parts)

	var character_parts: Array[String] = []
	for entry in snapshot.get("characters", []):
		character_parts.append("%sLv.%d" % [str(entry.get("char", "字")), int(entry.get("level", 1))])
	if character_parts.is_empty():
		characters_label.text = "已成字诀  暂无"
	else:
		characters_label.text = "已成字诀  %d / %d 槽\n%s" % [
			int(snapshot.get("slots_used", 0)),
			int(snapshot.get("slots_total", 4)),
			"  ".join(character_parts)
		]

	var word_parts: Array[String] = []
	for entry in snapshot.get("word_skills", []):
		word_parts.append(str(entry.get("word", "词技")))
	if word_parts.is_empty():
		word_skill_label.text = "词技  暂无"
	else:
		word_skill_label.text = "词技  %s" % "  /  ".join(word_parts)


func set_tip(text: String) -> void:
	if tip_label != null:
		tip_label.text = text


func show_message(text: String, duration: float = 2.5) -> void:
	persistent_message = false
	message_time = duration
	message_label.text = text
	message_label.visible = true
	message_label.modulate = Color(1.0, 0.97, 0.9, 1.0)


func show_choice_overlay(title: String, body: String, options: Array) -> void:
	if selection_panel == null:
		return

	selection_title_label.text = title
	selection_body_label.text = body

	for child in selection_options_box.get_children():
		child.free()

	for index in range(options.size()):
		var option: Dictionary = options[index]
		var label = _make_label("", 20, Color(0.98, 0.95, 0.9))
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.text = "%d. [%s] %s\n%s\n%s" % [
			index + 1,
			str(option.get("glyph", "字")),
			str(option.get("title", "选项")),
			str(option.get("description", "")),
			str(option.get("detail", ""))
		]
		selection_options_box.add_child(label)

	selection_panel.visible = true


func hide_choice_overlay() -> void:
	if selection_panel != null:
		selection_panel.visible = false


func set_game_over(enabled: bool) -> void:
	persistent_message = enabled
	hide_choice_overlay()
	if enabled:
		message_label.text = "墨潮将你吞没了。按 R 重新开局。"
		message_label.visible = true
		message_label.modulate = Color(1.0, 0.9, 0.84, 1.0)
		tip_label.text = "本轮已结束。现在这版已经有房间结算、字路和偏旁构筑了。"


func _build_ui() -> void:
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var status_panel = PanelContainer.new()
	status_panel.position = Vector2(18.0, 18.0)
	status_panel.size = Vector2(430.0, 230.0)
	status_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.08, 0.11, 0.78), Color(0.88, 0.63, 0.32, 0.88)))
	root.add_child(status_panel)

	var status_padding = MarginContainer.new()
	status_padding.set_anchors_preset(Control.PRESET_FULL_RECT)
	status_padding.add_theme_constant_override("margin_left", 14)
	status_padding.add_theme_constant_override("margin_top", 12)
	status_padding.add_theme_constant_override("margin_right", 14)
	status_padding.add_theme_constant_override("margin_bottom", 12)
	status_panel.add_child(status_padding)

	var status_box = VBoxContainer.new()
	status_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	status_box.add_theme_constant_override("separation", 6)
	status_padding.add_child(status_box)

	title_label = _make_label("字海残卷 · 2D 俯视试作", 28, Color(1.0, 0.92, 0.76))
	health_label = _make_label("气血  100 / 100", 18, Color(0.96, 0.9, 0.86))
	progress_label = _make_label("字力  Lv.1   0 / 6", 18, Color(0.86, 0.93, 1.0))
	runtime_label = _make_label("局时  00:00   斩字  0   压力  1", 18, Color(0.92, 0.86, 0.8))
	room_label = _make_label("房间  起墨室\n目标  击破来袭字灵", 16, Color(0.88, 0.95, 1.0))
	modifier_label = _make_label("房况  首轮先稳住脚下阵地。", 15, Color(0.84, 0.84, 0.92))
	tip_label = _make_label("WASD / 方向键移动。房间结算时用数字键选偏旁或字路。", 15, Color(0.83, 0.84, 0.9))

	status_box.add_child(title_label)
	status_box.add_child(health_label)
	status_box.add_child(progress_label)
	status_box.add_child(runtime_label)
	status_box.add_child(room_label)
	status_box.add_child(modifier_label)
	status_box.add_child(tip_label)

	var build_panel = PanelContainer.new()
	build_panel.position = Vector2(18.0, 262.0)
	build_panel.size = Vector2(430.0, 222.0)
	build_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.06, 0.07, 0.1, 0.76), Color(0.56, 0.76, 0.96, 0.78)))
	root.add_child(build_panel)

	var build_padding = MarginContainer.new()
	build_padding.set_anchors_preset(Control.PRESET_FULL_RECT)
	build_padding.add_theme_constant_override("margin_left", 14)
	build_padding.add_theme_constant_override("margin_top", 12)
	build_padding.add_theme_constant_override("margin_right", 14)
	build_padding.add_theme_constant_override("margin_bottom", 12)
	build_panel.add_child(build_padding)

	var build_box = VBoxContainer.new()
	build_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	build_box.add_theme_constant_override("separation", 8)
	build_padding.add_child(build_box)

	route_label = _make_label("字路  未立\n首轮通关后会先确立字路。", 16, Color(0.94, 0.94, 1.0))
	inventory_label = _make_label("偏旁库存  暂无", 16, Color(0.86, 0.94, 0.86))
	characters_label = _make_label("已成字诀  暂无", 16, Color(1.0, 0.9, 0.78))
	word_skill_label = _make_label("词技  暂无", 16, Color(0.9, 0.88, 1.0))

	build_box.add_child(route_label)
	build_box.add_child(inventory_label)
	build_box.add_child(characters_label)
	build_box.add_child(word_skill_label)

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

	selection_panel = PanelContainer.new()
	selection_panel.anchor_left = 0.5
	selection_panel.anchor_top = 0.5
	selection_panel.anchor_right = 0.5
	selection_panel.anchor_bottom = 0.5
	selection_panel.offset_left = -340.0
	selection_panel.offset_top = -220.0
	selection_panel.offset_right = 340.0
	selection_panel.offset_bottom = 220.0
	selection_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.05, 0.08, 0.94), Color(0.98, 0.82, 0.45, 0.95)))
	selection_panel.visible = false
	root.add_child(selection_panel)

	var selection_padding = MarginContainer.new()
	selection_padding.set_anchors_preset(Control.PRESET_FULL_RECT)
	selection_padding.add_theme_constant_override("margin_left", 22)
	selection_padding.add_theme_constant_override("margin_top", 18)
	selection_padding.add_theme_constant_override("margin_right", 22)
	selection_padding.add_theme_constant_override("margin_bottom", 18)
	selection_panel.add_child(selection_padding)

	var selection_box = VBoxContainer.new()
	selection_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	selection_box.add_theme_constant_override("separation", 12)
	selection_padding.add_child(selection_box)

	selection_title_label = _make_label("房间结算", 30, Color(1.0, 0.94, 0.8))
	selection_body_label = _make_label("按数字键选择。", 18, Color(0.92, 0.92, 0.98))
	selection_options_box = VBoxContainer.new()
	selection_options_box.add_theme_constant_override("separation", 10)

	selection_box.add_child(selection_title_label)
	selection_box.add_child(selection_body_label)
	selection_box.add_child(selection_options_box)


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var settings = LabelSettings.new()
	settings.font = CJKFont.get_font()
	settings.font_size = font_size
	settings.font_color = color
	label.label_settings = settings
	return label


func _make_panel_style(background: Color, border: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	return style
