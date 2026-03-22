extends Control

const CJKFont := preload("res://scripts/core/cjk_font.gd")
const HanziLocalization := preload("res://scripts/core/hanzi_localization.gd")
const BASE_VIEWPORT := Vector2(2100.0, 1200.0)
const MIN_UI_SCALE := 0.6
const HERO_REACTION_DURATION := 3.2
const NIGHT_THEME := {
	"background": Color(0.03, 0.05, 0.07, 1.0),
	"glow_amber": Color(0.88, 0.58, 0.28, 0.08),
	"glow_azure": Color(0.42, 0.74, 0.88, 0.06),
	"glow_gold": Color(0.9, 0.74, 0.34, 0.04),
	"line": Color(0.18, 0.24, 0.28, 0.08),
	"shadow": Color(0.0, 0.0, 0.0, 0.18),
	"outline": Color(0.02, 0.03, 0.04, 0.28)
}
const PAPER_THEME := {
	"background": Color(0.94, 0.9, 0.82, 1.0),
	"glow_amber": Color(0.66, 0.43, 0.18, 0.08),
	"glow_azure": Color(0.38, 0.5, 0.66, 0.07),
	"glow_gold": Color(0.76, 0.62, 0.26, 0.05),
	"line": Color(0.32, 0.24, 0.16, 0.09),
	"shadow": Color(0.18, 0.14, 0.1, 0.08),
	"outline": Color(0.95, 0.92, 0.86, 0.4)
}
const MENU_EN_TEXT := {
	"返回启动器": "Back to Launcher",
	"人物志": "Character Archive",
	"合字图谱": "Fusion Atlas",
	"怪物图鉴": "Enemy Archive",
	"玩家名帖": "Player Sigil",
	"查看排行榜": "Leaderboard",
	"直接开始": "Start Now",
	"字海残卷": "Ink-Sea Remnant Scroll",
	"先进入残卷，再决定谁来执笔。每名角色都会把同一套偏旁系统，写成完全不同的战斗节奏。": "Enter the remnant scroll first, then decide who will write it. The same radical system becomes a different battle rhythm for each hero.",
	"可选执笔者": "Available Scribes",
	"执笔者档案": "Scribe Dossier",
	"执笔回应": "Scribe Response",
	"起笔落点": "Opening Route",
	"源稿字技（待迁移）": "Source Skill (Pending Migration)",
	"当前只在菜单里保留 hanziHero 的字技预览，Godot 战斗内仍未接入独立主动输入。": "This menu currently keeps the hanziHero active-skill preview only as a reference. The Godot battle scene still does not have separate manual skill input.",
	"残卷路线": "Scroll Route",
	"把开卷补笔、中盘续写与砚台磨词顺序先记住，进入战斗后更容易判断本轮 build 该补哪一笔。": "Memorize the opening, midgame, and inkstone phrase order first so it is easier to choose your next build step in battle.",
	"战斗轮廓": "Combat Outline",
	"快速试阵": "Quick Test Runs",
	"对照 web 原型保留第 10 / 20 波捷径，便于快速检查 HUD、混编敌潮与角色 build。试阵入口会单独写入试阵榜，不影响主卷榜。": "Wave 10 and wave 20 shortcuts remain for quick HUD, mixed-wave, and hero-build checks. Test entries go into a separate leaderboard and never affect the main scroll board.",
	"标准入卷": "Standard Entry",
	"试阵 · 第10波": "Test Run · Wave 10",
	"压测 · 第20波": "Stress Run · Wave 20",
	"把偏旁、成字与砚台磨词路线收进二级菜单，开局前就能快速确认成长链。": "Keep radicals, formed glyphs, and inkstone phrase routes inside the menu so you can review the growth chain before entering battle.",
	"当前先集中展示已经接入的偏旁、合字等级、词技等级与独立武器偏旁。真正的磨词仍然发生在战场砚台旁。": "This screen currently focuses on migrated radicals, glyph levels, phrase levels, and the independent weapon radical. Actual phrase refinement still happens beside the battlefield inkstone.",
	"把已经接入的执笔者档案收进二级菜单，进入残卷前先确认每名角色的身份与战斗轮廓。": "Keep the migrated hero dossiers inside the menu so you can confirm each fighter's identity and combat profile before entering the scroll.",
	"文本直接取自当前 Godot 迁移版的角色数据，不额外编造尚未落地的职业或成长线。": "The text comes directly from the current Godot migration data and does not invent classes or growth lines that are not implemented yet.",
	"残卷战绩": "Run Records",
	"现在可以在二级菜单里直接查看本地排行榜，并顺手回看每局 build 走向，不必先打到结算页。": "You can now inspect the local leaderboard directly from the sub-menu and review each build path without first reaching the result screen.",
	"当前可以按波次、击破或存活重新排序，更接近 source web 原型里回看不同 build 结果的方式。": "You can now resort by wave, kills, or survival time, closer to how the source web prototype reviews different build outcomes.",
	"像 source web 原型一样，先在菜单里维护这台设备的默认排行榜署名。结算页留空时，会自动复用这里的名字。": "Just like the source web prototype, keep the default leaderboard alias for this device inside the menu. Result screens reuse it automatically when left blank.",
	"当前署名": "Current Alias",
	"默认排行榜署名": "Default Leaderboard Alias",
	"输入想显示的名字": "Enter the name you want to show",
	"随机侠名": "Random Wuxia Name",
	"保存署名": "Save Alias",
	"恢复默认": "Restore Default",
	"把已经接入的敌人谱系收进二级菜单，开局前先记住预警和应对重点。": "Keep the migrated enemy families inside the sub-menu so you can remember their warnings and counters before battle.",
	"图鉴文本直接对应当前 Godot 迁移版已经写进战斗脚本的敌人行为，不额外虚构未接入兵种。": "Archive text maps directly to behaviors already implemented in the current Godot battle scripts instead of inventing unshipped units.",
	"收起人物志": "Close Archive",
	"收起图谱": "Close Atlas",
	"收起图鉴": "Close Archive",
	"墨线正在收束，字潮即将开启。": "Ink lines are closing. The glyph tide is about to begin.",
	"卷中文字": "Text Within the Scroll",
	"机动": "Mobility",
	"气血": "Vitality",
	"伤害": "Damage",
	"射程": "Range",
	"攻速": "Attack Rate",
	"拾取": "Pickup",
	"夜墨": "Night Ink",
	"纸墨": "Paper Ink",
	"切换到夜墨主题": "Switch to Night Ink theme",
	"切换到纸墨主题": "Switch to Paper Ink theme",
	"把 web 原型里更偏向的构筑方向先压缩成菜单预览，连同源稿词技 / 遗物搭配一起放在开局前参考。": "Compress the source web build routes into a menu preview and keep their source word and relic pairings visible before the run.",
	"当前只负责前台提示：源稿词技 / 遗物搭配还没有接回 Godot 战斗掉落或路线权重。": "Front-end reference only: source word and relic pairings are not yet wired back into Godot battle drops or route bias.",
	"对照 web 原型现有的路线选择，把更贴近这名执笔者的构筑方向与词技 / 遗物搭配保留成前台参考。": "Mirror the source web route choices by keeping the best-fitting build directions, words, and relic pairings visible for this hero.",
	"这些卡片当前不直接改战斗数值、掉落权重或路线偏向，只帮助对照 web 原型的构筑意图。": "These cards do not yet change combat values, drop weights, or route bias. They only surface the source prototype's build intent.",
	"源稿遗物偏向": "Source Relic Pairing",
	"源稿词技偏向": "Source Word Pairing"
}
var ui_font: Font
var ui_scale := 1.0
var floating_symbols: Array[Dictionary] = []
var preview_motifs: Array[Dictionary] = []
var selected_hero := "scholar"
var hero_quote_indices: Dictionary = {}
var current_theme := "night-ink"
var current_language := "zh"

var hero_panels: Dictionary = {}
var detail_name_label: Label
var detail_desc_label: Label
var detail_weapon_label: Label
var detail_focus_label: Label
var detail_dossier_label: Label
var detail_quote_label: Label
var detail_role_label: Label
var detail_reaction_panel: PanelContainer
var detail_reaction_label: Label
var detail_preview_core: PanelContainer
var detail_preview_glyph: Label
var detail_tags_row: Container
var detail_opening_label: Label
var detail_opening_radicals_row: Container
var detail_source_skill_title_label: Label
var detail_source_skill_body_label: Label
var detail_progression_cards_root: VBoxContainer
var detail_build_route_cards_root: VBoxContainer
var detail_stat_widgets: Dictionary = {}
var character_archive_overlay: Control
var character_archive_cards_root: VBoxContainer
var recipe_atlas_overlay: Control
var recipe_atlas_body_label: Label
var enemy_archive_overlay: Control
var enemy_archive_body_label: Label
var leaderboard_overlay: Control
var leaderboard_summary_label: Label
var leaderboard_body_label: Label
var leaderboard_manual_button: Button
var leaderboard_test_button: Button
var leaderboard_sort_wave_button: Button
var leaderboard_sort_kills_button: Button
var leaderboard_sort_time_button: Button
var leaderboard_view: String = "manual"
var leaderboard_sort: String = "wave"
var profile_overlay: Control
var profile_name_input: LineEdit
var profile_status_label: Label
var profile_hint_label: Label
var profile_preview_name_label: Label
var profile_preview_glyph_label: Label
var profile_preview_copy_label: Label
var transition_overlay: Control
var transition_glyph_label: Label
var transition_title_label: Label
var transition_subtitle_label: Label
var transition_busy: bool = false
var reaction_time_remaining := 0.0
var active_card_reaction_hero := ""


func _ready() -> void:
	ui_font = CJKFont.get_font()
	selected_hero = Session.selected_hero
	current_theme = Session.get_launcher_theme()
	current_language = Session.get_launcher_language()
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

	if reaction_time_remaining > 0.0:
		reaction_time_remaining = max(reaction_time_remaining - delta, 0.0)
		if reaction_time_remaining <= 0.0 and not active_card_reaction_hero.is_empty():
			_clear_card_reactions()
	if detail_reaction_panel != null:
		var emphasis: float = clampf(reaction_time_remaining / HERO_REACTION_DURATION, 0.0, 1.0)
		detail_reaction_panel.modulate = Color(1.0, 1.0, 1.0, 0.84 + emphasis * 0.16)
	queue_redraw()


func _draw() -> void:
	var rect: Rect2 = get_viewport_rect()
	var palette := _get_theme_palette()
	draw_rect(rect, palette["background"], true)
	draw_circle(Vector2(rect.size.x * 0.24, rect.size.y * 0.22), 210.0, palette["glow_amber"])
	draw_circle(Vector2(rect.size.x * 0.76, rect.size.y * 0.2), 240.0, palette["glow_azure"])
	draw_circle(Vector2(rect.size.x * 0.56, rect.size.y * 0.72), 300.0, palette["glow_gold"])

	for index in range(6):
		var x: float = rect.size.x * (0.06 + float(index) * 0.16)
		draw_line(Vector2(x, 0.0), Vector2(x + 180.0, rect.size.y), palette["line"], 1.0)

	for symbol in floating_symbols:
		var position: Vector2 = symbol["position"]
		var color: Color = _resolve_symbol_color(symbol["color"])
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
	var open_overlay := ""
	var profile_draft := ""
	if character_archive_overlay != null and character_archive_overlay.visible:
		open_overlay = "character"
	elif recipe_atlas_overlay != null and recipe_atlas_overlay.visible:
		open_overlay = "recipe"
	elif enemy_archive_overlay != null and enemy_archive_overlay.visible:
		open_overlay = "enemy"
	elif leaderboard_overlay != null and leaderboard_overlay.visible:
		open_overlay = "leaderboard"
	elif profile_overlay != null and profile_overlay.visible:
		open_overlay = "profile"
		if profile_name_input != null:
			profile_draft = profile_name_input.text
	ui_scale = _compute_ui_scale()
	preview_motifs.clear()
	hero_panels.clear()
	detail_stat_widgets.clear()
	active_card_reaction_hero = ""
	detail_name_label = null
	detail_desc_label = null
	detail_weapon_label = null
	detail_focus_label = null
	detail_dossier_label = null
	detail_quote_label = null
	detail_role_label = null
	detail_reaction_panel = null
	detail_reaction_label = null
	detail_preview_core = null
	detail_preview_glyph = null
	detail_tags_row = null
	detail_opening_label = null
	detail_opening_radicals_row = null
	detail_source_skill_title_label = null
	detail_source_skill_body_label = null
	detail_progression_cards_root = null
	detail_build_route_cards_root = null
	character_archive_overlay = null
	character_archive_cards_root = null
	recipe_atlas_overlay = null
	recipe_atlas_body_label = null
	enemy_archive_overlay = null
	enemy_archive_body_label = null
	leaderboard_overlay = null
	leaderboard_summary_label = null
	leaderboard_body_label = null
	leaderboard_manual_button = null
	leaderboard_test_button = null
	leaderboard_sort_wave_button = null
	leaderboard_sort_kills_button = null
	leaderboard_sort_time_button = null
	profile_overlay = null
	profile_name_input = null
	profile_status_label = null
	profile_hint_label = null
	profile_preview_name_label = null
	profile_preview_glyph_label = null
	profile_preview_copy_label = null
	transition_overlay = null
	transition_glyph_label = null
	transition_title_label = null
	transition_subtitle_label = null
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_build_ui()
	_refresh_selection(true)
	match open_overlay:
		"character":
			_show_character_archive_overlay()
		"recipe":
			_show_recipe_atlas_overlay()
		"enemy":
			_show_enemy_archive_overlay()
		"leaderboard":
			_show_leaderboard_overlay()
		"profile":
			if profile_overlay != null and profile_name_input != null:
				profile_name_input.text = profile_draft
				_refresh_profile_overlay()
				profile_overlay.visible = true


