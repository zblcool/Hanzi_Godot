extends Control

const CJKFont := preload("res://scripts/core/cjk_font.gd")
const FrontEndContent := preload("res://scripts/core/front_end_content.gd")
const CangjieRouteLinkLayer := preload("res://scripts/ui/cangjie_route_link_layer.gd")
const BASE_VIEWPORT := Vector2(2100.0, 1200.0)
const MIN_UI_SCALE := 0.6
const NIGHT_THEME := {
	"background": Color(0.03, 0.05, 0.07, 1.0),
	"glow_amber": Color(0.88, 0.58, 0.28, 0.08),
	"glow_azure": Color(0.42, 0.74, 0.88, 0.06),
	"glow_gold": Color(0.9, 0.74, 0.34, 0.04),
	"line": Color(0.18, 0.24, 0.28, 0.08),
	"diamond": Color(0.52, 0.62, 0.72, 0.12),
	"shadow": Color(0.0, 0.0, 0.0, 0.18),
	"outline": Color(0.02, 0.03, 0.04, 0.28)
}
const PAPER_THEME := {
	"background": Color(0.94, 0.9, 0.82, 1.0),
	"glow_amber": Color(0.66, 0.43, 0.18, 0.08),
	"glow_azure": Color(0.38, 0.5, 0.66, 0.07),
	"glow_gold": Color(0.76, 0.62, 0.26, 0.05),
	"line": Color(0.32, 0.24, 0.16, 0.09),
	"diamond": Color(0.48, 0.37, 0.24, 0.11),
	"shadow": Color(0.18, 0.14, 0.1, 0.08),
	"outline": Color(0.95, 0.92, 0.86, 0.4)
}
const EN_TEXT := {
	"玩家名帖": "Player Sigil",
	"关于字海": "About",
	"汉字游戏启动器": "Hanzi Game Launcher",
	"从字形、部件到战斗系统，把汉字本身做成游戏的核心机制。": "Turn Chinese glyphs, radicals, and combat systems into the core mechanics of the game.",
	"微信内打开": "Opening from WeChat",
	"如果是微信内置浏览器，尽量切到系统浏览器再进入。": "If this opens inside WeChat, switch to the system browser when possible.",
	"这样更容易拿到稳定的全屏、音频和触控体验。": "That usually gives more stable fullscreen, audio, and touch behavior.",
	"iPhone / iPad": "iPhone / iPad",
	"可以用“分享 -> 添加到主屏幕”把启动器放到桌面。": "Use Share -> Add to Home Screen to pin the launcher like an app.",
	"主屏幕入口会更接近独立应用的打开方式。": "The home-screen shortcut feels much closer to launching a standalone app.",
	"字海残卷": "Ink-Sea Remnant Scroll",
	"在墨阵里活下去，把偏旁一步步磨成成字与词技。": "Survive inside the ink array and turn radicals into formed glyph skills and refined phrase arts.",
	"3D 自动战斗": "3D auto-battle",
	"偏旁三选一": "Three radical picks",
	"合字 -> 磨词": "Fuse glyphs -> refine phrases",
	"进入字海残卷": "Enter Ink-Sea",
	"仓颉之路": "Cangjie Road",
	"把字形拆解、语义路线和出牌构筑压进同一条爬塔曲线。": "Fold glyph structure, semantic routes, and deckbuilding into one climb.",
	"卡牌构筑": "Deckbuilding",
	"字形拼装": "Glyph assembly",
	"进入仓颉入口": "Open Cangjie Portal",
	"迁移阶段": "Migration Status",
	"入口 -> 二级菜单 -> 战斗 的层级已经稳定。": "Launcher -> sub-menu -> battle is now a stable front-end stack.",
	"字海残卷保持 3D 俯视角，不回退到纯占位原型。": "Ink-Sea stays a 3D top-down game instead of falling back to placeholder screens.",
	"敌人轮廓、字核和 UI 正在向 web 端气质统一。": "Enemy silhouettes, glyph cores, and UI are converging toward the web prototype tone.",
	"当前目标": "Current Focus",
	"把偏旁、合字、词技做成真正的成长主线。": "Turn radicals, fused glyphs, and phrase arts into the real growth spine.",
	"让战斗里的字、墨、纸和敌人轮廓属于同一世界。": "Make glyphs, ink, paper, and enemy silhouettes feel like one world.",
	"把菜单和 HUD 提到可展示、可录像的完成度。": "Push the menu and HUD to a presentable, recordable level of polish.",
	"启动器更新日志入口已补齐": "Launcher changelog entry restored",
	"Godot 启动器首页现在既保留最近更新聚光卡，也能直接打开内置更新历史面板，继续向 web 原型首页的 changelog panel 对齐。": "The Godot launcher now keeps the recent update spotlight and can open an in-app changelog panel, moving closer to the web prototype front page.",
	"Godot 启动器": "Godot Launcher",
	"更新日志": "Update History",
	"首页“最近更新”卡现在可以直接展开最近几次迁移里程碑，不再只停在单条快照。": "The recent update card can now expand into several migration milestones instead of staying as one snapshot.",
	"前台已补齐主题联动、玩家名帖与场景 smoke 检查，近期推进可以留在同一层里回看。": "Theme sync, player sigils, and scene smoke checks now live in the same front-end layer.",
	"启动器层剩余更大的缺口仍是双语切换与仓颉入口接入。": "The bigger launcher gaps were bilingual support and the Cangjie portal.",
	"完整长期追踪仍以仓库根目录的 MIGRATION_CHECKLIST 为准。": "The long-running migration checklist in the repo root remains the source of truth.",
	"查看更新记录": "View Update History",
	"关于汉字工坊": "About Hanzi Workshop",
	"这里先讲清这款游戏为什么会被做出来，再继续介绍当前已经迁进 Godot 的部分，以及还留在 web 原型里的目标。": "This page explains why the project exists, what has already migrated into Godot, and what still lives in the web prototype.",
	"作为生活在海外的中国人，多种文化之间的碰撞与交流，让我重新看见自己的母语。汉字像古老而仍然鲜活的图画，从甲骨文到小篆、从繁体到简体，每一次演变都藏着故事，也延续着几千年的文化脉络。": "Living overseas keeps bringing me back to my mother tongue. Chinese characters feel like ancient yet living pictures, with each evolution carrying story and culture across thousands of years.",
	"一直以来，我都想做一款和中文有关的游戏。直到孩子出生，这个念头变得更具体了。身处英语环境，我开始更认真地想：能不能用游戏去点燃他，也点燃更多孩子，对汉字与中华文化的兴趣？对我来说，这既是一次实验，也是一个父亲的愿望。": "I had long wanted to make a game about Chinese, but after my child was born that wish became much more concrete. In an English-speaking environment, I kept asking whether a game could spark curiosity about Chinese characters and culture for him and for more children.",
	"这个项目会持续借助 AI 参与开发，但归根结底，它更像是一封写给汉字、写给中文文化的情书。现在 Godot 主线先把《字海残卷》的启动器、二级菜单和 3D 战斗接牢，再继续把 web 原型里更完整的内容一项项迁回来。": "AI helps build this project, but at heart it is a love letter to Chinese characters and Chinese culture. The Godot branch is first stabilizing the launcher, sub-menu, and 3D battle before migrating the richer web prototype piece by piece.",
	"自动攻击、生存走位、偏旁合字、词技磨成与字阵地图。像幸存者类，但核心成长来自汉字结构和语义。": "Auto-attacks, survival movement, radical fusion, phrase refinement, and glyph-array maps. It feels like a survivors-like game, but its progression comes from Chinese structure and meaning.",
	"偏旁收集、合字成技、词技进阶": "Collect radicals, fuse glyphs, refine phrase arts",
	"波次、关键怪、卷主、地图地标": "Waves, key enemies, scroll lords, landmarks",
	"移动端横屏保护与战斗适配": "Mobile landscape guardrails and battle adaptation",
	"类杀戮尖塔的卡牌爬塔原型。每张牌同时是战斗动作与汉字学习卡，字形、语义和组合路线都能进入构筑。": "A Slay-the-Spire-like deckbuilder climb where each card is both a combat action and a Chinese learning card.",
	"地图节点、卡牌战斗、奖励选牌": "Map nodes, card battles, reward drafts",
	"中英双语辅助，更适合非中文母语玩家": "Chinese-English assist for non-native Chinese players",
	"当前仍在 web 原型，等待 Godot 迁入": "Still lives in the web prototype and awaits Godot migration",
	"面向谁": "Who It Is For",
	"不仅面向中文母语者，也面向中文学习者、教育者，以及想通过游戏认识汉字结构、字义和词感的玩家。": "It is for native speakers, Chinese learners, educators, and players who want to understand character structure and meaning through games.",
	"适合传播": "Easy To Share",
	"先保留浏览器可试玩 demo，更适合在中文学习社区、独立游戏圈和语言社群里直接分享与验证。": "Keeping a browser demo makes it easier to share in Chinese-learning communities, indie circles, and language groups.",
	"迁移重点": "Migration Priorities",
	"Godot 主线优先补齐启动器、菜单、HUD 和战斗成长链，再追赶 web 端的音乐、设置、双语和仓颉玩法。": "The Godot branch first fills in the launcher, menus, HUD, and battle growth chain before catching up on music, settings, bilingual support, and Cangjie gameplay.",
	"下一步产品化": "Next Product Step",
	"先把 Godot 版做成稳定可展示的 vertical slice，验证玩法和学习体验，再决定哪些角色、卡组、塔层与字阵系统进入完整版本。": "First make the Godot build a stable vertical slice, validate both play and learning value, then decide which heroes, decks, tower layers, and glyph systems graduate into the full game.",
	"返回启动器": "Back to Launcher",
	"先把 deckbuilder 原型的核心结构、迁移状态和后续切入点收进同一层入口里，避免第二项目继续停在一张静态卡片。": "This portal gathers the deckbuilder prototype structure, migration status, and next entry points in one layer so the second project no longer stalls as a static card.",
	"返回游戏选择": "Back to Game Select",
	"首页最近更新卡现在会把近期 Godot 迁移里程碑一并展开，方便直接对照前台推进节奏。": "The home update spotlight now expands recent Godot milestones so the front-end pace is easy to review.",
	"完整变更记录仍保留在仓库根目录 CHANGELOG.md；长期迁移状态仍以 MIGRATION_CHECKLIST.md 为准。": "The full history still lives in CHANGELOG.md, while MIGRATION_CHECKLIST.md tracks the long migration state.",
	"像 web 原型那样，为这台设备保存默认排行榜署名。结算页里留空时，后续战绩会直接复用这里的名字。": "Save a default leaderboard alias for this device just like the web prototype. Future runs reuse it whenever the result screen is left blank.",
	"当前署名": "Current Alias",
	"默认排行榜署名": "Default Leaderboard Alias",
	"输入想显示的名字": "Enter the name you want to show",
	"随机侠名": "Random Wuxia Name",
	"保存署名": "Save Alias",
	"恢复默认": "Restore Default",
	"夜墨": "Night Ink",
	"纸墨": "Paper Ink",
	"切换到夜墨主题": "Switch to Night Ink theme",
	"切换到纸墨主题": "Switch to Paper Ink theme",
	"仓颉之路入口": "Cangjie Road Portal",
	"迁移前台": "Front-end Migration",
	"新增": "Added",
	"同步": "Synced",
	"下一步": "Next",
	"打磨": "Polish",
	"系统": "Systems",
	"近期的主题联动、玩家名帖、战场乐题提示和 utility 掉落迁移成果都被收进同一条前台历史里。": "Recent work such as theme sync, player sigils, battle callouts, and utility drops is now reflected in one front-end history.",
	"继续对齐 hanziHero web 启动器里的 changelog panel 角色，但先保留当前 Godot 单语结构。": "This keeps aligning with the hanziHero web launcher changelog panel while still respecting the current Godot front-end.",
	"如果继续做前台层，小而稳的下一步更适合补菜单侧的 build / progression 展示。": "A small, steady next step on the front end is to strengthen build and progression presentation in the menu.",
	"Godot 主线把启动器后的字海二级菜单、局外资料面板和本地排行榜署名链路接成了更完整的一段 vertical slice。": "The Godot branch linked the launcher, sub-menu, reference overlays, and local leaderboard alias flow into a fuller vertical slice.",
	"补上人物志、合字图谱、怪物图鉴和本地排行榜这些字海二级菜单 overlays。": "Added character archive, fusion atlas, enemy archive, and local leaderboard overlays to the Ink-Sea menu layer.",
	"启动器和菜单都能维护玩家名帖，后续结算页留空时会自动复用默认署名。": "Both launcher and menu can now manage player sigils that flow into later result screens.",
	"移动端战斗入口、暂停和小屏 UI 进一步压实，不再只是桌面演示。": "Mobile battle entry, pause flow, and small-screen UI have all been tightened beyond desktop-only demos.",
	"场景 smoke 检查、README 与迁移清单开始持续跟着当前主线一起维护。": "Scene smoke checks, the README, and the migration checklist now move forward with the main branch.",
	"Godot 仓库完成了启动器、菜单、3D 战斗、地图、导出与移动端守护的第一轮闭环，字海残卷开始脱离占位原型。": "The Godot repo completed its first playable loop across launcher, menu, 3D battle, map, export, and mobile support.",
	"搭出 Godot 版启动器、字海战斗原型、地图 modal、暂停层和移动端横屏保护。": "Built the Godot launcher, Ink-Sea battle prototype, map modal, pause layer, and mobile landscape guardrails.",
	"接通 Web 导出脚本、Vercel 部署路径，以及基础本地排行榜存档。": "Wired web export scripts, the Vercel path, and the first local leaderboard save flow.",
	"敌人谱系、宝箱与场景道具、波次推进和核心偏旁成长链路开始在 Godot 内成型。": "Enemy families, chests, map props, wave pacing, and the core radical growth chain all took shape in Godot.",
	"Launcher -> 字海菜单 -> 3D 战斗 的仓库主线从这一天开始可持续迭代。": "From that point on, the launcher -> menu -> 3D battle branch became an iteration-worthy mainline."
}

var title_font: Font
var ui_scale := 1.0
var floating_symbols: Array[Dictionary] = []
var preview_motifs: Array[Dictionary] = []
var current_theme := "night-ink"
var current_language := "zh"
var about_overlay: Control
var cangjie_overlay: Control
var cangjie_section_title_label: Label
var cangjie_section_content_box: VBoxContainer
var cangjie_nav_buttons: Dictionary = {}
var cangjie_section := "start_climb"
var cangjie_stage_fx_enabled := true
var cangjie_run_shell_open := false
var cangjie_reward_chain_choice := "draft"
var cangjie_rest_choice := "prepare"
var cangjie_archive_choice := "trim"
var cangjie_treasure_choice := "inkstone"
var cangjie_shop_choice := "restock"
var cangjie_route_ledger_choice := "deepen"
var cangjie_tutor_choice := "trim"
var cangjie_broker_choice := "power"
var cangjie_margin_choice := "greed"
var cangjie_route_preview_node_id := ""
var cangjie_duelist_line_indices := {}
var changelog_overlay: Control
var profile_overlay: Control
var profile_name_input: LineEdit
var profile_status_label: Label
var profile_hint_label: Label
var profile_preview_name_label: Label
var profile_preview_glyph_label: Label
var profile_preview_copy_label: Label


func _ready() -> void:
	title_font = CJKFont.get_font()
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
		var velocity: Vector2 = symbol["velocity"]
		var symbol_position: Vector2 = symbol["position"]
		symbol_position += velocity * delta
		if symbol_position.x > viewport_size.x + 90.0:
			symbol_position.x = -90.0
		if symbol_position.y > viewport_size.y + 80.0:
			symbol_position.y = -80.0
		symbol["position"] = symbol_position

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
	var palette := _get_theme_palette()
	draw_rect(rect, palette["background"], true)
	draw_circle(Vector2(rect.size.x * 0.2, rect.size.y * 0.16), 240.0, palette["glow_amber"])
	draw_circle(Vector2(rect.size.x * 0.74, rect.size.y * 0.18), 280.0, palette["glow_azure"])
	draw_circle(Vector2(rect.size.x * 0.58, rect.size.y * 0.72), 360.0, palette["glow_gold"])

	for index in range(7):
		var x: float = rect.size.x * (0.08 + float(index) * 0.14)
		draw_line(Vector2(x, 0.0), Vector2(x - 120.0, rect.size.y), palette["line"], 1.0)

	for index in range(6):
		var diamond_size := 72.0 + float(index) * 20.0
		var center := Vector2(
			rect.size.x * (0.07 + float(index) * 0.16),
			rect.size.y * (0.14 + float(index % 3) * 0.24)
		)
		var diamond := PackedVector2Array([
			center + Vector2(0.0, -diamond_size),
			center + Vector2(diamond_size * 0.72, 0.0),
			center + Vector2(0.0, diamond_size),
			center + Vector2(-diamond_size * 0.72, 0.0),
			center + Vector2(0.0, -diamond_size)
		])
		draw_polyline(diamond, palette["diamond"], 2.0)

	for symbol in floating_symbols:
		var draw_position: Vector2 = symbol["position"]
		var color: Color = _resolve_symbol_color(symbol["color"])
		draw_string(
			title_font,
			draw_position,
			String(symbol["glyph"]),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1.0,
			int(symbol["size"]),
			color
		)


func _rebuild_ui() -> void:
	var restore_about := about_overlay != null and about_overlay.visible
	var restore_cangjie := cangjie_overlay != null and cangjie_overlay.visible
	var restore_changelog := changelog_overlay != null and changelog_overlay.visible
	var restore_profile := profile_overlay != null and profile_overlay.visible
	var profile_draft := ""
	if restore_profile and profile_name_input != null:
		profile_draft = profile_name_input.text
	ui_scale = _compute_ui_scale()
	preview_motifs.clear()
	about_overlay = null
	cangjie_overlay = null
	cangjie_section_title_label = null
	cangjie_section_content_box = null
	cangjie_nav_buttons.clear()
	changelog_overlay = null
	profile_overlay = null
	profile_name_input = null
	profile_status_label = null
	profile_hint_label = null
	profile_preview_name_label = null
	profile_preview_glyph_label = null
	profile_preview_copy_label = null
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_build_ui()
	if restore_about and about_overlay != null:
		about_overlay.visible = true
	if restore_cangjie and cangjie_overlay != null:
		_show_cangjie_portal()
	if restore_changelog and changelog_overlay != null:
		changelog_overlay.visible = true
	if restore_profile and profile_overlay != null and profile_name_input != null:
		profile_name_input.text = profile_draft
		_refresh_profile_overlay()
		profile_overlay.visible = true
	queue_redraw()


func _on_viewport_size_changed() -> void:
	_rebuild_ui()


func _compute_ui_scale() -> float:
	var viewport_size := get_viewport_rect().size
	var min_scale := 0.44 if _is_portrait_layout() else MIN_UI_SCALE
	if _is_web_platform():
		if _is_portrait_layout():
			min_scale = 0.36
		elif viewport_size.y < 780.0 or viewport_size.x < 1280.0:
			min_scale = 0.48
		else:
			min_scale = 0.54
	return clamp(min(viewport_size.x / BASE_VIEWPORT.x, viewport_size.y / BASE_VIEWPORT.y), min_scale, 1.0)


func _is_portrait_layout() -> bool:
	var viewport_size := get_viewport_rect().size
	return viewport_size.x <= viewport_size.y


func _make_responsive_box_container(portrait_layout: bool) -> BoxContainer:
	if portrait_layout:
		return VBoxContainer.new()
	return HBoxContainer.new()


func _is_web_platform() -> bool:
	return OS.has_feature("web")


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
	return String(EN_TEXT.get(text, text))


func _localize_cangjie_text(value: Variant) -> String:
	if value is Dictionary:
		var localized: Dictionary = value
		if _is_english():
			return String(localized.get("en", localized.get("zh", "")))
		return String(localized.get("zh", localized.get("en", "")))
	return _localize_text(String(value))


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


func _make_theme_toggle_button(control_size: Vector2) -> Button:
	var button := _make_pill_button(_get_theme_toggle_label(), control_size, Callable(self, "_on_toggle_theme_pressed"))
	button.tooltip_text = _get_theme_toggle_tooltip()
	return button


func _make_language_toggle_button(control_size: Vector2) -> Button:
	var button := _make_pill_button(_get_language_toggle_label(), control_size, Callable(self, "_on_toggle_language_pressed"))
	button.tooltip_text = _get_language_toggle_tooltip()
	return button


func _resolve_launcher_action(action_id: String) -> Callable:
	match action_id:
		"show_profile":
			return Callable(self, "_show_profile")
		"show_about":
			return Callable(self, "_show_about")
		"enter_zihai":
			return Callable(self, "_on_enter_zihai_pressed")
		"show_cangjie_portal":
			return Callable(self, "_show_cangjie_portal")
		"show_changelog":
			return Callable(self, "_show_changelog")
		_:
			return Callable()


func _make_launcher_top_button(button_data: Dictionary) -> Button:
	var button_size: Vector2 = button_data.get("size", Vector2(0.0, 54.0))
	match String(button_data.get("kind", "action")):
		"theme_toggle":
			return _make_theme_toggle_button(button_size)
		"language_toggle":
			return _make_language_toggle_button(button_size)
		_:
			return _make_pill_button(
				String(button_data.get("title", "")),
				button_size,
				_resolve_launcher_action(String(button_data.get("action", "")))
			)


