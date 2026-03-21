extends Node

const LAUNCHER_SCENE := "res://scenes/app/launcher.tscn"
const ZIHAI_MENU_SCENE := "res://scenes/app/zihai_menu.tscn"
const ZIHAI_BATTLE_SCENE := "res://scenes/battle/zihai_battle.tscn"
const LOCAL_LEADERBOARD_PATH := "user://local_leaderboard.json"
const LOCAL_LEADERBOARD_LIMIT := 12
const FALLBACK_RUN_NAME_SURNAMES := ["沈", "陆", "谢", "顾", "裴", "苏", "闻", "叶", "秦", "燕", "柳", "程"]
const FALLBACK_RUN_NAME_GIVENS := ["孤舟", "青崖", "听雨", "照夜", "长风", "归云", "惊鸿", "秋水", "横雪", "寻梅", "渡川", "鸣泉"]

const HERO_ORDER := ["scholar", "xia"]
const HEROES := {
	"scholar": {
		"id": "scholar",
		"name": "书生",
		"glyph": "书",
		"title": "墨诀远射",
		"role_label": "远程控场",
		"focus": "稳扎稳打地收束偏旁，让合字更早成型。",
		"tags": ["索敌", "连射", "成字稳定"],
		"weapon": "笔阵 / 远程自动索敌",
		"description": "更稳定地积累偏旁，靠连射字诀把字海撑开。",
		"role": "ranged",
		"accent": Color(0.85, 0.64, 0.33, 1.0),
		"body": Color(0.91, 0.9, 0.84, 1.0),
		"move_speed": 6.2,
		"max_health": 100.0,
		"attack_interval": 0.58,
		"attack_damage": 15.0,
		"attack_range": 15.0,
		"projectile_speed": 21.0,
		"collect_radius": 4.2
	},
	"xia": {
		"id": "xia",
		"name": "侠",
		"glyph": "侠",
		"title": "长剑近战",
		"role_label": "近战斩阵",
		"focus": "压进敌潮里以斩势拆阵，让 `刂` 直接转成武器成长。",
		"tags": ["贴脸", "爆发", "剑势成长"],
		"weapon": "巨刃 / 扇形斩击",
		"description": "贴脸斩碎字灵，`刂` 会直接夸张地放大剑势。",
		"role": "melee",
		"accent": Color(0.76, 0.23, 0.18, 1.0),
		"body": Color(0.89, 0.86, 0.79, 1.0),
		"move_speed": 6.7,
		"max_health": 128.0,
		"attack_interval": 0.82,
		"attack_damage": 20.0,
		"attack_range": 4.4,
		"projectile_speed": 0.0,
		"collect_radius": 3.9
	}
}

const RECIPE_ORDER := ["ming", "xiu", "hai"]
const RECIPES := {
	"ming": {
		"id": "ming",
		"display": "明",
		"radicals": ["日", "月"],
		"title": "明光成字",
		"description": "强化主攻节奏。书生会多发字诀，侠会扩大剑势。",
		"color": Color(1.0, 0.84, 0.4, 1.0),
		"max_level": 3,
		"word_id": "ming_guang"
	},
	"xiu": {
		"id": "xiu",
		"display": "休",
		"radicals": ["亻", "木"],
		"title": "休息成字",
		"description": "给角色带来持续回气，拖长生存曲线。",
		"color": Color(0.56, 0.9, 0.68, 1.0),
		"max_level": 3,
		"word_id": "xiu_yang"
	},
	"hai": {
		"id": "hai",
		"display": "海",
		"radicals": ["氵", "每"],
		"title": "海潮成字",
		"description": "定期引爆墨潮波纹，处理近身杂兵。",
		"color": Color(0.45, 0.83, 1.0, 1.0),
		"max_level": 3,
		"word_id": "hai_xiao"
	}
}