func _on_viewport_size_changed() -> void:
	_rebuild_ui()


func _compute_ui_scale() -> float:
	var viewport_size := get_viewport_rect().size
	var min_scale := 0.44 if _is_portrait_layout() else MIN_UI_SCALE
	return clamp(min(viewport_size.x / BASE_VIEWPORT.x, viewport_size.y / BASE_VIEWPORT.y), min_scale, 1.0)


func _is_portrait_layout() -> bool:
	var viewport_size := get_viewport_rect().size
	return viewport_size.x <= viewport_size.y


func _safe_area_insets() -> Dictionary:
	var visible_rect := get_viewport_rect()
	var safe_area: Rect2 = Rect2(DisplayServer.get_display_safe_area())
	if safe_area.size.x <= 0.0 or safe_area.size.y <= 0.0:
		return {"left": 0.0, "top": 0.0, "right": 0.0, "bottom": 0.0}

	var left := maxf(safe_area.position.x - visible_rect.position.x, 0.0)
	var top := maxf(safe_area.position.y - visible_rect.position.y, 0.0)
	var right := maxf((visible_rect.position.x + visible_rect.size.x) - (safe_area.position.x + safe_area.size.x), 0.0)
	var bottom := maxf((visible_rect.position.y + visible_rect.size.y) - (safe_area.position.y + safe_area.size.y), 0.0)
	return {"left": left, "top": top, "right": right, "bottom": bottom}


func _apply_root_safe_margins(root: MarginContainer, left: float, top: float, right: float, bottom: float) -> void:
	var safe_area := _safe_area_insets()
	root.add_theme_constant_override("margin_left", _i(left) + int(round(float(safe_area["left"]))))
	root.add_theme_constant_override("margin_top", _i(top) + int(round(float(safe_area["top"]))))
	root.add_theme_constant_override("margin_right", _i(right) + int(round(float(safe_area["right"]))))
	root.add_theme_constant_override("margin_bottom", _i(bottom) + int(round(float(safe_area["bottom"]))))


func _set_center_overlay_panel(panel: Control, design_width: float, design_height: float, margin_x: float = 24.0, margin_y: float = 24.0) -> void:
	var safe_area := _safe_area_insets()
	var viewport_size := get_viewport_rect().size
	var usable_position := Vector2(float(safe_area["left"]) + margin_x, float(safe_area["top"]) + margin_y)
	var usable_size := Vector2(
		maxf(260.0, viewport_size.x - float(safe_area["left"]) - float(safe_area["right"]) - margin_x * 2.0),
		maxf(260.0, viewport_size.y - float(safe_area["top"]) - float(safe_area["bottom"]) - margin_y * 2.0)
	)
	var panel_size := Vector2(min(_f(design_width), usable_size.x), min(_f(design_height), usable_size.y))
	panel.anchor_left = 0.0
	panel.anchor_top = 0.0
	panel.anchor_right = 0.0
	panel.anchor_bottom = 0.0
	panel.position = usable_position + (usable_size - panel_size) * 0.5
	panel.size = panel_size


func _f(value: float) -> float:
	return value * ui_scale


func _i(value: float) -> int:
	return maxi(1, int(round(value * ui_scale)))


func _v(x: float, y: float) -> Vector2:
	return Vector2(_f(x), _f(y))


func _is_paper_theme() -> bool:
	return current_theme == "paper-ink"


func _is_english() -> bool:
	return current_language == "en"


func _get_theme_palette() -> Dictionary:
	return PAPER_THEME if _is_paper_theme() else NIGHT_THEME


func _get_theme_toggle_label() -> String:
	return "Paper Ink" if _is_english() and _is_paper_theme() else ("Night Ink" if _is_english() else ("纸墨" if _is_paper_theme() else "夜墨"))


func _get_theme_toggle_tooltip() -> String:
	return "Switch to Night Ink theme" if _is_english() and _is_paper_theme() else ("Switch to Paper Ink theme" if _is_english() else ("切换到夜墨主题" if _is_paper_theme() else "切换到纸墨主题"))


func _get_language_toggle_label() -> String:
	return "中" if _is_english() else "EN"


func _get_language_toggle_tooltip() -> String:
	return "切换到中文" if _is_english() else "Switch to English"


func _localize_text(text: String) -> String:
	if not _is_english():
		return text
	if text.begins_with("• "):
		return "• %s" % _localize_text(text.substr(2))
	return String(MENU_EN_TEXT.get(text, text))


func _resolve_surface_fill(fill_color: Color) -> Color:
	if not _is_paper_theme():
		return fill_color
	var paper := Color(0.97, 0.95, 0.9, fill_color.a)
	return fill_color.lerp(paper, 0.88)


func _resolve_surface_border(border_color: Color) -> Color:
	if not _is_paper_theme():
		return border_color
	var ink := Color(0.46, 0.33, 0.2, border_color.a)
	return ink.lerp(border_color, 0.4)


func _resolve_button_fill(fill_color: Color) -> Color:
	if not _is_paper_theme():
		return fill_color
	var paper := Color(0.95, 0.9, 0.8, fill_color.a)
	var mix_strength := 0.22 if fill_color.get_luminance() > 0.45 else 0.58
	return fill_color.lerp(paper, mix_strength)


func _resolve_label_color(color: Color) -> Color:
	if not _is_paper_theme():
		return color
	var ink := Color(0.18, 0.13, 0.09, color.a)
	if color.r > color.b + 0.08:
		ink = Color(0.38, 0.26, 0.13, color.a)
	elif color.b > color.r + 0.08:
		ink = Color(0.23, 0.28, 0.36, color.a)
	var darkened := color.darkened(0.45)
	var themed := ink.lerp(darkened, 0.28)
	themed.a = color.a
	return themed


func _resolve_symbol_color(color: Color) -> Color:
	if not _is_paper_theme():
		return color
	var themed := _resolve_label_color(color)
	themed.a = min(0.18, color.a + 0.03)
	return themed


func _make_theme_toggle_button(size: Vector2) -> Button:
	var button := _make_pill_button(_get_theme_toggle_label(), size, Callable(self, "_on_toggle_theme_pressed"))
	button.tooltip_text = _get_theme_toggle_tooltip()
	return button


func _make_language_toggle_button(size: Vector2) -> Button:
	var button := _make_pill_button(_get_language_toggle_label(), size, Callable(self, "_on_toggle_language_pressed"))
	button.tooltip_text = _get_language_toggle_tooltip()
	return button


func _build_ui() -> void:
	var portrait_layout := _is_portrait_layout()
	var root := MarginContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_apply_root_safe_margins(
		root,
		22.0 if portrait_layout else 40.0,
		18.0 if portrait_layout else 30.0,
		22.0 if portrait_layout else 40.0,
		20.0 if portrait_layout else 28.0
	)
	add_child(root)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	var layout := VBoxContainer.new()
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_theme_constant_override("separation", _i(18))
	scroll.add_child(layout)

	var top_bar: Container
	if portrait_layout:
		var top_grid := GridContainer.new()
		top_grid.columns = 2
		top_grid.add_theme_constant_override("h_separation", _i(12))
		top_grid.add_theme_constant_override("v_separation", _i(12))
		top_bar = top_grid
	else:
		var top_row := HBoxContainer.new()
		top_row.add_theme_constant_override("separation", _i(12))
		var spacer := Control.new()
		spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		top_row.add_child(spacer)
		top_bar = top_row
	layout.add_child(top_bar)

	var top_buttons: Array[Control] = [
		_make_pill_button("返回启动器", _v(168.0, 54.0), Callable(self, "_on_back_pressed")),
		_make_pill_button("人物志", _v(148.0, 54.0), Callable(self, "_on_character_archive_pressed")),
		_make_pill_button("合字图谱", _v(164.0, 54.0), Callable(self, "_on_recipe_atlas_pressed")),
		_make_pill_button("怪物图鉴", _v(164.0, 54.0), Callable(self, "_on_enemy_archive_pressed")),
		_make_pill_button("玩家名帖", _v(156.0, 54.0), Callable(self, "_on_profile_pressed")),
		_make_pill_button("查看排行榜", _v(172.0, 54.0), Callable(self, "_on_leaderboard_pressed")),
		_make_pill_button("直接开始", _v(152.0, 54.0), Callable(self, "_on_start_pressed")),
		_make_theme_toggle_button(_v(94.0, 54.0)),
		_make_language_toggle_button(_v(74.0, 54.0))
	]
	for button in top_buttons:
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL if portrait_layout else 0
		top_bar.add_child(button)

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
	header_panel.custom_minimum_size = _v(0.0, 198.0 if portrait_layout else 174.0)
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

	var content_row: BoxContainer = VBoxContainer.new() if portrait_layout else HBoxContainer.new()
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
		var hero_data: Dictionary = _localized_hero_data(hero_id)
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
	detail_dossier_label = _make_label("", 16, Color(0.95, 0.9, 0.8, 0.96))
	detail_quote_label = _make_label("", 16, Color(0.84, 0.91, 1.0, 0.95))
	detail_box.add_child(detail_name_label)
	detail_box.add_child(detail_role_label)
	detail_box.add_child(detail_weapon_label)
	detail_box.add_child(detail_desc_label)
	detail_box.add_child(detail_focus_label)
	detail_box.add_child(detail_dossier_label)
	detail_box.add_child(detail_quote_label)

	detail_reaction_panel = PanelContainer.new()
	detail_reaction_panel.custom_minimum_size = _v(0.0, 104.0)
	detail_reaction_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.1, 0.13, 0.17, 0.78), Color(0.92, 0.68, 0.42, 0.34)))
	detail_box.add_child(detail_reaction_panel)

	var reaction_margin := MarginContainer.new()
	reaction_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	reaction_margin.add_theme_constant_override("margin_left", _i(16))
	reaction_margin.add_theme_constant_override("margin_top", _i(14))
	reaction_margin.add_theme_constant_override("margin_right", _i(16))
	reaction_margin.add_theme_constant_override("margin_bottom", _i(14))
	detail_reaction_panel.add_child(reaction_margin)

	var reaction_box := VBoxContainer.new()
	reaction_box.add_theme_constant_override("separation", _i(6))
	reaction_margin.add_child(reaction_box)
	reaction_box.add_child(_make_label("执笔回应", 15, Color(0.96, 0.82, 0.54, 0.88)))
	detail_reaction_label = _make_label("", 18, Color(0.96, 0.95, 0.9, 0.98))
	reaction_box.add_child(detail_reaction_label)

	detail_tags_row = HFlowContainer.new()
	detail_tags_row.add_theme_constant_override("h_separation", _i(10))
	detail_tags_row.add_theme_constant_override("v_separation", _i(10))
	detail_box.add_child(detail_tags_row)

	var opening_panel := PanelContainer.new()
	opening_panel.custom_minimum_size = _v(0.0, 146.0)
	opening_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.72), Color(0.42, 0.68, 0.86, 0.34)))
	detail_box.add_child(opening_panel)

	var opening_margin := MarginContainer.new()
	opening_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	opening_margin.add_theme_constant_override("margin_left", _i(16))
	opening_margin.add_theme_constant_override("margin_top", _i(16))
	opening_margin.add_theme_constant_override("margin_right", _i(16))
	opening_margin.add_theme_constant_override("margin_bottom", _i(16))
	opening_panel.add_child(opening_margin)

	var opening_box := VBoxContainer.new()
	opening_box.add_theme_constant_override("separation", _i(8))
	opening_margin.add_child(opening_box)
	opening_box.add_child(_make_label("起笔落点", 22, Color(1.0, 0.92, 0.8, 1.0)))

	detail_opening_label = _make_label("", 16, Color(0.88, 0.92, 0.96, 0.94))
	opening_box.add_child(detail_opening_label)

	detail_opening_radicals_row = HFlowContainer.new()
	detail_opening_radicals_row.add_theme_constant_override("h_separation", _i(10))
	detail_opening_radicals_row.add_theme_constant_override("v_separation", _i(10))
	opening_box.add_child(detail_opening_radicals_row)

	var source_skill_panel := PanelContainer.new()
	source_skill_panel.custom_minimum_size = _v(0.0, 166.0)
	source_skill_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.72), Color(0.9, 0.66, 0.36, 0.3)))
	detail_box.add_child(source_skill_panel)

	var source_skill_margin := MarginContainer.new()
	source_skill_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	source_skill_margin.add_theme_constant_override("margin_left", _i(16))
	source_skill_margin.add_theme_constant_override("margin_top", _i(16))
	source_skill_margin.add_theme_constant_override("margin_right", _i(16))
	source_skill_margin.add_theme_constant_override("margin_bottom", _i(16))
	source_skill_panel.add_child(source_skill_margin)

	var source_skill_box := VBoxContainer.new()
	source_skill_box.add_theme_constant_override("separation", _i(8))
	source_skill_margin.add_child(source_skill_box)
	source_skill_box.add_child(_make_label("源稿字技（待迁移）", 22, Color(1.0, 0.92, 0.8, 1.0)))

	detail_source_skill_title_label = _make_label("", 17, Color(0.96, 0.82, 0.54, 0.96))
	source_skill_box.add_child(detail_source_skill_title_label)

	detail_source_skill_body_label = _make_label("", 16, Color(0.9, 0.92, 0.95, 0.94))
	source_skill_box.add_child(detail_source_skill_body_label)

	source_skill_box.add_child(_make_label("当前只在菜单里保留 hanziHero 的字技预览，Godot 战斗内仍未接入独立主动输入。", 15, Color(0.82, 0.9, 1.0, 0.9)))

	var progression_panel := PanelContainer.new()
	progression_panel.custom_minimum_size = _v(0.0, 224.0)
	progression_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.72), Color(0.74, 0.56, 0.28, 0.34)))
	detail_box.add_child(progression_panel)

	var progression_margin := MarginContainer.new()
	progression_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	progression_margin.add_theme_constant_override("margin_left", _i(16))
	progression_margin.add_theme_constant_override("margin_top", _i(16))
	progression_margin.add_theme_constant_override("margin_right", _i(16))
	progression_margin.add_theme_constant_override("margin_bottom", _i(16))
	progression_panel.add_child(progression_margin)

	var progression_box := VBoxContainer.new()
	progression_box.add_theme_constant_override("separation", _i(10))
	progression_margin.add_child(progression_box)
	progression_box.add_child(_make_label("残卷路线", 22, Color(1.0, 0.92, 0.8, 1.0)))
	progression_box.add_child(_make_label("把开卷补笔、中盘续写与砚台磨词顺序先记住，进入战斗后更容易判断本轮 build 该补哪一笔。", 16, Color(0.88, 0.92, 0.96, 0.94)))

	detail_progression_cards_root = VBoxContainer.new()
	detail_progression_cards_root.add_theme_constant_override("separation", _i(10))
	progression_box.add_child(detail_progression_cards_root)
	progression_box.add_child(_make_label("当前只先保留 web 原型的 build 顺序与路线提示，Godot 战斗内还没有真正的路线权重修正。", 15, Color(0.82, 0.9, 1.0, 0.88)))

	var build_route_panel := PanelContainer.new()
	build_route_panel.custom_minimum_size = _v(0.0, 224.0)
	build_route_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.72), Color(0.42, 0.68, 0.86, 0.34)))
	detail_box.add_child(build_route_panel)

	var build_route_margin := MarginContainer.new()
	build_route_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	build_route_margin.add_theme_constant_override("margin_left", _i(16))
	build_route_margin.add_theme_constant_override("margin_top", _i(16))
	build_route_margin.add_theme_constant_override("margin_right", _i(16))
	build_route_margin.add_theme_constant_override("margin_bottom", _i(16))
	build_route_panel.add_child(build_route_margin)

	var build_route_box := VBoxContainer.new()
	build_route_box.add_theme_constant_override("separation", _i(10))
	build_route_margin.add_child(build_route_box)
	build_route_box.add_child(_make_label("源稿构筑方向", 22, Color(1.0, 0.92, 0.8, 1.0)))
	build_route_box.add_child(_make_label("把 web 原型里更偏向的构筑方向先压缩成菜单预览，连同源稿词技 / 遗物搭配一起放在开局前参考。", 16, Color(0.88, 0.92, 0.96, 0.94)))

	detail_build_route_cards_root = VBoxContainer.new()
	detail_build_route_cards_root.add_theme_constant_override("separation", _i(10))
	build_route_box.add_child(detail_build_route_cards_root)
	build_route_box.add_child(_make_label("当前只负责前台提示：源稿词技 / 遗物搭配还没有接回 Godot 战斗掉落或路线权重。", 15, Color(0.82, 0.9, 1.0, 0.88)))

	var stats_panel := PanelContainer.new()
	stats_panel.custom_minimum_size = _v(0.0, 312.0)
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
	detail_stat_widgets["attack_rate"] = _make_stat_row(stats_box, "攻速")
	detail_stat_widgets["pickup_radius"] = _make_stat_row(stats_box, "拾取")

	var quick_start_panel := PanelContainer.new()
	quick_start_panel.custom_minimum_size = _v(0.0, 164.0)
	quick_start_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.72), Color(0.28, 0.36, 0.42, 0.46)))
	detail_box.add_child(quick_start_panel)

	var quick_start_margin := MarginContainer.new()
	quick_start_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	quick_start_margin.add_theme_constant_override("margin_left", _i(16))
	quick_start_margin.add_theme_constant_override("margin_top", _i(16))
	quick_start_margin.add_theme_constant_override("margin_right", _i(16))
	quick_start_margin.add_theme_constant_override("margin_bottom", _i(16))
	quick_start_panel.add_child(quick_start_margin)

	var quick_start_box := VBoxContainer.new()
	quick_start_box.add_theme_constant_override("separation", _i(10))
	quick_start_margin.add_child(quick_start_box)
	quick_start_box.add_child(_make_label("快速试阵", 22, Color(1.0, 0.92, 0.8, 1.0)))
	quick_start_box.add_child(_make_label("对照 web 原型保留第 10 / 20 波捷径，便于快速检查 HUD、混编敌潮与角色 build。试阵入口会单独写入试阵榜，不影响主卷榜。", 16, Color(0.88, 0.92, 0.96, 0.94)))

	var quick_start_row: BoxContainer = VBoxContainer.new() if portrait_layout else HBoxContainer.new()
	quick_start_row.add_theme_constant_override("separation", _i(10))
	quick_start_box.add_child(quick_start_row)
	quick_start_row.add_child(_make_quick_start_button("标准入卷", Color(0.92, 0.68, 0.42, 1.0), Callable(self, "_on_start_pressed")))
	quick_start_row.add_child(_make_quick_start_button("试阵 · 第10波", Color(0.56, 0.84, 1.0, 1.0), Callable(self, "_on_start_wave_10_pressed")))
	quick_start_row.add_child(_make_quick_start_button("压测 · 第20波", Color(0.78, 0.52, 1.0, 1.0), Callable(self, "_on_start_wave_20_pressed")))

	_build_character_archive_overlay()
	_build_recipe_atlas_overlay()
	_build_enemy_archive_overlay()
	_build_leaderboard_overlay()
	_build_profile_overlay()
	_build_transition_overlay()