func _to_string_array(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(String(value))
	return result


func _build_ui() -> void:
	var portrait_layout := _is_portrait_layout()
	var root := MarginContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_apply_root_safe_margins(
		root,
		24.0 if portrait_layout else 44.0,
		20.0 if portrait_layout else 32.0,
		24.0 if portrait_layout else 44.0,
		20.0 if portrait_layout else 24.0
	)
	add_child(root)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	var layout := VBoxContainer.new()
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_theme_constant_override("separation", _i(20))
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
		var top_spacer := Control.new()
		top_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		top_row.add_child(top_spacer)
		top_bar = top_row
	layout.add_child(top_bar)

	for button_data in FrontEndContent.launcher_top_actions():
		var button := _make_launcher_top_button(button_data)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL if portrait_layout else 0
		top_bar.add_child(button)

	var header_panel := PanelContainer.new()
	header_panel.custom_minimum_size = _v(0.0, 212.0 if portrait_layout else 188.0)
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

	var mobile_row := _make_responsive_box_container(portrait_layout)
	mobile_row.add_theme_constant_override("separation", _i(18))
	layout.add_child(mobile_row)

	for info_panel in FrontEndContent.launcher_mobile_info_panels():
		var info_accent: Color = info_panel.get("accent", Color.WHITE)
		mobile_row.add_child(_make_info_panel(
			String(info_panel.get("title", "")),
			_to_string_array(info_panel.get("lines", [])),
			info_accent
		))

	var main_row := _make_responsive_box_container(portrait_layout)
	main_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_row.add_theme_constant_override("separation", _i(20))
	layout.add_child(main_row)

	for card_data in FrontEndContent.launcher_game_cards():
		var card_accent: Color = card_data.get("accent", Color.WHITE)
		main_row.add_child(_make_game_card(
			String(card_data.get("title", "")),
			String(card_data.get("badge_text", "")),
			String(card_data.get("tagline", "")),
			_to_string_array(card_data.get("tags", [])),
			card_accent,
			String(card_data.get("preview_kind", "")),
			String(card_data.get("button_text", "")),
			_resolve_launcher_action(String(card_data.get("action", ""))),
			bool(card_data.get("enabled", true))
		))

	layout.add_child(_make_update_spotlight_panel())

	var roadmap_row := _make_responsive_box_container(portrait_layout)
	roadmap_row.add_theme_constant_override("separation", _i(18))
	layout.add_child(roadmap_row)

	for info_panel in FrontEndContent.launcher_roadmap_info_panels():
		var info_accent: Color = info_panel.get("accent", Color.WHITE)
		roadmap_row.add_child(_make_info_panel(
			String(info_panel.get("title", "")),
			_to_string_array(info_panel.get("lines", [])),
			info_accent
		))

	_build_about_overlay()
	_build_cangjie_overlay()
	_build_changelog_overlay()
	_build_profile_overlay()


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
	button.add_theme_color_override("font_color", _resolve_label_color(Color(0.08, 0.07, 0.07, 1.0)))
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


func _make_update_spotlight_panel() -> PanelContainer:
	var spotlight := FrontEndContent.launcher_update_spotlight()
	var accent := Color(0.92, 0.7, 0.38, 1.0)
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = _v(0.0, 292.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.1, accent.g * 0.09, accent.b * 0.08, 0.9), Color(accent.r, accent.g, accent.b, 0.54)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(24))
	margin.add_theme_constant_override("margin_top", _i(22))
	margin.add_theme_constant_override("margin_right", _i(24))
	margin.add_theme_constant_override("margin_bottom", _i(22))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)

	box.add_child(_make_tag(String(spotlight.get("eyebrow", "")), Color(0.14, 0.18, 0.24, 0.88), Color(0.96, 0.82, 0.56, 0.98)))
	box.add_child(_make_label(String(spotlight.get("title", "")), 32, Color(1.0, 0.95, 0.86, 1.0)))
	box.add_child(_make_label(String(spotlight.get("summary", "")), 18, Color(0.9, 0.92, 0.96, 0.95)))

	var meta_row := HBoxContainer.new()
	meta_row.add_theme_constant_override("separation", _i(8))
	box.add_child(meta_row)
	for meta_text_variant in spotlight.get("meta", []):
		meta_row.add_child(_make_tag(String(meta_text_variant), Color(accent.r * 0.14, accent.g * 0.14, accent.b * 0.16, 0.9), Color(0.98, 0.94, 0.88, 0.96)))

	var highlights_box := VBoxContainer.new()
	highlights_box.add_theme_constant_override("separation", _i(6))
	box.add_child(highlights_box)
	for highlight_variant in spotlight.get("highlights", []):
		highlights_box.add_child(_make_label("• %s" % String(highlight_variant), 16, Color(0.9, 0.92, 0.96, 0.92)))

	box.add_child(_make_label(String(spotlight.get("footnote", "")), 15, Color(0.86, 0.9, 0.94, 0.8)))

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", _i(10))
	box.add_child(action_row)

	var history_button := _make_pill_button("查看更新记录", _v(0.0, 48.0), _resolve_launcher_action("show_changelog"))
	history_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_row.add_child(history_button)
	return panel


func _build_about_overlay() -> void:
	var portrait_layout := _is_portrait_layout()
	var about_content := FrontEndContent.launcher_about_content()
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
	_set_center_overlay_panel(panel, 1120.0, 780.0 if portrait_layout else 636.0)
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

	box.add_child(_make_tag(String(about_content.get("tag", "")), Color(0.14, 0.18, 0.24, 0.88), Color(0.96, 0.82, 0.56, 0.98)))
	box.add_child(_make_label(String(about_content.get("title", "")), 44, Color(1.0, 0.95, 0.86, 1.0)))
	box.add_child(_make_label(String(about_content.get("summary", "")), 18, Color(0.9, 0.92, 0.96, 0.95)))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", _i(18))
	scroll.add_child(content)

	content.add_child(_make_about_story_panel(
		String(about_content.get("story_title", "")),
		_to_string_array(about_content.get("story_paragraphs", []))
	))

	var game_grid := GridContainer.new()
	game_grid.columns = 1 if portrait_layout else 2
	game_grid.add_theme_constant_override("h_separation", _i(16))
	game_grid.add_theme_constant_override("v_separation", _i(16))
	content.add_child(game_grid)

	for game_card_variant in about_content.get("games", []):
		var game_card: Dictionary = game_card_variant
		var game_accent: Color = game_card.get("accent", Color.WHITE)
		game_grid.add_child(_make_about_game_card(
			String(game_card.get("kicker", "")),
			String(game_card.get("title", "")),
			String(game_card.get("copy", "")),
			_to_string_array(game_card.get("points", [])),
			game_accent,
			String(game_card.get("preview_kind", ""))
		))

	var notes_grid := GridContainer.new()
	notes_grid.columns = 1 if portrait_layout else 2
	notes_grid.add_theme_constant_override("h_separation", _i(14))
	notes_grid.add_theme_constant_override("v_separation", _i(14))
	content.add_child(notes_grid)

	for note_card_variant in about_content.get("notes", []):
		var note_card: Dictionary = note_card_variant
		var note_accent: Color = note_card.get("accent", Color.WHITE)
		notes_grid.add_child(_make_about_note_card(
			String(note_card.get("title", "")),
			String(note_card.get("body", "")),
			note_accent
		))

	var footer_row := _make_responsive_box_container(portrait_layout)
	footer_row.add_theme_constant_override("separation", _i(10))
	box.add_child(footer_row)

	var theme_button := _make_theme_toggle_button(_v(0.0, 52.0))
	theme_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer_row.add_child(theme_button)

	var close_button := Button.new()
	close_button.text = _localize_text(String(about_content.get("close_text", "返回启动器")))
	close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close_button.custom_minimum_size = _v(0.0, 52.0)
	close_button.add_theme_font_override("font", title_font)
	close_button.add_theme_font_size_override("font_size", _i(22))
	close_button.add_theme_color_override("font_color", _resolve_label_color(Color(0.08, 0.07, 0.07, 1.0)))
	close_button.add_theme_stylebox_override("normal", _make_button_style(Color(0.92, 0.62, 0.28, 1.0), 16))
	close_button.add_theme_stylebox_override("hover", _make_button_style(Color(0.98, 0.7, 0.34, 1.0), 16))
	close_button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.84, 0.54, 0.22, 1.0), 16))
	close_button.pressed.connect(_hide_about)
	footer_row.add_child(close_button)


func _build_cangjie_overlay() -> void:
	var portrait_layout := _is_portrait_layout()
	cangjie_overlay = Control.new()
	cangjie_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	cangjie_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	cangjie_overlay.visible = false
	add_child(cangjie_overlay)

	var scrim := ColorRect.new()
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.01, 0.02, 0.03, 0.78)
	cangjie_overlay.add_child(scrim)

	var panel := PanelContainer.new()
	_set_center_overlay_panel(panel, 1080.0, 780.0 if portrait_layout else 640.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.08, 0.1, 0.96), Color(0.44, 0.68, 0.94, 0.88)))
	cangjie_overlay.add_child(panel)

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

	box.add_child(_make_tag("Cangjie Portal", Color(0.12, 0.18, 0.24, 0.88), Color(0.78, 0.9, 1.0, 0.98)))
	box.add_child(_make_label("仓颉之路入口", 42, Color(1.0, 0.95, 0.86, 1.0)))
	box.add_child(_make_label("先把 deckbuilder 原型的核心结构、迁移状态和后续切入点收进同一层入口里，避免第二项目继续停在一张静态卡片。", 18, Color(0.9, 0.92, 0.96, 0.95)))

	var portal_sections := FrontEndContent.cangjie_portal_sections()

	var nav_container: Container
	if portrait_layout:
		var nav_grid := GridContainer.new()
		nav_grid.columns = 2
		nav_grid.add_theme_constant_override("h_separation", _i(10))
		nav_grid.add_theme_constant_override("v_separation", _i(10))
		nav_container = nav_grid
	else:
		var nav_row := HBoxContainer.new()
		nav_row.add_theme_constant_override("separation", _i(10))
		nav_container = nav_row
	box.add_child(nav_container)

	cangjie_nav_buttons.clear()
	for section in portal_sections:
		var section_id := String(section.get("id", "overview"))
		var button := _make_pill_button(_localize_cangjie_text(section.get("title", section_id)), _v(0.0, 48.0), Callable(self, "_on_cangjie_section_pressed").bind(section_id))
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nav_container.add_child(button)
		cangjie_nav_buttons[section_id] = button

	var content_panel := PanelContainer.new()
	content_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.82), Color(0.38, 0.62, 0.9, 0.38)))
	box.add_child(content_panel)

	var content_margin := MarginContainer.new()
	content_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	content_margin.add_theme_constant_override("margin_left", _i(22))
	content_margin.add_theme_constant_override("margin_top", _i(20))
	content_margin.add_theme_constant_override("margin_right", _i(22))
	content_margin.add_theme_constant_override("margin_bottom", _i(20))
	content_panel.add_child(content_margin)

	var content_box := VBoxContainer.new()
	content_box.add_theme_constant_override("separation", _i(10))
	content_margin.add_child(content_box)

	cangjie_section_title_label = _make_label("", 32, Color(1.0, 0.95, 0.86, 1.0))
	content_box.add_child(cangjie_section_title_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content_box.add_child(scroll)

	cangjie_section_content_box = VBoxContainer.new()
	cangjie_section_content_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cangjie_section_content_box.add_theme_constant_override("separation", _i(12))
	scroll.add_child(cangjie_section_content_box)

	var footer_row := _make_responsive_box_container(portrait_layout)
	footer_row.add_theme_constant_override("separation", _i(10))
	box.add_child(footer_row)

	var theme_button := _make_theme_toggle_button(_v(0.0, 52.0))
	theme_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer_row.add_child(theme_button)

	var language_button := _make_language_toggle_button(_v(0.0, 52.0))
	language_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer_row.add_child(language_button)

	var profile_button := _make_pill_button("玩家名帖", _v(0.0, 52.0), Callable(self, "_show_profile"))
	profile_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer_row.add_child(profile_button)

	var close_button := Button.new()
	close_button.text = _localize_text("返回游戏选择")
	close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close_button.custom_minimum_size = _v(0.0, 52.0)
	close_button.add_theme_font_override("font", title_font)
	close_button.add_theme_font_size_override("font_size", _i(22))
	close_button.add_theme_color_override("font_color", _resolve_label_color(Color(0.08, 0.07, 0.07, 1.0)))
	close_button.add_theme_stylebox_override("normal", _make_button_style(Color(0.38, 0.58, 0.9, 1.0), 16))
	close_button.add_theme_stylebox_override("hover", _make_button_style(Color(0.46, 0.66, 0.98, 1.0), 16))
	close_button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.3, 0.5, 0.84, 1.0), 16))
	close_button.pressed.connect(_hide_cangjie_portal)
	footer_row.add_child(close_button)

	_refresh_cangjie_portal()


func _refresh_cangjie_portal() -> void:
	if cangjie_section_title_label == null or cangjie_section_content_box == null:
		return

	var sections := FrontEndContent.cangjie_portal_sections()
	if sections.is_empty():
		return

	var active_section: Dictionary = sections[0]
	for section in sections:
		if String(section.get("id", "")) == cangjie_section:
			active_section = section
			break
	cangjie_section = String(active_section.get("id", cangjie_section))

	cangjie_section_title_label.text = "%s  ·  %s" % [
		_localize_cangjie_text(active_section.get("title", "")),
		_localize_cangjie_text(active_section.get("eyebrow", ""))
	]
	for child in cangjie_section_content_box.get_children():
		cangjie_section_content_box.remove_child(child)
		child.queue_free()

	var accent: Color = active_section.get("accent", Color(0.44, 0.68, 0.94, 1.0))
	cangjie_section_content_box.add_child(_make_label(_localize_cangjie_text(active_section.get("summary", "")), 18, Color(0.9, 0.92, 0.96, 0.96)))
	var points_variant: Variant = active_section.get("points", [])
	if points_variant is Array and not (points_variant as Array).is_empty():
		cangjie_section_content_box.add_child(_make_cangjie_focus_panel(points_variant as Array, accent))
	var duel_preview_variant: Variant = active_section.get("duel_preview", {})
	if duel_preview_variant is Dictionary and not (duel_preview_variant as Dictionary).is_empty():
		cangjie_section_content_box.add_child(_make_cangjie_duel_preview(duel_preview_variant as Dictionary, accent))
	var run_shell_preview_variant: Variant = active_section.get("run_shell_preview", {})
	if run_shell_preview_variant is Dictionary and not (run_shell_preview_variant as Dictionary).is_empty():
		cangjie_section_content_box.add_child(_make_cangjie_run_shell_preview(run_shell_preview_variant as Dictionary, accent))
	var reward_chain_preview_variant: Variant = active_section.get("reward_chain_preview", {})
	if reward_chain_preview_variant is Dictionary and not (reward_chain_preview_variant as Dictionary).is_empty():
		cangjie_section_content_box.add_child(_make_cangjie_reward_chain_preview(reward_chain_preview_variant as Dictionary, accent))
	var route_preview_variant: Variant = active_section.get("route_preview", {})
	if route_preview_variant is Dictionary and not (route_preview_variant as Dictionary).is_empty():
		cangjie_section_content_box.add_child(_make_cangjie_route_preview(route_preview_variant as Dictionary, accent))
	var rest_preview_variant: Variant = active_section.get("rest_preview", {})
	if rest_preview_variant is Dictionary and not (rest_preview_variant as Dictionary).is_empty():
		cangjie_section_content_box.add_child(_make_cangjie_rest_preview(rest_preview_variant as Dictionary, accent))
	var archive_preview_variant: Variant = active_section.get("archive_preview", {})
	if archive_preview_variant is Dictionary and not (archive_preview_variant as Dictionary).is_empty():
		cangjie_section_content_box.add_child(_make_cangjie_archive_preview(archive_preview_variant as Dictionary, accent))
	var treasure_preview_variant: Variant = active_section.get("treasure_preview", {})
	if treasure_preview_variant is Dictionary and not (treasure_preview_variant as Dictionary).is_empty():
		cangjie_section_content_box.add_child(_make_cangjie_treasure_preview(treasure_preview_variant as Dictionary, accent))
	var shop_preview_variant: Variant = active_section.get("shop_preview", {})
	if shop_preview_variant is Dictionary and not (shop_preview_variant as Dictionary).is_empty():
		cangjie_section_content_box.add_child(_make_cangjie_shop_preview(shop_preview_variant as Dictionary, accent))
	var route_ledger_preview_variant: Variant = active_section.get("route_ledger_preview", {})
	if route_ledger_preview_variant is Dictionary and not (route_ledger_preview_variant as Dictionary).is_empty():
		cangjie_section_content_box.add_child(_make_cangjie_route_ledger_preview(route_ledger_preview_variant as Dictionary, accent))
	var tutor_preview_variant: Variant = active_section.get("tutor_preview", {})
	if tutor_preview_variant is Dictionary and not (tutor_preview_variant as Dictionary).is_empty():
		cangjie_section_content_box.add_child(_make_cangjie_tutor_preview(tutor_preview_variant as Dictionary, accent))
	var broker_preview_variant: Variant = active_section.get("broker_preview", {})
	if broker_preview_variant is Dictionary and not (broker_preview_variant as Dictionary).is_empty():
		cangjie_section_content_box.add_child(_make_cangjie_broker_preview(broker_preview_variant as Dictionary, accent))
	var margin_preview_variant: Variant = active_section.get("margin_preview", {})
	if margin_preview_variant is Dictionary and not (margin_preview_variant as Dictionary).is_empty():
		cangjie_section_content_box.add_child(_make_cangjie_margin_preview(margin_preview_variant as Dictionary, accent))
	var groups_variant: Variant = active_section.get("sample_groups", [])
	if groups_variant is Array:
		for group_variant in groups_variant:
			if group_variant is Dictionary:
				cangjie_section_content_box.add_child(_make_cangjie_group_panel(group_variant as Dictionary, accent))

	for section_id in cangjie_nav_buttons.keys():
		var button: Button = cangjie_nav_buttons[section_id]
		var active: bool = String(section_id) == cangjie_section
		var button_fill := Color(0.38, 0.58, 0.9, 1.0) if active else Color(0.16, 0.22, 0.3, 0.86)
		button.add_theme_stylebox_override("normal", _make_panel_style(button_fill if active else Color(0.04, 0.06, 0.08, 0.78), Color(0.44, 0.68, 0.94, 0.46)))
		button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.46, 0.66, 0.98, 1.0) if active else Color(0.08, 0.1, 0.12, 0.84), Color(0.44, 0.68, 0.94, 0.54)))
		button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.3, 0.5, 0.84, 1.0) if active else Color(0.08, 0.1, 0.12, 0.9), Color(0.44, 0.68, 0.94, 0.62)))


func _make_cangjie_focus_panel(points: Array, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.78), Color(accent.r, accent.g, accent.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(8))
	margin.add_child(box)
	box.add_child(_make_label("迁移重点", 18, Color(1.0, 0.94, 0.82, 0.96)))
	for point_variant in points:
		box.add_child(_make_label("• %s" % _localize_cangjie_text(point_variant), 16, Color(0.88, 0.92, 0.96, 0.94)))
	return panel


func _make_cangjie_duel_preview(preview: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.78), Color(accent.r, accent.g, accent.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)
	box.add_child(_make_label(_localize_cangjie_text(preview.get("title", "")), 20, Color(1.0, 0.95, 0.86, 1.0)))

	var summary_text := _localize_cangjie_text(preview.get("summary", ""))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 16, Color(0.88, 0.92, 0.96, 0.92)))

	var action_row := _make_responsive_box_container(_is_portrait_layout())
	action_row.add_theme_constant_override("separation", _i(10))
	box.add_child(action_row)

	var fx_button := _make_pill_button(_localize_cangjie_text(preview.get("fx_button", "3D 特效")), _v(0.0, 46.0), Callable(self, "_on_toggle_cangjie_stage_fx_pressed"))
	fx_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_row.add_child(fx_button)

	var fx_state_key := "fx_state_on" if cangjie_stage_fx_enabled else "fx_state_off"
	var fx_state := _make_static_pill(_localize_cangjie_text(preview.get(fx_state_key, "")), _v(0.0, 46.0))
	fx_state.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_row.add_child(fx_state)

	var duel_row := _make_responsive_box_container(_is_portrait_layout())
	duel_row.add_theme_constant_override("separation", _i(10))
	box.add_child(duel_row)

	var duelists_variant: Variant = preview.get("duelists", [])
	if duelists_variant is Array:
		for duelist_variant in duelists_variant:
			if duelist_variant is Dictionary:
				duel_row.add_child(_make_cangjie_duelist_card(duelist_variant as Dictionary, accent))

	var hint_text := _localize_cangjie_text(preview.get("hint", ""))
	if not hint_text.is_empty():
		box.add_child(_make_label(hint_text, 15, Color(0.82, 0.9, 0.96, 0.82)))

	return panel


func _make_cangjie_run_shell_preview(preview: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.78), Color(accent.r, accent.g, accent.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)
	box.add_child(_make_label(_localize_cangjie_text(preview.get("title", "")), 20, Color(1.0, 0.95, 0.86, 1.0)))

	var summary_text := _localize_cangjie_text(preview.get("summary", ""))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 16, Color(0.88, 0.92, 0.96, 0.92)))

	var action_row := HFlowContainer.new()
	action_row.add_theme_constant_override("h_separation", _i(10))
	action_row.add_theme_constant_override("v_separation", _i(10))
	box.add_child(action_row)

	var actions_variant: Variant = preview.get("actions", [])
	if actions_variant is Array:
		for action_variant in actions_variant:
			if action_variant is Dictionary:
				action_row.add_child(_make_cangjie_run_action_control(action_variant as Dictionary, accent))

	var status_row := HFlowContainer.new()
	status_row.add_theme_constant_override("h_separation", _i(10))
	status_row.add_theme_constant_override("v_separation", _i(10))
	box.add_child(status_row)

	var status_variant: Variant = preview.get("status_pills", [])
	if status_variant is Array:
		for pill_variant in status_variant:
			if pill_variant is Dictionary:
				status_row.add_child(_make_cangjie_run_status_pill(pill_variant as Dictionary, accent))

	var deck_preview_variant: Variant = preview.get("deck_preview", {})
	if deck_preview_variant is Dictionary and not (deck_preview_variant as Dictionary).is_empty():
		if cangjie_run_shell_open:
			box.add_child(_make_cangjie_deck_preview_panel(deck_preview_variant as Dictionary, accent))
		else:
			var deck_hint := _localize_cangjie_text((deck_preview_variant as Dictionary).get("hint", ""))
			if not deck_hint.is_empty():
				box.add_child(_make_label(deck_hint, 14, Color(0.82, 0.9, 0.96, 0.84)))

	return panel


func _make_cangjie_run_action_control(action: Dictionary, accent: Color) -> Control:
	var action_id := String(action.get("id", "action"))
	var tone: Color = action.get("tone", accent)
	if action_id == "deck":
		var label_key := "active_label" if cangjie_run_shell_open else "label"
		var button := Button.new()
		button.text = _localize_cangjie_text(action.get(label_key, action.get("label", "")))
		button.custom_minimum_size = _v(170.0 if _is_portrait_layout() else 184.0, 46.0)
		button.add_theme_font_override("font", title_font)
		button.add_theme_font_size_override("font_size", _i(18))
		button.add_theme_color_override("font_color", Color(0.98, 0.94, 0.88, 0.98))
		button.add_theme_stylebox_override("normal", _make_panel_style(Color(tone.r * 0.16, tone.g * 0.16, tone.b * 0.18, 0.94), Color(tone.r, tone.g, tone.b, 0.34)))
		button.add_theme_stylebox_override("hover", _make_panel_style(Color(tone.r * 0.2, tone.g * 0.18, tone.b * 0.2, 0.98), Color(tone.r, tone.g, tone.b, 0.46)))
		button.add_theme_stylebox_override("pressed", _make_panel_style(Color(tone.r * 0.24, tone.g * 0.22, tone.b * 0.24, 1.0), Color(tone.r, tone.g, tone.b, 0.54)))
		button.pressed.connect(_on_toggle_cangjie_run_shell_pressed)
		return button

	return _make_cangjie_shell_pill(_localize_cangjie_text(action.get("label", "")), tone, _v(170.0 if _is_portrait_layout() else 184.0, 46.0), 18)


func _make_cangjie_shell_pill(text: String, tone: Color, control_size: Vector2, font_size: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = control_size
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.14, tone.g * 0.14, tone.b * 0.16, 0.88), Color(tone.r, tone.g, tone.b, 0.24)))

	var label := _make_label(text, font_size, Color(0.98, 0.94, 0.88, 0.98))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(label)
	return panel


func _make_cangjie_run_status_pill(pill: Dictionary, accent: Color) -> PanelContainer:
	var tone: Color = pill.get("tone", accent)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = _v(138.0, 72.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.12, tone.g * 0.12, tone.b * 0.14, 0.86), Color(tone.r, tone.g, tone.b, 0.24)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(12))
	margin.add_theme_constant_override("margin_top", _i(10))
	margin.add_theme_constant_override("margin_right", _i(12))
	margin.add_theme_constant_override("margin_bottom", _i(10))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(4))
	margin.add_child(box)

	var label := _make_label(_localize_cangjie_text(pill.get("label", "")), 13, Color(0.82, 0.9, 0.96, 0.84))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(label)

	var value := _make_label(_localize_cangjie_text(pill.get("value", "")), 20, Color(1.0, 0.95, 0.86, 1.0))
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(value)

	return panel


