extends Node

const LAUNCHER_SCENE := "res://scenes/app/launcher.tscn"
const ZIHAI_MENU_SCENE := "res://scenes/app/zihai_menu.tscn"
const ZIHAI_BATTLE_SCENE := "res://scenes/battle/zihai_battle.tscn"
const LOCAL_LEADERBOARD_PATH := "user://local_leaderboard.json"
const LOCAL_LEADERBOARD_LIMIT := 12

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


func record_local_run(summary: Dictionary, hero_id: String = selected_hero) -> void:
	_ensure_local_leaderboard_loaded()

	var normalized_entry := _normalize_leaderboard_entry({
		"hero_id": hero_id,
		"hero_name": String(get_hero_data(hero_id).get("name", "书生")),
		"elapsed": float(summary.get("elapsed", 0.0)),
		"kills": int(summary.get("kills", 0)),
		"threat": int(summary.get("threat", 1)),
		"level": int(summary.get("level", 1)),
		"bosses": int(summary.get("bosses", 0)),
		"chapter_complete": bool(summary.get("chapter_complete", false)),
		"recorded_at": int(Time.get_unix_time_from_system())
	})
	if normalized_entry.is_empty():
		return

	local_leaderboard.append(normalized_entry)
	_sort_local_leaderboard()
	while local_leaderboard.size() > LOCAL_LEADERBOARD_LIMIT:
		local_leaderboard.pop_back()
	_save_local_leaderboard()


func get_local_leaderboard(limit: int = 5) -> Array[Dictionary]:
	_ensure_local_leaderboard_loaded()

	var entries: Array[Dictionary] = []
	var safe_limit := mini(limit, local_leaderboard.size())
	for index in range(safe_limit):
		entries.append(local_leaderboard[index].duplicate(true))
	return entries


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
	var entry: Dictionary = {
		"hero_id": hero_id,
		"hero_name": String(data.get("hero_name", hero_data.get("name", "书生"))),
		"elapsed": maxf(0.0, float(data.get("elapsed", 0.0))),
		"kills": maxi(0, int(data.get("kills", 0))),
		"threat": maxi(1, int(data.get("threat", 1))),
		"level": maxi(1, int(data.get("level", 1))),
		"bosses": maxi(0, int(data.get("bosses", 0))),
		"chapter_complete": bool(data.get("chapter_complete", false)),
		"recorded_at": maxi(0, int(data.get("recorded_at", 0)))
	}
	return entry


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
