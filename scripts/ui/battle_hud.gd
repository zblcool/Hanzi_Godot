extends CanvasLayer

const CJKFont := preload("res://scripts/core/cjk_font.gd")

signal radical_choice_selected(radical: String)
signal word_choice_selected(word_id: String)

var ui_font: Font

var hero_label: Label
var health_label: Label
var progress_label: Label
var status_label: Label
var radicals_label: Label
var skills_label: Label
var tip_label: Label
var banner_label: Label
var overlay_label: Label
var xp_bar: ProgressBar

var choice_overlay: Control
var choice_title_label: Label
var choice_hint_label: Label
var choice_buttons: Array[Button] = []
var choice_mode: String = ""

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
	hero_label.text = "%s  ·  %s" % [String(hero_data["name"]), String(hero_data["title"])]
	tip_label.text = "WASD / 方向键移动，`R` 重开，`Esc` 返回二级菜单。"


func set_health(current: float, maximum: float) -> void:
	health_label.text = "气血  %d / %d" % [int(ceil(current)), int(ceil(maximum))]


func set_progress(level: int, current: int, target: int) -> void:
	progress_label.text = "字力  Lv.%d   %d / %d" % [level, current, target]
	xp_bar.max_value = max(1, target)
	xp_bar.value = clamp(current, 0, target)


func set_status(elapsed: float, kills: int, threat: int) -> void:
	var total_seconds: int = int(floor(elapsed))
	var minutes: int = int(total_seconds / 60)
	var seconds: int = total_seconds % 60
	status_label.text = "波次  %d   存活  %02d:%02d   斩字  %d" % [threat, minutes, seconds, kills]


func set_radicals(radicals: Dictionary) -> void:
	var lines: Array[String] = []
	var current_line := "偏旁仓  "
	for radical_variant in Session.RADICAL_ORDER:
		var radical := String(radical_variant)
		var amount: int = int(radicals.get(radical, 0))
		var segment := "%s×%d" % [radical, amount]
		if current_line.length() > 16:
			lines.append(current_line)
			current_line = segment
		else:
			current_line += segment + "   "
	if not current_line.is_empty():
		lines.append(current_line)
	radicals_label.text = "\n".join(lines)


func set_skills(recipe_levels: Dictionary, word_levels: Dictionary, word_progress: Dictionary, blade_level: int, hero_id: String) -> void:
	var lines: Array[String] = ["合字"]
	for recipe_id_variant in Session.RECIPE_ORDER:
		var recipe_id := String(recipe_id_variant)
		var recipe: Dictionary = Session.get_recipe_data(recipe_id)
		var level: int = int(recipe_levels.get(recipe_id, 0))
		var max_level: int = int(recipe["max_level"])
		if level > 0:
			lines.append("%s  Lv.%d/%d" % [String(recipe["display"]), level, max_level])
		else:
			lines.append("%s  待成字" % String(recipe["display"]))

	lines.append("")
	lines.append("词技")
	for word_id_variant in Session.WORD_ORDER:
		var word_id := String(word_id_variant)
		var word: Dictionary = Session.get_word_data(word_id)
		var recipe_id: String = String(word["recipe_id"])
		var recipe_level: int = int(recipe_levels.get(recipe_id, 0))
		var recipe_max: int = int(Session.get_recipe_data(recipe_id)["max_level"])
		var level: int = int(word_levels.get(word_id, 0))
		if level > 0:
			lines.append("%s  Lv.%d/%d" % [String(word["display"]), level, int(word["max_level"])])
		elif recipe_level < recipe_max:
			lines.append("%s  待满级" % String(word["display"]))
		else:
			lines.append("%s  磨词 %d/%d" % [
				String(word["display"]),
				int(word_progress.get(word_id, 0)),
				int(word["unlock_cost"])
			])

	lines.append("")
	lines.append("%s  Lv.%d" % ["刀势" if hero_id == "xia" else "笔锋", blade_level])
	skills_label.text = "\n".join(lines)


func set_tip(text: String) -> void:
	tip_label.text = text


func show_banner(text: String, color: Color, duration: float = 2.4) -> void:
	banner_label.text = text
	banner_color = color
	banner_label.modulate = color
	banner_label.visible = true
	banner_time = duration


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
				"%s  %s" % [
					String(choice["radical"]),
					String(choice["name"])
				],
				String(choice["headline"]),
				String(choice["description"]),
				Color(choice["color"]),
				"radical",
				String(choice["radical"]),
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
				"%s  %s" % [
					String(choice["display"]),
					String(choice["title"])
				],
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


func set_game_over(summary: String) -> void:
	hide_choice_overlay()
	overlay_label.text = summary
	overlay_label.visible = true