func _make_cangjie_deck_preview_panel(preview: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.06, accent.g * 0.08, accent.b * 0.1, 0.72), Color(accent.r, accent.g, accent.b, 0.26)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)
	box.add_child(_make_label(_localize_cangjie_text(preview.get("title", "")), 20, Color(1.0, 0.95, 0.86, 1.0)))

	var summary_text := _localize_cangjie_text(preview.get("summary", ""))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 16, Color(0.88, 0.92, 0.96, 0.92)))

	var tags_variant: Variant = preview.get("tags", [])
	if tags_variant is Array and not (tags_variant as Array).is_empty():
		var tag_row := HFlowContainer.new()
		tag_row.add_theme_constant_override("h_separation", _i(8))
		tag_row.add_theme_constant_override("v_separation", _i(8))
		box.add_child(tag_row)
		for tag_variant in tags_variant:
			tag_row.add_child(_make_tag(_localize_cangjie_text(tag_variant), Color(accent.r * 0.16, accent.g * 0.16, accent.b * 0.18, 0.86), Color(0.98, 0.94, 0.88, 0.96)))

	var groups_variant: Variant = preview.get("groups", [])
	if groups_variant is Array:
		for group_variant in groups_variant:
			if group_variant is Dictionary:
				box.add_child(_make_cangjie_group_panel(group_variant as Dictionary, accent))

	return panel


func _make_cangjie_route_shell_carry_panel(config: Dictionary, preview: Dictionary, selected_node: Dictionary, accent: Color) -> PanelContainer:
	var shell_preview := _get_cangjie_run_shell_preview_config()
	if shell_preview.is_empty():
		return _make_cangjie_run_shell_preview(config, accent)

	shell_preview["title"] = config.get("title", shell_preview.get("title", ""))
	shell_preview["summary"] = config.get("summary", shell_preview.get("summary", ""))

	var status_pills_variant: Variant = shell_preview.get("status_pills", [])
	var status_pills: Array = status_pills_variant as Array if status_pills_variant is Array else []
	shell_preview["status_pills"] = _build_cangjie_route_shell_status_pills(status_pills, preview, selected_node)
	return _make_cangjie_run_shell_preview(shell_preview, accent)


func _get_cangjie_run_shell_preview_config() -> Dictionary:
	var sections := FrontEndContent.cangjie_portal_sections()
	for section_variant in sections:
		if not (section_variant is Dictionary):
			continue
		var section := section_variant as Dictionary
		if String(section.get("id", "")) != "run_controls":
			continue
		var preview_variant: Variant = section.get("run_shell_preview", {})
		if preview_variant is Dictionary and not (preview_variant as Dictionary).is_empty():
			return (preview_variant as Dictionary).duplicate(true)
	return {}


func _build_cangjie_route_shell_status_pills(base_status_pills: Array, preview: Dictionary, selected_node: Dictionary) -> Array:
	var status_pills: Array = []
	var floor_value: Variant = ""
	var has_floor_value := false
	var selected_id := String(selected_node.get("id", ""))
	if not selected_id.is_empty():
		var route_index := _build_cangjie_route_preview_index(preview)
		var indexed_variant: Variant = route_index.get(selected_id, {})
		if indexed_variant is Dictionary:
			var indexed := indexed_variant as Dictionary
			var floor_variant: Variant = indexed.get("floor", "")
			if floor_variant is Dictionary:
				var floor_dict := floor_variant as Dictionary
				if not floor_dict.is_empty():
					has_floor_value = true
					floor_value = floor_dict
			else:
				var floor_text := String(floor_variant)
				if not floor_text.is_empty():
					has_floor_value = true
					floor_value = floor_text

	for pill_variant in base_status_pills:
		if not (pill_variant is Dictionary):
			continue
		var pill := (pill_variant as Dictionary).duplicate(true)
		if status_pills.is_empty() and has_floor_value:
			pill["value"] = floor_value
		status_pills.append(pill)
	return status_pills


func _make_cangjie_route_preview(preview: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.78), Color(accent.r, accent.g, accent.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)
	box.add_child(_make_label(_localize_cangjie_text(preview.get("title", "")), 20, Color(1.0, 0.95, 0.86, 1.0)))

	var summary_text := _localize_cangjie_text(preview.get("summary", ""))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 16, Color(0.88, 0.92, 0.96, 0.92)))

	var hint_text := _localize_cangjie_text(preview.get("hint", ""))
	if not hint_text.is_empty():
		box.add_child(_make_label(hint_text, 14, Color(0.82, 0.9, 0.96, 0.86)))

	var selected_node := _find_cangjie_route_preview_node(preview, cangjie_route_preview_node_id)
	if selected_node.is_empty():
		selected_node = _find_cangjie_route_preview_node(preview, String(preview.get("default_node_id", "")))
	if selected_node.is_empty():
		selected_node = _first_cangjie_route_preview_node(preview)
	if not selected_node.is_empty():
		cangjie_route_preview_node_id = String(selected_node.get("id", ""))
	var selected_node_id := String(selected_node.get("id", ""))
	var selected_lane := String(selected_node.get("lane", ""))
	var state_legend_variant: Variant = preview.get("state_legend", {})
	var state_legend: Dictionary = state_legend_variant as Dictionary if state_legend_variant is Dictionary else {}
	var progress_stub_variant: Variant = preview.get("progress_stub", {})
	var progress_stub: Dictionary = progress_stub_variant as Dictionary if progress_stub_variant is Dictionary else {}
	var history_strip_variant: Variant = preview.get("history_strip", {})
	var history_strip: Dictionary = history_strip_variant as Dictionary if history_strip_variant is Dictionary else {}
	var shell_carry_variant: Variant = preview.get("shell_carry", {})
	var shell_carry: Dictionary = shell_carry_variant as Dictionary if shell_carry_variant is Dictionary else {}
	var next_row_handoff_variant: Variant = preview.get("next_row_handoff", {})
	var next_row_handoff: Dictionary = next_row_handoff_variant as Dictionary if next_row_handoff_variant is Dictionary else {}
	var progress_info := _build_cangjie_route_progress_info(preview, selected_node)
	var progress_states_variant: Variant = progress_info.get("node_states", {})
	var progress_states: Dictionary = progress_states_variant as Dictionary if progress_states_variant is Dictionary else {}
	var node_details_variant: Variant = preview.get("node_details", {})
	var node_details: Dictionary = node_details_variant as Dictionary if node_details_variant is Dictionary else {}

	if not shell_carry.is_empty():
		box.add_child(_make_cangjie_route_shell_carry_panel(shell_carry, preview, selected_node, accent))

	var rows_variant: Variant = preview.get("rows", [])
	if rows_variant is Array and not (rows_variant as Array).is_empty():
		var route_shell := PanelContainer.new()
		route_shell.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.06, accent.g * 0.08, accent.b * 0.1, 0.72), Color(accent.r, accent.g, accent.b, 0.24)))
		box.add_child(route_shell)

		var shell_margin := MarginContainer.new()
		shell_margin.add_theme_constant_override("margin_left", _i(12))
		shell_margin.add_theme_constant_override("margin_top", _i(12))
		shell_margin.add_theme_constant_override("margin_right", _i(12))
		shell_margin.add_theme_constant_override("margin_bottom", _i(12))
		route_shell.add_child(shell_margin)

		var rows_box := VBoxContainer.new()
		rows_box.add_theme_constant_override("separation", _i(10))
		shell_margin.add_child(rows_box)

		var route_node_lookup := {}
		for row_variant in rows_variant:
			if row_variant is Dictionary:
				rows_box.add_child(_make_cangjie_route_row(row_variant as Dictionary, accent, selected_node_id, selected_lane, route_node_lookup, state_legend, progress_states))

		var link_layer := CangjieRouteLinkLayer.new()
		link_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
		link_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		route_shell.add_child(link_layer)
		call_deferred("_sync_cangjie_route_link_layer", link_layer, route_node_lookup, _build_cangjie_route_links(preview, progress_states), selected_node_id, selected_lane, accent)

	if not state_legend.is_empty():
		box.add_child(_make_cangjie_route_state_legend(state_legend, selected_node, accent))
	if not progress_stub.is_empty():
		box.add_child(_make_cangjie_route_progress_stub_panel(progress_stub, progress_info, selected_node, accent))
	if not history_strip.is_empty():
		box.add_child(_make_cangjie_route_history_strip_panel(history_strip, preview, progress_info, accent))
	if not next_row_handoff.is_empty():
		box.add_child(_make_cangjie_route_next_row_panel(next_row_handoff, preview, selected_node, progress_info, node_details, accent))

	if not selected_node.is_empty() and not node_details.is_empty():
		var detail_key := String(selected_node.get("kind", selected_node.get("id", "")))
		var node_detail_variant: Variant = node_details.get(detail_key, {})
		if node_detail_variant is Dictionary and not (node_detail_variant as Dictionary).is_empty():
			var node_detail := node_detail_variant as Dictionary
			var selected_tone: Color = selected_node.get("tone", accent)
			var follow_through_variant: Variant = node_detail.get("follow_through", {})
			if follow_through_variant is Dictionary and not (follow_through_variant as Dictionary).is_empty():
				var follow_through := follow_through_variant as Dictionary
				var follow_label := _localize_cangjie_text(follow_through.get("label", ""))
				if not follow_label.is_empty():
					box.add_child(_make_tag(follow_label, Color(selected_tone.r * 0.18, selected_tone.g * 0.18, selected_tone.b * 0.2, 0.92), Color(0.98, 0.94, 0.88, 0.96)))

				var follow_tags_variant: Variant = follow_through.get("tags", [])
				if follow_tags_variant is Array and not (follow_tags_variant as Array).is_empty():
					var follow_tag_grid := GridContainer.new()
					follow_tag_grid.columns = 1 if _is_portrait_layout() else 2
					follow_tag_grid.add_theme_constant_override("h_separation", _i(8))
					follow_tag_grid.add_theme_constant_override("v_separation", _i(8))
					box.add_child(follow_tag_grid)
					for tag_variant in follow_tags_variant:
						follow_tag_grid.add_child(_make_tag(_localize_cangjie_text(tag_variant), Color(selected_tone.r * 0.16, selected_tone.g * 0.16, selected_tone.b * 0.18, 0.88), Color(0.98, 0.94, 0.88, 0.94)))

			var detail_summary := _localize_cangjie_text(node_detail.get("summary", ""))
			if not detail_summary.is_empty():
				box.add_child(_make_label(detail_summary, 15, Color(0.94, 0.92, 0.88, 0.94)))

			var valuation_group_variant: Variant = node_detail.get("valuation_group", {})
			if valuation_group_variant is Dictionary and not (valuation_group_variant as Dictionary).is_empty():
				box.add_child(_make_cangjie_group_panel(valuation_group_variant as Dictionary, selected_tone))

			var preview_route_ribbon_variant: Variant = preview.get("route_ribbon", {})
			var preview_route_ribbon: Dictionary = preview_route_ribbon_variant as Dictionary if preview_route_ribbon_variant is Dictionary else {}
			var node_route_ribbon_variant: Variant = node_detail.get("route_ribbon", {})
			var node_route_ribbon: Dictionary = node_route_ribbon_variant as Dictionary if node_route_ribbon_variant is Dictionary else {}
			if not preview_route_ribbon.is_empty() or not node_route_ribbon.is_empty():
				box.add_child(_make_cangjie_route_ribbon_panel(preview_route_ribbon, node_route_ribbon, preview, selected_node, selected_tone))

			var group_variant: Variant = node_detail.get("group", {})
			if group_variant is Dictionary and not (group_variant as Dictionary).is_empty():
				box.add_child(_make_cangjie_group_panel(group_variant as Dictionary, selected_tone))

	var footnote_text := _localize_cangjie_text(preview.get("footnote", ""))
	if not footnote_text.is_empty():
		box.add_child(_make_label(footnote_text, 14, Color(0.82, 0.9, 0.96, 0.82)))

	return panel


func _make_cangjie_route_state_legend(legend: Dictionary, selected_node: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.74), Color(accent.r, accent.g, accent.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)

	var title_text := _localize_cangjie_text(legend.get("title", ""))
	if not title_text.is_empty():
		box.add_child(_make_label(title_text, 18, Color(1.0, 0.95, 0.86, 1.0)))

	var summary_text := _localize_cangjie_text(legend.get("summary", ""))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 14, Color(0.86, 0.9, 0.98, 0.88)))

	var items_variant: Variant = legend.get("items", [])
	if items_variant is Array and not (items_variant as Array).is_empty():
		var grid := GridContainer.new()
		grid.columns = 1 if _is_portrait_layout() else 2
		grid.add_theme_constant_override("h_separation", _i(10))
		grid.add_theme_constant_override("v_separation", _i(10))
		box.add_child(grid)

		var selected_state := String(selected_node.get("state", ""))
		var has_selected := not selected_node.is_empty()
		for item_variant in items_variant:
			if item_variant is Dictionary:
				var item := item_variant as Dictionary
				var item_id := String(item.get("id", ""))
				var active := item_id == selected_state or (item_id == "focus" and has_selected)
				grid.add_child(_make_cangjie_route_state_legend_card(item, active, accent))

	return panel


func _make_cangjie_route_state_legend_card(item: Dictionary, active: bool, accent: Color) -> PanelContainer:
	var tone: Color = item.get("tone", accent)
	var border_alpha := 0.42 if active else 0.22
	var fill_alpha := 0.86 if active else 0.76

	var panel := PanelContainer.new()
	panel.custom_minimum_size = _v(0.0, 144.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.15, tone.g * 0.15, tone.b * 0.18, fill_alpha), Color(tone.r, tone.g, tone.b, border_alpha)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(14))
	margin.add_theme_constant_override("margin_top", _i(12))
	margin.add_theme_constant_override("margin_right", _i(14))
	margin.add_theme_constant_override("margin_bottom", _i(12))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(8))
	margin.add_child(box)

	var badge_row := HBoxContainer.new()
	badge_row.add_theme_constant_override("separation", _i(8))
	box.add_child(badge_row)

	var badge_text := _localize_cangjie_text(item.get("badge", item.get("title", "")))
	if not badge_text.is_empty():
		badge_row.add_child(_make_tag(badge_text, Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.22, 0.9), Color(0.98, 0.94, 0.88, 0.96)))
	if active:
		badge_row.add_child(_make_tag("当前读法" if not _is_english() else "Active Read", Color(tone.r * 0.22, tone.g * 0.2, tone.b * 0.16, 0.92), Color(0.98, 0.94, 0.88, 0.96)))

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", _i(10))
	box.add_child(header)

	var glyph_panel := PanelContainer.new()
	glyph_panel.custom_minimum_size = _v(40.0, 40.0)
	glyph_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.22, tone.g * 0.18, tone.b * 0.16, 0.92), Color(tone.r, tone.g, tone.b, 0.3)))
	header.add_child(glyph_panel)

	var glyph_label := _make_label(String(item.get("glyph", "")), 19, Color(1.0, 0.95, 0.86, 1.0))
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph_panel.add_child(glyph_label)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", _i(3))
	header.add_child(text_box)
	text_box.add_child(_make_label(_localize_cangjie_text(item.get("title", "")), 15, Color(1.0, 0.95, 0.86, 1.0)))

	var body_text := _localize_cangjie_text(item.get("body", ""))
	if not body_text.is_empty():
		box.add_child(_make_label(body_text, 13, Color(0.84, 0.9, 0.98, 0.84)))

	return panel


func _make_cangjie_route_progress_stub_panel(stub: Dictionary, progress_info: Dictionary, selected_node: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.74), Color(accent.r, accent.g, accent.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)

	var title_text := _localize_cangjie_text(stub.get("title", ""))
	if not title_text.is_empty():
		box.add_child(_make_label(title_text, 18, Color(1.0, 0.95, 0.86, 1.0)))

	var summary_text := _localize_cangjie_text(stub.get("summary", ""))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 14, Color(0.86, 0.9, 0.98, 0.88)))

	var cards_variant: Variant = stub.get("cards", [])
	if cards_variant is Array and not (cards_variant as Array).is_empty():
		var grid := GridContainer.new()
		grid.columns = 1 if _is_portrait_layout() else 3
		grid.add_theme_constant_override("h_separation", _i(10))
		grid.add_theme_constant_override("v_separation", _i(10))
		box.add_child(grid)

		for card_variant in cards_variant:
			if card_variant is Dictionary:
				var card := card_variant as Dictionary
				var card_id := String(card.get("id", "locked"))
				grid.add_child(_make_cangjie_route_progress_stub_card(card, _get_cangjie_route_progress_count(progress_info, card_id), accent))

	var footnote_format := _localize_cangjie_text(stub.get("footnote_format", ""))
	var selected_label := _localize_cangjie_text(selected_node.get("label", ""))
	if not footnote_format.is_empty() and not selected_label.is_empty():
		box.add_child(_make_label(footnote_format % selected_label, 13, Color(0.82, 0.9, 0.96, 0.82)))

	return panel


func _make_cangjie_route_progress_stub_card(item: Dictionary, count: int, accent: Color) -> PanelContainer:
	var tone: Color = item.get("tone", accent)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = _v(0.0, 156.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.15, tone.g * 0.15, tone.b * 0.18, 0.82), Color(tone.r, tone.g, tone.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(14))
	margin.add_theme_constant_override("margin_top", _i(12))
	margin.add_theme_constant_override("margin_right", _i(14))
	margin.add_theme_constant_override("margin_bottom", _i(12))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(8))
	margin.add_child(box)

	var badge_row := HBoxContainer.new()
	badge_row.add_theme_constant_override("separation", _i(8))
	box.add_child(badge_row)

	var badge_text := _localize_cangjie_text(item.get("badge", item.get("title", "")))
	if not badge_text.is_empty():
		badge_row.add_child(_make_tag(badge_text, Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.22, 0.9), Color(0.98, 0.94, 0.88, 0.96)))
	badge_row.add_child(_make_tag(_format_cangjie_route_progress_count(count), Color(tone.r * 0.22, tone.g * 0.2, tone.b * 0.18, 0.9), Color(0.98, 0.94, 0.88, 0.96)))

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", _i(10))
	box.add_child(header)

	var glyph_panel := PanelContainer.new()
	glyph_panel.custom_minimum_size = _v(40.0, 40.0)
	glyph_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.22, tone.g * 0.18, tone.b * 0.16, 0.92), Color(tone.r, tone.g, tone.b, 0.3)))
	header.add_child(glyph_panel)

	var glyph_label := _make_label(String(item.get("glyph", "")), 19, Color(1.0, 0.95, 0.86, 1.0))
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph_panel.add_child(glyph_label)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", _i(3))
	header.add_child(text_box)
	text_box.add_child(_make_label(_localize_cangjie_text(item.get("title", "")), 15, Color(1.0, 0.95, 0.86, 1.0)))

	var body_text := _localize_cangjie_text(item.get("body", ""))
	if not body_text.is_empty():
		box.add_child(_make_label(body_text, 13, Color(0.84, 0.9, 0.98, 0.84)))

	return panel


func _make_cangjie_route_history_strip_panel(config: Dictionary, preview: Dictionary, progress_info: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.74), Color(accent.r, accent.g, accent.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)

	var title_text := _localize_cangjie_text(config.get("title", ""))
	if not title_text.is_empty():
		box.add_child(_make_label(title_text, 18, Color(1.0, 0.95, 0.86, 1.0)))

	var summary_text := _localize_cangjie_text(config.get("summary", ""))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 14, Color(0.86, 0.9, 0.98, 0.88)))

	var steps := _build_cangjie_route_history_steps(preview, progress_info)
	if steps.is_empty():
		var empty_body := _localize_cangjie_text(config.get("empty_body", ""))
		if not empty_body.is_empty():
			box.add_child(_make_label(empty_body, 13, Color(0.84, 0.9, 0.98, 0.84)))
		return panel

	var count_format := _localize_cangjie_text(config.get("count_format", ""))
	if not count_format.is_empty():
		box.add_child(_make_tag(count_format % steps.size(), Color(accent.r * 0.18, accent.g * 0.18, accent.b * 0.22, 0.9), Color(0.98, 0.94, 0.88, 0.96)))

	var trail_flow := HFlowContainer.new()
	trail_flow.add_theme_constant_override("h_separation", _i(8))
	trail_flow.add_theme_constant_override("v_separation", _i(8))
	box.add_child(trail_flow)

	for step_index in range(steps.size()):
		var step := steps[step_index]
		trail_flow.add_child(_make_cangjie_route_history_step(step, accent))
		if step_index < steps.size() - 1:
			var connector_tone: Color = step.get("tone", accent)
			trail_flow.add_child(_make_label("→", 16, Color(connector_tone.r, connector_tone.g, connector_tone.b, 0.72)))

	return panel


func _build_cangjie_route_history_steps(preview: Dictionary, progress_info: Dictionary) -> Array[Dictionary]:
	var completed_ids_variant: Variant = progress_info.get("completed_ids", [])
	if not (completed_ids_variant is Array) or (completed_ids_variant as Array).is_empty():
		return []

	var selected_id := String(progress_info.get("selected_id", ""))
	var route_index := _build_cangjie_route_preview_index(preview)
	var steps: Array[Dictionary] = []
	for completed_id_variant in completed_ids_variant:
		var completed_id := String(completed_id_variant)
		var indexed_variant: Variant = route_index.get(completed_id, {})
		if not (indexed_variant is Dictionary):
			continue
		var indexed := indexed_variant as Dictionary
		var node_variant: Variant = indexed.get("node", {})
		if not (node_variant is Dictionary):
			continue
		var node := node_variant as Dictionary
		if node.is_empty():
			continue
		steps.append({
			"id": completed_id,
			"floor": indexed.get("floor", {}),
			"glyph": node.get("glyph", ""),
			"label": node.get("label", ""),
			"note": node.get("note", ""),
			"tone": node.get("tone", Color.WHITE),
			"active": completed_id == selected_id
		})

	return steps