const WORD_ORDER := ["ming_guang", "xiu_yang", "hai_xiao"]
const WORDS := {
	"ming_guang": {
		"id": "ming_guang",
		"display": "明光",
		"title": "明光词技",
		"description": "让主武器真正进入成词阶段。书生追加字诀，侠扩大斩势。",
		"recipe_id": "ming",
		"unlock_cost": 2,
		"max_level": 2,
		"color": Color(1.0, 0.9, 0.58, 1.0)
	},
	"xiu_yang": {
		"id": "xiu_yang",
		"display": "休养",
		"title": "休养词技",
		"description": "把回血推进成稳定续航，并抬高容错上限。",
		"recipe_id": "xiu",
		"unlock_cost": 2,
		"max_level": 2,
		"color": Color(0.68, 1.0, 0.76, 1.0)
	},
	"hai_xiao": {
		"id": "hai_xiao",
		"display": "海啸",
		"title": "海啸词技",
		"description": "将海潮磨成更凶猛的墨浪，周期更短、范围更大。",
		"recipe_id": "hai",
		"unlock_cost": 2,
		"max_level": 2,
		"color": Color(0.62, 0.9, 1.0, 1.0)
	}
}

const ENEMY_ORDER := ["basic", "swift", "tank", "archer", "assassin", "cavalry", "ritualist", "elite", "boss"]
const ENEMIES := {
	"basic": {
		"id": "basic",
		"name": "魇卒",
		"glyph": "魇",
		"title": "正面追击",
		"summary": "最基础的近身字灵，直接压进来逼你持续走位。",
		"warning": "没有额外预警，危险来自数量和贴身碰撞。",
		"counter": "优先在开场用来积累偏旁，不要让它们把撤退路线堵死。"
	},
	"swift": {
		"id": "swift",
		"name": "疾卒",
		"glyph": "迅",
		"title": "高速侧切",
		"summary": "速度更快，会带着横移幅度切进你的侧翼。",
		"warning": "没有明显起手，但移动轨迹更飘、更容易补位。",
		"counter": "横向拉扯时别停步，优先清掉它避免被包夹。"
	},
	"tank": {
		"id": "tank",
		"name": "墨甲",
		"glyph": "甲",
		"title": "重装顶线",
		"summary": "血厚、体型大，专门拖慢清场节奏并替后排争时间。",
		"warning": "主要靠高耐久压近，没有单独技能预警。",
		"counter": "别被它黏住路线，用范围技能顺手磨血，再先拆后排。"
	},
	"archer": {
		"id": "archer",
		"name": "弓手",
		"glyph": "弓",
		"title": "远程牵制",
		"summary": "会保持距离横移，并在中远距离持续发射投射物。",
		"warning": "进入射程后会短暂起手，再打出一发直线字矢。",
		"counter": "优先切断它的站位空间，不要在远处和它长时间对线。"
	},
	"assassin": {
		"id": "assassin",
		"name": "忍",
		"glyph": "忍",
		"title": "突刺游走",
		"summary": "会在中距离侧移找角度，然后沿直线突然突刺。",
		"warning": "突刺前地面会出现偏紫色短线预警。",
		"counter": "看见线就斜切离开，不要沿着预警方向后退。"
	},
	"cavalry": {
		"id": "cavalry",
		"name": "墨骑",
		"glyph": "骑",
		"title": "重骑冲锋",
		"summary": "体格更大，会用长距离直线冲锋直接切穿战场。",
		"warning": "冲锋前会铺出更长更宽的路线预警，命中还会造成短暂晕眩。",
		"counter": "先横向离开冲锋线，再利用它冲过头后的空档反打。"
	},
	"ritualist": {
		"id": "ritualist",
		"name": "阵师",
		"glyph": "阵",
		"title": "地阵施压",
		"summary": "保持距离布置地面字阵，把安全区域一点点切碎。",
		"warning": "会在脚下或附近生成圆形预警，随后变成持续危险区域。",
		"counter": "不要贪输出，先把脚下净空，再考虑继续拉怪。"
	},
	"elite": {
		"id": "elite",
		"name": "魁首",
		"glyph": "魁",
		"title": "技能轮替",
		"summary": "会轮换爆圈、横排弹幕、梅花散射与大型冲锋，是混编战的节奏点。",
		"warning": "不同技能有不同预警，其中爆圈和冲锋会先把地面标出来。",
		"counter": "看到精英先留心技能轮次，别在处理杂兵时被第二段技能吃满。"
	},
	"boss": {
		"id": "boss",
		"name": "卷主",
		"glyph": "卷",
		"title": "残卷首领",
		"summary": "卷主会把禁阵、扇形弹幕、直线冲锋与十字裂阵叠在一起。",
		"warning": "大范围禁阵和冲锋都有明确预警，其他弹幕则会在短起手后同时压来。",
		"counter": "先保命躲掉大范围技能，再在卷主技能收束后的空档追回输出。"
	}
}