func _make_hero_card(hero_id: String, hero_data: Dictionary) -> PanelContainer:
	var portrait_layout := _is_portrait_layout()
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

	var row: BoxContainer = VBoxContainer.new() if portrait_layout else HBoxContainer.new()
	row.add_theme_constant_override("separation", _i(16))
	margin.add_child(row)

	var preview := PanelContainer.new()
	preview.custom_minimum_size = _v(0.0, 132.0 if portrait_layout else 0.0)
	preview.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.14, accent.g * 0.14, accent.b * 0.16, 0.58), Color(accent.r, accent.g, accent.b, 0.24)))
	row.add_child(preview)
	_build_card_preview(preview, hero_data)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.add_theme_constant_override("separation", _i(8))
	row.add_child(text_col)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", _i(10))
	text_col.add_child(title_row)

	var title_label := _make_label("%s  ·  %s" % [_localize_text(String(hero_data["name"])), _localize_text(String(hero_data["title"]))], 30, Color(1.0, 0.95, 0.86, 1.0))
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title_label)

	var status_badge := _make_selected_badge(accent)
	title_row.add_child(status_badge)
	panel.set_meta("status_badge", status_badge)
	panel.set_meta("status_badge_label", status_badge.get_meta("label"))

	text_col.add_child(_make_label(String(hero_data["role_label"]), 18, accent))
	text_col.add_child(_make_label(String(hero_data["description"]), 17, Color(0.91, 0.92, 0.9, 0.95)))

	var tag_row := HBoxContainer.new()
	tag_row.add_theme_constant_override("separation", 8)
	text_col.add_child(tag_row)
	for tag_text in hero_data["tags"]:
		tag_row.add_child(_make_tag(String(tag_text), Color(accent.r * 0.16, accent.g * 0.16, accent.b * 0.2, 0.88), Color(0.98, 0.95, 0.9, 0.96)))

	var reaction_panel := _make_card_reaction_bubble(accent)
	reaction_panel.visible = false
	text_col.add_child(reaction_panel)
	panel.set_meta("reaction_panel", reaction_panel)
	panel.set_meta("reaction_label", reaction_panel.get_meta("label"))

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_col.add_child(spacer)

	var select_label := "Choose %s" % String(hero_data["name"]) if _is_english() else "选择 %s" % String(hero_data["name"])
	var select_button := _make_action_button(select_label, accent)
	select_button.pressed.connect(func() -> void:
		_on_select_hero(hero_id)
	)
	text_col.add_child(select_button)

	return panel


func _make_selected_badge(accent: Color) -> PanelContainer:
	var badge := PanelContainer.new()
	badge.visible = false
	badge.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.16, accent.g * 0.16, accent.b * 0.22, 0.92), Color(accent.r, accent.g, accent.b, 0.26)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(12))
	margin.add_theme_constant_override("margin_top", _i(6))
	margin.add_theme_constant_override("margin_right", _i(12))
	margin.add_theme_constant_override("margin_bottom", _i(6))
	badge.add_child(margin)

	var label := _make_label("", 14, Color(0.98, 0.95, 0.9, 0.98))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	margin.add_child(label)
	badge.set_meta("label", label)
	return badge


func _make_card_reaction_bubble(accent: Color) -> PanelContainer:
	var bubble := PanelContainer.new()
	bubble.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bubble.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.12, accent.g * 0.12, accent.b * 0.16, 0.84), Color(accent.r, accent.g, accent.b, 0.24)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(14))
	margin.add_theme_constant_override("margin_top", _i(12))
	margin.add_theme_constant_override("margin_right", _i(14))
	margin.add_theme_constant_override("margin_bottom", _i(12))
	bubble.add_child(margin)

	var label := _make_label("", 16, Color(0.98, 0.95, 0.9, 0.98))
	margin.add_child(label)
	bubble.set_meta("label", label)
	return bubble


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
	button.text = _localize_text(text)
	button.custom_minimum_size = _v(0.0, 52.0)
	button.add_theme_font_override("font", ui_font)
	button.add_theme_font_size_override("font_size", _i(21))
	button.add_theme_color_override("font_color", _resolve_label_color(Color(0.08, 0.07, 0.07, 1.0)))
	button.add_theme_stylebox_override("normal", _make_button_style(accent))
	button.add_theme_stylebox_override("hover", _make_button_style(accent.lightened(0.1)))
	button.add_theme_stylebox_override("pressed", _make_button_style(accent.darkened(0.08)))
	return button


func _make_quick_start_button(text: String, accent: Color, callback: Callable) -> Button:
	var button := _make_action_button(text, accent)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = _v(0.0, 48.0)
	button.add_theme_font_size_override("font_size", _i(18))
	button.pressed.connect(callback)
	return button


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = _localize_text(text)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var settings := LabelSettings.new()
	settings.font = ui_font
	settings.font_size = _i(font_size)
	settings.font_color = _resolve_label_color(color)
	settings.outline_size = 1
	settings.outline_color = _get_theme_palette()["outline"]
	label.label_settings = settings
	return label


func _make_text_input(placeholder_text: String) -> LineEdit:
	var input := LineEdit.new()
	input.custom_minimum_size = _v(0.0, 50.0)
	input.placeholder_text = _localize_text(placeholder_text)
	input.clear_button_enabled = true
	input.add_theme_font_override("font", ui_font)
	input.add_theme_font_size_override("font_size", _i(19))
	input.add_theme_color_override("font_color", _resolve_label_color(Color(0.96, 0.95, 0.9, 0.98)))
	input.add_theme_color_override("caret_color", _resolve_label_color(Color(0.96, 0.82, 0.56, 0.94)))
	input.add_theme_color_override("font_placeholder_color", _resolve_label_color(Color(0.68, 0.76, 0.84, 0.8)))
	input.add_theme_stylebox_override("normal", _make_panel_style(Color(0.06, 0.08, 0.1, 0.9), Color(0.28, 0.36, 0.42, 0.56)))
	input.add_theme_stylebox_override("focus", _make_panel_style(Color(0.08, 0.11, 0.14, 0.94), Color(0.92, 0.68, 0.42, 0.58)))
	input.add_theme_stylebox_override("read_only", _make_panel_style(Color(0.06, 0.08, 0.1, 0.72), Color(0.28, 0.36, 0.42, 0.4)))
	return input


func _make_panel_style(fill_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = _resolve_surface_fill(fill_color)
	style.border_width_left = maxi(1, _i(2))
	style.border_width_top = maxi(1, _i(2))
	style.border_width_right = maxi(1, _i(2))
	style.border_width_bottom = maxi(1, _i(2))
	style.border_color = _resolve_surface_border(border_color)
	style.corner_radius_top_left = _i(28)
	style.corner_radius_top_right = _i(28)
	style.corner_radius_bottom_left = _i(28)
	style.corner_radius_bottom_right = _i(28)
	style.shadow_color = _get_theme_palette()["shadow"]
	style.shadow_size = _i(12)
	return style


func _make_card_style(selected: bool, accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = _resolve_surface_fill(Color(accent.r * 0.14, accent.g * 0.14, accent.b * 0.18, 0.94))
	style.border_width_left = 3 if selected else 2
	style.border_width_top = 3 if selected else 2
	style.border_width_right = 3 if selected else 2
	style.border_width_bottom = 3 if selected else 2
	style.border_color = _resolve_surface_border(accent if selected else Color(accent.r, accent.g, accent.b, 0.65))
	style.corner_radius_top_left = _i(28)
	style.corner_radius_top_right = _i(28)
	style.corner_radius_bottom_left = _i(28)
	style.corner_radius_bottom_right = _i(28)
	style.shadow_color = _get_theme_palette()["shadow"]
	style.shadow_size = _i(12)
	return style


func _make_button_style(accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = _resolve_button_fill(accent)
	style.corner_radius_top_left = _i(14)
	style.corner_radius_top_right = _i(14)
	style.corner_radius_bottom_left = _i(14)
	style.corner_radius_bottom_right = _i(14)
	return style


func _make_fill_style(fill_color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = _resolve_button_fill(fill_color)
	style.corner_radius_top_left = _i(radius)
	style.corner_radius_top_right = _i(radius)
	style.corner_radius_bottom_left = _i(radius)
	style.corner_radius_bottom_right = _i(radius)
	return style


func _make_pill_button(text: String, size: Vector2, callback: Callable) -> Button:
	var button := Button.new()
	button.text = _localize_text(text)
	button.custom_minimum_size = size
	button.add_theme_font_override("font", ui_font)
	button.add_theme_font_size_override("font_size", _i(19))
	button.add_theme_color_override("font_color", _resolve_label_color(Color(0.98, 0.92, 0.82, 0.98)))
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.04, 0.06, 0.08, 0.78), Color(0.2, 0.26, 0.32, 0.54)))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.08, 0.1, 0.12, 0.84), Color(0.92, 0.68, 0.42, 0.44)))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.08, 0.1, 0.12, 0.88), Color(0.92, 0.68, 0.42, 0.62)))
	button.pressed.connect(callback)
	return button