func _make_cangjie_route_history_step(step: Dictionary, accent: Color) -> PanelContainer:
	var tone: Color = step.get("tone", accent)
	var active := bool(step.get("active", false))
	var panel := PanelContainer.new()
	panel.custom_minimum_size = _v(164.0, 0.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.16, tone.g * 0.16, tone.b * 0.18, 0.8), Color(tone.r, tone.g, tone.b, 0.4 if active else 0.24)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(12))
	margin.add_theme_constant_override("margin_top", _i(10))
	margin.add_theme_constant_override("margin_right", _i(12))
	margin.add_theme_constant_override("margin_bottom", _i(10))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(6))
	margin.add_child(box)

	var badge_row := HFlowContainer.new()
	badge_row.add_theme_constant_override("h_separation", _i(6))
	badge_row.add_theme_constant_override("v_separation", _i(6))
	box.add_child(badge_row)

	var floor_text := _localize_cangjie_text(step.get("floor", {}))
	if not floor_text.is_empty():
		badge_row.add_child(_make_tag(floor_text, Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.22, 0.88), Color(0.98, 0.94, 0.88, 0.94)))
	badge_row.add_child(_make_tag("Current Focus" if _is_english() and active else ("当前焦点" if active else _get_cangjie_route_progress_badge_text("completed")), Color(tone.r * 0.22, tone.g * 0.18, tone.b * 0.16, 0.88), Color(0.98, 0.94, 0.88, 0.94)))

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", _i(10))
	box.add_child(header)

	var glyph_panel := PanelContainer.new()
	glyph_panel.custom_minimum_size = _v(38.0, 38.0)
	glyph_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.22, tone.g * 0.18, tone.b * 0.16, 0.92), Color(tone.r, tone.g, tone.b, 0.28)))
	header.add_child(glyph_panel)

	var glyph_label := _make_label(String(step.get("glyph", "")), 18, Color(1.0, 0.95, 0.86, 1.0))
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph_panel.add_child(glyph_label)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", _i(2))
	header.add_child(text_box)
	text_box.add_child(_make_label(_localize_cangjie_text(step.get("label", "")), 14, Color(1.0, 0.95, 0.86, 1.0)))

	var note_text := _localize_cangjie_text(step.get("note", ""))
	if not note_text.is_empty():
		box.add_child(_make_label(note_text, 12, Color(0.84, 0.9, 0.98, 0.82)))

	return panel


func _make_cangjie_route_next_row_panel(config: Dictionary, preview: Dictionary, selected_node: Dictionary, progress_info: Dictionary, node_details: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.74), Color(accent.r, accent.g, accent.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)

	var title_text := _localize_cangjie_text(config.get("title", ""))
	if not title_text.is_empty():
		box.add_child(_make_label(title_text, 18, Color(1.0, 0.95, 0.86, 1.0)))

	var summary_text := _localize_cangjie_text(config.get("summary", ""))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 14, Color(0.86, 0.9, 0.98, 0.88)))

	var action_hint := _localize_cangjie_text(config.get("action_hint", ""))
	if not action_hint.is_empty():
		box.add_child(_make_label(action_hint, 13, Color(0.94, 0.76, 0.46, 0.82)))

	var badge_text := _localize_cangjie_text(config.get("badge", ""))
	var card_hint_text := _localize_cangjie_text(config.get("card_hint_badge", ""))
	var next_nodes := _collect_cangjie_route_next_nodes(preview, selected_node, progress_info)
	if next_nodes.is_empty():
		box.add_child(_make_cangjie_route_next_row_empty_card(config, accent))
	else:
		var first_next_variant: Variant = next_nodes[0]
		var open_count_format := _localize_cangjie_text(config.get("open_count_format", ""))
		if not open_count_format.is_empty() and first_next_variant is Dictionary:
			var floor_text := _localize_cangjie_text((first_next_variant as Dictionary).get("floor", {}))
			if not floor_text.is_empty():
				box.add_child(_make_tag(open_count_format % [floor_text, next_nodes.size()], Color(accent.r * 0.18, accent.g * 0.18, accent.b * 0.22, 0.9), Color(0.98, 0.94, 0.88, 0.96)))

		var grid := GridContainer.new()
		grid.columns = 1 if _is_portrait_layout() else 3
		grid.add_theme_constant_override("h_separation", _i(10))
		grid.add_theme_constant_override("v_separation", _i(10))
		box.add_child(grid)
		for next_node_variant in next_nodes:
			if next_node_variant is Dictionary:
				var indexed_node := next_node_variant as Dictionary
				var node_variant: Variant = indexed_node.get("node", {})
				var node: Dictionary = node_variant as Dictionary if node_variant is Dictionary else {}
				var detail_key := String(node.get("kind", node.get("id", "")))
				var detail_variant: Variant = node_details.get(detail_key, {})
				var detail: Dictionary = detail_variant as Dictionary if detail_variant is Dictionary else {}
				grid.add_child(_make_cangjie_route_next_row_card(indexed_node, detail, badge_text, card_hint_text, accent))

	var footnote_format := _localize_cangjie_text(config.get("footnote_format", ""))
	var selected_label := _localize_cangjie_text(selected_node.get("label", ""))
	if not footnote_format.is_empty() and not selected_label.is_empty():
		box.add_child(_make_label(footnote_format % selected_label, 13, Color(0.82, 0.9, 0.96, 0.82)))

	return panel


func _collect_cangjie_route_next_nodes(preview: Dictionary, selected_node: Dictionary, progress_info: Dictionary) -> Array[Dictionary]:
	var next_nodes: Array[Dictionary] = []
	var selected_connections_variant: Variant = selected_node.get("connections", [])
	if not (selected_connections_variant is Array) or (selected_connections_variant as Array).is_empty():
		return next_nodes

	var route_index := _build_cangjie_route_preview_index(preview)
	var progress_states_variant: Variant = progress_info.get("node_states", {})
	var progress_states: Dictionary = progress_states_variant as Dictionary if progress_states_variant is Dictionary else {}
	for next_id_variant in selected_connections_variant:
		var next_id := String(next_id_variant)
		if String(progress_states.get(next_id, "locked")) != "available":
			continue
		var indexed_variant: Variant = route_index.get(next_id, {})
		if indexed_variant is Dictionary and not (indexed_variant as Dictionary).is_empty():
			next_nodes.append(indexed_variant as Dictionary)
	return next_nodes


func _build_cangjie_route_preview_index(preview: Dictionary) -> Dictionary:
	var route_index := {}
	var rows_variant: Variant = preview.get("rows", [])
	if not (rows_variant is Array):
		return route_index

	for row_variant in rows_variant:
		if not (row_variant is Dictionary):
			continue
		var row := row_variant as Dictionary
		var floor_variant: Variant = row.get("floor", {})
		var nodes_variant: Variant = row.get("nodes", [])
		if not (nodes_variant is Array):
			continue
		for node_variant in nodes_variant:
			if node_variant is Dictionary:
				var node := node_variant as Dictionary
				var node_id := String(node.get("id", ""))
				if not node_id.is_empty():
					route_index[node_id] = {
						"node": node,
						"floor": floor_variant
					}

	return route_index


func _make_cangjie_route_next_row_card(indexed_node: Dictionary, node_detail: Dictionary, badge_text: String, card_hint_text: String, accent: Color) -> Button:
	var node_variant: Variant = indexed_node.get("node", {})
	var node: Dictionary = node_variant as Dictionary if node_variant is Dictionary else {}
	var tone: Color = node.get("tone", accent)

	var button := Button.new()
	button.custom_minimum_size = _v(0.0, 246.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(tone.r * 0.15, tone.g * 0.15, tone.b * 0.18, 0.82), Color(tone.r, tone.g, tone.b, 0.28)))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.22, 0.88), Color(tone.r, tone.g, tone.b, 0.4)))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(tone.r * 0.2, tone.g * 0.2, tone.b * 0.24, 0.92), Color(tone.r, tone.g, tone.b, 0.52)))
	button.add_theme_stylebox_override("focus", _make_panel_style(Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.22, 0.88), Color(tone.r, tone.g, tone.b, 0.44)))
	button.add_theme_stylebox_override("disabled", _make_panel_style(Color(tone.r * 0.15, tone.g * 0.15, tone.b * 0.18, 0.82), Color(tone.r, tone.g, tone.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(14))
	margin.add_theme_constant_override("margin_top", _i(12))
	margin.add_theme_constant_override("margin_right", _i(14))
	margin.add_theme_constant_override("margin_bottom", _i(12))
	button.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(8))
	margin.add_child(box)

	var badge_row := HFlowContainer.new()
	badge_row.add_theme_constant_override("h_separation", _i(6))
	badge_row.add_theme_constant_override("v_separation", _i(6))
	box.add_child(badge_row)

	if not badge_text.is_empty():
		badge_row.add_child(_make_tag(badge_text, Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.22, 0.9), Color(0.98, 0.94, 0.88, 0.96)))
	if not card_hint_text.is_empty():
		badge_row.add_child(_make_tag(card_hint_text, Color(tone.r * 0.22, tone.g * 0.18, tone.b * 0.16, 0.88), Color(0.98, 0.94, 0.88, 0.96)))
	var floor_text := _localize_cangjie_text(indexed_node.get("floor", {}))
	if not floor_text.is_empty():
		badge_row.add_child(_make_tag(floor_text, Color(tone.r * 0.16, tone.g * 0.16, tone.b * 0.2, 0.86), Color(0.98, 0.94, 0.88, 0.94)))
	var follow_through_variant: Variant = node_detail.get("follow_through", {})
	var follow_through: Dictionary = follow_through_variant as Dictionary if follow_through_variant is Dictionary else {}
	var follow_label := _localize_cangjie_text(follow_through.get("label", ""))
	if not follow_label.is_empty():
		badge_row.add_child(_make_tag(follow_label, Color(tone.r * 0.14, tone.g * 0.14, tone.b * 0.18, 0.84), Color(0.98, 0.94, 0.88, 0.92)))

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", _i(10))
	box.add_child(header)

	var glyph_panel := PanelContainer.new()
	glyph_panel.custom_minimum_size = _v(40.0, 40.0)
	glyph_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.22, tone.g * 0.18, tone.b * 0.16, 0.92), Color(tone.r, tone.g, tone.b, 0.3)))
	header.add_child(glyph_panel)

	var glyph_label := _make_label(String(node.get("glyph", "")), 19, Color(1.0, 0.95, 0.86, 1.0))
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph_panel.add_child(glyph_label)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", _i(3))
	header.add_child(text_box)
	text_box.add_child(_make_label(_localize_cangjie_text(node.get("label", "")), 15, Color(1.0, 0.95, 0.86, 1.0)))

	var note_text := _localize_cangjie_text(node.get("note", ""))
	if not note_text.is_empty():
		text_box.add_child(_make_label(note_text, 13, Color(0.84, 0.9, 0.98, 0.84)))

	var body_text := _localize_cangjie_text(node_detail.get("summary", node.get("focus_body", "")))
	if not body_text.is_empty():
		box.add_child(_make_label(body_text, 13, Color(0.84, 0.9, 0.98, 0.84)))

	var route_read_variant: Variant = node_detail.get("route_read", {})
	if route_read_variant is Dictionary and not (route_read_variant as Dictionary).is_empty():
		box.add_child(_make_cangjie_route_next_row_route_read_panel(route_read_variant as Dictionary, tone))

	var value_shift_variant: Variant = node_detail.get("value_shift", {})
	if value_shift_variant is Dictionary and not (value_shift_variant as Dictionary).is_empty():
		box.add_child(_make_cangjie_route_next_row_value_shift_panel(value_shift_variant as Dictionary, tone))

	var tags_variant: Variant = follow_through.get("tags", node.get("focus_tags", []))
	if tags_variant is Array and not (tags_variant as Array).is_empty():
		var tag_flow := HFlowContainer.new()
		tag_flow.add_theme_constant_override("h_separation", _i(6))
		tag_flow.add_theme_constant_override("v_separation", _i(6))
		box.add_child(tag_flow)
		for tag_variant in tags_variant:
			var tag_text := _localize_cangjie_text(tag_variant)
			if not tag_text.is_empty():
				tag_flow.add_child(_make_tag(tag_text, Color(tone.r * 0.16, tone.g * 0.16, tone.b * 0.18, 0.88), Color(0.98, 0.94, 0.88, 0.94)))

	var beat_strip := _make_cangjie_route_next_row_beat_strip(node_detail, tone)
	if beat_strip != null:
		box.add_child(beat_strip)

	_set_mouse_filter_recursive(margin, Control.MOUSE_FILTER_IGNORE)

	var node_id := String(node.get("id", ""))
	if not node_id.is_empty():
		button.pressed.connect(Callable(self, "_on_select_cangjie_route_preview_node").bind(
			node_id,
			String(node.get("linked_preview_kind", "")),
			String(node.get("linked_preview_option", ""))
		))
	else:
		button.disabled = true

	return button


func _make_cangjie_route_next_row_route_read_panel(route_read: Dictionary, accent: Color) -> PanelContainer:
	var tone: Color = route_read.get("tone", accent)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.14, tone.g * 0.14, tone.b * 0.18, 0.8), Color(tone.r, tone.g, tone.b, 0.26)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(12))
	margin.add_theme_constant_override("margin_top", _i(10))
	margin.add_theme_constant_override("margin_right", _i(12))
	margin.add_theme_constant_override("margin_bottom", _i(10))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(6))
	margin.add_child(box)

	box.add_child(_make_tag("Route Read" if _is_english() else "路线读法", Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.22, 0.88), Color(0.98, 0.94, 0.88, 0.94)))

	var title_text := _localize_cangjie_text(route_read.get("title", ""))
	if not title_text.is_empty():
		box.add_child(_make_label(title_text, 13, Color(1.0, 0.95, 0.86, 0.98)))

	var summary_text := _localize_cangjie_text(route_read.get("summary", ""))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 12, Color(0.84, 0.9, 0.98, 0.82)))

	return panel


func _make_cangjie_route_next_row_value_shift_panel(value_shift: Dictionary, accent: Color) -> PanelContainer:
	var tone: Color = value_shift.get("tone", accent)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.14, tone.g * 0.14, tone.b * 0.18, 0.78), Color(tone.r, tone.g, tone.b, 0.24)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(12))
	margin.add_theme_constant_override("margin_top", _i(10))
	margin.add_theme_constant_override("margin_right", _i(12))
	margin.add_theme_constant_override("margin_bottom", _i(10))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(6))
	margin.add_child(box)

	box.add_child(_make_tag("Value Shift" if _is_english() else "估值偏转", Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.22, 0.86), Color(0.98, 0.94, 0.88, 0.94)))

	var title_text := _localize_cangjie_text(value_shift.get("title", ""))
	if not title_text.is_empty():
		box.add_child(_make_label(title_text, 13, Color(1.0, 0.95, 0.86, 0.96)))

	var summary_text := _localize_cangjie_text(value_shift.get("summary", ""))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 12, Color(0.84, 0.9, 0.98, 0.82)))

	return panel


func _make_cangjie_route_next_row_beat_strip(node_detail: Dictionary, accent: Color) -> Control:
	var route_ribbon_variant: Variant = node_detail.get("route_ribbon", {})
	if not (route_ribbon_variant is Dictionary):
		return null

	var route_ribbon := route_ribbon_variant as Dictionary
	var steps_variant: Variant = route_ribbon.get("steps", [])
	if not (steps_variant is Array) or (steps_variant as Array).is_empty():
		return null

	var ribbon_box := VBoxContainer.new()
	ribbon_box.add_theme_constant_override("separation", _i(6))

	var title_text := _localize_cangjie_text(route_ribbon.get("title", ""))
	if not title_text.is_empty():
		ribbon_box.add_child(_make_label(title_text, 12, Color(0.82, 0.9, 0.98, 0.78)))

	var beat_flow := HFlowContainer.new()
	beat_flow.add_theme_constant_override("h_separation", _i(6))
	beat_flow.add_theme_constant_override("v_separation", _i(6))
	ribbon_box.add_child(beat_flow)

	var steps := steps_variant as Array
	for step_index in range(steps.size()):
		var step_variant: Variant = steps[step_index]
		if not (step_variant is Dictionary):
			continue
		beat_flow.add_child(_make_cangjie_route_next_row_beat_chip(step_variant as Dictionary, accent))
		if step_index < steps.size() - 1:
			beat_flow.add_child(_make_label("→", 14, Color(accent.r, accent.g, accent.b, 0.72)))

	return ribbon_box


func _make_cangjie_route_next_row_beat_chip(step: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.18, accent.g * 0.18, accent.b * 0.2, 0.84), Color(accent.r, accent.g, accent.b, 0.24)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(10))
	margin.add_theme_constant_override("margin_top", _i(6))
	margin.add_theme_constant_override("margin_right", _i(10))
	margin.add_theme_constant_override("margin_bottom", _i(6))
	panel.add_child(margin)

	var label_text := "%s %s" % [String(step.get("glyph", "")), _localize_cangjie_text(step.get("title", ""))]
	margin.add_child(_make_label(label_text.strip_edges(), 12, Color(0.98, 0.94, 0.88, 0.94)))
	return panel


func _make_cangjie_route_next_row_empty_card(config: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = _v(0.0, 132.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.15, accent.g * 0.15, accent.b * 0.18, 0.8), Color(accent.r, accent.g, accent.b, 0.24)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(14))
	margin.add_theme_constant_override("margin_top", _i(12))
	margin.add_theme_constant_override("margin_right", _i(14))
	margin.add_theme_constant_override("margin_bottom", _i(12))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(8))
	margin.add_child(box)

	var title_text := _localize_cangjie_text(config.get("empty_title", ""))
	if not title_text.is_empty():
		box.add_child(_make_label(title_text, 15, Color(1.0, 0.95, 0.86, 1.0)))

	var body_text := _localize_cangjie_text(config.get("empty_body", ""))
	if not body_text.is_empty():
		box.add_child(_make_label(body_text, 13, Color(0.84, 0.9, 0.98, 0.84)))

	return panel


func _get_cangjie_route_progress_count(progress_info: Dictionary, progress_id: String) -> int:
	var counts_variant: Variant = progress_info.get("counts", {})
	var counts: Dictionary = counts_variant as Dictionary if counts_variant is Dictionary else {}
	return int(counts.get(progress_id, 0))


func _format_cangjie_route_progress_count(count: int) -> String:
	return ("%d rooms" if _is_english() else "%d 个节点") % count


func _build_cangjie_route_progress_info(preview: Dictionary, selected_node: Dictionary) -> Dictionary:
	var node_states := {}
	var counts := {"completed": 0, "available": 0, "locked": 0}
	var completed_ids: Array[String] = []
	var rows_variant: Variant = preview.get("rows", [])
	if not (rows_variant is Array):
		return {"node_states": node_states, "counts": counts, "completed_ids": completed_ids, "selected_id": ""}

	var node_lookup := {}
	var predecessors := {}
	for row_variant in rows_variant:
		if not (row_variant is Dictionary):
			continue
		var nodes_variant: Variant = (row_variant as Dictionary).get("nodes", [])
		if not (nodes_variant is Array):
			continue
		for node_variant in nodes_variant:
			if not (node_variant is Dictionary):
				continue
			var node := node_variant as Dictionary
			var node_id := String(node.get("id", ""))
			if node_id.is_empty():
				continue
			node_lookup[node_id] = node
			node_states[node_id] = "locked"
			predecessors[node_id] = []

	for row_variant in rows_variant:
		if not (row_variant is Dictionary):
			continue
		var nodes_variant: Variant = (row_variant as Dictionary).get("nodes", [])
		if not (nodes_variant is Array):
			continue
		for node_variant in nodes_variant:
			if not (node_variant is Dictionary):
				continue
			var node := node_variant as Dictionary
			var from_id := String(node.get("id", ""))
			var connections_variant: Variant = node.get("connections", [])
			if from_id.is_empty() or not (connections_variant is Array):
				continue
			for connection_variant in connections_variant:
				var to_id := String(connection_variant)
				if not predecessors.has(to_id):
					predecessors[to_id] = []
				var previous_ids_variant: Variant = predecessors.get(to_id, [])
				if previous_ids_variant is Array:
					var previous_ids := previous_ids_variant as Array
					previous_ids.append(from_id)
					predecessors[to_id] = previous_ids

	var selected_id := String(selected_node.get("id", ""))
	if not selected_id.is_empty():
		completed_ids = _build_cangjie_route_completed_ids(selected_id, node_lookup, predecessors)
		for completed_id in completed_ids:
			node_states[completed_id] = "completed"

		var selected_connections_variant: Variant = selected_node.get("connections", [])
		if selected_connections_variant is Array:
			for connection_variant in selected_connections_variant:
				var next_id := String(connection_variant)
				if String(node_states.get(next_id, "locked")) != "completed":
					node_states[next_id] = "available"

	for progress_state_variant in node_states.values():
		var progress_state := String(progress_state_variant)
		counts[progress_state] = int(counts.get(progress_state, 0)) + 1

	return {"node_states": node_states, "counts": counts, "completed_ids": completed_ids, "selected_id": selected_id}


func _build_cangjie_route_completed_ids(selected_id: String, node_lookup: Dictionary, predecessors: Dictionary) -> Array[String]:
	var completed_ids: Array[String] = []
	var current_id := selected_id
	var safety := 0
	while not current_id.is_empty() and safety < 12:
		completed_ids.push_front(current_id)
		var previous_ids_variant: Variant = predecessors.get(current_id, [])
		if not (previous_ids_variant is Array) or (previous_ids_variant as Array).is_empty():
			break
		current_id = _pick_cangjie_route_progress_predecessor(previous_ids_variant as Array, node_lookup, current_id)
		safety += 1
	return completed_ids


func _pick_cangjie_route_progress_predecessor(previous_ids: Array, node_lookup: Dictionary, current_id: String) -> String:
	var current_node_variant: Variant = node_lookup.get(current_id, {})
	var current_node: Dictionary = current_node_variant as Dictionary if current_node_variant is Dictionary else {}
	var current_lane := String(current_node.get("lane", ""))
	var best_id := ""
	var best_score := -1.0

	for index in range(previous_ids.size()):
		var previous_id := String(previous_ids[index])
		var previous_node_variant: Variant = node_lookup.get(previous_id, {})
		if not (previous_node_variant is Dictionary):
			continue
		var previous_node := previous_node_variant as Dictionary
		var score := 0.0
		if String(previous_node.get("state", "")) == "path":
			score += 5.0
		elif String(previous_node.get("state", "")) == "boss":
			score += 4.0
		if String(previous_node.get("lane", "")) == current_lane:
			score += 2.0
		score += maxf(0.0, 1.0 - float(index) * 0.05)
		if score > best_score:
			best_score = score
			best_id = previous_id

	return best_id


func _make_cangjie_route_ribbon_panel(preview_ribbon: Dictionary, node_ribbon: Dictionary, preview: Dictionary, selected_node: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.74), Color(accent.r, accent.g, accent.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)
	var ribbon_title_source := node_ribbon if not node_ribbon.is_empty() else preview_ribbon
	var ribbon_summary_source := node_ribbon if not node_ribbon.is_empty() else preview_ribbon

	var title_text := _localize_cangjie_text(ribbon_title_source.get("title", preview_ribbon.get("title", "")))
	if not title_text.is_empty():
		box.add_child(_make_label(title_text, 18, Color(1.0, 0.95, 0.86, 1.0)))

	var summary_text := _localize_cangjie_text(ribbon_summary_source.get("summary", preview_ribbon.get("summary", "")))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 14, Color(0.86, 0.9, 0.98, 0.88)))

	var explicit_steps_variant: Variant = node_ribbon.get("steps", [])
	if explicit_steps_variant is Array and not (explicit_steps_variant as Array).is_empty():
		var beat_flow := _make_responsive_box_container(_is_portrait_layout())
		beat_flow.add_theme_constant_override("separation", _i(10))
		box.add_child(beat_flow)

		var explicit_steps := explicit_steps_variant as Array
		for step_index in range(explicit_steps.size()):
			var step_variant: Variant = explicit_steps[step_index]
			if step_variant is Dictionary:
				var beat_step := _make_cangjie_route_ribbon_beat_step(step_variant as Dictionary, accent, step_index)
				beat_step.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				beat_flow.add_child(beat_step)
		return panel

	var steps := _build_cangjie_route_ribbon_steps(preview, selected_node)
	if steps.is_empty():
		return panel

	var ribbon_flow := _make_responsive_box_container(_is_portrait_layout())
	ribbon_flow.add_theme_constant_override("separation", _i(10))
	box.add_child(ribbon_flow)

	for step_index in range(steps.size()):
		var step: Dictionary = steps[step_index]
		var step_tone: Color = step.get("tone", accent)
		var step_card := _make_cangjie_route_ribbon_step(step, step_tone)
		step_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ribbon_flow.add_child(step_card)
		if step_index < steps.size() - 1:
			ribbon_flow.add_child(_make_cangjie_route_ribbon_connector(step_tone))

	return panel