const RADICAL_ORDER := ["亻", "木", "日", "月", "氵", "每", "刂"]
const RADICAL_COLORS := {
	"亻": Color(0.88, 0.71, 0.55, 1.0),
	"木": Color(0.49, 0.82, 0.56, 1.0),
	"日": Color(1.0, 0.78, 0.32, 1.0),
	"月": Color(0.68, 0.79, 1.0, 1.0),
	"氵": Color(0.42, 0.82, 1.0, 1.0),
	"每": Color(0.86, 0.56, 1.0, 1.0),
	"刂": Color(1.0, 0.45, 0.38, 1.0)
}
const RADICALS := {
	"亻": {
		"display": "亻",
		"name": "单人旁",
		"description": "和 `木` 一起合成「休」，偏向续航与回复。",
		"recipe_id": "xiu"
	},
	"木": {
		"display": "木",
		"name": "木字旁",
		"description": "补足「休」的另一半，也能继续抬升休养系。",
		"recipe_id": "xiu"
	},
	"日": {
		"display": "日",
		"name": "日字旁",
		"description": "和 `月` 组成「明」，主攻输出节奏。",
		"recipe_id": "ming"
	},
	"月": {
		"display": "月",
		"name": "月字旁",
		"description": "推进「明」线，让武器更快进入成词。",
		"recipe_id": "ming"
	},
	"氵": {
		"display": "氵",
		"name": "三点水",
		"description": "和 `每` 合成「海」，走范围波纹与清场路线。",
		"recipe_id": "hai"
	},
	"每": {
		"display": "每",
		"name": "每字底",
		"description": "补齐「海」字，也能继续磨成更高阶的海潮词技。",
		"recipe_id": "hai"
	},
	"刂": {
		"display": "刂",
		"name": "立刀旁",
		"description": "独立强化武器锋势。侠会直接长剑，书生会强化笔锋。",
		"recipe_id": ""
	}
}

var selected_hero := "scholar"
var last_run_summary: Dictionary = {}
var pending_battle_intro: Dictionary = {}
var chapter_progress: Dictionary = {}
var local_leaderboard: Array[Dictionary] = []
var local_leaderboard_loaded: bool = false
var last_recorded_leaderboard_run: Dictionary = {}


func _ready() -> void:
	_load_local_leaderboard()


func select_hero(hero_id: String) -> void:
	if HEROES.has(hero_id):
		selected_hero = hero_id


func prepare_battle_intro(entry_source: String = "menu") -> void:
	var hero_data: Dictionary = get_selected_hero()
	pending_battle_intro = {
		"entry": entry_source,
		"title": "残卷一·入墨",
		"subtitle": "%s 执笔，落字入卷。" % String(hero_data["name"]),
		"glyph": String(hero_data["glyph"]),
		"hero_id": String(hero_data["id"])
	}
	chapter_progress = {
		"title": "残卷一·入墨",
		"completed_bosses": 0,
		"chapter_complete": false
	}


func consume_battle_intro() -> Dictionary:
	var data: Dictionary = pending_battle_intro.duplicate(true)
	pending_battle_intro = {}
	return data


func get_selected_hero() -> Dictionary:
	return get_hero_data(selected_hero)


func get_hero_data(hero_id: String) -> Dictionary:
	var fallback: Dictionary = HEROES["scholar"]
	if HEROES.has(hero_id):
		return HEROES[hero_id].duplicate(true)
	return fallback.duplicate(true)


func get_recipe_data(recipe_id: String) -> Dictionary:
	var fallback: Dictionary = RECIPES["ming"]
	if RECIPES.has(recipe_id):
		return RECIPES[recipe_id].duplicate(true)
	return fallback.duplicate(true)


func get_word_data(word_id: String) -> Dictionary:
	var fallback: Dictionary = WORDS["ming_guang"]
	if WORDS.has(word_id):
		return WORDS[word_id].duplicate(true)
	return fallback.duplicate(true)


func get_enemy_data(enemy_id: String) -> Dictionary:
	var fallback: Dictionary = ENEMIES["basic"]
	if ENEMIES.has(enemy_id):
		return ENEMIES[enemy_id].duplicate(true)
	return fallback.duplicate(true)


func get_radical_data(radical: String) -> Dictionary:
	var fallback: Dictionary = RADICALS["日"]
	if RADICALS.has(radical):
		return RADICALS[radical].duplicate(true)
	return fallback.duplicate(true)