func _make_static_pill(text: String, size: Vector2) -> PanelContainer:
	var pill := PanelContainer.new()
	pill.custom_minimum_size = size
	pill.add_theme_stylebox_override("panel", _make_panel_style(Color(0.04, 0.06, 0.08, 0.78), Color(0.2, 0.26, 0.32, 0.54)))
	var label := _make_label(_localize_text(text), 18, Color(0.98, 0.92, 0.82, 0.98))
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
	var portrait_layout := _is_portrait_layout()
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
	_set_center_overlay_panel(panel, 860.0, 760.0 if portrait_layout else 580.0)
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
	var portrait_layout := _is_portrait_layout()
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
	_set_center_overlay_panel(panel, 860.0, 760.0 if portrait_layout else 580.0)
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

	character_archive_cards_root = VBoxContainer.new()
	character_archive_cards_root.custom_minimum_size = _v(740.0, 0.0)
	character_archive_cards_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	character_archive_cards_root.add_theme_constant_override("separation", _i(16))
	scroll.add_child(character_archive_cards_root)

	var action_row := HBoxContainer.new()
	action_row.alignment = BoxContainer.ALIGNMENT_END
	action_row.add_theme_constant_override("separation", _i(12))
	box.add_child(action_row)
	action_row.add_child(_make_pill_button("收起人物志", _v(170.0, 52.0), Callable(self, "_hide_character_archive_overlay")))
	_populate_character_archive_cards()


func _build_leaderboard_overlay() -> void:
	var portrait_layout := _is_portrait_layout()
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
	_set_center_overlay_panel(panel, 840.0, 740.0 if portrait_layout else 560.0)
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
	box.add_child(_make_label("现在可以在二级菜单里直接查看本地排行榜，并顺手回看每局 build 走向，不必先打到结算页。", 18, Color(0.88, 0.92, 0.96, 0.95)))

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
	leaderboard_summary_label = _make_label("", 17, Color(0.94, 0.82, 0.56, 0.94))
	summary_margin.add_child(leaderboard_summary_label)

	var switch_row: BoxContainer = VBoxContainer.new() if portrait_layout else HBoxContainer.new()
	switch_row.add_theme_constant_override("separation", _i(12))
	box.add_child(switch_row)

	leaderboard_manual_button = _make_pill_button("主卷榜", _v(0.0, 48.0), Callable(self, "_on_leaderboard_manual_pressed"))
	leaderboard_manual_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	switch_row.add_child(leaderboard_manual_button)

	leaderboard_test_button = _make_pill_button("试阵榜", _v(0.0, 48.0), Callable(self, "_on_leaderboard_test_pressed"))
	leaderboard_test_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	switch_row.add_child(leaderboard_test_button)

	var sort_shell := VBoxContainer.new()
	sort_shell.add_theme_constant_override("separation", _i(10))
	box.add_child(sort_shell)
	sort_shell.add_child(_make_label("当前可以按波次、击破或存活重新排序，更接近 source web 原型里回看不同 build 结果的方式。", 16, Color(0.82, 0.9, 1.0, 0.9)))

	var sort_row: BoxContainer = VBoxContainer.new() if portrait_layout else HBoxContainer.new()
	sort_row.add_theme_constant_override("separation", _i(10))
	sort_shell.add_child(sort_row)

	leaderboard_sort_wave_button = _make_pill_button("按波次", _v(0.0, 46.0), Callable(self, "_on_leaderboard_sort_wave_pressed"))
	leaderboard_sort_wave_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sort_row.add_child(leaderboard_sort_wave_button)

	leaderboard_sort_kills_button = _make_pill_button("按击破", _v(0.0, 46.0), Callable(self, "_on_leaderboard_sort_kills_pressed"))
	leaderboard_sort_kills_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sort_row.add_child(leaderboard_sort_kills_button)

	leaderboard_sort_time_button = _make_pill_button("按存活", _v(0.0, 46.0), Callable(self, "_on_leaderboard_sort_time_pressed"))
	leaderboard_sort_time_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sort_row.add_child(leaderboard_sort_time_button)

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
	_refresh_leaderboard_overlay()


func _build_profile_overlay() -> void:
	var portrait_layout := _is_portrait_layout()
	profile_overlay = Control.new()
	profile_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	profile_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	profile_overlay.visible = false
	add_child(profile_overlay)

	var scrim := ColorRect.new()
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.02, 0.03, 0.04, 0.82)
	profile_overlay.add_child(scrim)

	var panel := PanelContainer.new()
	_set_center_overlay_panel(panel, 760.0, 760.0 if portrait_layout else 500.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.08, 0.1, 0.96), Color(0.52, 0.8, 1.0, 0.58)))
	profile_overlay.add_child(panel)

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

	box.add_child(_make_label("玩家名帖", 36, Color(1.0, 0.95, 0.86, 1.0)))
	box.add_child(_make_label("像 source web 原型一样，先在菜单里维护这台设备的默认排行榜署名。结算页留空时，会自动复用这里的名字。", 18, Color(0.88, 0.92, 0.96, 0.95)))

	var content_row: BoxContainer = VBoxContainer.new() if portrait_layout else HBoxContainer.new()
	content_row.add_theme_constant_override("separation", _i(16))
	box.add_child(content_row)

	var preview_card := PanelContainer.new()
	preview_card.custom_minimum_size = _v(220.0, 0.0)
	preview_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_card.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.72), Color(0.38, 0.72, 0.82, 0.34)))
	content_row.add_child(preview_card)

	var preview_margin := MarginContainer.new()
	preview_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	preview_margin.add_theme_constant_override("margin_left", _i(18))
	preview_margin.add_theme_constant_override("margin_top", _i(18))
	preview_margin.add_theme_constant_override("margin_right", _i(18))
	preview_margin.add_theme_constant_override("margin_bottom", _i(18))
	preview_card.add_child(preview_margin)

	var preview_box := VBoxContainer.new()
	preview_box.add_theme_constant_override("separation", _i(10))
	preview_margin.add_child(preview_box)
	preview_box.add_child(_make_label("当前署名", 18, Color(0.96, 0.82, 0.54, 0.94)))

	var avatar_panel := PanelContainer.new()
	avatar_panel.custom_minimum_size = _v(0.0, 108.0)
	avatar_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.1, 0.14, 0.18, 0.86), Color(0.52, 0.8, 1.0, 0.28)))
	preview_box.add_child(avatar_panel)

	profile_preview_glyph_label = _make_label("侠", 46, Color(1.0, 0.95, 0.86, 1.0))
	profile_preview_glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	profile_preview_glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	profile_preview_glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	avatar_panel.add_child(profile_preview_glyph_label)

	profile_preview_name_label = _make_label("", 26, Color(1.0, 0.95, 0.86, 1.0))
	profile_preview_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_box.add_child(profile_preview_name_label)

	profile_preview_copy_label = _make_label("", 16, Color(0.86, 0.9, 0.94, 0.92))
	preview_box.add_child(profile_preview_copy_label)

	var editor_card := PanelContainer.new()
	editor_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor_card.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.72), Color(0.92, 0.68, 0.42, 0.32)))
	content_row.add_child(editor_card)

	var editor_margin := MarginContainer.new()
	editor_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	editor_margin.add_theme_constant_override("margin_left", _i(18))
	editor_margin.add_theme_constant_override("margin_top", _i(18))
	editor_margin.add_theme_constant_override("margin_right", _i(18))
	editor_margin.add_theme_constant_override("margin_bottom", _i(18))
	editor_card.add_child(editor_margin)

	var editor_box := VBoxContainer.new()
	editor_box.add_theme_constant_override("separation", _i(10))
	editor_margin.add_child(editor_box)
	editor_box.add_child(_make_label("默认排行榜署名", 22, Color(1.0, 0.92, 0.8, 1.0)))

	profile_status_label = _make_label("", 15, Color(0.82, 0.9, 1.0, 0.92))
	profile_status_label.visible = false
	editor_box.add_child(profile_status_label)

	profile_name_input = _make_text_input("输入想显示的名字")
	profile_name_input.text_changed.connect(func(_text: String) -> void:
		_refresh_profile_preview_from_input()
	)
	profile_name_input.text_submitted.connect(func(_text: String) -> void:
		_on_profile_save_pressed()
	)
	editor_box.add_child(profile_name_input)

	profile_hint_label = _make_label("", 16, Color(0.88, 0.92, 0.96, 0.92))
	editor_box.add_child(profile_hint_label)

	var action_row: BoxContainer = VBoxContainer.new() if portrait_layout else HBoxContainer.new()
	action_row.add_theme_constant_override("separation", _i(10))
	editor_box.add_child(action_row)

	var random_button := _make_pill_button("随机侠名", _v(0.0, 48.0), Callable(self, "_on_profile_random_pressed"))
	random_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_row.add_child(random_button)

	var save_button := _make_action_button("保存署名", Color(0.92, 0.62, 0.28, 1.0))
	save_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_button.custom_minimum_size = _v(0.0, 48.0)
	save_button.add_theme_font_size_override("font_size", _i(19))
	save_button.pressed.connect(_on_profile_save_pressed)
	action_row.add_child(save_button)

	var footer_row: BoxContainer = VBoxContainer.new() if portrait_layout else HBoxContainer.new()
	footer_row.add_theme_constant_override("separation", _i(10))
	box.add_child(footer_row)

	var reset_button := _make_pill_button("恢复默认", _v(0.0, 50.0), Callable(self, "_on_profile_reset_pressed"))
	reset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer_row.add_child(reset_button)

	var close_button := _make_pill_button("返回菜单", _v(0.0, 50.0), Callable(self, "_hide_profile_overlay"))
	close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer_row.add_child(close_button)

	_refresh_profile_overlay()


func _build_enemy_archive_overlay() -> void:
	var portrait_layout := _is_portrait_layout()
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
	_set_center_overlay_panel(panel, 880.0, 780.0 if portrait_layout else 600.0)
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
	var portrait_layout := _is_portrait_layout()
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
	_set_center_overlay_panel(panel, 680.0, 420.0 if portrait_layout else 340.0)
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


func _localized_hero_data(hero_id: String) -> Dictionary:
	return HanziLocalization.localized_hero_data(hero_id, current_language)


func _localized_recipe_data(recipe_id: String) -> Dictionary:
	return HanziLocalization.localized_recipe_data(recipe_id, current_language)


func _localized_word_data(word_id: String) -> Dictionary:
	return HanziLocalization.localized_word_data(word_id, current_language)


func _localized_radical_data(radical: String) -> Dictionary:
	return HanziLocalization.localized_radical_data(radical, current_language)


func _localized_enemy_data(enemy_id: String) -> Dictionary:
	return HanziLocalization.localized_enemy_data(enemy_id, current_language)


func _build_recipe_atlas_text() -> String:
	var lines: Array[String]
	if _is_english():
		lines = [
			"Complete radicals into formed glyphs first, then refine them into phrase arts at the inkstone once they are maxed.",
			"Review the route before entering battle so each three-choice level-up is easier to judge.",
			""
		]
	else:
		lines = [
			"偏旁先补齐成字，成字满级后再去砚台磨成词技。",
			"进入残卷前先看一眼路线，升级三选一时会更容易判断当前该补哪一笔。",
			""
		]
	for recipe_id_variant in Session.RECIPE_ORDER:
		var recipe_id := String(recipe_id_variant)
		var recipe: Dictionary = _localized_recipe_data(recipe_id)
		var radicals: Array = recipe.get("radicals", [])
		var radical_texts: Array[String] = []
		for radical_variant in radicals:
			var radical := String(radical_variant)
			var radical_data: Dictionary = _localized_radical_data(radical)
			radical_texts.append("%s %s" % [radical, String(radical_data.get("name", ""))])

		var word_id := String(recipe.get("word_id", ""))
		var word: Dictionary = {}
		if word_id != "":
			word = _localized_word_data(word_id)

		lines.append("%s  %s" % [String(recipe.get("display", "")), " + ".join(radical_texts)])
		if _is_english():
			lines.append("Glyph: %s  Lv.%d" % [String(recipe.get("title", "")), int(recipe.get("max_level", 1))])
		else:
			lines.append("成字：%s  Lv.%d" % [String(recipe.get("title", "")), int(recipe.get("max_level", 1))])
		lines.append("  %s" % String(recipe.get("description", "")))
		if not word.is_empty():
			if _is_english():
				lines.append("Phrase: %s  Lv.%d  Inkstone cost %d" % [String(word.get("title", "")), int(word.get("max_level", 1)), int(word.get("unlock_cost", 0))])
			else:
				lines.append("磨词：%s  Lv.%d  砚台消耗 %d" % [String(word.get("title", "")), int(word.get("max_level", 1)), int(word.get("unlock_cost", 0))])
			lines.append("  %s" % String(word.get("description", "")))
		lines.append("")

	var blade_data: Dictionary = _localized_radical_data("刂")
	lines.append("Independent Radical" if _is_english() else "独立偏旁")
	lines.append("刂  %s" % String(blade_data.get("name", "")))
	lines.append("  %s" % String(blade_data.get("description", "")))
	return "\n".join(lines)