func _make_cangjie_route_ribbon_beat_step(step: Dictionary, accent: Color, step_index: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = _v(0.0, 112.0)

	var weight: float = clampf(1.0 - float(step_index) * 0.08, 0.0, 1.0)
	var fill: float = 0.74 + weight * 0.08
	var border: float = 0.18 + weight * 0.08
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.15, accent.g * 0.15, accent.b * 0.18, fill), Color(accent.r, accent.g, accent.b, border)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(12))
	margin.add_theme_constant_override("margin_top", _i(12))
	margin.add_theme_constant_override("margin_right", _i(12))
	margin.add_theme_constant_override("margin_bottom", _i(12))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(8))
	margin.add_child(box)

	var beat_label := ("第 %d 拍" if not _is_english() else "Beat %d") % (step_index + 1)
	box.add_child(_make_tag(beat_label, Color(accent.r * 0.18, accent.g * 0.18, accent.b * 0.22, 0.9), Color(0.98, 0.94, 0.88, 0.96)))

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", _i(10))
	box.add_child(header)

	var glyph_panel := PanelContainer.new()
	glyph_panel.custom_minimum_size = _v(38.0, 38.0)
	glyph_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.22, accent.g * 0.18, accent.b * 0.16, 0.92), Color(accent.r, accent.g, accent.b, 0.28)))
	header.add_child(glyph_panel)

	var glyph_label := _make_label(String(step.get("glyph", "")), 18, Color(1.0, 0.95, 0.86, 1.0))
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph_panel.add_child(glyph_label)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", _i(3))
	header.add_child(text_box)
	text_box.add_child(_make_label(_localize_cangjie_text(step.get("title", "")), 15, Color(1.0, 0.95, 0.86, 1.0)))

	var subtitle_text := _localize_cangjie_text(step.get("subtitle", ""))
	if not subtitle_text.is_empty():
		text_box.add_child(_make_label(subtitle_text, 13, Color(0.84, 0.9, 0.98, 0.84)))

	return panel


func _make_cangjie_route_ledger_preview(preview: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.78), Color(accent.r, accent.g, accent.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)
	box.add_child(_make_label(_localize_cangjie_text(preview.get("title", "")), 20, Color(1.0, 0.95, 0.86, 1.0)))

	var summary_text := _localize_cangjie_text(preview.get("summary", ""))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 16, Color(0.88, 0.92, 0.96, 0.92)))

	var hint_text := _localize_cangjie_text(preview.get("hint", ""))
	if not hint_text.is_empty():
		box.add_child(_make_label(hint_text, 14, Color(0.82, 0.9, 0.96, 0.86)))

	var options_variant: Variant = preview.get("options", [])
	var selected_option: Dictionary = {}
	if options_variant is Array and not (options_variant as Array).is_empty():
		var options := options_variant as Array
		var option_row: Container
		if _is_portrait_layout():
			var option_grid := GridContainer.new()
			option_grid.columns = 1
			option_grid.add_theme_constant_override("h_separation", _i(10))
			option_grid.add_theme_constant_override("v_separation", _i(10))
			option_row = option_grid
		else:
			var option_box := HBoxContainer.new()
			option_box.add_theme_constant_override("separation", _i(10))
			option_row = option_box
		box.add_child(option_row)

		var first_option := {}
		for option_variant in options:
			if option_variant is Dictionary:
				var option := option_variant as Dictionary
				if first_option.is_empty():
					first_option = option
				option_row.add_child(_make_cangjie_route_ledger_option_button(option, accent))
				if String(option.get("id", "")) == cangjie_route_ledger_choice:
					selected_option = option
		if selected_option.is_empty() and not first_option.is_empty():
			selected_option = first_option
			cangjie_route_ledger_choice = String(first_option.get("id", cangjie_route_ledger_choice))

	if not selected_option.is_empty():
		var selected_tone: Color = selected_option.get("tone", accent)
		var selected_summary := _localize_cangjie_text(selected_option.get("summary", ""))
		if not selected_summary.is_empty():
			box.add_child(_make_label(selected_summary, 15, Color(0.94, 0.92, 0.88, 0.94)))

		var result_group_variant: Variant = selected_option.get("result_group", {})
		if result_group_variant is Dictionary and not (result_group_variant as Dictionary).is_empty():
			box.add_child(_make_cangjie_group_panel(result_group_variant as Dictionary, selected_tone))

	var footnote_text := _localize_cangjie_text(preview.get("footnote", ""))
	if not footnote_text.is_empty():
		box.add_child(_make_label(footnote_text, 14, Color(0.82, 0.9, 0.96, 0.82)))

	return panel


func _make_cangjie_tutor_preview(preview: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.78), Color(accent.r, accent.g, accent.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)
	box.add_child(_make_label(_localize_cangjie_text(preview.get("title", "")), 20, Color(1.0, 0.95, 0.86, 1.0)))

	var summary_text := _localize_cangjie_text(preview.get("summary", ""))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 16, Color(0.88, 0.92, 0.96, 0.92)))

	var hint_text := _localize_cangjie_text(preview.get("hint", ""))
	if not hint_text.is_empty():
		box.add_child(_make_label(hint_text, 14, Color(0.82, 0.9, 0.96, 0.86)))

	var options_variant: Variant = preview.get("options", [])
	var selected_option: Dictionary = {}
	if options_variant is Array and not (options_variant as Array).is_empty():
		var options := options_variant as Array
		var option_row: Container
		if _is_portrait_layout():
			var option_grid := GridContainer.new()
			option_grid.columns = 1
			option_grid.add_theme_constant_override("h_separation", _i(10))
			option_grid.add_theme_constant_override("v_separation", _i(10))
			option_row = option_grid
		else:
			var option_box := HBoxContainer.new()
			option_box.add_theme_constant_override("separation", _i(10))
			option_row = option_box
		box.add_child(option_row)

		var first_option := {}
		for option_variant in options:
			if option_variant is Dictionary:
				var option := option_variant as Dictionary
				if first_option.is_empty():
					first_option = option
				option_row.add_child(_make_cangjie_tutor_option_button(option, accent))
				if String(option.get("id", "")) == cangjie_tutor_choice:
					selected_option = option
		if selected_option.is_empty() and not first_option.is_empty():
			selected_option = first_option
			cangjie_tutor_choice = String(first_option.get("id", cangjie_tutor_choice))

	if not selected_option.is_empty():
		var selected_tone: Color = selected_option.get("tone", accent)
		var selected_summary := _localize_cangjie_text(selected_option.get("summary", ""))
		if not selected_summary.is_empty():
			box.add_child(_make_label(selected_summary, 15, Color(0.94, 0.92, 0.88, 0.94)))

		var result_group_variant: Variant = selected_option.get("result_group", {})
		if result_group_variant is Dictionary and not (result_group_variant as Dictionary).is_empty():
			box.add_child(_make_cangjie_group_panel(result_group_variant as Dictionary, selected_tone))

	var footnote_text := _localize_cangjie_text(preview.get("footnote", ""))
	if not footnote_text.is_empty():
		box.add_child(_make_label(footnote_text, 14, Color(0.82, 0.9, 0.96, 0.82)))

	return panel


func _make_cangjie_reward_chain_preview(preview: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.78), Color(accent.r, accent.g, accent.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)
	box.add_child(_make_label(_localize_cangjie_text(preview.get("title", "")), 20, Color(1.0, 0.95, 0.86, 1.0)))

	var summary_text := _localize_cangjie_text(preview.get("summary", ""))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 16, Color(0.88, 0.92, 0.96, 0.92)))

	var hint_text := _localize_cangjie_text(preview.get("hint", ""))
	if not hint_text.is_empty():
		box.add_child(_make_label(hint_text, 14, Color(0.82, 0.9, 0.96, 0.86)))

	var options_variant: Variant = preview.get("options", [])
	var selected_option: Dictionary = {}
	if options_variant is Array and not (options_variant as Array).is_empty():
		var options := options_variant as Array
		var option_row: Container
		if _is_portrait_layout():
			var option_grid := GridContainer.new()
			option_grid.columns = 1
			option_grid.add_theme_constant_override("h_separation", _i(10))
			option_grid.add_theme_constant_override("v_separation", _i(10))
			option_row = option_grid
		else:
			var option_box := HBoxContainer.new()
			option_box.add_theme_constant_override("separation", _i(10))
			option_row = option_box
		box.add_child(option_row)

		var first_option := {}
		for option_variant in options:
			if option_variant is Dictionary:
				var option := option_variant as Dictionary
				if first_option.is_empty():
					first_option = option
				option_row.add_child(_make_cangjie_reward_chain_option_button(option, accent))
				if String(option.get("id", "")) == cangjie_reward_chain_choice:
					selected_option = option
		if selected_option.is_empty() and not first_option.is_empty():
			selected_option = first_option
			cangjie_reward_chain_choice = String(first_option.get("id", cangjie_reward_chain_choice))

	if not selected_option.is_empty():
		var selected_tone: Color = selected_option.get("tone", accent)
		var selected_summary := _localize_cangjie_text(selected_option.get("summary", ""))
		if not selected_summary.is_empty():
			box.add_child(_make_label(selected_summary, 15, Color(0.94, 0.92, 0.88, 0.94)))

		var result_group_variant: Variant = selected_option.get("result_group", {})
		if result_group_variant is Dictionary and not (result_group_variant as Dictionary).is_empty():
			box.add_child(_make_cangjie_group_panel(result_group_variant as Dictionary, selected_tone))

	var footnote_text := _localize_cangjie_text(preview.get("footnote", ""))
	if not footnote_text.is_empty():
		box.add_child(_make_label(footnote_text, 14, Color(0.82, 0.9, 0.96, 0.82)))

	return panel


func _make_cangjie_rest_preview(preview: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.78), Color(accent.r, accent.g, accent.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)
	box.add_child(_make_label(_localize_cangjie_text(preview.get("title", "")), 20, Color(1.0, 0.95, 0.86, 1.0)))

	var summary_text := _localize_cangjie_text(preview.get("summary", ""))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 16, Color(0.88, 0.92, 0.96, 0.92)))

	var hint_text := _localize_cangjie_text(preview.get("hint", ""))
	if not hint_text.is_empty():
		box.add_child(_make_label(hint_text, 14, Color(0.82, 0.9, 0.96, 0.86)))

	var options_variant: Variant = preview.get("options", [])
	var selected_option: Dictionary = {}
	if options_variant is Array and not (options_variant as Array).is_empty():
		var options := options_variant as Array
		var option_row: Container
		if _is_portrait_layout():
			var option_grid := GridContainer.new()
			option_grid.columns = 1
			option_grid.add_theme_constant_override("h_separation", _i(10))
			option_grid.add_theme_constant_override("v_separation", _i(10))
			option_row = option_grid
		else:
			var option_box := HBoxContainer.new()
			option_box.add_theme_constant_override("separation", _i(10))
			option_row = option_box
		box.add_child(option_row)

		var first_option := {}
		for option_variant in options:
			if option_variant is Dictionary:
				var option := option_variant as Dictionary
				if first_option.is_empty():
					first_option = option
				option_row.add_child(_make_cangjie_rest_option_button(option, accent))
				if String(option.get("id", "")) == cangjie_rest_choice:
					selected_option = option
		if selected_option.is_empty() and not first_option.is_empty():
			selected_option = first_option
			cangjie_rest_choice = String(first_option.get("id", cangjie_rest_choice))

	if not selected_option.is_empty():
		var selected_tone: Color = selected_option.get("tone", accent)
		var selected_summary := _localize_cangjie_text(selected_option.get("summary", ""))
		if not selected_summary.is_empty():
			box.add_child(_make_label(selected_summary, 15, Color(0.94, 0.92, 0.88, 0.94)))

		var result_group_variant: Variant = selected_option.get("result_group", {})
		if result_group_variant is Dictionary and not (result_group_variant as Dictionary).is_empty():
			box.add_child(_make_cangjie_group_panel(result_group_variant as Dictionary, selected_tone))

	var footnote_text := _localize_cangjie_text(preview.get("footnote", ""))
	if not footnote_text.is_empty():
		box.add_child(_make_label(footnote_text, 14, Color(0.82, 0.9, 0.96, 0.82)))

	return panel


func _make_cangjie_archive_preview(preview: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.78), Color(accent.r, accent.g, accent.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)
	box.add_child(_make_label(_localize_cangjie_text(preview.get("title", "")), 20, Color(1.0, 0.95, 0.86, 1.0)))

	var summary_text := _localize_cangjie_text(preview.get("summary", ""))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 16, Color(0.88, 0.92, 0.96, 0.92)))

	var hint_text := _localize_cangjie_text(preview.get("hint", ""))
	if not hint_text.is_empty():
		box.add_child(_make_label(hint_text, 14, Color(0.82, 0.9, 0.96, 0.86)))

	var options_variant: Variant = preview.get("options", [])
	var selected_option: Dictionary = {}
	if options_variant is Array and not (options_variant as Array).is_empty():
		var options := options_variant as Array
		var option_row: Container
		if _is_portrait_layout():
			var option_grid := GridContainer.new()
			option_grid.columns = 1
			option_grid.add_theme_constant_override("h_separation", _i(10))
			option_grid.add_theme_constant_override("v_separation", _i(10))
			option_row = option_grid
		else:
			var option_box := HBoxContainer.new()
			option_box.add_theme_constant_override("separation", _i(10))
			option_row = option_box
		box.add_child(option_row)

		var first_option := {}
		for option_variant in options:
			if option_variant is Dictionary:
				var option := option_variant as Dictionary
				if first_option.is_empty():
					first_option = option
				option_row.add_child(_make_cangjie_archive_option_button(option, accent))
				if String(option.get("id", "")) == cangjie_archive_choice:
					selected_option = option
		if selected_option.is_empty() and not first_option.is_empty():
			selected_option = first_option
			cangjie_archive_choice = String(first_option.get("id", cangjie_archive_choice))

	if not selected_option.is_empty():
		var selected_tone: Color = selected_option.get("tone", accent)
		var selected_summary := _localize_cangjie_text(selected_option.get("summary", ""))
		if not selected_summary.is_empty():
			box.add_child(_make_label(selected_summary, 15, Color(0.94, 0.92, 0.88, 0.94)))

		var result_group_variant: Variant = selected_option.get("result_group", {})
		if result_group_variant is Dictionary and not (result_group_variant as Dictionary).is_empty():
			box.add_child(_make_cangjie_group_panel(result_group_variant as Dictionary, selected_tone))

	var footnote_text := _localize_cangjie_text(preview.get("footnote", ""))
	if not footnote_text.is_empty():
		box.add_child(_make_label(footnote_text, 14, Color(0.82, 0.9, 0.96, 0.82)))

	return panel


func _make_cangjie_treasure_preview(preview: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.78), Color(accent.r, accent.g, accent.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)
	box.add_child(_make_label(_localize_cangjie_text(preview.get("title", "")), 20, Color(1.0, 0.95, 0.86, 1.0)))

	var summary_text := _localize_cangjie_text(preview.get("summary", ""))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 16, Color(0.88, 0.92, 0.96, 0.92)))

	var hint_text := _localize_cangjie_text(preview.get("hint", ""))
	if not hint_text.is_empty():
		box.add_child(_make_label(hint_text, 14, Color(0.82, 0.9, 0.96, 0.86)))

	var options_variant: Variant = preview.get("options", [])
	var selected_option: Dictionary = {}
	if options_variant is Array and not (options_variant as Array).is_empty():
		var options := options_variant as Array
		var option_row: Container
		if _is_portrait_layout():
			var option_grid := GridContainer.new()
			option_grid.columns = 1
			option_grid.add_theme_constant_override("h_separation", _i(10))
			option_grid.add_theme_constant_override("v_separation", _i(10))
			option_row = option_grid
		else:
			var option_box := HBoxContainer.new()
			option_box.add_theme_constant_override("separation", _i(10))
			option_row = option_box
		box.add_child(option_row)

		var first_option := {}
		for option_variant in options:
			if option_variant is Dictionary:
				var option := option_variant as Dictionary
				if first_option.is_empty():
					first_option = option
				option_row.add_child(_make_cangjie_treasure_option_button(option, accent))
				if String(option.get("id", "")) == cangjie_treasure_choice:
					selected_option = option
		if selected_option.is_empty() and not first_option.is_empty():
			selected_option = first_option
			cangjie_treasure_choice = String(first_option.get("id", cangjie_treasure_choice))

	if not selected_option.is_empty():
		var selected_tone: Color = selected_option.get("tone", accent)
		var selected_summary := _localize_cangjie_text(selected_option.get("summary", ""))
		if not selected_summary.is_empty():
			box.add_child(_make_label(selected_summary, 15, Color(0.94, 0.92, 0.88, 0.94)))

		var result_group_variant: Variant = selected_option.get("result_group", {})
		if result_group_variant is Dictionary and not (result_group_variant as Dictionary).is_empty():
			box.add_child(_make_cangjie_group_panel(result_group_variant as Dictionary, selected_tone))

	var footnote_text := _localize_cangjie_text(preview.get("footnote", ""))
	if not footnote_text.is_empty():
		box.add_child(_make_label(footnote_text, 14, Color(0.82, 0.9, 0.96, 0.82)))

	return panel


func _make_cangjie_shop_preview(preview: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.78), Color(accent.r, accent.g, accent.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)
	box.add_child(_make_label(_localize_cangjie_text(preview.get("title", "")), 20, Color(1.0, 0.95, 0.86, 1.0)))

	var summary_text := _localize_cangjie_text(preview.get("summary", ""))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 16, Color(0.88, 0.92, 0.96, 0.92)))

	var hint_text := _localize_cangjie_text(preview.get("hint", ""))
	if not hint_text.is_empty():
		box.add_child(_make_label(hint_text, 14, Color(0.82, 0.9, 0.96, 0.86)))

	var options_variant: Variant = preview.get("options", [])
	var selected_option: Dictionary = {}
	if options_variant is Array and not (options_variant as Array).is_empty():
		var options := options_variant as Array
		var option_row: Container
		if _is_portrait_layout():
			var option_grid := GridContainer.new()
			option_grid.columns = 1
			option_grid.add_theme_constant_override("h_separation", _i(10))
			option_grid.add_theme_constant_override("v_separation", _i(10))
			option_row = option_grid
		else:
			var option_box := HBoxContainer.new()
			option_box.add_theme_constant_override("separation", _i(10))
			option_row = option_box
		box.add_child(option_row)

		var first_option := {}
		for option_variant in options:
			if option_variant is Dictionary:
				var option := option_variant as Dictionary
				if first_option.is_empty():
					first_option = option
				option_row.add_child(_make_cangjie_shop_option_button(option, accent))
				if String(option.get("id", "")) == cangjie_shop_choice:
					selected_option = option
		if selected_option.is_empty() and not first_option.is_empty():
			selected_option = first_option
			cangjie_shop_choice = String(first_option.get("id", cangjie_shop_choice))

	if not selected_option.is_empty():
		var selected_tone: Color = selected_option.get("tone", accent)
		var selected_summary := _localize_cangjie_text(selected_option.get("summary", ""))
		if not selected_summary.is_empty():
			box.add_child(_make_label(selected_summary, 15, Color(0.94, 0.92, 0.88, 0.94)))

		var result_group_variant: Variant = selected_option.get("result_group", {})
		if result_group_variant is Dictionary and not (result_group_variant as Dictionary).is_empty():
			box.add_child(_make_cangjie_group_panel(result_group_variant as Dictionary, selected_tone))

	var footnote_text := _localize_cangjie_text(preview.get("footnote", ""))
	if not footnote_text.is_empty():
		box.add_child(_make_label(footnote_text, 14, Color(0.82, 0.9, 0.96, 0.82)))

	return panel


func _make_cangjie_broker_preview(preview: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.78), Color(accent.r, accent.g, accent.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)
	box.add_child(_make_label(_localize_cangjie_text(preview.get("title", "")), 20, Color(1.0, 0.95, 0.86, 1.0)))

	var summary_text := _localize_cangjie_text(preview.get("summary", ""))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 16, Color(0.88, 0.92, 0.96, 0.92)))

	var hint_text := _localize_cangjie_text(preview.get("hint", ""))
	if not hint_text.is_empty():
		box.add_child(_make_label(hint_text, 14, Color(0.82, 0.9, 0.96, 0.86)))

	var options_variant: Variant = preview.get("options", [])
	var selected_option: Dictionary = {}
	if options_variant is Array and not (options_variant as Array).is_empty():
		var options := options_variant as Array
		var option_row: Container
		if _is_portrait_layout():
			var option_grid := GridContainer.new()
			option_grid.columns = 1
			option_grid.add_theme_constant_override("h_separation", _i(10))
			option_grid.add_theme_constant_override("v_separation", _i(10))
			option_row = option_grid
		else:
			var option_box := HBoxContainer.new()
			option_box.add_theme_constant_override("separation", _i(10))
			option_row = option_box
		box.add_child(option_row)

		var first_option := {}
		for option_variant in options:
			if option_variant is Dictionary:
				var option := option_variant as Dictionary
				if first_option.is_empty():
					first_option = option
				option_row.add_child(_make_cangjie_broker_option_button(option, accent))
				if String(option.get("id", "")) == cangjie_broker_choice:
					selected_option = option
		if selected_option.is_empty() and not first_option.is_empty():
			selected_option = first_option
			cangjie_broker_choice = String(first_option.get("id", cangjie_broker_choice))

	if not selected_option.is_empty():
		var selected_tone: Color = selected_option.get("tone", accent)
		var selected_summary := _localize_cangjie_text(selected_option.get("summary", ""))
		if not selected_summary.is_empty():
			box.add_child(_make_label(selected_summary, 15, Color(0.94, 0.92, 0.88, 0.94)))

		var result_group_variant: Variant = selected_option.get("result_group", {})
		if result_group_variant is Dictionary and not (result_group_variant as Dictionary).is_empty():
			box.add_child(_make_cangjie_group_panel(result_group_variant as Dictionary, selected_tone))

	var footnote_text := _localize_cangjie_text(preview.get("footnote", ""))
	if not footnote_text.is_empty():
		box.add_child(_make_label(footnote_text, 14, Color(0.82, 0.9, 0.96, 0.82)))

	return panel