func get_recipe_id_for_radical(radical: String) -> String:
	if RADICALS.has(radical):
		return String(RADICALS[radical]["recipe_id"])
	return ""


func build_empty_radicals() -> Dictionary:
	var radicals: Dictionary = {}
	for radical_variant in RADICAL_ORDER:
		var radical := String(radical_variant)
		radicals[radical] = 0
	return radicals


func build_empty_recipe_levels() -> Dictionary:
	var data: Dictionary = {}
	for recipe_id_variant in RECIPE_ORDER:
		var recipe_id := String(recipe_id_variant)
		data[recipe_id] = 0
	return data


func build_empty_word_levels() -> Dictionary:
	var data: Dictionary = {}
	for word_id_variant in WORD_ORDER:
		var word_id := String(word_id_variant)
		data[word_id] = 0
	return data


func build_empty_word_progress() -> Dictionary:
	var data: Dictionary = {}
	for word_id_variant in WORD_ORDER:
		var word_id := String(word_id_variant)
		data[word_id] = 0
	return data


func build_empty_enemy_counts() -> Dictionary:
	var data: Dictionary = {}
	for enemy_id_variant in ENEMY_ORDER:
		var enemy_id := String(enemy_id_variant)
		data[enemy_id] = 0
	return data


func record_local_run(summary: Dictionary, hero_id: String = selected_hero) -> void:
	_ensure_local_leaderboard_loaded()

	var recorded_at: int = int(Time.get_unix_time_from_system())
	var normalized_entry := _normalize_leaderboard_entry({
		"hero_id": hero_id,
		"hero_name": String(get_hero_data(hero_id).get("name", "书生")),
		"player_name": _resolve_run_player_name(String(summary.get("player_name", "")), hero_id, recorded_at),
		"elapsed": float(summary.get("elapsed", 0.0)),
		"kills": int(summary.get("kills", 0)),
		"threat": int(summary.get("threat", 1)),
		"level": int(summary.get("level", 1)),
		"bosses": int(summary.get("bosses", 0)),
		"chapter_complete": bool(summary.get("chapter_complete", false)),
		"radicals": summary.get("radicals", {}),
		"recipes": summary.get("recipes", {}),
		"words": summary.get("words", {}),
		"blade_level": int(summary.get("blade_level", 0)),
		"enemy_kills": summary.get("enemy_kills", {}),
		"recorded_at": recorded_at
	})
	if normalized_entry.is_empty():
		last_recorded_leaderboard_run = {}
		return

	local_leaderboard.append(normalized_entry)
	_sort_local_leaderboard()
	while local_leaderboard.size() > LOCAL_LEADERBOARD_LIMIT:
		local_leaderboard.pop_back()
	_save_local_leaderboard()
	last_recorded_leaderboard_run = {}
	for entry in local_leaderboard:
		if int(entry.get("recorded_at", 0)) != recorded_at:
			continue
		if String(entry.get("hero_id", selected_hero)) != hero_id:
			continue
		last_recorded_leaderboard_run = entry.duplicate(true)
		break


func get_local_leaderboard(limit: int = 5) -> Array[Dictionary]:
	_ensure_local_leaderboard_loaded()

	var entries: Array[Dictionary] = []
	var safe_limit := mini(limit, local_leaderboard.size())
	for index in range(safe_limit):
		entries.append(local_leaderboard[index].duplicate(true))
	return entries


func get_last_recorded_leaderboard_run() -> Dictionary:
	return last_recorded_leaderboard_run.duplicate(true)


func update_last_recorded_run_player_name(raw_name: String) -> String:
	if last_recorded_leaderboard_run.is_empty():
		return ""

	var hero_id := String(last_recorded_leaderboard_run.get("hero_id", selected_hero))
	var recorded_at: int = int(last_recorded_leaderboard_run.get("recorded_at", 0))
	var resolved_name := _resolve_run_player_name(raw_name, hero_id, recorded_at)
	var updated := false

	for index in range(local_leaderboard.size()):
		var entry: Dictionary = local_leaderboard[index]
		if int(entry.get("recorded_at", 0)) != recorded_at:
			continue
		if String(entry.get("hero_id", selected_hero)) != hero_id:
			continue
		entry["player_name"] = resolved_name
		local_leaderboard[index] = entry
		updated = true
		break

	last_recorded_leaderboard_run["player_name"] = resolved_name
	if updated:
		_save_local_leaderboard()
	return resolved_name