func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var left_panel := PanelContainer.new()
	left_panel.position = Vector2(18.0, 18.0)
	left_panel.size = Vector2(386.0, 272.0)
	left_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.06, 0.07, 0.09, 0.8), Color(0.93, 0.63, 0.31, 0.95)))
	root.add_child(left_panel)

	var left_margin := MarginContainer.new()
	left_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	left_margin.add_theme_constant_override("margin_left", 14)
	left_margin.add_theme_constant_override("margin_top", 12)
	left_margin.add_theme_constant_override("margin_right", 14)
	left_margin.add_theme_constant_override("margin_bottom", 12)
	left_panel.add_child(left_margin)

	var left_box := VBoxContainer.new()
	left_box.add_theme_constant_override("separation", 6)
	left_margin.add_child(left_box)

	hero_label = _make_label("角色", 28, Color(1.0, 0.92, 0.8, 1.0))
	health_label = _make_label("气血  0 / 0", 18, Color(0.95, 0.91, 0.86, 1.0))
	progress_label = _make_label("字力  Lv.1   0 / 4", 18, Color(0.98, 0.91, 0.72, 1.0))
	status_label = _make_label("波次  1   存活  00:00   斩字  0", 18, Color(0.86, 0.92, 0.98, 0.98))
	radicals_label = _make_label("偏旁仓", 18, Color(0.91, 0.88, 0.84, 0.96))
	xp_bar = ProgressBar.new()
	xp_bar.min_value = 0
	xp_bar.max_value = 4
	xp_bar.value = 0
	xp_bar.custom_minimum_size = Vector2(0.0, 16.0)
	xp_bar.show_percentage = false
	xp_bar.add_theme_stylebox_override("background", _make_fill_style(Color(0.12, 0.11, 0.1, 0.95), 7))
	xp_bar.add_theme_stylebox_override("fill", _make_fill_style(Color(0.94, 0.7, 0.31, 0.98), 7))
	left_box.add_child(hero_label)
	left_box.add_child(health_label)
	left_box.add_child(progress_label)
	left_box.add_child(xp_bar)
	left_box.add_child(status_label)
	left_box.add_child(radicals_label)

	var right_panel := PanelContainer.new()
	right_panel.position = Vector2(980.0, 18.0)
	right_panel.size = Vector2(282.0, 272.0)
	right_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.08, 0.11, 0.82), Color(0.41, 0.64, 0.96, 0.92)))
	root.add_child(right_panel)

	var right_margin := MarginContainer.new()
	right_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	right_margin.add_theme_constant_override("margin_left", 14)
	right_margin.add_theme_constant_override("margin_top", 12)
	right_margin.add_theme_constant_override("margin_right", 14)
	right_margin.add_theme_constant_override("margin_bottom", 12)
	right_panel.add_child(right_margin)

	skills_label = _make_label("合字 / 词技", 18, Color(0.92, 0.94, 0.99, 0.97))
	right_margin.add_child(skills_label)

	tip_label = _make_label("", 18, Color(0.93, 0.9, 0.84, 0.95))
	tip_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	tip_label.offset_left = 28.0
	tip_label.offset_right = -28.0
	tip_label.offset_top = -52.0
	tip_label.offset_bottom = -16.0
	tip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(tip_label)

	banner_label = _make_label("", 38, Color(1.0, 0.9, 0.76, 1.0))
	banner_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	banner_label.offset_left = 160.0
	banner_label.offset_right = -160.0
	banner_label.offset_top = 24.0
	banner_label.offset_bottom = 86.0
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

	_build_choice_overlay(root)


func _build_choice_overlay(root: Control) -> void:
	choice_overlay = Control.new()
	choice_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	choice_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	choice_overlay.visible = false
	root.add_child(choice_overlay)

	var scrim := ColorRect.new()
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.01, 0.01, 0.02, 0.72)
	choice_overlay.add_child(scrim)

	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -450.0
	panel.offset_top = -220.0
	panel.offset_right = 450.0
	panel.offset_bottom = 220.0
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.08, 0.1, 0.96), Color(0.95, 0.68, 0.32, 0.98)))
	choice_overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	margin.add_child(box)

	choice_title_label = _make_label("字力突破", 34, Color(1.0, 0.92, 0.82, 1.0))
	choice_hint_label = _make_label("", 18, Color(0.9, 0.92, 0.97, 0.96))
	box.add_child(choice_title_label)
	box.add_child(choice_hint_label)

	var cards_row := HBoxContainer.new()
	cards_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cards_row.add_theme_constant_override("separation", 14)
	box.add_child(cards_row)

	for index in range(3):
		var button := Button.new()
		button.custom_minimum_size = Vector2(0.0, 240.0)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.add_theme_font_override("font", ui_font)
		button.add_theme_font_size_override("font_size", 22)
		button.add_theme_color_override("font_color", Color(0.08, 0.07, 0.07, 1.0))
		button.pressed.connect(_on_choice_button_pressed.bind(index))
		choice_buttons.append(button)
		cards_row.add_child(button)


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
	button.add_theme_stylebox_override("normal", _make_button_style(color))
	button.add_theme_stylebox_override("hover", _make_button_style(color.lightened(0.08)))
	button.add_theme_stylebox_override("pressed", _make_button_style(color.darkened(0.08)))


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
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	return style


func _make_fill_style(fill_color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	return style


func _make_button_style(fill_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	return style