func _make_cangjie_rest_option_button(option: Dictionary, accent: Color) -> Button:
	var option_id := String(option.get("id", ""))
	var tone: Color = option.get("tone", accent)
	var active := option_id == cangjie_rest_choice

	var button := Button.new()
	button.text = ""
	button.flat = true
	button.clip_contents = false
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = _v(0.0, 136.0)

	var border_strength := 0.42 if active else 0.22
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(tone.r * 0.16, tone.g * 0.16, tone.b * 0.18, 0.8), Color(tone.r, tone.g, tone.b, border_strength)))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.88), Color(tone.r, tone.g, tone.b, 0.5 if active else 0.3)))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(tone.r * 0.2, tone.g * 0.2, tone.b * 0.22, 0.92), Color(tone.r, tone.g, tone.b, 0.58 if active else 0.36)))

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", _i(14))
	margin.add_theme_constant_override("margin_top", _i(12))
	margin.add_theme_constant_override("margin_right", _i(14))
	margin.add_theme_constant_override("margin_bottom", _i(12))
	button.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(8))
	margin.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", _i(10))
	box.add_child(header)

	var glyph_panel := PanelContainer.new()
	glyph_panel.custom_minimum_size = _v(46.0, 46.0)
	glyph_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.22, tone.g * 0.18, tone.b * 0.16, 0.92), Color(tone.r, tone.g, tone.b, 0.3)))
	header.add_child(glyph_panel)

	var glyph_label := _make_label(String(option.get("glyph", "")), 22, Color(1.0, 0.95, 0.86, 1.0))
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph_panel.add_child(glyph_label)

	var heading_box := VBoxContainer.new()
	heading_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading_box.add_theme_constant_override("separation", _i(3))
	header.add_child(heading_box)
	heading_box.add_child(_make_label(_localize_cangjie_text(option.get("title", "")), 16, Color(1.0, 0.95, 0.86, 1.0)))

	var subtitle_text := _localize_cangjie_text(option.get("subtitle", ""))
	if not subtitle_text.is_empty():
		heading_box.add_child(_make_label(subtitle_text, 13, Color(0.86, 0.9, 0.98, 0.84)))

	if active:
		box.add_child(_make_tag("当前模式" if not _is_english() else "Active Mode", Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.9), Color(0.98, 0.94, 0.88, 0.96)))

	button.pressed.connect(Callable(self, "_on_select_cangjie_rest_option").bind(option_id))
	return button


func _make_cangjie_archive_option_button(option: Dictionary, accent: Color) -> Button:
	var option_id := String(option.get("id", ""))
	var tone: Color = option.get("tone", accent)
	var active := option_id == cangjie_archive_choice

	var button := Button.new()
	button.text = ""
	button.flat = true
	button.clip_contents = false
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = _v(0.0, 136.0)

	var border_strength := 0.42 if active else 0.22
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(tone.r * 0.16, tone.g * 0.16, tone.b * 0.18, 0.8), Color(tone.r, tone.g, tone.b, border_strength)))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.88), Color(tone.r, tone.g, tone.b, 0.5 if active else 0.3)))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(tone.r * 0.2, tone.g * 0.2, tone.b * 0.22, 0.92), Color(tone.r, tone.g, tone.b, 0.58 if active else 0.36)))

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", _i(14))
	margin.add_theme_constant_override("margin_top", _i(12))
	margin.add_theme_constant_override("margin_right", _i(14))
	margin.add_theme_constant_override("margin_bottom", _i(12))
	button.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(8))
	margin.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", _i(10))
	box.add_child(header)

	var glyph_panel := PanelContainer.new()
	glyph_panel.custom_minimum_size = _v(46.0, 46.0)
	glyph_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.22, tone.g * 0.18, tone.b * 0.16, 0.92), Color(tone.r, tone.g, tone.b, 0.3)))
	header.add_child(glyph_panel)

	var glyph_label := _make_label(String(option.get("glyph", "")), 22, Color(1.0, 0.95, 0.86, 1.0))
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph_panel.add_child(glyph_label)

	var heading_box := VBoxContainer.new()
	heading_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading_box.add_theme_constant_override("separation", _i(3))
	header.add_child(heading_box)
	heading_box.add_child(_make_label(_localize_cangjie_text(option.get("title", "")), 16, Color(1.0, 0.95, 0.86, 1.0)))

	var subtitle_text := _localize_cangjie_text(option.get("subtitle", ""))
	if not subtitle_text.is_empty():
		heading_box.add_child(_make_label(subtitle_text, 13, Color(0.86, 0.9, 0.98, 0.84)))

	if active:
		box.add_child(_make_tag("当前模式" if not _is_english() else "Active Mode", Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.9), Color(0.98, 0.94, 0.88, 0.96)))

	button.pressed.connect(Callable(self, "_on_select_cangjie_archive_option").bind(option_id))
	return button

func _make_cangjie_margin_preview(preview: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.78), Color(accent.r, accent.g, accent.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)
	box.add_child(_make_label(_localize_cangjie_text(preview.get("title", "")), 20, Color(1.0, 0.95, 0.86, 1.0)))

	var summary_text := _localize_cangjie_text(preview.get("summary", ""))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 16, Color(0.88, 0.92, 0.96, 0.92)))

	var hint_text := _localize_cangjie_text(preview.get("hint", ""))
	if not hint_text.is_empty():
		box.add_child(_make_label(hint_text, 14, Color(0.82, 0.9, 0.96, 0.86)))

	var options_variant: Variant = preview.get("options", [])
	var selected_option: Dictionary = {}
	if options_variant is Array and not (options_variant as Array).is_empty():
		var options := options_variant as Array
		var option_row: Container
		if _is_portrait_layout():
			var option_grid := GridContainer.new()
			option_grid.columns = 1
			option_grid.add_theme_constant_override("h_separation", _i(10))
			option_grid.add_theme_constant_override("v_separation", _i(10))
			option_row = option_grid
		else:
			var option_box := HBoxContainer.new()
			option_box.add_theme_constant_override("separation", _i(10))
			option_row = option_box
		box.add_child(option_row)

		var first_option := {}
		for option_variant in options:
			if option_variant is Dictionary:
				var option := option_variant as Dictionary
				if first_option.is_empty():
					first_option = option
				option_row.add_child(_make_cangjie_margin_option_button(option, accent))
				if String(option.get("id", "")) == cangjie_margin_choice:
					selected_option = option
		if selected_option.is_empty() and not first_option.is_empty():
			selected_option = first_option
			cangjie_margin_choice = String(first_option.get("id", cangjie_margin_choice))

	if not selected_option.is_empty():
		var selected_tone: Color = selected_option.get("tone", accent)
		var selected_summary := _localize_cangjie_text(selected_option.get("summary", ""))
		if not selected_summary.is_empty():
			box.add_child(_make_label(selected_summary, 15, Color(0.94, 0.92, 0.88, 0.94)))

		var result_group_variant: Variant = selected_option.get("result_group", {})
		if result_group_variant is Dictionary and not (result_group_variant as Dictionary).is_empty():
			box.add_child(_make_cangjie_group_panel(result_group_variant as Dictionary, selected_tone))

	var footnote_text := _localize_cangjie_text(preview.get("footnote", ""))
	if not footnote_text.is_empty():
		box.add_child(_make_label(footnote_text, 14, Color(0.82, 0.9, 0.96, 0.82)))

	return panel


func _make_cangjie_treasure_option_button(option: Dictionary, accent: Color) -> Button:
	var option_id := String(option.get("id", ""))
	var tone: Color = option.get("tone", accent)
	var active := option_id == cangjie_treasure_choice

	var button := Button.new()
	button.text = ""
	button.flat = true
	button.clip_contents = false
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = _v(0.0, 136.0)

	var border_strength := 0.42 if active else 0.22
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(tone.r * 0.16, tone.g * 0.16, tone.b * 0.18, 0.8), Color(tone.r, tone.g, tone.b, border_strength)))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.88), Color(tone.r, tone.g, tone.b, 0.5 if active else 0.3)))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(tone.r * 0.2, tone.g * 0.2, tone.b * 0.22, 0.92), Color(tone.r, tone.g, tone.b, 0.58 if active else 0.36)))

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", _i(14))
	margin.add_theme_constant_override("margin_top", _i(12))
	margin.add_theme_constant_override("margin_right", _i(14))
	margin.add_theme_constant_override("margin_bottom", _i(12))
	button.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(8))
	margin.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", _i(10))
	box.add_child(header)

	var glyph_panel := PanelContainer.new()
	glyph_panel.custom_minimum_size = _v(46.0, 46.0)
	glyph_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.22, tone.g * 0.18, tone.b * 0.16, 0.92), Color(tone.r, tone.g, tone.b, 0.3)))
	header.add_child(glyph_panel)

	var glyph_label := _make_label(String(option.get("glyph", "")), 22, Color(1.0, 0.95, 0.86, 1.0))
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph_panel.add_child(glyph_label)

	var heading_box := VBoxContainer.new()
	heading_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading_box.add_theme_constant_override("separation", _i(3))
	header.add_child(heading_box)
	heading_box.add_child(_make_label(_localize_cangjie_text(option.get("title", "")), 16, Color(1.0, 0.95, 0.86, 1.0)))

	var subtitle_text := _localize_cangjie_text(option.get("subtitle", ""))
	if not subtitle_text.is_empty():
		heading_box.add_child(_make_label(subtitle_text, 13, Color(0.86, 0.9, 0.98, 0.84)))

	if active:
		box.add_child(_make_tag("当前遗物" if not _is_english() else "Active Relic", Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.9), Color(0.98, 0.94, 0.88, 0.96)))

	button.pressed.connect(Callable(self, "_on_select_cangjie_treasure_option").bind(option_id))
	return button


func _make_cangjie_shop_option_button(option: Dictionary, accent: Color) -> Button:
	var option_id := String(option.get("id", ""))
	var tone: Color = option.get("tone", accent)
	var active := option_id == cangjie_shop_choice

	var button := Button.new()
	button.text = ""
	button.flat = true
	button.clip_contents = false
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = _v(0.0, 136.0)

	var border_strength := 0.42 if active else 0.22
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(tone.r * 0.16, tone.g * 0.16, tone.b * 0.18, 0.8), Color(tone.r, tone.g, tone.b, border_strength)))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.88), Color(tone.r, tone.g, tone.b, 0.5 if active else 0.3)))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(tone.r * 0.2, tone.g * 0.2, tone.b * 0.22, 0.92), Color(tone.r, tone.g, tone.b, 0.58 if active else 0.36)))

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", _i(14))
	margin.add_theme_constant_override("margin_top", _i(12))
	margin.add_theme_constant_override("margin_right", _i(14))
	margin.add_theme_constant_override("margin_bottom", _i(12))
	button.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(8))
	margin.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", _i(10))
	box.add_child(header)

	var glyph_panel := PanelContainer.new()
	glyph_panel.custom_minimum_size = _v(46.0, 46.0)
	glyph_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.22, tone.g * 0.18, tone.b * 0.16, 0.92), Color(tone.r, tone.g, tone.b, 0.3)))
	header.add_child(glyph_panel)

	var glyph_label := _make_label(String(option.get("glyph", "")), 22, Color(1.0, 0.95, 0.86, 1.0))
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph_panel.add_child(glyph_label)

	var heading_box := VBoxContainer.new()
	heading_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading_box.add_theme_constant_override("separation", _i(3))
	header.add_child(heading_box)
	heading_box.add_child(_make_label(_localize_cangjie_text(option.get("title", "")), 16, Color(1.0, 0.95, 0.86, 1.0)))

	var subtitle_text := _localize_cangjie_text(option.get("subtitle", ""))
	if not subtitle_text.is_empty():
		heading_box.add_child(_make_label(subtitle_text, 13, Color(0.86, 0.9, 0.98, 0.84)))

	if active:
		box.add_child(_make_tag("当前货架" if not _is_english() else "Active Shelf", Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.9), Color(0.98, 0.94, 0.88, 0.96)))

	button.pressed.connect(Callable(self, "_on_select_cangjie_shop_option").bind(option_id))
	return button


func _make_cangjie_route_ledger_option_button(option: Dictionary, accent: Color) -> Button:
	var option_id := String(option.get("id", ""))
	var tone: Color = option.get("tone", accent)
	var active := option_id == cangjie_route_ledger_choice

	var button := Button.new()
	button.text = ""
	button.flat = true
	button.clip_contents = false
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = _v(0.0, 136.0)

	var border_strength := 0.42 if active else 0.22
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(tone.r * 0.16, tone.g * 0.16, tone.b * 0.18, 0.8), Color(tone.r, tone.g, tone.b, border_strength)))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.88), Color(tone.r, tone.g, tone.b, 0.5 if active else 0.3)))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(tone.r * 0.2, tone.g * 0.2, tone.b * 0.22, 0.92), Color(tone.r, tone.g, tone.b, 0.58 if active else 0.36)))

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", _i(14))
	margin.add_theme_constant_override("margin_top", _i(12))
	margin.add_theme_constant_override("margin_right", _i(14))
	margin.add_theme_constant_override("margin_bottom", _i(12))
	button.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(8))
	margin.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", _i(10))
	box.add_child(header)

	var glyph_panel := PanelContainer.new()
	glyph_panel.custom_minimum_size = _v(46.0, 46.0)
	glyph_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.22, tone.g * 0.18, tone.b * 0.16, 0.92), Color(tone.r, tone.g, tone.b, 0.3)))
	header.add_child(glyph_panel)

	var glyph_label := _make_label(String(option.get("glyph", "")), 22, Color(1.0, 0.95, 0.86, 1.0))
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph_panel.add_child(glyph_label)

	var heading_box := VBoxContainer.new()
	heading_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading_box.add_theme_constant_override("separation", _i(3))
	header.add_child(heading_box)
	heading_box.add_child(_make_label(_localize_cangjie_text(option.get("title", "")), 16, Color(1.0, 0.95, 0.86, 1.0)))

	var subtitle_text := _localize_cangjie_text(option.get("subtitle", ""))
	if not subtitle_text.is_empty():
		heading_box.add_child(_make_label(subtitle_text, 13, Color(0.86, 0.9, 0.98, 0.84)))

	if active:
		box.add_child(_make_tag("当前预览" if not _is_english() else "Active Preview", Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.9), Color(0.98, 0.94, 0.88, 0.96)))

	button.pressed.connect(Callable(self, "_on_select_cangjie_route_ledger_option").bind(option_id))
	return button


func _make_cangjie_tutor_option_button(option: Dictionary, accent: Color) -> Button:
	var option_id := String(option.get("id", ""))
	var tone: Color = option.get("tone", accent)
	var active := option_id == cangjie_tutor_choice

	var button := Button.new()
	button.text = ""
	button.flat = true
	button.clip_contents = false
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = _v(0.0, 136.0)

	var border_strength := 0.42 if active else 0.22
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(tone.r * 0.16, tone.g * 0.16, tone.b * 0.18, 0.8), Color(tone.r, tone.g, tone.b, border_strength)))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.88), Color(tone.r, tone.g, tone.b, 0.5 if active else 0.3)))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(tone.r * 0.2, tone.g * 0.2, tone.b * 0.22, 0.92), Color(tone.r, tone.g, tone.b, 0.58 if active else 0.36)))

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", _i(14))
	margin.add_theme_constant_override("margin_top", _i(12))
	margin.add_theme_constant_override("margin_right", _i(14))
	margin.add_theme_constant_override("margin_bottom", _i(12))
	button.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(8))
	margin.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", _i(10))
	box.add_child(header)

	var glyph_panel := PanelContainer.new()
	glyph_panel.custom_minimum_size = _v(46.0, 46.0)
	glyph_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.22, tone.g * 0.18, tone.b * 0.16, 0.92), Color(tone.r, tone.g, tone.b, 0.3)))
	header.add_child(glyph_panel)

	var glyph_label := _make_label(String(option.get("glyph", "")), 22, Color(1.0, 0.95, 0.86, 1.0))
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph_panel.add_child(glyph_label)

	var heading_box := VBoxContainer.new()
	heading_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading_box.add_theme_constant_override("separation", _i(3))
	header.add_child(heading_box)
	heading_box.add_child(_make_label(_localize_cangjie_text(option.get("title", "")), 16, Color(1.0, 0.95, 0.86, 1.0)))

	var subtitle_text := _localize_cangjie_text(option.get("subtitle", ""))
	if not subtitle_text.is_empty():
		heading_box.add_child(_make_label(subtitle_text, 13, Color(0.86, 0.9, 0.98, 0.84)))

	if active:
		box.add_child(_make_tag("当前预览" if not _is_english() else "Active Preview", Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.9), Color(0.98, 0.94, 0.88, 0.96)))

	button.pressed.connect(Callable(self, "_on_select_cangjie_tutor_option").bind(option_id))
	return button


func _make_cangjie_broker_option_button(option: Dictionary, accent: Color) -> Button:
	var option_id := String(option.get("id", ""))
	var tone: Color = option.get("tone", accent)
	var active := option_id == cangjie_broker_choice

	var button := Button.new()
	button.text = ""
	button.flat = true
	button.clip_contents = false
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = _v(0.0, 136.0)

	var border_strength := 0.42 if active else 0.22
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(tone.r * 0.16, tone.g * 0.16, tone.b * 0.18, 0.8), Color(tone.r, tone.g, tone.b, border_strength)))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.88), Color(tone.r, tone.g, tone.b, 0.5 if active else 0.3)))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(tone.r * 0.2, tone.g * 0.2, tone.b * 0.22, 0.92), Color(tone.r, tone.g, tone.b, 0.58 if active else 0.36)))

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", _i(14))
	margin.add_theme_constant_override("margin_top", _i(12))
	margin.add_theme_constant_override("margin_right", _i(14))
	margin.add_theme_constant_override("margin_bottom", _i(12))
	button.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(8))
	margin.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", _i(10))
	box.add_child(header)

	var glyph_panel := PanelContainer.new()
	glyph_panel.custom_minimum_size = _v(46.0, 46.0)
	glyph_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.22, tone.g * 0.18, tone.b * 0.16, 0.92), Color(tone.r, tone.g, tone.b, 0.3)))
	header.add_child(glyph_panel)

	var glyph_label := _make_label(String(option.get("glyph", "")), 22, Color(1.0, 0.95, 0.86, 1.0))
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph_panel.add_child(glyph_label)

	var heading_box := VBoxContainer.new()
	heading_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading_box.add_theme_constant_override("separation", _i(3))
	header.add_child(heading_box)
	heading_box.add_child(_make_label(_localize_cangjie_text(option.get("title", "")), 16, Color(1.0, 0.95, 0.86, 1.0)))

	var subtitle_text := _localize_cangjie_text(option.get("subtitle", ""))
	if not subtitle_text.is_empty():
		heading_box.add_child(_make_label(subtitle_text, 13, Color(0.86, 0.9, 0.98, 0.84)))

	if active:
		box.add_child(_make_tag("当前交易" if not _is_english() else "Active Offer", Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.9), Color(0.98, 0.94, 0.88, 0.96)))

	button.pressed.connect(Callable(self, "_on_select_cangjie_broker_option").bind(option_id))
	return button


func _make_cangjie_margin_option_button(option: Dictionary, accent: Color) -> Button:
	var option_id := String(option.get("id", ""))
	var tone: Color = option.get("tone", accent)
	var active := option_id == cangjie_margin_choice

	var button := Button.new()
	button.text = ""
	button.flat = true
	button.clip_contents = false
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = _v(0.0, 136.0)

	var border_strength := 0.42 if active else 0.22
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(tone.r * 0.16, tone.g * 0.16, tone.b * 0.18, 0.8), Color(tone.r, tone.g, tone.b, border_strength)))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.88), Color(tone.r, tone.g, tone.b, 0.5 if active else 0.3)))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(tone.r * 0.2, tone.g * 0.2, tone.b * 0.22, 0.92), Color(tone.r, tone.g, tone.b, 0.58 if active else 0.36)))

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", _i(14))
	margin.add_theme_constant_override("margin_top", _i(12))
	margin.add_theme_constant_override("margin_right", _i(14))
	margin.add_theme_constant_override("margin_bottom", _i(12))
	button.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(8))
	margin.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", _i(10))
	box.add_child(header)

	var glyph_panel := PanelContainer.new()
	glyph_panel.custom_minimum_size = _v(46.0, 46.0)
	glyph_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.22, tone.g * 0.18, tone.b * 0.16, 0.92), Color(tone.r, tone.g, tone.b, 0.3)))
	header.add_child(glyph_panel)

	var glyph_label := _make_label(String(option.get("glyph", "")), 22, Color(1.0, 0.95, 0.86, 1.0))
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph_panel.add_child(glyph_label)

	var heading_box := VBoxContainer.new()
	heading_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading_box.add_theme_constant_override("separation", _i(3))
	header.add_child(heading_box)
	heading_box.add_child(_make_label(_localize_cangjie_text(option.get("title", "")), 16, Color(1.0, 0.95, 0.86, 1.0)))

	var subtitle_text := _localize_cangjie_text(option.get("subtitle", ""))
	if not subtitle_text.is_empty():
		heading_box.add_child(_make_label(subtitle_text, 13, Color(0.86, 0.9, 0.98, 0.84)))

	if active:
		box.add_child(_make_tag("当前赌约" if not _is_english() else "Active Wager", Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.9), Color(0.98, 0.94, 0.88, 0.96)))

	button.pressed.connect(Callable(self, "_on_select_cangjie_margin_option").bind(option_id))
	return button


func _make_cangjie_reward_chain_option_button(option: Dictionary, accent: Color) -> Button:
	var option_id := String(option.get("id", ""))
	var tone: Color = option.get("tone", accent)
	var active := option_id == cangjie_reward_chain_choice

	var button := Button.new()
	button.text = ""
	button.flat = true
	button.clip_contents = false
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = _v(0.0, 136.0)

	var border_strength := 0.42 if active else 0.22
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(tone.r * 0.16, tone.g * 0.16, tone.b * 0.18, 0.8), Color(tone.r, tone.g, tone.b, border_strength)))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.88), Color(tone.r, tone.g, tone.b, 0.5 if active else 0.3)))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(tone.r * 0.2, tone.g * 0.2, tone.b * 0.22, 0.92), Color(tone.r, tone.g, tone.b, 0.58 if active else 0.36)))

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", _i(14))
	margin.add_theme_constant_override("margin_top", _i(12))
	margin.add_theme_constant_override("margin_right", _i(14))
	margin.add_theme_constant_override("margin_bottom", _i(12))
	button.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(8))
	margin.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", _i(10))
	box.add_child(header)

	var glyph_panel := PanelContainer.new()
	glyph_panel.custom_minimum_size = _v(46.0, 46.0)
	glyph_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.22, tone.g * 0.18, tone.b * 0.16, 0.92), Color(tone.r, tone.g, tone.b, 0.3)))
	header.add_child(glyph_panel)

	var glyph_label := _make_label(String(option.get("glyph", "")), 22, Color(1.0, 0.95, 0.86, 1.0))
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph_panel.add_child(glyph_label)

	var heading_box := VBoxContainer.new()
	heading_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading_box.add_theme_constant_override("separation", _i(3))
	header.add_child(heading_box)
	heading_box.add_child(_make_label(_localize_cangjie_text(option.get("title", "")), 16, Color(1.0, 0.95, 0.86, 1.0)))

	var subtitle_text := _localize_cangjie_text(option.get("subtitle", ""))
	if not subtitle_text.is_empty():
		heading_box.add_child(_make_label(subtitle_text, 13, Color(0.86, 0.9, 0.98, 0.84)))

	if active:
		box.add_child(_make_tag("当前链路" if not _is_english() else "Active Chain", Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.9), Color(0.98, 0.94, 0.88, 0.96)))

	button.pressed.connect(Callable(self, "_on_select_cangjie_reward_chain_option").bind(option_id))
	return button