func _ensure_local_leaderboard_loaded() -> void:
	if not local_leaderboard_loaded:
		_load_local_leaderboard()


func _load_local_leaderboard() -> void:
	local_leaderboard.clear()
	local_leaderboard_loaded = true

	if not FileAccess.file_exists(LOCAL_LEADERBOARD_PATH):
		return

	var file := FileAccess.open(LOCAL_LEADERBOARD_PATH, FileAccess.READ)
	if file == null:
		return

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	var raw_entries: Variant = []
	if parsed is Dictionary:
		raw_entries = parsed.get("entries", [])
	elif parsed is Array:
		raw_entries = parsed

	if raw_entries is Array:
		for raw_entry in raw_entries:
			var normalized_entry := _normalize_leaderboard_entry(raw_entry)
			if not normalized_entry.is_empty():
				local_leaderboard.append(normalized_entry)
	_sort_local_leaderboard()


func _save_local_leaderboard() -> void:
	var file := FileAccess.open(LOCAL_LEADERBOARD_PATH, FileAccess.WRITE)
	if file == null:
		return

	var payload: Array[Dictionary] = []
	for entry in local_leaderboard:
		payload.append(entry.duplicate(true))
	file.store_string(JSON.stringify({"entries": payload}))


func _normalize_leaderboard_entry(raw_entry: Variant) -> Dictionary:
	if not (raw_entry is Dictionary):
		return {}

	var data := raw_entry as Dictionary
	var hero_id := String(data.get("hero_id", selected_hero))
	var hero_data: Dictionary = get_hero_data(hero_id)
	var recorded_at: int = maxi(0, int(data.get("recorded_at", 0)))
	var entry: Dictionary = {
		"hero_id": hero_id,
		"hero_name": String(data.get("hero_name", hero_data.get("name", "书生"))),
		"player_name": _resolve_run_player_name(String(data.get("player_name", "")), hero_id, recorded_at),
		"elapsed": maxf(0.0, float(data.get("elapsed", 0.0))),
		"kills": maxi(0, int(data.get("kills", 0))),
		"threat": maxi(1, int(data.get("threat", 1))),
		"level": maxi(1, int(data.get("level", 1))),
		"bosses": maxi(0, int(data.get("bosses", 0))),
		"chapter_complete": bool(data.get("chapter_complete", false)),
		"radicals": _normalize_run_counts(data.get("radicals", {}), RADICAL_ORDER),
		"recipes": _normalize_run_counts(data.get("recipes", {}), RECIPE_ORDER),
		"words": _normalize_run_counts(data.get("words", {}), WORD_ORDER),
		"blade_level": maxi(0, int(data.get("blade_level", 0))),
		"enemy_kills": _normalize_run_counts(data.get("enemy_kills", {}), ENEMY_ORDER),
		"recorded_at": recorded_at
	}
	return entry


func _resolve_run_player_name(raw_name: String, hero_id: String, recorded_at: int) -> String:
	var trimmed_name := raw_name.strip_edges()
	if not trimmed_name.is_empty():
		return trimmed_name
	return _build_fallback_player_name(hero_id, recorded_at)


func _build_fallback_player_name(hero_id: String, recorded_at: int) -> String:
	var base_key := "%s:%d" % [hero_id, recorded_at]
	var surname_index: int = abs(hash("%s:surname" % base_key)) % FALLBACK_RUN_NAME_SURNAMES.size()
	var given_index: int = abs(hash("%s:given" % base_key)) % FALLBACK_RUN_NAME_GIVENS.size()
	return "%s%s" % [
		FALLBACK_RUN_NAME_SURNAMES[surname_index],
		FALLBACK_RUN_NAME_GIVENS[given_index]
	]


func _normalize_run_counts(raw_counts: Variant, order: Array) -> Dictionary:
	var counts: Dictionary = {}
	for key_variant in order:
		var key := String(key_variant)
		counts[key] = 0

	if raw_counts is Dictionary:
		var raw_dictionary := raw_counts as Dictionary
		for key_variant in order:
			var key := String(key_variant)
			counts[key] = maxi(0, int(raw_dictionary.get(key, 0)))

	return counts


func _sort_local_leaderboard() -> void:
	local_leaderboard.sort_custom(Callable(self, "_sort_leaderboard_entries"))


func _sort_leaderboard_entries(left: Dictionary, right: Dictionary) -> bool:
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