func _build_hero_opening_summary(hero: Dictionary) -> String:
	var hero_id := String(hero.get("id", "scholar"))
	var starting_radicals: Array[String] = Session.get_hero_starting_radicals(hero_id)
	if starting_radicals.is_empty():
		return "The current Godot build keeps this hero without fixed opening radicals, so the first drops are meant to decide which fusion line the run should follow." if _is_english() else "当前 Godot 保持无固定起手偏旁，第一批掉落更适合顺势决定这一局往哪条合字线转。"
	var radical_labels: Array[String] = []
	for radical in starting_radicals:
		var radical_data: Dictionary = _localized_radical_data(radical)
		radical_labels.append("%s %s" % [radical, String(radical_data.get("name", ""))])
	return "This Godot build starts with %s, letting the hero reach their opening route earlier." % " / ".join(radical_labels) if _is_english() else "当前 Godot 会带着 %s 入卷，让这名执笔者更早摸到自己的开场路线。" % " / ".join(radical_labels)


func _build_hero_starting_tags(hero: Dictionary) -> Array[String]:
	var hero_id := String(hero.get("id", "scholar"))
	var starting_radicals: Array[String] = Session.get_hero_starting_radicals(hero_id)
	if starting_radicals.is_empty():
		var fallback_tags: Array[String] = []
		fallback_tags.append("No fixed opener" if _is_english() else "无固定起手")
		return fallback_tags
	var tags: Array[String] = []
	for radical in starting_radicals:
		var radical_data: Dictionary = _localized_radical_data(radical)
		tags.append("%s %s" % [radical, String(radical_data.get("name", ""))])
	return tags


func _get_hero_attack_rate(hero: Dictionary) -> float:
	var attack_interval := float(hero.get("attack_interval", 0.0))
	if attack_interval <= 0.0:
		return 0.0
	return 1.0 / attack_interval


func _build_hero_active_skill_headline(hero: Dictionary) -> String:
	var glyph := String(hero.get("active_skill_glyph", "")).strip_edges()
	var name := String(hero.get("active_skill_name", "")).strip_edges()
	var cooldown := float(hero.get("active_skill_cooldown", 0.0))
	var parts: Array[String] = []
	if not glyph.is_empty():
		parts.append(glyph)
	if not name.is_empty():
		parts.append(name)
	if cooldown > 0.0:
		parts.append("%.1fs cooldown" % cooldown if _is_english() else "%.1f 秒冷却" % cooldown)
	if parts.is_empty():
		return "There is no matching source skill entry for this hero yet." if _is_english() else "当前还没有可对照的源稿字技条目。"
	return " · ".join(parts)


func _build_hero_active_skill_body(hero: Dictionary) -> String:
	var description := String(hero.get("active_skill_description", "")).strip_edges()
	if description.is_empty():
		return "This hero does not yet have an extra source-skill note." if _is_english() else "当前这名执笔者还没有额外记录到独立字技说明。"
	return _localize_text(description)


func _make_progression_card(card: Dictionary, accent: Color, compact: bool = false) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.12, accent.g * 0.12, accent.b * 0.16, 0.58), Color(accent.r, accent.g, accent.b, 0.24)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(14 if compact else 16))
	margin.add_theme_constant_override("margin_top", _i(12 if compact else 14))
	margin.add_theme_constant_override("margin_right", _i(14 if compact else 16))
	margin.add_theme_constant_override("margin_bottom", _i(12 if compact else 14))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(6 if compact else 8))
	margin.add_child(box)

	var title := String(card.get("title", "")).strip_edges()
	if not title.is_empty():
		box.add_child(_make_label(title, 16 if compact else 17, Color(1.0, 0.92, 0.8, 1.0)))

	var description := String(card.get("description", "")).strip_edges()
	if not description.is_empty():
		box.add_child(_make_label(description, 15 if compact else 16, Color(0.9, 0.92, 0.95, 0.95)))

	var tags_variant: Variant = card.get("tags", [])
	if tags_variant is Array and not (tags_variant as Array).is_empty():
		var tag_row := HFlowContainer.new()
		tag_row.add_theme_constant_override("h_separation", _i(10))
		tag_row.add_theme_constant_override("v_separation", _i(10))
		box.add_child(tag_row)
		for tag_variant in tags_variant:
			tag_row.add_child(_make_tag(String(tag_variant), Color(accent.r * 0.16, accent.g * 0.16, accent.b * 0.2, 0.88), Color(0.98, 0.95, 0.9, 0.96)))

	return panel


func _populate_progression_cards(root: VBoxContainer, hero: Dictionary, accent: Color, compact: bool = false) -> void:
	if root == null:
		return
	for child in root.get_children():
		child.queue_free()
	var cards_variant: Variant = hero.get("progression_cards", [])
	if cards_variant is Array:
		for card_variant in cards_variant:
			if card_variant is Dictionary:
				root.add_child(_make_progression_card(card_variant as Dictionary, accent, compact))


func _make_build_route_card(card: Dictionary, accent: Color, compact: bool = false) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.12, accent.g * 0.12, accent.b * 0.16, 0.58), Color(accent.r, accent.g, accent.b, 0.24)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(14 if compact else 16))
	margin.add_theme_constant_override("margin_top", _i(12 if compact else 14))
	margin.add_theme_constant_override("margin_right", _i(14 if compact else 16))
	margin.add_theme_constant_override("margin_bottom", _i(12 if compact else 14))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(8 if compact else 10))
	margin.add_child(box)

	var head_row := HBoxContainer.new()
	head_row.add_theme_constant_override("separation", _i(12))
	box.add_child(head_row)

	var glyph_panel := PanelContainer.new()
	glyph_panel.custom_minimum_size = _v(56.0 if compact else 62.0, 56.0 if compact else 62.0)
	glyph_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.16, accent.g * 0.16, accent.b * 0.2, 0.88), Color(accent.r, accent.g, accent.b, 0.28)))
	head_row.add_child(glyph_panel)

	var glyph_label := _make_label(String(card.get("glyph", "路")).strip_edges(), 24 if compact else 28, Color(1.0, 0.95, 0.9, 1.0))
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph_panel.add_child(glyph_label)

	var summary_box := VBoxContainer.new()
	summary_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_box.add_theme_constant_override("separation", _i(4))
	head_row.add_child(summary_box)

	var title := String(card.get("title", "")).strip_edges()
	if not title.is_empty():
		summary_box.add_child(_make_label(title, 16 if compact else 17, Color(1.0, 0.92, 0.8, 1.0)))

	var subtitle := String(card.get("subtitle", "")).strip_edges()
	if not subtitle.is_empty():
		summary_box.add_child(_make_label(subtitle, 14 if compact else 15, Color(0.82, 0.9, 1.0, 0.94)))

	var description := String(card.get("description", "")).strip_edges()
	if not description.is_empty():
		box.add_child(_make_label(description, 15 if compact else 16, Color(0.9, 0.92, 0.95, 0.95)))

	var tags_variant: Variant = card.get("tags", [])
	if tags_variant is Array and not (tags_variant as Array).is_empty():
		var tag_row := HFlowContainer.new()
		tag_row.add_theme_constant_override("h_separation", _i(10))
		tag_row.add_theme_constant_override("v_separation", _i(10))
		box.add_child(tag_row)
		for tag_variant in tags_variant:
			tag_row.add_child(_make_tag(String(tag_variant), Color(accent.r * 0.16, accent.g * 0.16, accent.b * 0.2, 0.88), Color(0.98, 0.95, 0.9, 0.96)))

	var source_relics_variant: Variant = card.get("source_relics", [])
	if source_relics_variant is Array and not (source_relics_variant as Array).is_empty():
		box.add_child(
			_make_build_route_pairing_block(
				"源稿遗物偏向",
				source_relics_variant as Array,
				Color(0.92, 0.7, 0.42, 0.14),
				Color(1.0, 0.95, 0.88, 0.96),
				compact
			)
		)

	var source_words_variant: Variant = card.get("source_words", [])
	if source_words_variant is Array and not (source_words_variant as Array).is_empty():
		box.add_child(
			_make_build_route_pairing_block(
				"源稿词技偏向",
				source_words_variant as Array,
				Color(0.44, 0.68, 0.86, 0.14),
				Color(0.92, 0.96, 1.0, 0.96),
				compact
			)
		)

	return panel


func _make_build_route_pairing_block(title: String, entries: Array, fill_color: Color, text_color: Color, compact: bool = false) -> VBoxContainer:
	var block := VBoxContainer.new()
	block.add_theme_constant_override("separation", _i(6))
	block.add_child(_make_label(title, 13 if compact else 14, Color(0.96, 0.82, 0.54, 0.9)))

	var row := HFlowContainer.new()
	row.add_theme_constant_override("h_separation", _i(8))
	row.add_theme_constant_override("v_separation", _i(8))
	block.add_child(row)

	for entry_variant in entries:
		row.add_child(_make_tag(String(entry_variant), fill_color, text_color))

	return block


func _populate_build_route_cards(root: VBoxContainer, hero: Dictionary, accent: Color, compact: bool = false) -> void:
	if root == null:
		return
	for child in root.get_children():
		child.queue_free()
	var cards_variant: Variant = hero.get("build_route_cards", [])
	if cards_variant is Array:
		for card_variant in cards_variant:
			if card_variant is Dictionary:
				root.add_child(_make_build_route_card(card_variant as Dictionary, accent, compact))


func _make_archive_stat_item(title: String, value: String, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.12, accent.g * 0.12, accent.b * 0.16, 0.58), Color(accent.r, accent.g, accent.b, 0.2)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(14))
	margin.add_theme_constant_override("margin_top", _i(12))
	margin.add_theme_constant_override("margin_right", _i(14))
	margin.add_theme_constant_override("margin_bottom", _i(12))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(4))
	margin.add_child(box)
	box.add_child(_make_label(title, 14, Color(0.96, 0.82, 0.54, 0.88)))
	box.add_child(_make_label(value, 20, Color(0.98, 0.95, 0.9, 0.98)))
	return panel