func _make_cangjie_route_row(row: Dictionary, accent: Color, focused_node_id: String, focused_lane: String, node_lookup: Dictionary, state_legend: Dictionary, progress_states: Dictionary) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.06, accent.g * 0.08, accent.b * 0.1, 0.7), Color(accent.r, accent.g, accent.b, 0.22)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(14))
	margin.add_theme_constant_override("margin_top", _i(12))
	margin.add_theme_constant_override("margin_right", _i(14))
	margin.add_theme_constant_override("margin_bottom", _i(12))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(8))
	margin.add_child(box)
	box.add_child(_make_label(_localize_cangjie_text(row.get("floor", "")), 15, Color(0.84, 0.9, 0.98, 0.92)))

	var node_row := HBoxContainer.new()
	node_row.add_theme_constant_override("separation", _i(10))
	box.add_child(node_row)

	var nodes_variant: Variant = row.get("nodes", [])
	if nodes_variant is Array:
		var nodes := nodes_variant as Array
		if nodes.size() == 1 and not _is_portrait_layout():
			var left_spacer := Control.new()
			left_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			node_row.add_child(left_spacer)
		for node_variant in nodes:
			if node_variant is Dictionary:
				var node := node_variant as Dictionary
				var node_id := String(node.get("id", ""))
				var lane_id := String(node.get("lane", ""))
				var progress_state := String(progress_states.get(node_id, "locked"))
				var node_button := _make_cangjie_route_node_card(node, accent, node_id == focused_node_id, not focused_lane.is_empty() and lane_id == focused_lane, state_legend, progress_state)
				node_row.add_child(node_button)
				if not node_id.is_empty():
					node_lookup[node_id] = node_button
		if nodes.size() == 1 and not _is_portrait_layout():
			var right_spacer := Control.new()
			right_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			node_row.add_child(right_spacer)

	return panel


func _build_cangjie_route_links(preview: Dictionary, progress_states: Dictionary = {}) -> Array[Dictionary]:
	var rows_variant: Variant = preview.get("rows", [])
	var links: Array[Dictionary] = []
	if not (rows_variant is Array):
		return links

	var node_lookup := {}
	for row_variant in rows_variant:
		if not (row_variant is Dictionary):
			continue
		var nodes_variant: Variant = (row_variant as Dictionary).get("nodes", [])
		if not (nodes_variant is Array):
			continue
		for node_variant in nodes_variant:
			if node_variant is Dictionary:
				var node := node_variant as Dictionary
				var node_id := String(node.get("id", ""))
				if not node_id.is_empty():
					node_lookup[node_id] = node

	for row_variant in rows_variant:
		if not (row_variant is Dictionary):
			continue
		var nodes_variant: Variant = (row_variant as Dictionary).get("nodes", [])
		if not (nodes_variant is Array):
			continue
		for node_variant in nodes_variant:
			if not (node_variant is Dictionary):
				continue
			var node := node_variant as Dictionary
			var from_id := String(node.get("id", ""))
			var connections_variant: Variant = node.get("connections", [])
			if from_id.is_empty() or not (connections_variant is Array):
				continue
			for connection_variant in connections_variant:
				var to_id := String(connection_variant)
				var target_node: Dictionary = node_lookup.get(to_id, {})
				if target_node.is_empty():
					continue
				var from_progress_state := String(progress_states.get(from_id, "locked"))
				var to_progress_state := String(progress_states.get(to_id, "locked"))
				var progress_state := "locked"
				if from_progress_state == "completed" and to_progress_state == "completed":
					progress_state = "completed"
				elif to_progress_state == "available" or from_progress_state == "available":
					progress_state = "available"
				links.append({
					"from_id": from_id,
					"to_id": to_id,
					"from_lane": String(node.get("lane", "")),
					"to_lane": String(target_node.get("lane", "")),
					"tone": node.get("tone", Color.WHITE),
					"state": String(node.get("state", "option")),
					"progress_state": progress_state
				})

	return links


func _sync_cangjie_route_link_layer(link_layer: Control, node_lookup: Dictionary, route_links: Array[Dictionary], focused_node_id: String, focused_lane: String, accent: Color) -> void:
	if link_layer == null or not is_instance_valid(link_layer):
		return
	link_layer.call("set_route_data", node_lookup, route_links, focused_node_id, focused_lane, accent)


func _build_cangjie_route_ribbon_steps(preview: Dictionary, selected_node: Dictionary) -> Array[Dictionary]:
	var selected_id := String(selected_node.get("id", ""))
	var rows_variant: Variant = preview.get("rows", [])
	var steps: Array[Dictionary] = []
	if not (rows_variant is Array):
		return steps

	for row_variant in rows_variant:
		if not (row_variant is Dictionary):
			continue
		var row := row_variant as Dictionary
		var nodes_variant: Variant = row.get("nodes", [])
		if not (nodes_variant is Array):
			continue

		var chosen_node: Dictionary = {}
		for node_variant in nodes_variant:
			if node_variant is Dictionary and String((node_variant as Dictionary).get("id", "")) == selected_id:
				chosen_node = node_variant as Dictionary
				break

		if chosen_node.is_empty():
			for node_variant in nodes_variant:
				if node_variant is Dictionary:
					var node := node_variant as Dictionary
					var state := String(node.get("state", "option"))
					if state == "path" or state == "boss":
						chosen_node = node
						break

		if chosen_node.is_empty():
			for node_variant in nodes_variant:
				if node_variant is Dictionary:
					chosen_node = node_variant as Dictionary
					break

		if chosen_node.is_empty():
			continue

		steps.append({
			"floor": row.get("floor", {}),
			"id": chosen_node.get("id", ""),
			"lane": chosen_node.get("lane", ""),
			"glyph": chosen_node.get("glyph", ""),
			"label": chosen_node.get("label", ""),
			"note": chosen_node.get("note", ""),
			"tone": chosen_node.get("tone", Color.WHITE),
			"active": String(chosen_node.get("id", "")) == selected_id
		})

	return steps


func _make_cangjie_route_ribbon_step(step: Dictionary, accent: Color) -> PanelContainer:
	var tone: Color = step.get("tone", accent)
	var active := bool(step.get("active", false))
	var fill_alpha := 0.24 if active else 0.14
	var border_alpha := 0.46 if active else 0.24

	var panel := PanelContainer.new()
	panel.custom_minimum_size = _v(0.0, 116.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.16, tone.g * 0.16, tone.b * 0.18, 0.78 + fill_alpha * 0.2), Color(tone.r, tone.g, tone.b, border_alpha)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(14))
	margin.add_theme_constant_override("margin_top", _i(12))
	margin.add_theme_constant_override("margin_right", _i(14))
	margin.add_theme_constant_override("margin_bottom", _i(12))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(6))
	margin.add_child(box)

	box.add_child(_make_label(_localize_cangjie_text(step.get("floor", "")), 13, Color(0.82, 0.9, 0.98, 0.82)))

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", _i(10))
	box.add_child(header)

	var glyph_panel := PanelContainer.new()
	glyph_panel.custom_minimum_size = _v(40.0, 40.0)
	glyph_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.22, tone.g * 0.18, tone.b * 0.16, 0.92), Color(tone.r, tone.g, tone.b, 0.3)))
	header.add_child(glyph_panel)

	var glyph_label := _make_label(String(step.get("glyph", "")), 19, Color(1.0, 0.95, 0.86, 1.0))
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph_panel.add_child(glyph_label)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", _i(2))
	header.add_child(text_box)
	text_box.add_child(_make_label(_localize_cangjie_text(step.get("label", "")), 15, Color(1.0, 0.95, 0.86, 1.0)))

	var note_text := _localize_cangjie_text(step.get("note", ""))
	if not note_text.is_empty():
		box.add_child(_make_label(note_text, 13, Color(0.84, 0.9, 0.98, 0.84)))

	if active:
		box.add_child(_make_tag("当前聚焦" if not _is_english() else "Focused", Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.9), Color(0.98, 0.94, 0.88, 0.96)))

	return panel


func _make_cangjie_route_ribbon_connector(accent: Color) -> Control:
	var connector := PanelContainer.new()
	connector.custom_minimum_size = _v(0.0, 28.0) if _is_portrait_layout() else _v(44.0, 0.0)
	connector.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	connector.add_theme_stylebox_override("panel", StyleBoxEmpty.new())

	var label := _make_label("↓" if _is_portrait_layout() else "→", 20, Color(accent.r, accent.g, accent.b, 0.72))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	connector.add_child(label)
	return connector


func _make_cangjie_route_node_card(node: Dictionary, accent: Color, active: bool, lane_active: bool, state_legend: Dictionary, progress_state: String) -> Button:
	var tone: Color = node.get("tone", accent)
	var node_id := String(node.get("id", ""))
	var state := String(node.get("state", "option"))
	var fill_alpha := 0.12
	var border_alpha := 0.18
	if progress_state == "completed":
		fill_alpha = 0.24
		border_alpha = 0.4
	elif progress_state == "available":
		fill_alpha = 0.18
		border_alpha = 0.32
	if state == "path":
		fill_alpha = maxf(fill_alpha, 0.22)
		border_alpha = maxf(border_alpha, 0.38)
	elif state == "boss":
		fill_alpha = maxf(fill_alpha, 0.28)
		border_alpha = maxf(border_alpha, 0.48)
	if lane_active:
		fill_alpha = maxf(fill_alpha, 0.24)
		border_alpha = maxf(border_alpha, 0.42)
	if active:
		fill_alpha = maxf(fill_alpha, 0.32)
		border_alpha = maxf(border_alpha, 0.56)
	var text_alpha := 0.68 if progress_state == "locked" else 0.96

	var button := Button.new()
	button.text = ""
	button.flat = true
	button.clip_contents = false
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = _v(0.0, 118.0)
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(tone.r * 0.16, tone.g * 0.16, tone.b * 0.18, 0.8 + fill_alpha * 0.2), Color(tone.r, tone.g, tone.b, border_alpha)))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.88), Color(tone.r, tone.g, tone.b, minf(border_alpha + 0.1, 0.72))))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(tone.r * 0.2, tone.g * 0.2, tone.b * 0.22, 0.92), Color(tone.r, tone.g, tone.b, minf(border_alpha + 0.16, 0.82))))

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", _i(12))
	margin.add_theme_constant_override("margin_top", _i(10))
	margin.add_theme_constant_override("margin_right", _i(12))
	margin.add_theme_constant_override("margin_bottom", _i(10))
	button.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(6))
	margin.add_child(box)

	var badge_row := HFlowContainer.new()
	badge_row.add_theme_constant_override("h_separation", _i(6))
	badge_row.add_theme_constant_override("v_separation", _i(6))
	box.add_child(badge_row)

	var progress_badge := _get_cangjie_route_progress_badge_text(progress_state)
	if not progress_badge.is_empty():
		badge_row.add_child(_make_tag(progress_badge, Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.88 if progress_state != "locked" else 0.72), Color(0.98, 0.94, 0.88, 0.94 if progress_state != "locked" else 0.8)))
	var state_badge := _get_cangjie_route_state_badge_text(state_legend, state)
	if not state_badge.is_empty():
		badge_row.add_child(_make_tag(state_badge, Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.88), Color(0.98, 0.94, 0.88, 0.94)))

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", _i(10))
	box.add_child(header)

	var glyph_panel := PanelContainer.new()
	glyph_panel.custom_minimum_size = _v(42.0, 42.0)
	glyph_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.2, tone.g * 0.18, tone.b * 0.16, 0.92), Color(tone.r, tone.g, tone.b, 0.28)))
	header.add_child(glyph_panel)

	var glyph_label := _make_label(String(node.get("glyph", "")), 20, Color(1.0, 0.95, 0.86, text_alpha))
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph_panel.add_child(glyph_label)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", _i(2))
	header.add_child(text_box)
	text_box.add_child(_make_label(_localize_cangjie_text(node.get("label", "")), 15, Color(1.0, 0.95, 0.86, text_alpha)))

	var state_text := _localize_cangjie_text(node.get("note", ""))
	if not state_text.is_empty():
		box.add_child(_make_label(state_text, 13, Color(0.84, 0.9, 0.98, 0.84 if progress_state != "locked" else 0.62)))

	if active:
		box.add_child(_make_tag("Current Focus" if _is_english() else "当前焦点", Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.9), Color(0.98, 0.94, 0.88, 0.96)))

	if not node_id.is_empty():
		button.pressed.connect(Callable(self, "_on_select_cangjie_route_preview_node").bind(
			String(node.get("id", "")),
			String(node.get("linked_preview_kind", "")),
			String(node.get("linked_preview_option", ""))
		))
	return button


func _get_cangjie_route_state_badge_text(state_legend: Dictionary, state_id: String) -> String:
	if state_id.is_empty():
		return ""
	var items_variant: Variant = state_legend.get("items", [])
	if items_variant is Array:
		for item_variant in items_variant:
			if item_variant is Dictionary:
				var item := item_variant as Dictionary
				if String(item.get("id", "")) == state_id:
					var badge_text := _localize_cangjie_text(item.get("badge", item.get("title", "")))
					if not badge_text.is_empty():
						return badge_text

	if state_id == "path":
		return "Backbone" if _is_english() else "主脉"
	if state_id == "boss":
		return "Closure" if _is_english() else "收束"
	return "Pivot" if _is_english() else "转笔"


func _get_cangjie_route_progress_badge_text(progress_state: String) -> String:
	if progress_state == "completed":
		return "Completed" if _is_english() else "已走"
	if progress_state == "available":
		return "Available" if _is_english() else "已开"
	return "Locked" if _is_english() else "未亮"


func _first_cangjie_route_preview_node(preview: Dictionary) -> Dictionary:
	var rows_variant: Variant = preview.get("rows", [])
	if not (rows_variant is Array):
		return {}
	for row_variant in rows_variant:
		if row_variant is Dictionary:
			var nodes_variant: Variant = (row_variant as Dictionary).get("nodes", [])
			if nodes_variant is Array:
				for node_variant in nodes_variant:
					if node_variant is Dictionary:
						return node_variant as Dictionary
	return {}


func _find_cangjie_route_preview_node(preview: Dictionary, node_id: String) -> Dictionary:
	if node_id.is_empty():
		return {}
	var rows_variant: Variant = preview.get("rows", [])
	if not (rows_variant is Array):
		return {}
	for row_variant in rows_variant:
		if row_variant is Dictionary:
			var nodes_variant: Variant = (row_variant as Dictionary).get("nodes", [])
			if nodes_variant is Array:
				for node_variant in nodes_variant:
					if node_variant is Dictionary and String((node_variant as Dictionary).get("id", "")) == node_id:
						return node_variant as Dictionary
	return {}


func _make_cangjie_duelist_card(duelist: Dictionary, accent: Color) -> Button:
	var tone: Color = duelist.get("tone", accent)
	var button := Button.new()
	button.text = ""
	button.flat = true
	button.clip_contents = false
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = _v(0.0, 232.0)
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(tone.r * 0.14, tone.g * 0.14, tone.b * 0.16, 0.86), Color(tone.r, tone.g, tone.b, 0.3 if cangjie_stage_fx_enabled else 0.2)))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(tone.r * 0.16, tone.g * 0.16, tone.b * 0.18, 0.92), Color(tone.r, tone.g, tone.b, 0.42 if cangjie_stage_fx_enabled else 0.28)))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(tone.r * 0.18, tone.g * 0.18, tone.b * 0.2, 0.94), Color(tone.r, tone.g, tone.b, 0.5 if cangjie_stage_fx_enabled else 0.32)))

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", _i(16))
	margin.add_theme_constant_override("margin_top", _i(14))
	margin.add_theme_constant_override("margin_right", _i(16))
	margin.add_theme_constant_override("margin_bottom", _i(14))
	button.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)

	var bubble_panel := PanelContainer.new()
	bubble_panel.visible = false
	bubble_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	bubble_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.2, tone.g * 0.18, tone.b * 0.16, 0.88), Color(tone.r, tone.g, tone.b, 0.34)))
	box.add_child(bubble_panel)

	var bubble_margin := MarginContainer.new()
	bubble_margin.add_theme_constant_override("margin_left", _i(12))
	bubble_margin.add_theme_constant_override("margin_top", _i(10))
	bubble_margin.add_theme_constant_override("margin_right", _i(12))
	bubble_margin.add_theme_constant_override("margin_bottom", _i(10))
	bubble_panel.add_child(bubble_margin)

	var bubble_label := _make_label("", 14, Color(0.98, 0.95, 0.9, 0.96))
	bubble_margin.add_child(bubble_label)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", _i(12))
	box.add_child(header)

	var stage := Control.new()
	stage.custom_minimum_size = _v(108.0, 92.0)
	header.add_child(stage)

	var aura_outer := PanelContainer.new()
	aura_outer.size = _v(86.0, 86.0)
	aura_outer.position = _v(6.0, 2.0)
	aura_outer.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.12, tone.g * 0.12, tone.b * 0.14, 0.16 if cangjie_stage_fx_enabled else 0.06), Color(tone.r, tone.g, tone.b, 0.22 if cangjie_stage_fx_enabled else 0.08)))
	stage.add_child(aura_outer)

	var aura_inner := PanelContainer.new()
	aura_inner.size = _v(62.0, 62.0)
	aura_inner.position = _v(18.0, 14.0)
	aura_inner.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.18, tone.g * 0.16, tone.b * 0.14, 0.22 if cangjie_stage_fx_enabled else 0.1), Color(tone.r, tone.g, tone.b, 0.18 if cangjie_stage_fx_enabled else 0.08)))
	stage.add_child(aura_inner)

	var beam := ColorRect.new()
	beam.color = Color(tone.r, tone.g, tone.b, 0.76 if cangjie_stage_fx_enabled else 0.24)
	beam.position = _v(78.0, 42.0)
	beam.size = _v(24.0, 5.0)
	stage.add_child(beam)

	var glyph_panel := PanelContainer.new()
	glyph_panel.size = _v(62.0, 62.0)
	glyph_panel.position = _v(18.0, 14.0)
	glyph_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(tone.r * 0.22, tone.g * 0.18, tone.b * 0.16, 0.94), Color(tone.r, tone.g, tone.b, 0.34)))
	stage.add_child(glyph_panel)

	var glyph_label := _make_label(String(duelist.get("glyph", "")), 30, Color(1.0, 0.95, 0.86, 1.0))
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph_panel.add_child(glyph_label)

	var heading_box := VBoxContainer.new()
	heading_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading_box.add_theme_constant_override("separation", _i(4))
	header.add_child(heading_box)
	heading_box.add_child(_make_tag(_localize_cangjie_text(duelist.get("kicker", "")), Color(tone.r * 0.16, tone.g * 0.16, tone.b * 0.18, 0.86), Color(0.98, 0.94, 0.88, 0.96)))
	heading_box.add_child(_make_label(_localize_cangjie_text(duelist.get("title", "")), 18, Color(1.0, 0.95, 0.86, 1.0)))

	var primary_text := _localize_cangjie_text(duelist.get("primary", ""))
	if not primary_text.is_empty():
		box.add_child(_make_label(primary_text, 15, Color(0.9, 0.92, 0.96, 0.94)))
	var secondary_text := _localize_cangjie_text(duelist.get("secondary", ""))
	if not secondary_text.is_empty():
		box.add_child(_make_label(secondary_text, 14, Color(0.8, 0.88, 0.95, 0.82)))

	var prompt := _make_label("点按角色试试" if not _is_english() else "Tap to preview a response", 13, Color(tone.r, tone.g, tone.b, 0.92))
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	box.add_child(prompt)

	button.set_meta("bubble_panel", bubble_panel)
	button.set_meta("bubble_label", bubble_label)
	button.pressed.connect(Callable(self, "_on_cangjie_duelist_pressed").bind(button, duelist))
	return button


func _make_cangjie_group_panel(group: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.06, accent.g * 0.08, accent.b * 0.1, 0.72), Color(accent.r, accent.g, accent.b, 0.26)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)
	box.add_child(_make_label(_localize_cangjie_text(group.get("title", "")), 20, Color(1.0, 0.95, 0.86, 1.0)))

	var summary_text := _localize_cangjie_text(group.get("summary", ""))
	if not summary_text.is_empty():
		box.add_child(_make_label(summary_text, 16, Color(0.88, 0.92, 0.96, 0.92)))

	var cards_variant: Variant = group.get("cards", [])
	if cards_variant is Array and not (cards_variant as Array).is_empty():
		var cards := cards_variant as Array
		var grid := GridContainer.new()
		grid.columns = 1 if _is_portrait_layout() else mini(3, maxi(1, cards.size()))
		grid.add_theme_constant_override("h_separation", _i(10))
		grid.add_theme_constant_override("v_separation", _i(10))
		box.add_child(grid)
		for card_variant in cards:
			if card_variant is Dictionary:
				grid.add_child(_make_cangjie_sample_card(card_variant as Dictionary, accent))
	return panel


func _make_cangjie_sample_card(card: Dictionary, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = _v(0.0, 216.0)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.12, accent.g * 0.12, accent.b * 0.14, 0.84), Color(accent.r, accent.g, accent.b, 0.32)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(16))
	margin.add_theme_constant_override("margin_top", _i(14))
	margin.add_theme_constant_override("margin_right", _i(16))
	margin.add_theme_constant_override("margin_bottom", _i(14))
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", _i(12))
	box.add_child(header)

	var glyph_panel := PanelContainer.new()
	glyph_panel.custom_minimum_size = _v(68.0, 68.0)
	glyph_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.18, accent.g * 0.16, accent.b * 0.14, 0.88), Color(accent.r, accent.g, accent.b, 0.22)))
	header.add_child(glyph_panel)

	var glyph_label := _make_label(String(card.get("glyph", "")), 34, Color(1.0, 0.95, 0.86, 1.0))
	glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	glyph_panel.add_child(glyph_label)

	var heading_box := VBoxContainer.new()
	heading_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading_box.add_theme_constant_override("separation", _i(4))
	header.add_child(heading_box)
	heading_box.add_child(_make_label(_localize_cangjie_text(card.get("title", "")), 18, Color(1.0, 0.95, 0.86, 1.0)))
	var subtitle_text := _localize_cangjie_text(card.get("subtitle", ""))
	if not subtitle_text.is_empty():
		heading_box.add_child(_make_label(subtitle_text, 14, Color(0.92, 0.82, 0.62, 0.92)))
	if _is_english():
		var learning_meta_parts: Array[String] = []
		var pinyin_text := String(card.get("pinyin", "")).strip_edges()
		if not pinyin_text.is_empty():
			learning_meta_parts.append(pinyin_text)
		var gloss_text := _localize_cangjie_text(card.get("gloss", "")).strip_edges()
		if not gloss_text.is_empty():
			learning_meta_parts.append(gloss_text)
		if not learning_meta_parts.is_empty():
			heading_box.add_child(_make_label(" · ".join(learning_meta_parts), 13, Color(0.82, 0.9, 0.98, 0.8)))

	box.add_child(_make_label(_localize_cangjie_text(card.get("body", "")), 15, Color(0.88, 0.92, 0.96, 0.94)))

	var tags_variant: Variant = card.get("tags", [])
	if tags_variant is Array and not (tags_variant as Array).is_empty():
		var tag_row := HFlowContainer.new()
		tag_row.add_theme_constant_override("h_separation", _i(8))
		tag_row.add_theme_constant_override("v_separation", _i(8))
		box.add_child(tag_row)
		for tag_variant in tags_variant:
			tag_row.add_child(_make_tag(_localize_cangjie_text(tag_variant), Color(accent.r * 0.16, accent.g * 0.16, accent.b * 0.18, 0.86), Color(0.98, 0.94, 0.88, 0.96)))

	return panel


func _build_changelog_overlay() -> void:
	var portrait_layout := _is_portrait_layout()
	var changelog_content := FrontEndContent.launcher_changelog_content()
	changelog_overlay = Control.new()
	changelog_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	changelog_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	changelog_overlay.visible = false
	add_child(changelog_overlay)

	var scrim := ColorRect.new()
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.01, 0.02, 0.03, 0.76)
	changelog_overlay.add_child(scrim)

	var panel := PanelContainer.new()
	_set_center_overlay_panel(panel, 1200.0, 860.0 if portrait_layout else 676.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.08, 0.1, 0.96), Color(0.92, 0.72, 0.42, 0.88)))
	changelog_overlay.add_child(panel)

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

	box.add_child(_make_tag(String(changelog_content.get("tag", "")), Color(0.14, 0.18, 0.24, 0.88), Color(0.96, 0.82, 0.56, 0.98)))
	box.add_child(_make_label(String(changelog_content.get("title", "")), 44, Color(1.0, 0.95, 0.86, 1.0)))
	box.add_child(_make_label(String(changelog_content.get("summary", "")), 18, Color(0.9, 0.92, 0.96, 0.95)))
	box.add_child(_make_label(String(changelog_content.get("footnote", "")), 16, Color(0.86, 0.9, 0.94, 0.84)))

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	box.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", _i(14))
	scroll.add_child(content)

	var changelog_history := FrontEndContent.launcher_changelog_history()
	for entry_index in range(changelog_history.size()):
		content.add_child(_make_changelog_entry_card(changelog_history[entry_index], entry_index == 0))

	var footer_row := _make_responsive_box_container(portrait_layout)
	footer_row.add_theme_constant_override("separation", _i(10))
	box.add_child(footer_row)

	var theme_button := _make_theme_toggle_button(_v(0.0, 52.0))
	theme_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer_row.add_child(theme_button)

	var close_button := Button.new()
	close_button.text = _localize_text(String(changelog_content.get("close_text", "返回启动器")))
	close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close_button.custom_minimum_size = _v(0.0, 52.0)
	close_button.add_theme_font_override("font", title_font)
	close_button.add_theme_font_size_override("font_size", _i(22))
	close_button.add_theme_color_override("font_color", _resolve_label_color(Color(0.08, 0.07, 0.07, 1.0)))
	close_button.add_theme_stylebox_override("normal", _make_button_style(Color(0.92, 0.62, 0.28, 1.0), 16))
	close_button.add_theme_stylebox_override("hover", _make_button_style(Color(0.98, 0.7, 0.34, 1.0), 16))
	close_button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.84, 0.54, 0.22, 1.0), 16))
	close_button.pressed.connect(_hide_changelog)
	footer_row.add_child(close_button)


func _build_profile_overlay() -> void:
	var portrait_layout := _is_portrait_layout()
	var profile_content := FrontEndContent.launcher_profile_content()
	profile_overlay = Control.new()
	profile_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	profile_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	profile_overlay.visible = false
	add_child(profile_overlay)

	var scrim := ColorRect.new()
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.01, 0.02, 0.03, 0.74)
	profile_overlay.add_child(scrim)

	var panel := PanelContainer.new()
	_set_center_overlay_panel(panel, 760.0, 760.0 if portrait_layout else 500.0)
	panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.05, 0.08, 0.1, 0.96), Color(0.52, 0.8, 1.0, 0.72)))
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

	box.add_child(_make_tag(String(profile_content.get("tag", "")), Color(0.12, 0.18, 0.24, 0.88), Color(0.96, 0.82, 0.56, 0.96)))
	box.add_child(_make_label(String(profile_content.get("title", "")), 40, Color(1.0, 0.95, 0.86, 1.0)))
	box.add_child(_make_label(String(profile_content.get("summary", "")), 18, Color(0.9, 0.92, 0.96, 0.95)))

	var content_row := _make_responsive_box_container(portrait_layout)
	content_row.add_theme_constant_override("separation", _i(16))
	box.add_child(content_row)

	var preview_card := PanelContainer.new()
	preview_card.custom_minimum_size = _v(220.0, 0.0)
	preview_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_card.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.76), Color(0.38, 0.72, 0.82, 0.34)))
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
	preview_box.add_child(_make_label(String(profile_content.get("preview_title", "")), 18, Color(0.96, 0.82, 0.54, 0.94)))

	var avatar_panel := PanelContainer.new()
	avatar_panel.custom_minimum_size = _v(0.0, 112.0)
	avatar_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.1, 0.14, 0.18, 0.86), Color(0.52, 0.8, 1.0, 0.28)))
	preview_box.add_child(avatar_panel)

	profile_preview_glyph_label = _make_label("侠", 48, Color(1.0, 0.95, 0.86, 1.0))
	profile_preview_glyph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	profile_preview_glyph_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	profile_preview_glyph_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	avatar_panel.add_child(profile_preview_glyph_label)

	profile_preview_name_label = _make_label("", 28, Color(1.0, 0.95, 0.86, 1.0))
	profile_preview_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_box.add_child(profile_preview_name_label)
	profile_preview_copy_label = _make_label("", 16, Color(0.86, 0.9, 0.94, 0.92))
	preview_box.add_child(profile_preview_copy_label)

	var editor_card := PanelContainer.new()
	editor_card.custom_minimum_size = _v(0.0, 0.0)
	editor_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor_card.add_theme_stylebox_override("panel", _make_panel_style(Color(0.08, 0.12, 0.16, 0.76), Color(0.92, 0.68, 0.42, 0.3)))
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
	editor_box.add_child(_make_label(String(profile_content.get("name_field_title", "")), 22, Color(1.0, 0.92, 0.8, 1.0)))

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

	var action_row := _make_responsive_box_container(portrait_layout)
	action_row.add_theme_constant_override("separation", _i(10))
	editor_box.add_child(action_row)

	var random_button := _make_pill_button("随机侠名", _v(0.0, 48.0), Callable(self, "_on_profile_random_pressed"))
	random_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_row.add_child(random_button)

	var save_button := Button.new()
	save_button.text = _localize_text(String(profile_content.get("save_text", "保存署名")))
	save_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_button.custom_minimum_size = _v(0.0, 48.0)
	save_button.add_theme_font_override("font", title_font)
	save_button.add_theme_font_size_override("font_size", _i(20))
	save_button.add_theme_color_override("font_color", _resolve_label_color(Color(0.08, 0.07, 0.07, 1.0)))
	save_button.add_theme_stylebox_override("normal", _make_button_style(Color(0.92, 0.62, 0.28, 1.0), 16))
	save_button.add_theme_stylebox_override("hover", _make_button_style(Color(0.98, 0.7, 0.34, 1.0), 16))
	save_button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.84, 0.54, 0.22, 1.0), 16))
	save_button.pressed.connect(_on_profile_save_pressed)
	action_row.add_child(save_button)

	var footer_row := _make_responsive_box_container(portrait_layout)
	footer_row.add_theme_constant_override("separation", _i(10))
	box.add_child(footer_row)

	var reset_button := _make_pill_button(String(profile_content.get("reset_text", "恢复默认")), _v(0.0, 50.0), Callable(self, "_on_profile_reset_pressed"))
	reset_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer_row.add_child(reset_button)

	var close_button := _make_pill_button(String(profile_content.get("close_text", "返回启动器")), _v(0.0, 50.0), Callable(self, "_hide_profile"))
	close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer_row.add_child(close_button)

	_refresh_profile_overlay()


func _make_about_story_panel(title: String, paragraphs: Array[String]) -> PanelContainer:
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
	box.add_child(_make_label(title, 24, Color(1.0, 0.92, 0.8, 1.0)))

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


func _make_changelog_entry_card(entry: Dictionary, is_latest: bool) -> PanelContainer:
	var accent := Color(0.92, 0.7, 0.38, 1.0) if is_latest else Color(0.42, 0.72, 0.92, 1.0)
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.1, accent.g * 0.09, accent.b * 0.11, 0.88), Color(accent.r, accent.g, accent.b, 0.46)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(20))
	margin.add_theme_constant_override("margin_top", _i(20))
	margin.add_theme_constant_override("margin_right", _i(20))
	margin.add_theme_constant_override("margin_bottom", _i(20))
	card.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(10))
	margin.add_child(box)

	var meta_row := HBoxContainer.new()
	meta_row.add_theme_constant_override("separation", _i(8))
	box.add_child(meta_row)
	if is_latest:
		meta_row.add_child(_make_tag("当前快照", Color(0.14, 0.18, 0.24, 0.9), Color(0.96, 0.82, 0.56, 0.98)))
	meta_row.add_child(_make_tag(String(entry.get("date", "")), Color(accent.r * 0.14, accent.g * 0.14, accent.b * 0.16, 0.9), Color(0.98, 0.94, 0.88, 0.96)))
	for meta_variant in entry.get("meta", []):
		meta_row.add_child(_make_tag(String(meta_variant), Color(accent.r * 0.12, accent.g * 0.12, accent.b * 0.16, 0.8), Color(0.92, 0.94, 0.9, 0.94)))

	box.add_child(_make_label(String(entry.get("title", "")), 30 if is_latest else 26, Color(1.0, 0.95, 0.86, 1.0)))
	box.add_child(_make_label(String(entry.get("summary", "")), 17, Color(0.9, 0.92, 0.96, 0.94)))

	var sections_box := VBoxContainer.new()
	sections_box.add_theme_constant_override("separation", _i(10))
	box.add_child(sections_box)
	for section_variant in entry.get("sections", []):
		var section: Dictionary = section_variant
		sections_box.add_child(_make_changelog_section_card(String(section.get("label", "")), section.get("items", []), accent))

	return card


func _make_changelog_section_card(title: String, items: Array, accent: Color) -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _make_panel_style(Color(accent.r * 0.08, accent.g * 0.08, accent.b * 0.1, 0.82), Color(accent.r, accent.g, accent.b, 0.28)))

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", _i(18))
	margin.add_theme_constant_override("margin_top", _i(16))
	margin.add_theme_constant_override("margin_right", _i(18))
	margin.add_theme_constant_override("margin_bottom", _i(16))
	card.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", _i(8))
	margin.add_child(box)
	box.add_child(_make_label(title, 21, Color(1.0, 0.92, 0.8, 1.0)))
	for item_variant in items:
		box.add_child(_make_label("• %s" % String(item_variant), 16, Color(0.9, 0.92, 0.95, 0.93)))

	return card


func _make_text_input(placeholder_text: String) -> LineEdit:
	var input := LineEdit.new()
	input.custom_minimum_size = _v(0.0, 52.0)
	input.placeholder_text = _localize_text(placeholder_text)
	input.clear_button_enabled = true
	input.add_theme_font_override("font", title_font)
	input.add_theme_font_size_override("font_size", _i(20))
	input.add_theme_color_override("font_color", _resolve_label_color(Color(0.96, 0.95, 0.9, 0.98)))
	input.add_theme_color_override("caret_color", _resolve_label_color(Color(0.96, 0.82, 0.56, 0.94)))
	input.add_theme_color_override("font_placeholder_color", _resolve_label_color(Color(0.68, 0.76, 0.84, 0.8)))
	input.add_theme_stylebox_override("normal", _make_panel_style(Color(0.06, 0.08, 0.1, 0.9), Color(0.28, 0.36, 0.42, 0.56)))
	input.add_theme_stylebox_override("focus", _make_panel_style(Color(0.08, 0.11, 0.14, 0.94), Color(0.92, 0.68, 0.42, 0.58)))
	input.add_theme_stylebox_override("read_only", _make_panel_style(Color(0.06, 0.08, 0.1, 0.72), Color(0.28, 0.36, 0.42, 0.4)))
	return input


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = _localize_text(text)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var settings := LabelSettings.new()
	settings.font = title_font
	settings.font_size = _i(font_size)
	settings.font_color = _resolve_label_color(color)
	settings.outline_size = 1
	settings.outline_color = _get_theme_palette()["outline"]
	label.label_settings = settings
	return label


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


func _make_button_style(fill_color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = _resolve_button_fill(fill_color)
	style.corner_radius_top_left = _i(radius)
	style.corner_radius_top_right = _i(radius)
	style.corner_radius_bottom_left = _i(radius)
	style.corner_radius_bottom_right = _i(radius)
	return style


func _make_pill_button(text: String, control_size: Vector2, callback: Callable) -> Button:
	var button := Button.new()
	button.text = _localize_text(text)
	button.custom_minimum_size = control_size
	button.add_theme_font_override("font", title_font)
	button.add_theme_font_size_override("font_size", _i(20))
	button.add_theme_color_override("font_color", _resolve_label_color(Color(0.98, 0.92, 0.82, 0.98)))
	button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.04, 0.06, 0.08, 0.78), Color(0.2, 0.26, 0.32, 0.54)))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.08, 0.1, 0.12, 0.84), Color(0.92, 0.68, 0.42, 0.44)))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.08, 0.1, 0.12, 0.9), Color(0.92, 0.68, 0.42, 0.6)))
	button.pressed.connect(callback)
	return button


func _make_static_pill(text: String, control_size: Vector2) -> PanelContainer:
	var pill := PanelContainer.new()
	pill.custom_minimum_size = control_size
	pill.add_theme_stylebox_override("panel", _make_panel_style(Color(0.04, 0.06, 0.08, 0.76), Color(0.2, 0.26, 0.32, 0.56)))
	var label := _make_label(_localize_text(text), 20, Color(0.98, 0.92, 0.82, 0.98))
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


func _set_mouse_filter_recursive(control: Control, filter_mode: Control.MouseFilter) -> void:
	control.mouse_filter = filter_mode
	for child in control.get_children():
		if child is Control:
			_set_mouse_filter_recursive(child as Control, filter_mode)


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


func _on_toggle_theme_pressed() -> void:
	current_theme = "paper-ink" if current_theme == "night-ink" else "night-ink"
	Session.set_launcher_theme(current_theme)
	_rebuild_ui()


func _on_toggle_language_pressed() -> void:
	current_language = "zh" if _is_english() else "en"
	Session.set_launcher_language(current_language)
	_rebuild_ui()


func _on_toggle_cangjie_stage_fx_pressed() -> void:
	cangjie_stage_fx_enabled = not cangjie_stage_fx_enabled
	_refresh_cangjie_portal()


func _on_toggle_cangjie_run_shell_pressed() -> void:
	cangjie_run_shell_open = not cangjie_run_shell_open
	_refresh_cangjie_portal()


func _on_select_cangjie_reward_chain_option(option_id: String) -> void:
	cangjie_reward_chain_choice = option_id
	_refresh_cangjie_portal()


func _on_select_cangjie_route_preview_node(node_id: String, preview_kind: String = "", option_id: String = "") -> void:
	cangjie_route_preview_node_id = node_id
	if preview_kind == "reward_chain" and not option_id.is_empty():
		cangjie_reward_chain_choice = option_id
	elif preview_kind == "rest" and not option_id.is_empty():
		cangjie_rest_choice = option_id
	elif preview_kind == "archive" and not option_id.is_empty():
		cangjie_archive_choice = option_id
	elif preview_kind == "treasure" and not option_id.is_empty():
		cangjie_treasure_choice = option_id
	elif preview_kind == "shop" and not option_id.is_empty():
		cangjie_shop_choice = option_id
	elif preview_kind == "route_ledger" and not option_id.is_empty():
		cangjie_route_ledger_choice = option_id
	elif preview_kind == "tutor" and not option_id.is_empty():
		cangjie_tutor_choice = option_id
	elif preview_kind == "broker" and not option_id.is_empty():
		cangjie_broker_choice = option_id
	elif preview_kind == "margin" and not option_id.is_empty():
		cangjie_margin_choice = option_id
	_refresh_cangjie_portal()


func _on_select_cangjie_rest_option(option_id: String) -> void:
	cangjie_rest_choice = option_id
	_refresh_cangjie_portal()


func _on_select_cangjie_archive_option(option_id: String) -> void:
	cangjie_archive_choice = option_id
	_refresh_cangjie_portal()


func _on_select_cangjie_treasure_option(option_id: String) -> void:
	cangjie_treasure_choice = option_id
	_refresh_cangjie_portal()


func _on_select_cangjie_shop_option(option_id: String) -> void:
	cangjie_shop_choice = option_id
	_refresh_cangjie_portal()


func _on_select_cangjie_route_ledger_option(option_id: String) -> void:
	cangjie_route_ledger_choice = option_id
	_refresh_cangjie_portal()


func _on_select_cangjie_tutor_option(option_id: String) -> void:
	cangjie_tutor_choice = option_id
	_refresh_cangjie_portal()


func _on_select_cangjie_broker_option(option_id: String) -> void:
	cangjie_broker_choice = option_id
	_refresh_cangjie_portal()


func _on_select_cangjie_margin_option(option_id: String) -> void:
	cangjie_margin_choice = option_id
	_refresh_cangjie_portal()


func _on_cangjie_duelist_pressed(card_button: Button, duelist: Dictionary) -> void:
	if card_button == null or not is_instance_valid(card_button):
		return

	var responses_variant: Variant = duelist.get("responses", [])
	if not (responses_variant is Array) or (responses_variant as Array).is_empty():
		return

	var duelist_id := String(duelist.get("id", "duelist"))
	var responses := responses_variant as Array
	var response_index := int(cangjie_duelist_line_indices.get(duelist_id, 0))
	cangjie_duelist_line_indices[duelist_id] = response_index + 1
	var response_text := _localize_cangjie_text(responses[response_index % responses.size()])

	var bubble_panel := card_button.get_meta("bubble_panel") as PanelContainer
	var bubble_label := card_button.get_meta("bubble_label") as Label
	if bubble_label != null:
		bubble_label.text = response_text
	if bubble_panel != null:
		var token := Time.get_ticks_msec()
		bubble_panel.set_meta("token", token)
		bubble_panel.visible = true
		bubble_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
		var bubble_tween := create_tween()
		bubble_tween.tween_property(bubble_panel, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.12)
		bubble_tween.tween_interval(1.25)
		bubble_tween.tween_property(bubble_panel, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.2)
		bubble_tween.tween_callback(Callable(self, "_hide_cangjie_duelist_bubble").bind(bubble_panel, token))

	card_button.pivot_offset = card_button.size * 0.5
	card_button.rotation_degrees = 0.0
	card_button.scale = Vector2.ONE
	var bounce_tween := create_tween()
	bounce_tween.tween_property(card_button, "rotation_degrees", 4.0, 0.06)
	bounce_tween.parallel().tween_property(card_button, "scale", Vector2(1.03, 1.03), 0.06)
	bounce_tween.tween_property(card_button, "rotation_degrees", -4.0, 0.08)
	bounce_tween.parallel().tween_property(card_button, "scale", Vector2(0.99, 0.99), 0.08)
	bounce_tween.tween_property(card_button, "rotation_degrees", 0.0, 0.06)
	bounce_tween.parallel().tween_property(card_button, "scale", Vector2.ONE, 0.06)


func _hide_cangjie_duelist_bubble(bubble_panel: PanelContainer, token: int) -> void:
	if bubble_panel == null or not is_instance_valid(bubble_panel):
		return
	if int(bubble_panel.get_meta("token", -1)) != token:
		return
	bubble_panel.visible = false


func _show_about() -> void:
	if about_overlay != null:
		_hide_cangjie_portal()
		_hide_changelog()
		_hide_profile()
		about_overlay.visible = true


func _hide_about() -> void:
	if about_overlay != null:
		about_overlay.visible = false


func _show_changelog() -> void:
	if changelog_overlay != null:
		_hide_cangjie_portal()
		_hide_about()
		_hide_profile()
		changelog_overlay.visible = true


func _hide_changelog() -> void:
	if changelog_overlay != null:
		changelog_overlay.visible = false


func _show_cangjie_portal() -> void:
	if cangjie_overlay != null:
		_hide_about()
		_hide_changelog()
		_hide_profile()
		cangjie_run_shell_open = false
		cangjie_reward_chain_choice = "draft"
		cangjie_rest_choice = "prepare"
		cangjie_archive_choice = "trim"
		cangjie_treasure_choice = "inkstone"
		cangjie_shop_choice = "restock"
		cangjie_route_ledger_choice = "deepen"
		cangjie_tutor_choice = "trim"
		cangjie_broker_choice = "power"
		cangjie_margin_choice = "greed"
		cangjie_route_preview_node_id = ""
		cangjie_overlay.visible = true
		_refresh_cangjie_portal()


func _hide_cangjie_portal() -> void:
	if cangjie_overlay != null:
		cangjie_overlay.visible = false


func _on_cangjie_section_pressed(section_id: String) -> void:
	cangjie_section = section_id
	cangjie_run_shell_open = false
	_refresh_cangjie_portal()


func _show_profile() -> void:
	if profile_overlay == null or profile_name_input == null:
		return
	_hide_cangjie_portal()
	_hide_about()
	_hide_changelog()
	var identity: Dictionary = Session.get_leaderboard_identity()
	profile_name_input.text = String(identity.get("custom_name", ""))
	_refresh_profile_overlay()
	profile_overlay.visible = true


func _hide_profile() -> void:
	if profile_overlay != null:
		profile_overlay.visible = false


func _refresh_profile_overlay(status_text: String = "") -> void:
	if profile_name_input == null or profile_status_label == null or profile_hint_label == null:
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
			profile_preview_copy_label.text = "The device is still using its default wuxia alias. Saving a custom alias will replace later records with this name."
			profile_hint_label.text = "If you do not save a custom alias, the system will keep using this device default: %s" % device_alias
		else:
			profile_preview_copy_label.text = "当前仍使用设备默认侠名；保存自定义署名后，后续战绩会覆盖成这个名字。"
			profile_hint_label.text = "如果不另外保存自定义署名，系统会继续使用本机默认侠名：%s" % device_alias
	else:
		if _is_english():
			profile_preview_copy_label.text = "The saved alias will be reused automatically for later local leaderboard entries."
			profile_hint_label.text = "Clear or reset it to fall back to the device default again: %s" % device_alias
		else:
			profile_preview_copy_label.text = "当前默认署名会直接复用到之后的本地排行榜记录里。"
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


func _get_profile_monogram(profile_name: String) -> String:
	var trimmed_name := profile_name.strip_edges()
	if trimmed_name.is_empty():
		return "侠"
	return trimmed_name.substr(0, 1)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if cangjie_overlay != null and cangjie_overlay.visible:
		_hide_cangjie_portal()
		get_viewport().set_input_as_handled()
		return
	if profile_overlay != null and profile_overlay.visible:
		_hide_profile()
		get_viewport().set_input_as_handled()
		return
	if changelog_overlay != null and changelog_overlay.visible:
		_hide_changelog()
		get_viewport().set_input_as_handled()
		return
	if about_overlay != null and about_overlay.visible:
		_hide_about()
		get_viewport().set_input_as_handled()


func _on_enter_zihai_pressed() -> void:
	get_tree().change_scene_to_file(Session.ZIHAI_MENU_SCENE)