func _make_character_archive_card(hero: Dictionary) -> PanelContainer:
	var portrait_layout := _is_portrait_layout()
	var accent: Color = hero["accent"]
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_card_style(false, accent))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(20))
	margin.add_theme_constant_override("margin_top", _i(20))
	margin.add_theme_constant_override("margin_right", _i(20))
	margin.add_theme_constant_override("margin_bottom", _i(20))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(14))
	margin.add_child(box)

	var head_row: BoxContainer = VBoxContainer.new() if portrait_layout else HBoxContainer.new()
	head_row.add_theme_constant_override("separation", _i(16))
	box.add_child(head_row)

	var preview := PanelContainer.new()
	preview.custom_minimum_size = _v(0.0, 132.0 if portrait_layout else 0.0)
	preview.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.14, accent.g * 0.14, accent.b * 0.16, 0.58), Color(accent.r, accent.g, accent.b, 0.24)))
	head_row.add_child(preview)
	_build_card_preview(preview, hero)

	var summary_box := VBoxContainer.new()
	summary_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_box.add_theme_constant_override("separation", _i(8))
	head_row.add_child(summary_box)
	summary_box.add_child(_make_label("%s  ·  %s" % [_localize_text(String(hero.get("name", ""))), _localize_text(String(hero.get("title", "")))], 30, Color(1.0, 0.95, 0.86, 1.0)))
	summary_box.add_child(_make_label(String(hero.get("role_label", "")), 18, accent))
	summary_box.add_child(_make_label(String(hero.get("description", "")), 17, Color(0.9, 0.92, 0.95, 0.96)))
	summary_box.add_child(_make_label("Hero focus: %s" % String(hero.get("focus", "")) if _is_english() else "执笔焦点：%s" % String(hero.get("focus", "")), 16, Color(0.82, 0.9, 1.0, 0.94)))

	var tag_row := HFlowContainer.new()
	tag_row.add_theme_constant_override("h_separation", _i(10))
	tag_row.add_theme_constant_override("v_separation", _i(10))
	summary_box.add_child(tag_row)
	for tag_variant in hero.get("tags", []):
		tag_row.add_child(_make_tag(String(tag_variant), Color(accent.r * 0.16, accent.g * 0.16, accent.b * 0.2, 0.88), Color(0.98, 0.95, 0.9, 0.96)))

	var quote_panel := PanelContainer.new()
	quote_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quote_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.12, accent.g * 0.12, accent.b * 0.16, 0.68), Color(accent.r, accent.g, accent.b, 0.24)))
	box.add_child(quote_panel)

	var quote_margin := MarginContainer.new()
	quote_margin.add_theme_constant_override("margin_left", _i(16))
	quote_margin.add_theme_constant_override("margin_top", _i(16))
	quote_margin.add_theme_constant_override("margin_right", _i(16))
	quote_margin.add_theme_constant_override("margin_bottom", _i(16))
	quote_panel.add_child(quote_margin)

	var quote_box := VBoxContainer.new()
	quote_box.add_theme_constant_override("separation", _i(6))
	quote_margin.add_child(quote_box)
	quote_box.add_child(_make_label("卷中文字", 16, Color(0.96, 0.82, 0.54, 0.88)))
	quote_box.add_child(_make_label("“%s”" % String(hero.get("record_excerpt", String(hero.get("focus", "")))), 18, Color(0.98, 0.95, 0.9, 0.98)))
	quote_box.add_child(_make_label(String(hero.get("record_source", "")), 15, Color(0.82, 0.9, 1.0, 0.92)))

	var record_panel := PanelContainer.new()
	record_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	record_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.72), Color(0.28, 0.36, 0.42, 0.46)))
	box.add_child(record_panel)

	var record_margin := MarginContainer.new()
	record_margin.add_theme_constant_override("margin_left", _i(16))
	record_margin.add_theme_constant_override("margin_top", _i(16))
	record_margin.add_theme_constant_override("margin_right", _i(16))
	record_margin.add_theme_constant_override("margin_bottom", _i(16))
	record_panel.add_child(record_margin)

	var record_box := VBoxContainer.new()
	record_box.add_theme_constant_override("separation", _i(6))
	record_margin.add_child(record_box)
	record_box.add_child(_make_label(String(hero.get("record_title", "人物札记")), 20, Color(1.0, 0.92, 0.8, 1.0)))
	record_box.add_child(_make_label(String(hero.get("record_body", String(hero.get("description", "")))), 17, Color(0.9, 0.92, 0.95, 0.96)))

	var route_panel := PanelContainer.new()
	route_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	route_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.72), Color(0.42, 0.68, 0.86, 0.34)))
	box.add_child(route_panel)

	var route_margin := MarginContainer.new()
	route_margin.add_theme_constant_override("margin_left", _i(16))
	route_margin.add_theme_constant_override("margin_top", _i(16))
	route_margin.add_theme_constant_override("margin_right", _i(16))
	route_margin.add_theme_constant_override("margin_bottom", _i(16))
	route_panel.add_child(route_margin)

	var route_box := VBoxContainer.new()
	route_box.add_theme_constant_override("separation", _i(8))
	route_margin.add_child(route_box)
	route_box.add_child(_make_label("起笔落点", 18, Color(1.0, 0.92, 0.8, 1.0)))
	route_box.add_child(_make_label(_build_hero_opening_summary(hero), 16, Color(0.88, 0.92, 0.96, 0.94)))

	var route_tags := HFlowContainer.new()
	route_tags.add_theme_constant_override("h_separation", _i(10))
	route_tags.add_theme_constant_override("v_separation", _i(10))
	route_box.add_child(route_tags)
	for tag_text in _build_hero_starting_tags(hero):
		route_tags.add_child(_make_tag(tag_text, Color(accent.r * 0.16, accent.g * 0.16, accent.b * 0.2, 0.88), Color(0.98, 0.95, 0.9, 0.96)))

	var trait_label := String(hero.get("trait_label", "")).strip_edges()
	var trait_description := String(hero.get("trait_description", "")).strip_edges()
	var route_hint := String(hero.get("route_hint", "")).strip_edges()
	if not trait_label.is_empty():
		route_box.add_child(_make_label("角色特性：%s" % trait_label, 16, Color(0.96, 0.82, 0.54, 0.9)))
	if not trait_description.is_empty():
		route_box.add_child(_make_label(trait_description, 16, Color(0.9, 0.92, 0.95, 0.94)))
	if not route_hint.is_empty():
		route_box.add_child(_make_label("入卷建议：%s" % route_hint, 16, Color(0.82, 0.9, 1.0, 0.94)))

	var active_panel := PanelContainer.new()
	active_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	active_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.72), Color(0.9, 0.66, 0.36, 0.3)))
	box.add_child(active_panel)

	var active_margin := MarginContainer.new()
	active_margin.add_theme_constant_override("margin_left", _i(16))
	active_margin.add_theme_constant_override("margin_top", _i(16))
	active_margin.add_theme_constant_override("margin_right", _i(16))
	active_margin.add_theme_constant_override("margin_bottom", _i(16))
	active_panel.add_child(active_margin)

	var active_box := VBoxContainer.new()
	active_box.add_theme_constant_override("separation", _i(8))
	active_margin.add_child(active_box)
	active_box.add_child(_make_label("源稿字技（待迁移）", 18, Color(1.0, 0.92, 0.8, 1.0)))
	active_box.add_child(_make_label(_build_hero_active_skill_headline(hero), 16, Color(0.96, 0.82, 0.54, 0.96)))
	active_box.add_child(_make_label(_build_hero_active_skill_body(hero), 16, Color(0.9, 0.92, 0.95, 0.94)))
	active_box.add_child(_make_label("当前只在人物志里保留对照预览，实际战斗输入仍待迁移。", 15, Color(0.82, 0.9, 1.0, 0.9)))

	var progression_panel := PanelContainer.new()
	progression_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	progression_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.72), Color(0.74, 0.56, 0.28, 0.34)))
	box.add_child(progression_panel)

	var progression_margin := MarginContainer.new()
	progression_margin.add_theme_constant_override("margin_left", _i(16))
	progression_margin.add_theme_constant_override("margin_top", _i(16))
	progression_margin.add_theme_constant_override("margin_right", _i(16))
	progression_margin.add_theme_constant_override("margin_bottom", _i(16))
	progression_panel.add_child(progression_margin)

	var progression_box := VBoxContainer.new()
	progression_box.add_theme_constant_override("separation", _i(10))
	progression_margin.add_child(progression_box)
	progression_box.add_child(_make_label("残卷路线", 18, Color(1.0, 0.92, 0.8, 1.0)))
	progression_box.add_child(_make_label("把这名执笔者的前几步 build 顺序先看清，再入卷会更容易顺着掉落继续写。", 16, Color(0.88, 0.92, 0.96, 0.94)))

	var progression_cards_root := VBoxContainer.new()
	progression_cards_root.add_theme_constant_override("separation", _i(10))
	progression_box.add_child(progression_cards_root)
	_populate_progression_cards(progression_cards_root, hero, accent)
	progression_box.add_child(_make_label("当前先保留 web 原型的 build 顺序与路线提示，Godot 战斗内还没有真正的路线权重修正与额外掉落偏向。", 15, Color(0.82, 0.9, 1.0, 0.88)))

	var build_route_panel := PanelContainer.new()
	build_route_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	build_route_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.72), Color(0.42, 0.68, 0.86, 0.34)))
	box.add_child(build_route_panel)

	var build_route_margin := MarginContainer.new()
	build_route_margin.add_theme_constant_override("margin_left", _i(16))
	build_route_margin.add_theme_constant_override("margin_top", _i(16))
	build_route_margin.add_theme_constant_override("margin_right", _i(16))
	build_route_margin.add_theme_constant_override("margin_bottom", _i(16))
	build_route_panel.add_child(build_route_margin)

	var build_route_box := VBoxContainer.new()
	build_route_box.add_theme_constant_override("separation", _i(10))
	build_route_margin.add_child(build_route_box)
	build_route_box.add_child(_make_label("源稿构筑方向", 18, Color(1.0, 0.92, 0.8, 1.0)))
	build_route_box.add_child(_make_label("对照 web 原型现有的路线选择，把更贴近这名执笔者的构筑方向与词技 / 遗物搭配保留成前台参考。", 16, Color(0.88, 0.92, 0.96, 0.94)))

	var build_route_cards_root := VBoxContainer.new()
	build_route_cards_root.add_theme_constant_override("separation", _i(10))
	build_route_box.add_child(build_route_cards_root)
	_populate_build_route_cards(build_route_cards_root, hero, accent)
	build_route_box.add_child(_make_label("这些卡片当前不直接改战斗数值、掉落权重或路线偏向，只帮助对照 web 原型的构筑意图。", 15, Color(0.82, 0.9, 1.0, 0.88)))

	var stats_panel := PanelContainer.new()
	stats_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.72), Color(0.28, 0.36, 0.42, 0.46)))
	box.add_child(stats_panel)

	var stats_margin := MarginContainer.new()
	stats_margin.add_theme_constant_override("margin_left", _i(16))
	stats_margin.add_theme_constant_override("margin_top", _i(16))
	stats_margin.add_theme_constant_override("margin_right", _i(16))
	stats_margin.add_theme_constant_override("margin_bottom", _i(16))
	stats_panel.add_child(stats_margin)

	var stats_box := VBoxContainer.new()
	stats_box.add_theme_constant_override("separation", _i(10))
	stats_margin.add_child(stats_box)
	stats_box.add_child(_make_label("战斗轮廓", 18, Color(1.0, 0.92, 0.8, 1.0)))

	var stats_grid := GridContainer.new()
	stats_grid.columns = 2 if portrait_layout else 3
	stats_grid.add_theme_constant_override("h_separation", _i(10))
	stats_grid.add_theme_constant_override("v_separation", _i(10))
	stats_box.add_child(stats_grid)
	stats_grid.add_child(_make_archive_stat_item("机动", "%.1f" % float(hero.get("move_speed", 0.0)), accent))
	stats_grid.add_child(_make_archive_stat_item("气血", "%.0f" % float(hero.get("max_health", 0.0)), accent))
	stats_grid.add_child(_make_archive_stat_item("伤害", "%.0f" % float(hero.get("attack_damage", 0.0)), accent))
	stats_grid.add_child(_make_archive_stat_item("射程", "%.1f" % float(hero.get("attack_range", 0.0)), accent))
	stats_grid.add_child(_make_archive_stat_item("攻速", "%.2f/s" % _get_hero_attack_rate(hero) if _is_english() else "%.2f /秒" % _get_hero_attack_rate(hero), accent))
	stats_grid.add_child(_make_archive_stat_item("拾取", "%.1f" % float(hero.get("collect_radius", 0.0)), accent))

	return panel


func _populate_character_archive_cards() -> void:
	if character_archive_cards_root == null:
		return
	for child in character_archive_cards_root.get_children():
		child.queue_free()
	for hero_id_variant in Session.HERO_ORDER:
		var hero_id := String(hero_id_variant)
		var hero: Dictionary = _localized_hero_data(hero_id)
		character_archive_cards_root.add_child(_make_character_archive_card(hero))


func _build_local_leaderboard_text(view: String = "manual", limit: int = 8, sort: String = "wave") -> String:
	var normalized_view := _normalize_leaderboard_view(view)
	var normalized_sort := _normalize_leaderboard_sort(sort)
	var entries: Array[Dictionary] = _get_local_leaderboard_overlay_entries(normalized_view, normalized_sort, limit)
	if entries.is_empty():
		if normalized_view == "test":
			return "There are no test-run records yet. Use the wave 10 or wave 20 shortcut once and this board will fill in separately." if _is_english() else "当前还没有试阵记录。用第 10 / 20 波捷径打一轮后，这里会单独留下试阵榜。"
		return "There are no main-scroll results to show yet. Finish a true run from wave 1 and your record will appear here." if _is_english() else "当前还没有可展示的主卷战绩。下一次从第 1 波真正开卷后，这里会留下你的记录。"

	var lines: Array[String] = []
	if normalized_view == "test":
		lines.append("Test runs keep wave 10 and wave 20 shortcuts on a separate board." if _is_english() else "试阵榜会单独记录第 10 / 20 波捷径，不与主卷榜混排。")
	else:
		lines.append("The main-scroll board only tracks full runs that begin at wave 1." if _is_english() else "主卷榜只统计从第 1 波真正开卷的正式战绩。")
	lines.append("Sorted by %s." % _get_leaderboard_sort_summary_label(normalized_sort) if _is_english() else "当前排序：%s。" % _get_leaderboard_sort_summary_label(normalized_sort))
	lines.append("")
	for index in range(entries.size()):
		var entry: Dictionary = entries[index]
		var run_label := "Test W%d" % int(entry.get("start_wave", 1)) if _is_english() else "试阵 W%d" % int(entry.get("start_wave", 1))
		if normalized_view == "manual":
			run_label = ("Completed" if bool(entry.get("chapter_complete", false)) else "Scroll") if _is_english() else ("定卷" if bool(entry.get("chapter_complete", false)) else "残卷")
		var bosses_label := "Bosses" if _is_english() else "卷主"
		var threat_label := "Wave" if _is_english() else "波次"
		var kills_label := "Kills" if _is_english() else "击破"
		var level_label := "Level" if _is_english() else "等级"
		var elapsed_label := "Time" if _is_english() else "存活"
		lines.append(
			"%d. %s  %s  %s %d  %s %d  %s %d  %s %d  %s %s" % [
				index + 1,
				_format_leaderboard_identity(entry),
				run_label,
				bosses_label,
				int(entry.get("bosses", 0)),
				threat_label,
				int(entry.get("threat", 1)),
				kills_label,
				int(entry.get("kills", 0)),
				level_label,
				int(entry.get("level", 1)),
				elapsed_label,
				_format_elapsed(float(entry.get("elapsed", 0.0)))
			]
		)
		var detail_line := _build_local_leaderboard_detail_line(entry)
		if not detail_line.is_empty():
			lines.append("   %s" % detail_line)
		lines.append("")
	while not lines.is_empty() and String(lines[lines.size() - 1]).is_empty():
		lines.remove_at(lines.size() - 1)
	return "\n".join(lines)


func _refresh_leaderboard_overlay() -> void:
	if leaderboard_body_label == null or leaderboard_summary_label == null:
		return

	var manual_count := Session.get_local_leaderboard_count("manual")
	var test_count := Session.get_local_leaderboard_count("test")
	if leaderboard_view == "test" and test_count == 0 and manual_count > 0:
		leaderboard_view = "manual"
	elif leaderboard_view == "manual" and manual_count == 0 and test_count > 0:
		leaderboard_view = "test"
	else:
		leaderboard_view = _normalize_leaderboard_view(leaderboard_view)
	leaderboard_sort = _normalize_leaderboard_sort(leaderboard_sort)

	if leaderboard_view == "test":
		leaderboard_summary_label.text = "The test board keeps wave 10 and wave 20 shortcuts separate so you can inspect enemy mixes, builds, and HUD behavior. It now also pivots between wave, kills, and survival-time ordering so route checks read closer to the source leaderboard." if _is_english() else "试阵榜单独收录第 10 / 20 波捷径，方便检查敌潮、build 与 HUD；现在也能在波次 / 击破 / 存活三种排序之间切换，更接近 source 榜单的回看方式。"
	else:
		leaderboard_summary_label.text = "The main-scroll board only keeps real runs that start from wave 1. It now also pivots between wave, kills, and survival-time ordering so you can review route outcomes from different angles before the next run." if _is_english() else "主卷榜只收从第 1 波真正开卷的战绩；现在也能在波次 / 击破 / 存活三种排序之间切换，开局前可以从不同角度回看 route 成果。"

	leaderboard_body_label.text = _build_local_leaderboard_text(leaderboard_view, 8, leaderboard_sort)
	_apply_leaderboard_view_button(leaderboard_manual_button, "Main Board" if _is_english() else "主卷榜", manual_count, leaderboard_view == "manual")
	_apply_leaderboard_view_button(leaderboard_test_button, "Test Board" if _is_english() else "试阵榜", test_count, leaderboard_view == "test")
	_apply_leaderboard_sort_button(leaderboard_sort_wave_button, "Wave" if _is_english() else "按波次", leaderboard_sort == "wave")
	_apply_leaderboard_sort_button(leaderboard_sort_kills_button, "Kills" if _is_english() else "按击破", leaderboard_sort == "kills")
	_apply_leaderboard_sort_button(leaderboard_sort_time_button, "Time" if _is_english() else "按存活", leaderboard_sort == "time")


func _apply_leaderboard_view_button(button: Button, title: String, count: int, active: bool) -> void:
	if button == null:
		return

	button.text = "%s · %d" % [title, count]
	if active:
		button.add_theme_color_override("font_color", _resolve_label_color(Color(0.08, 0.07, 0.07, 1.0)))
		button.add_theme_stylebox_override("normal", _make_button_style(Color(0.92, 0.62, 0.28, 1.0)))
		button.add_theme_stylebox_override("hover", _make_button_style(Color(0.98, 0.7, 0.34, 1.0)))
		button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.84, 0.54, 0.22, 1.0)))
	else:
		button.add_theme_color_override("font_color", _resolve_label_color(Color(0.98, 0.92, 0.82, 0.98)))
		button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.04, 0.06, 0.08, 0.78), Color(0.2, 0.26, 0.32, 0.54)))
		button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.08, 0.1, 0.12, 0.84), Color(0.92, 0.68, 0.42, 0.44)))
		button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.08, 0.1, 0.12, 0.88), Color(0.92, 0.68, 0.42, 0.62)))


func _apply_leaderboard_sort_button(button: Button, title: String, active: bool) -> void:
	if button == null:
		return

	button.text = title
	if active:
		button.add_theme_color_override("font_color", _resolve_label_color(Color(0.06, 0.08, 0.1, 1.0)))
		button.add_theme_stylebox_override("normal", _make_button_style(Color(0.58, 0.82, 0.94, 1.0)))
		button.add_theme_stylebox_override("hover", _make_button_style(Color(0.66, 0.88, 0.98, 1.0)))
		button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.46, 0.72, 0.84, 1.0)))
	else:
		button.add_theme_color_override("font_color", _resolve_label_color(Color(0.96, 0.92, 0.86, 0.98)))
		button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.04, 0.06, 0.08, 0.78), Color(0.24, 0.34, 0.42, 0.54)))
		button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.08, 0.1, 0.12, 0.84), Color(0.58, 0.82, 0.94, 0.44)))
		button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.08, 0.1, 0.12, 0.88), Color(0.58, 0.82, 0.94, 0.62)))


func _normalize_leaderboard_sort(sort: String) -> String:
	if sort == "kills" or sort == "time":
		return sort
	return "wave"


func _get_leaderboard_sort_summary_label(sort: String) -> String:
	match _normalize_leaderboard_sort(sort):
		"kills":
			return "kills" if _is_english() else "按击破优先"
		"time":
			return "survival time" if _is_english() else "按存活优先"
		_:
			return "wave" if _is_english() else "按波次优先"


func _get_local_leaderboard_overlay_entries(view: String, sort: String, limit: int = 8) -> Array[Dictionary]:
	var normalized_view := _normalize_leaderboard_view(view)
	var normalized_sort := _normalize_leaderboard_sort(sort)
	var entries: Array[Dictionary] = []
	for entry in Session.get_local_leaderboard(Session.LOCAL_LEADERBOARD_LIMIT, normalized_view):
		entries.append(entry.duplicate(true))
	entries.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return _compare_leaderboard_overlay_entries(left, right, normalized_sort)
	)
	if limit > 0 and entries.size() > limit:
		entries.resize(limit)
	return entries


func _compare_leaderboard_overlay_entries(left: Dictionary, right: Dictionary, sort: String) -> bool:
	var normalized_sort := _normalize_leaderboard_sort(sort)
	if normalized_sort == "kills":
		var left_kills := int(left.get("kills", 0))
		var right_kills := int(right.get("kills", 0))
		if left_kills != right_kills:
			return left_kills > right_kills
		var left_threat := int(left.get("threat", 1))
		var right_threat := int(right.get("threat", 1))
		if left_threat != right_threat:
			return left_threat > right_threat
		var left_level := int(left.get("level", 1))
		var right_level := int(right.get("level", 1))
		if left_level != right_level:
			return left_level > right_level
		var left_elapsed := float(left.get("elapsed", 0.0))
		var right_elapsed := float(right.get("elapsed", 0.0))
		if not is_equal_approx(left_elapsed, right_elapsed):
			return left_elapsed > right_elapsed
		return _compare_leaderboard_overlay_entries_default(left, right)
	if normalized_sort == "time":
		var left_elapsed_time := float(left.get("elapsed", 0.0))
		var right_elapsed_time := float(right.get("elapsed", 0.0))
		if not is_equal_approx(left_elapsed_time, right_elapsed_time):
			return left_elapsed_time > right_elapsed_time
		var left_threat_time := int(left.get("threat", 1))
		var right_threat_time := int(right.get("threat", 1))
		if left_threat_time != right_threat_time:
			return left_threat_time > right_threat_time
		var left_kills_time := int(left.get("kills", 0))
		var right_kills_time := int(right.get("kills", 0))
		if left_kills_time != right_kills_time:
			return left_kills_time > right_kills_time
		var left_level_time := int(left.get("level", 1))
		var right_level_time := int(right.get("level", 1))
		if left_level_time != right_level_time:
			return left_level_time > right_level_time
	return _compare_leaderboard_overlay_entries_default(left, right)


func _compare_leaderboard_overlay_entries_default(left: Dictionary, right: Dictionary) -> bool:
	var left_complete: bool = bool(left.get("chapter_complete", false))
	var right_complete: bool = bool(right.get("chapter_complete", false))
	if left_complete != right_complete:
		return left_complete and not right_complete

	var left_bosses: int = int(left.get("bosses", 0))
	var right_bosses: int = int(right.get("bosses", 0))
	if left_bosses != right_bosses:
		return left_bosses > right_bosses

	var left_threat: int = int(left.get("threat", 1))
	var right_threat: int = int(right.get("threat", 1))
	if left_threat != right_threat:
		return left_threat > right_threat

	var left_kills: int = int(left.get("kills", 0))
	var right_kills: int = int(right.get("kills", 0))
	if left_kills != right_kills:
		return left_kills > right_kills

	var left_elapsed: float = float(left.get("elapsed", 0.0))
	var right_elapsed: float = float(right.get("elapsed", 0.0))
	if not is_equal_approx(left_elapsed, right_elapsed):
		return left_elapsed > right_elapsed

	return int(left.get("recorded_at", 0)) > int(right.get("recorded_at", 0))


func _format_leaderboard_identity(entry: Dictionary) -> String:
	var player_name := String(entry.get("player_name", "")).strip_edges()
	var hero_name := _localize_text(String(entry.get("hero_name", "书生")).strip_edges())
	if player_name.is_empty():
		return hero_name
	if hero_name.is_empty():
		return player_name
	return "%s · %s" % [player_name, hero_name]


func _build_local_leaderboard_detail_line(entry: Dictionary) -> String:
	var segments: Array[String] = []

	var radicals_text := _summarize_run_counts(entry.get("radicals", {}), Session.RADICAL_ORDER, "radical")
	if not radicals_text.is_empty():
		segments.append("Radicals %s" % radicals_text if _is_english() else "偏旁 %s" % radicals_text)

	var recipes_text := _summarize_run_counts(entry.get("recipes", {}), Session.RECIPE_ORDER, "recipe")
	if not recipes_text.is_empty():
		segments.append("Glyphs %s" % recipes_text if _is_english() else "成字 %s" % recipes_text)

	var words_text := _summarize_run_counts(entry.get("words", {}), Session.WORD_ORDER, "word")
	if not words_text.is_empty():
		segments.append("Phrases %s" % words_text if _is_english() else "词技 %s" % words_text)

	var blade_level: int = int(entry.get("blade_level", 0))
	if blade_level > 0:
		var blade_label := "Blade Arc" if String(entry.get("hero_id", "scholar")) == "xia" else "Brush Edge"
		if not _is_english():
			blade_label = "剑势" if String(entry.get("hero_id", "scholar")) == "xia" else "笔锋"
		segments.append("%s Lv.%d" % [blade_label, blade_level])

	var enemy_text := _summarize_enemy_kills(entry.get("enemy_kills", {}))
	if not enemy_text.is_empty():
		segments.append("Takedowns %s" % enemy_text if _is_english() else "击倒 %s" % enemy_text)

	return " | ".join(segments)


func _summarize_run_counts(raw_counts: Variant, order: Array, category: String) -> String:
	if not (raw_counts is Dictionary):
		return ""

	var counts := raw_counts as Dictionary
	var parts: Array[String] = []
	for key_variant in order:
		var key := String(key_variant)
		var amount: int = int(counts.get(key, 0))
		if amount <= 0:
			continue
		parts.append("%s%d" % [_run_count_label(key, category), amount])
		if parts.size() >= 3:
			break
	return " ".join(parts)


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
		parts.append("%s%d" % [String(Session.get_enemy_data(enemy_id).get("glyph", enemy_id)), int(item.get("amount", 0))])
	return " ".join(parts)


func _normalize_leaderboard_view(view: String) -> String:
	return "test" if view == "test" else "manual"


func _build_enemy_archive_text() -> String:
	var lines: Array[String] = [
		"The entries below describe enemy families, warnings, and counters that are already implemented in the current remnant scroll." if _is_english() else "以下条目对应当前残卷里已经接入的敌人谱系、预警方式与最实用的临场处理思路。",
		""
	]
	for enemy_id_variant in Session.ENEMY_ORDER:
		var enemy_id := String(enemy_id_variant)
		var enemy: Dictionary = _localized_enemy_data(enemy_id)
		lines.append("%s  %s  ·  %s" % [
			String(enemy.get("glyph", "")),
			String(enemy.get("name", "")),
			String(enemy.get("title", ""))
		])
		lines.append("  %s" % String(enemy.get("summary", "")))
		lines.append("  Warning: %s" % String(enemy.get("warning", "")) if _is_english() else "  预警：%s" % String(enemy.get("warning", "")))
		lines.append("  Counter: %s" % String(enemy.get("counter", "")) if _is_english() else "  应对：%s" % String(enemy.get("counter", "")))
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
	_refresh_leaderboard_overlay()
	leaderboard_overlay.visible = true


func _hide_leaderboard_overlay() -> void:
	if leaderboard_overlay != null:
		leaderboard_overlay.visible = false


func _on_leaderboard_manual_pressed() -> void:
	leaderboard_view = "manual"
	_refresh_leaderboard_overlay()


func _on_leaderboard_test_pressed() -> void:
	leaderboard_view = "test"
	_refresh_leaderboard_overlay()


func _on_leaderboard_sort_wave_pressed() -> void:
	leaderboard_sort = "wave"
	_refresh_leaderboard_overlay()


func _on_leaderboard_sort_kills_pressed() -> void:
	leaderboard_sort = "kills"
	_refresh_leaderboard_overlay()


func _on_leaderboard_sort_time_pressed() -> void:
	leaderboard_sort = "time"
	_refresh_leaderboard_overlay()


func _show_profile_overlay() -> void:
	if profile_overlay == null or profile_name_input == null:
		return
	_hide_character_archive_overlay()
	_hide_recipe_atlas_overlay()
	_hide_enemy_archive_overlay()
	_hide_leaderboard_overlay()
	var identity: Dictionary = Session.get_leaderboard_identity()
	profile_name_input.text = String(identity.get("custom_name", ""))
	_refresh_profile_overlay()
	profile_overlay.visible = true


func _hide_profile_overlay() -> void:
	if profile_overlay != null:
		profile_overlay.visible = false


func _refresh_profile_overlay(status_text: String = "") -> void:
	if profile_status_label == null:
		return
	profile_status_label.visible = not status_text.is_empty()
	profile_status_label.text = status_text
	_refresh_profile_preview_from_input()


func _refresh_profile_preview_from_input() -> void:
	if profile_name_input == null or profile_preview_name_label == null or profile_preview_glyph_label == null or profile_preview_copy_label == null or profile_hint_label == null:
		return
	var draft_name := Session.sanitize_leaderboard_name(profile_name_input.text)
	if profile_name_input.text != draft_name:
		profile_name_input.text = draft_name
		profile_name_input.caret_column = draft_name.length()
	var identity: Dictionary = Session.get_leaderboard_identity()
	var custom_name := String(identity.get("custom_name", ""))
	var device_alias := Session.get_leaderboard_device_alias()
	var preview_name := draft_name if not draft_name.is_empty() else (custom_name if not custom_name.is_empty() else device_alias)
	profile_preview_name_label.text = preview_name
	profile_preview_glyph_label.text = _get_profile_monogram(preview_name)
	if custom_name.is_empty():
		if _is_english():
			profile_preview_copy_label.text = "The device is still using its default wuxia alias. Saving a custom alias will switch later records to this name."
			profile_hint_label.text = "If you do not save a custom alias, the system keeps using the device default: %s" % device_alias
		else:
			profile_preview_copy_label.text = "当前仍使用设备默认侠名；保存自定义署名后，之后的战绩会直接切到这个名字。"
			profile_hint_label.text = "如果不另外保存自定义署名，系统会继续沿用本机默认侠名：%s" % device_alias
	else:
		if _is_english():
			profile_preview_copy_label.text = "The saved alias will be reused automatically for later local leaderboard records."
			profile_hint_label.text = "Clear or reset it to fall back to the device default again: %s" % device_alias
		else:
			profile_preview_copy_label.text = "当前默认署名会自动复用到之后的本地排行榜记录里。"
			profile_hint_label.text = "清空或恢复默认后，会重新回退到本机默认侠名：%s" % device_alias


func _on_profile_random_pressed() -> void:
	if profile_name_input == null:
		return
	profile_name_input.text = Session.generate_random_wuxia_name()
	_refresh_profile_overlay()


func _on_profile_save_pressed() -> void:
	if profile_name_input == null:
		return
	var resolved_name := Session.set_preferred_leaderboard_name(profile_name_input.text)
	var identity: Dictionary = Session.get_leaderboard_identity()
	profile_name_input.text = String(identity.get("custom_name", ""))
	var status_text := "Saved default alias: %s" % resolved_name if _is_english() else "已保存默认署名：%s" % resolved_name
	if String(identity.get("custom_name", "")).is_empty():
		status_text = "Restored device default alias: %s" % resolved_name if _is_english() else "已恢复设备默认侠名：%s" % resolved_name
	_refresh_profile_overlay(status_text)


func _on_profile_reset_pressed() -> void:
	if profile_name_input != null:
		profile_name_input.text = ""
	var resolved_name := Session.clear_preferred_leaderboard_name()
	_refresh_profile_overlay("Restored device default alias: %s" % resolved_name if _is_english() else "已恢复设备默认侠名：%s" % resolved_name)


func _get_profile_monogram(name: String) -> String:
	var trimmed_name := name.strip_edges()
	if trimmed_name.is_empty():
		return "侠"
	return trimmed_name.substr(0, 1)


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
	_hide_profile_overlay()


func _is_secondary_overlay_visible() -> bool:
	return (
		character_archive_overlay != null and character_archive_overlay.visible
	) or (
		recipe_atlas_overlay != null and recipe_atlas_overlay.visible
	) or (
		enemy_archive_overlay != null and enemy_archive_overlay.visible
	) or (
		leaderboard_overlay != null and leaderboard_overlay.visible
	) or (
		profile_overlay != null and profile_overlay.visible
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


func _on_profile_pressed() -> void:
	if transition_busy:
		return
	_show_profile_overlay()


func _on_start_pressed() -> void:
	_start_with_wave(1)


func _on_start_wave_10_pressed() -> void:
	_start_with_wave(10)


func _on_start_wave_20_pressed() -> void:
	_start_with_wave(20)


func _start_with_wave(start_wave: int) -> void:
	if transition_busy:
		return
	_hide_secondary_overlays()
	Session.select_hero(selected_hero)
	Session.prepare_battle_intro("zihai_menu", start_wave)
	_start_battle_transition()


func _on_back_pressed() -> void:
	if transition_busy:
		return
	_hide_secondary_overlays()
	get_tree().change_scene_to_file(Session.LAUNCHER_SCENE)


func _on_toggle_theme_pressed() -> void:
	current_theme = "paper-ink" if current_theme == "night-ink" else "night-ink"
	Session.set_launcher_theme(current_theme)
	_rebuild_ui()


func _on_toggle_language_pressed() -> void:
	current_language = "zh" if _is_english() else "en"
	Session.set_launcher_language(current_language)
	_rebuild_ui()


func _refresh_selection(trigger_reaction: bool = false) -> void:
	Session.select_hero(selected_hero)
	for hero_id_variant in hero_panels.keys():
		var hero_id := String(hero_id_variant)
		var panel: PanelContainer = hero_panels[hero_id]
		var hero_data: Dictionary = _localized_hero_data(hero_id)
		panel.add_theme_stylebox_override("panel", _make_card_style(hero_id == selected_hero, hero_data["accent"]))
		var status_badge: PanelContainer = panel.get_meta("status_badge", null) as PanelContainer
		var status_badge_label: Label = panel.get_meta("status_badge_label", null) as Label
		if status_badge_label != null:
			status_badge_label.text = "Selected" if _is_english() else "已选中"
		if status_badge != null:
			status_badge.visible = hero_id == selected_hero

	var selected_data: Dictionary = _localized_hero_data(selected_hero)
	var accent: Color = selected_data["accent"]
	detail_name_label.text = "%s  ·  %s" % [String(selected_data["name"]), String(selected_data["title"])]
	detail_role_label.text = "%s  ·  %s" % [String(selected_data["role_label"]), String(selected_data["weapon"])]
	detail_weapon_label.text = "Primary profile: %s" % String(selected_data["description"]) if _is_english() else "主战描述：%s" % String(selected_data["description"])
	detail_desc_label.text = "Combat focus: %s" % String(selected_data["focus"]) if _is_english() else "战斗焦点：%s" % String(selected_data["focus"])
	var record_title := String(selected_data.get("record_title", "")).strip_edges()
	var record_excerpt := String(selected_data.get("record_excerpt", "")).strip_edges()
	var record_source := String(selected_data.get("record_source", "")).strip_edges()
	var trait_label := String(selected_data.get("trait_label", "")).strip_edges()
	var trait_description := String(selected_data.get("trait_description", "")).strip_edges()
	var route_hint := String(selected_data.get("route_hint", "")).strip_edges()
	if record_title.is_empty():
		detail_focus_label.text = "Once you enter the scroll, the same radical route feels different depending on the hero's weapon." if _is_english() else "进入残卷后，同样的偏旁路线会因为角色武器而产生不同输出手感。"
	else:
		detail_focus_label.text = "Origin: %s" % record_title if _is_english() else "人物来路：%s" % record_title
	if trait_label.is_empty() and trait_description.is_empty():
		detail_dossier_label.text = ""
	elif trait_description.is_empty():
		detail_dossier_label.text = "Trait: %s" % trait_label if _is_english() else "角色特性：%s" % trait_label
	elif trait_label.is_empty():
		detail_dossier_label.text = "Trait: %s" % trait_description if _is_english() else "角色特性：%s" % trait_description
	else:
		detail_dossier_label.text = "Trait: %s · %s" % [trait_label, trait_description] if _is_english() else "角色特性：%s · %s" % [trait_label, trait_description]
	var quote_lines: Array[String] = []
	if not route_hint.is_empty():
		quote_lines.append("Run advice: %s" % route_hint if _is_english() else "入卷建议：%s" % route_hint)
	if not record_excerpt.is_empty():
		if record_source.is_empty():
			quote_lines.append("Excerpt: %s" % record_excerpt if _is_english() else "摘句：%s" % record_excerpt)
		else:
			quote_lines.append("Excerpt: %s · %s" % [record_excerpt, record_source] if _is_english() else "摘句：%s · %s" % [record_excerpt, record_source])
	detail_quote_label.text = "\n".join(quote_lines)

	detail_preview_core.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.24, accent.g * 0.2, accent.b * 0.16, 0.94), Color(accent.r, accent.g, accent.b, 0.26)))
	detail_preview_glyph.text = String(selected_data["glyph"])

	for child in detail_tags_row.get_children():
		child.queue_free()
	for tag_text in selected_data["tags"]:
		detail_tags_row.add_child(_make_tag(String(tag_text), Color(accent.r * 0.16, accent.g * 0.16, accent.b * 0.2, 0.88), Color(0.98, 0.95, 0.9, 0.96)))
	detail_opening_label.text = _build_hero_opening_summary(selected_data)
	for child in detail_opening_radicals_row.get_children():
		child.queue_free()
	for tag_text in _build_hero_starting_tags(selected_data):
		detail_opening_radicals_row.add_child(_make_tag(tag_text, Color(accent.r * 0.16, accent.g * 0.16, accent.b * 0.2, 0.88), Color(0.98, 0.95, 0.9, 0.96)))
	detail_source_skill_title_label.text = _build_hero_active_skill_headline(selected_data)
	detail_source_skill_body_label.text = _build_hero_active_skill_body(selected_data)
	_populate_progression_cards(detail_progression_cards_root, selected_data, accent, true)
	_populate_build_route_cards(detail_build_route_cards_root, selected_data, accent, true)

	_set_stat_value("move_speed", float(selected_data["move_speed"]), 7.2, "%.1f")
	_set_stat_value("max_health", float(selected_data["max_health"]), 140.0, "%.0f")
	_set_stat_value("attack_damage", float(selected_data["attack_damage"]), 24.0, "%.0f")
	_set_stat_value("attack_range", float(selected_data["attack_range"]), 15.5, "%.1f")
	_set_stat_value("attack_rate", _get_hero_attack_rate(selected_data), 2.0, "%.2f/s" if _is_english() else "%.2f /秒")
	_set_stat_value("pickup_radius", float(selected_data.get("collect_radius", 0.0)), 4.5, "%.1f")
	if trigger_reaction:
		_show_hero_reaction(selected_hero, selected_data)


func _show_hero_reaction(hero_id: String, hero_data: Dictionary) -> void:
	if detail_reaction_panel == null or detail_reaction_label == null:
		return

	var accent: Color = hero_data["accent"]
	var quote: String = _consume_hero_quote(hero_id, hero_data)
	detail_reaction_panel.add_theme_stylebox_override(
		"panel",
		_make_panel_style(
			Color(accent.r * 0.14, accent.g * 0.14, accent.b * 0.18, 0.8),
			Color(accent.r, accent.g, accent.b, 0.34)
		)
	)
	detail_reaction_label.text = "“%s”" % _localize_text(quote)
	_show_card_reaction(hero_id, quote, accent)
	reaction_time_remaining = HERO_REACTION_DURATION


func _show_card_reaction(hero_id: String, quote: String, accent: Color) -> void:
	_clear_card_reactions()
	var panel: PanelContainer = hero_panels.get(hero_id, null) as PanelContainer
	if panel == null:
		return
	var reaction_panel: PanelContainer = panel.get_meta("reaction_panel", null) as PanelContainer
	var reaction_label: Label = panel.get_meta("reaction_label", null) as Label
	if reaction_panel == null or reaction_label == null:
		return
	reaction_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.12, accent.g * 0.12, accent.b * 0.16, 0.84), Color(accent.r, accent.g, accent.b, 0.24)))
	reaction_label.text = "“%s”" % _localize_text(quote)
	reaction_panel.visible = true
	active_card_reaction_hero = hero_id


func _clear_card_reactions() -> void:
	active_card_reaction_hero = ""
	for hero_panel_variant in hero_panels.values():
		var panel: PanelContainer = hero_panel_variant as PanelContainer
		if panel == null:
			continue
		var reaction_panel: PanelContainer = panel.get_meta("reaction_panel", null) as PanelContainer
		if reaction_panel != null:
			reaction_panel.visible = false


func _consume_hero_quote(hero_id: String, hero_data: Dictionary) -> String:
	var quotes_variant: Variant = hero_data.get("select_quotes", [])
	if quotes_variant is Array:
		var quotes: Array = quotes_variant as Array
		if not quotes.is_empty():
			var next_index: int = int(hero_quote_indices.get(hero_id, 0))
			var quote: String = String(quotes[next_index % quotes.size()]).strip_edges()
			hero_quote_indices[hero_id] = (next_index + 1) % quotes.size()
			if not quote.is_empty():
				return quote
	return String(hero_data.get("focus", hero_data.get("description", "")))


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
	var hero_data: Dictionary = _localized_hero_data(selected_hero)
	transition_glyph_label.text = String(hero_data["glyph"])
	transition_title_label.text = "Scroll I · Inkfall" if _is_english() else "残卷一·入墨"
	transition_subtitle_label.text = "%s enters the scroll and sets the first glyph." % String(hero_data["name"]) if _is_english() else "%s 执笔，落字入卷。" % String(hero_data["name"])
	transition_overlay.visible = true
	transition_overlay.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween := create_tween()
	tween.tween_property(transition_overlay, "modulate:a", 1.0, 0.35)
	tween.tween_interval(0.3)
	tween.tween_callback(Callable(self, "_change_to_battle"))


func _on_select_hero(hero_id: String) -> void:
	selected_hero = hero_id
	_refresh_selection(true)


func _change_to_battle() -> void:
	get_tree().change_scene_to_file(Session.ZIHAI_BATTLE_SCENE)


func _unhandled_input(event: InputEvent) -> void:
	if not _is_secondary_overlay_visible():
		return
	if event.is_action_pressed("ui_cancel"):
		_hide_secondary_overlays()
		get_viewport().set_input_as_handled()
