extends Node

const LAUNCHER_SCENE := "res://scenes/app/launcher.tscn"
const ZIHAI_MENU_SCENE := "res://scenes/app/zihai_menu.tscn"
const ZIHAI_BATTLE_SCENE := "res://scenes/battle/zihai_battle.tscn"
const LOCAL_LEADERBOARD_PATH := "user://local_leaderboard.json"
const LEADERBOARD_IDENTITY_PATH := "user://leaderboard_identity.json"
const BATTLE_SETTINGS_PATH := "user://battle_settings.json"
const LAUNCHER_THEME_PATH := "user://launcher_theme.json"
const LOCAL_LEADERBOARD_LIMIT := 20
const LEADERBOARD_NAME_LIMIT := 18
const DEFAULT_LAUNCHER_THEME := "night-ink"
const LAUNCHER_THEME_IDS := ["paper-ink", "night-ink"]
const DEFAULT_LAUNCHER_LANGUAGE := "zh"
const LAUNCHER_LANGUAGE_IDS := ["zh", "en"]
const FALLBACK_RUN_NAME_SURNAMES := ["沈", "陆", "谢", "顾", "裴", "苏", "闻", "叶", "秦", "燕", "柳", "程"]
const FALLBACK_RUN_NAME_GIVENS := ["孤舟", "青崖", "听雨", "照夜", "长风", "归云", "惊鸿", "秋水", "横雪", "寻梅", "渡川", "鸣泉"]
const BATTLE_PERFORMANCE_MODES := ["performance", "balanced", "quality"]
const BATTLE_AMBIENT_DENSITIES := ["off", "medium", "high"]
const DEFAULT_BATTLE_SETTINGS := {
	"performance_mode": "balanced",
	"enemy_health_bars": true,
	"ambient_glyph_density": "medium",
	"visual_effects": true,
	"enemy_detail": true
}
const BATTLE_INPUT_BINDINGS := {
	"move_forward": [KEY_W, KEY_UP],
	"move_back": [KEY_S, KEY_DOWN],
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"interact": [KEY_E],
	"toggle_map": [KEY_M, KEY_TAB],
	"restart_run": [KEY_R],
	"return_menu": [KEY_ESCAPE]
}

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
		"record_title": "以文试阵的书生",
		"record_body": "他把残卷当成一张还在回应的答卷，不抢先预设唯一解，而是靠稳、全与持续成字把局势慢慢写开。",
		"record_excerpt": "先落一笔，再看残卷怎么回我。",
		"record_source": "残卷札记",
		"trait_label": "白纸起卷",
		"trait_description": "没有近战压阵负担，更适合从第一枚偏旁开始把任意成字路线慢慢养大，稳稳磨到词技。",
		"active_skill_glyph": "阵",
		"active_skill_name": "镇纸阵",
		"active_skill_description": "对照 hanziHero web 原型，书生会在身前压下一道纸阵，推开敌人，并留下兼具伤害、减速与站位护持的字阵区域。",
		"active_skill_cooldown": 13.5,
		"route_hint": "先凑出第一枚成字，再决定往续航、范围还是锁敌路线继续磨词；书生最擅长把中盘 build 写稳。",
		"starting_radicals": [],
		"progression_cards": [
			{
				"title": "开卷补笔",
				"description": "没有固定起手时，先顺着第一批掉落把一条稳定清线或续航线补齐，再决定这一局往哪条字路深写。",
				"tags": ["明", "海", "休"]
			},
			{
				"title": "中盘续写",
				"description": "第一枚成字站稳后，再补控场或锁敌线，把远程安全距离慢慢写出来，不急着把每条支线都摊开。",
				"tags": ["雷", "明", "海"]
			},
			{
				"title": "砚台磨词",
				"description": "先把当前最稳的主线磨进词技，让它接手中盘节奏；书生更适合把一条成熟路线先写深，而不是平均分散。",
				"tags": ["明月", "海啸", "休养"]
			}
		],
		"build_route_cards": [
				{
					"glyph": "守",
					"title": "墨守流",
					"subtitle": "续航 / 站场",
					"description": "对照 web 原型里的路线选择，更偏向木、水、田与月，适合把这一局往续航、站场和稳住纸阵区域慢慢写深。",
					"tags": ["木", "氵", "田", "月"],
					"source_relics": ["玉简", "墨壶"],
					"source_words": ["林海卷", "明月引"]
				},
				{
					"glyph": "雷",
				"title": "雷阵流",
				"subtitle": "齐射 / 控场",
				"description": "更偏向雨、田、日与水，适合把书生的远程安全距离扩成更稳的齐射节奏和控场覆盖。",
				"tags": ["雨", "田", "日", "氵"],
				"source_relics": ["惊墨钟", "斗杓"],
				"source_words": ["雷雨场", "昌明轮"]
			}
		],
		"select_quotes": [
			"先落一笔，再看残卷怎么回我。",
			"偏旁会自己说话，我只负责把它们写出来。",
			"这一局适合稳着写，把字慢慢养成势。"
		],
		"battle_quotes": {
			"intro": [
				"字先安下来，局面才会听话。",
				"先落一笔，再看这一卷怎么回我。"
			],
			"recipe_unlock": [
				"成字了，笔势终于接上。",
				"字已经开口，接下来该它替我清路。"
			],
			"word_unlock": [
				"词意接住了，这一局开始成章。",
				"词技入卷，后面的节奏就稳了。"
			],
			"low_health": [
				"别乱笔，先借一步缓气。",
				"气还没散，收一圈残纸就能稳住。"
			],
			"boss_defeat": [
				"这一重压过去了，先把散墨收回来。",
				"卷主既退，正好把字势续上。"
			],
			"chapter_complete": [
				"这一卷先写到这里，气还没散。",
				"残卷先稳住了，后面还能继续磨。"
			]
		},
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
		"record_title": "以近身护体写下侠字的人",
		"record_body": "他不是站在后线慢慢磨局的人，而是主动压进怪群里，用近战斩势把安全空间硬抢回来，让残卷像一场当面兑现的承诺。",
		"record_excerpt": "其言必信，其行必果，已诺必诚，不爱其躯，赴士之厄困。",
		"record_source": "《史记·游侠列传》",
		"trait_label": "近战压阵",
		"trait_description": "更高气血与贴脸斩击让他适合站在敌潮正面，把 `刂`、忍意和范围清场路线直接转成场面控制。",
		"active_skill_glyph": "斩",
		"active_skill_name": "断行斩",
		"active_skill_description": "对照 hanziHero web 原型，侠会沿当前方向疾斩突进，途中短暂无伤，并把路径上的敌人一并劈开。",
		"active_skill_cooldown": 8.8,
		"route_hint": "优先补足能稳住近身空间的成字线，再用剑势与波纹类技能把贴脸风险反转成压制。",
		"starting_radicals": ["亻", "心"],
		"progression_cards": [
			{
				"title": "开卷补笔",
				"description": "起手已经带着 `亻 / 心`，优先找 `木` 或 `刂`，尽快把能护体或爆发反压的第一枚成字写出来。",
				"tags": ["休", "忍"]
			},
			{
				"title": "中盘成势",
				"description": "近身空间稳住后，再补波纹、落雷或炎潮这类清群线，把贴脸风险反过来写成推进与压阵。",
				"tags": ["海", "雷", "炎"]
			},
			{
				"title": "砚台磨词",
				"description": "砚台优先磨能保命或帮近战开路的主线，让每次压进敌潮都更值；别等所有线都齐了再去磨词。",
				"tags": ["休养", "忍心", "海啸"]
			}
		],
		"build_route_cards": [
				{
					"glyph": "游",
					"title": "游侠流",
					"subtitle": "机动 / 主动",
					"description": "对照 web 原型里的路线选择，更偏向 `亻 / 刂 / 月 / 心`，让近身周转、切线腾挪与主动开路更顺手。",
					"tags": ["亻", "刂", "月", "心"],
					"source_relics": ["古印", "斗杓"],
					"source_words": ["明月引", "忍心诀"]
				},
			{
				"glyph": "烈",
				"title": "烈笔流",
				"subtitle": "爆发 / 近压",
				"description": "更偏向火、刂与心，适合把这一局往爆发、近压和更重的正面劈开推进去写。",
				"tags": ["火", "刂", "心", "炎 / 忍"],
				"source_relics": ["惊墨钟", "古印"],
				"source_words": ["忍心诀", "昌明轮"]
			}
		],
		"select_quotes": [
			"靠近一点，我替你把这一局劈开。",
			"侠字不躲在后面，先把人群压回去再说。",
			"今天这卷我来护着，你只管向前。"
		],
		"battle_quotes": {
			"intro": [
				"先压进去，这一页我来开。",
				"别退，靠近了才好把阵劈开。"
			],
			"recipe_unlock": [
				"字势上手了，接下来就看谁先断。",
				"成字成势，正好顺手继续压过去。"
			],
			"word_unlock": [
				"词技成了，这一局该轮到我追着他们打。",
				"词意一起，整片字潮都得让路。"
			],
			"low_health": [
				"还扛得住，给我一个空当就够。",
				"伤不碍事，先把最近这一群劈开。"
			],
			"boss_defeat": [
				"压住了，趁现在把场面抢回来。",
				"这一刀算清了，继续往前。"
			],
			"chapter_complete": [
				"这一卷先护住了，后面再继续开。",
				"卷先保住，手里的剑势还没停。"
			]
		},
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


func ensure_battle_input_actions() -> void:
	for action_name in BATTLE_INPUT_BINDINGS.keys():
		_ensure_input_action(action_name, BATTLE_INPUT_BINDINGS[action_name])


func _ensure_input_action(action_name: StringName, keycodes: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	if InputMap.action_get_events(action_name).is_empty():
		for keycode in keycodes:
			var event := InputEventKey.new()
			event.physical_keycode = keycode
			InputMap.action_add_event(action_name, event)

const RECIPE_ORDER := ["ming", "xiu", "hai", "lei", "ren", "yan"]
const RECIPES := {
	"ming": {
		"id": "ming",
		"display": "明",
		"radicals": ["日", "月"],
		"title": "双轮成字",
		"description": "强化主攻节奏，并周期放出日月追轮切开正面通路。",
		"color": Color(1.0, 0.84, 0.4, 1.0),
		"max_level": 3,
		"word_id": "ming_guang"
	},
	"xiu": {
		"id": "xiu",
		"display": "休",
		"radicals": ["亻", "木"],
		"title": "林息成字",
		"description": "周期回复气血并震开近身敌人，拖长生存曲线。",
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
	},
	"lei": {
		"id": "lei",
		"display": "雷",
		"radicals": ["雨", "田"],
		"title": "落雷成字",
		"description": "周期锁定最近敌群，以落雷重击压住中场。",
		"color": Color(0.76, 0.9, 1.0, 1.0),
		"max_level": 3,
		"word_id": "lei_yu"
	},
	"ren": {
		"id": "ren",
		"display": "忍",
		"radicals": ["刂", "心"],
		"title": "忍意成字",
		"description": "半血以下进入忍意，攻速、伤害和移速同步提升。",
		"color": Color(0.96, 0.58, 0.7, 1.0),
		"max_level": 3,
		"word_id": "ren_xin"
	},
	"yan": {
		"id": "yan",
		"display": "炎",
		"radicals": ["火", "火"],
		"title": "炎潮成字",
		"description": "周期向四面八方喷发炎字弹幕，烧开包围圈。",
		"color": Color(1.0, 0.54, 0.34, 1.0),
		"max_level": 3,
		"word_id": "yan_chao"
	}
}

const WORD_ORDER := ["ming_guang", "xiu_yang", "hai_xiao", "lei_yu", "ren_xin", "yan_chao"]
const WORDS := {
	"ming_guang": {
		"id": "ming_guang",
		"display": "明月",
		"title": "明月引",
		"description": "双轮会追加追月齐射，主武器也会被明字一并抬高。",
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
	},
	"lei_yu": {
		"id": "lei_yu",
		"display": "雷雨",
		"title": "雷雨场",
		"description": "落雷命中后会继续扩散成雨场，把点杀推进成控场。",
		"recipe_id": "lei",
		"unlock_cost": 2,
		"max_level": 2,
		"color": Color(0.82, 0.94, 1.0, 1.0)
	},
	"ren_xin": {
		"id": "ren_xin",
		"display": "忍心",
		"title": "忍心诀",
		"description": "忍意激活时会回复气血，并周期斩出震心余波。",
		"recipe_id": "ren",
		"unlock_cost": 2,
		"max_level": 2,
		"color": Color(1.0, 0.76, 0.84, 1.0)
	},
	"yan_chao": {
		"id": "yan_chao",
		"display": "炎潮",
		"title": "炎潮卷",
		"description": "让炎字弹幕更密更急，命中处还会迸出灼浪。",
		"recipe_id": "yan",
		"unlock_cost": 2,
		"max_level": 2,
		"color": Color(1.0, 0.74, 0.52, 1.0)
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

const RADICAL_ORDER := ["亻", "木", "日", "月", "氵", "每", "雨", "田", "心", "火", "刂"]
const RADICAL_COLORS := {
	"亻": Color(0.88, 0.71, 0.55, 1.0),
	"木": Color(0.49, 0.82, 0.56, 1.0),
	"日": Color(1.0, 0.78, 0.32, 1.0),
	"月": Color(0.68, 0.79, 1.0, 1.0),
	"氵": Color(0.42, 0.82, 1.0, 1.0),
	"每": Color(0.86, 0.56, 1.0, 1.0),
	"雨": Color(0.72, 0.9, 1.0, 1.0),
	"田": Color(0.74, 0.82, 0.62, 1.0),
	"心": Color(1.0, 0.58, 0.72, 1.0),
	"火": Color(1.0, 0.48, 0.28, 1.0),
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
	"雨": {
		"display": "雨",
		"name": "雨字头",
		"description": "和 `田` 组成「雷」，走锁敌落雷与中场控场路线。",
		"recipe_id": "lei"
	},
	"田": {
		"display": "田",
		"name": "田字格",
		"description": "补齐「雷」的地格，也能继续磨成雷雨场。",
		"recipe_id": "lei"
	},
	"心": {
		"display": "心",
		"name": "心字底",
		"description": "与 `刂` 合成「忍」，把残血换成更凶的压阵节奏。",
		"recipe_id": "ren"
	},
	"火": {
		"display": "火",
		"name": "火字旁",
		"description": "双火成「炎」，会把四周写成一圈炎潮弹幕。",
		"recipe_id": "yan"
	},
	"刂": {
		"display": "刂",
		"name": "立刀旁",
		"description": "既强化武器锋势，也能和 `心` 合成「忍」。",
		"recipe_id": "ren"
	}
}

const QUICK_START_PRESETS := {
	1: {
		"start_wave": 1,
		"title": "残卷一·入墨",
		"subtitle_template": "%s 执笔，落字入卷。",
		"tip": "先收第一枚偏旁，尽快合出首个成字。",
		"recordable": true,
		"elapsed_time": 0.0,
		"level": 1,
		"experience": 0,
		"experience_target": 4,
		"radicals": {},
		"recipes": {},
		"words": {},
		"word_progress": {},
		"blade_level": 0
	},
	10: {
		"start_wave": 10,
		"title": "残卷十·试阵",
		"subtitle_template": "%s 直接切入第 10 波试阵。",
		"tip": "带着一套中盘成长直接入卷，重点检查混编敌潮与地面预警节奏。",
		"recordable": false,
		"elapsed_time": 270.0,
		"level": 7,
		"experience": 0,
		"experience_target": 22,
		"radicals": {
			"亻": 1,
			"木": 1,
			"日": 1,
			"月": 1,
			"氵": 1,
			"每": 0,
			"雨": 1,
			"田": 0,
			"心": 0,
			"火": 1,
			"刂": 1
		},
		"recipes": {
			"ming": 2,
			"xiu": 1,
			"hai": 1,
			"lei": 1
		},
		"words": {
			"ming_guang": 1
		},
		"word_progress": {
			"xiu_yang": 1,
			"hai_xiao": 1
		},
		"blade_level": 1
	},
	20: {
		"start_wave": 20,
		"title": "残卷二十·压测",
		"subtitle_template": "%s 直接切入第 20 波压测。",
		"tip": "带着更完整的中后期 build 进入高压波次，用来检查精英、大潮与 HUD 节奏。",
		"recordable": false,
		"elapsed_time": 570.0,
		"level": 11,
		"experience": 0,
		"experience_target": 36,
		"radicals": {
			"亻": 1,
			"木": 1,
			"日": 1,
			"月": 1,
			"氵": 1,
			"每": 1,
			"雨": 1,
			"田": 1,
			"心": 1,
			"火": 2,
			"刂": 2
		},
		"recipes": {
			"ming": 3,
			"xiu": 2,
			"hai": 2,
			"lei": 3,
			"ren": 3,
			"yan": 2
		},
		"words": {
			"ming_guang": 2,
			"xiu_yang": 1,
			"hai_xiao": 1,
			"lei_yu": 1,
			"ren_xin": 1
		},
		"word_progress": {
			"yan_chao": 1
		},
		"blade_level": 2
	}
}

var selected_hero := "scholar"
var last_run_summary: Dictionary = {}
var pending_battle_intro: Dictionary = {}
var chapter_progress: Dictionary = {}
var leaderboard_identity: Dictionary = {}
var local_leaderboard: Array[Dictionary] = []
var local_leaderboard_loaded: bool = false
var last_recorded_leaderboard_run: Dictionary = {}
var battle_settings: Dictionary = DEFAULT_BATTLE_SETTINGS.duplicate(true)
var launcher_theme := DEFAULT_LAUNCHER_THEME
var launcher_language := DEFAULT_LAUNCHER_LANGUAGE


func _ready() -> void:
	_load_leaderboard_identity()
	_load_local_leaderboard()
	_load_battle_settings()
	_load_launcher_theme()


func select_hero(hero_id: String) -> void:
	if HEROES.has(hero_id):
		selected_hero = hero_id


func get_quick_start_preset(start_wave: int = 1) -> Dictionary:
	if QUICK_START_PRESETS.has(start_wave):
		return QUICK_START_PRESETS[start_wave].duplicate(true)
	return QUICK_START_PRESETS[1].duplicate(true)


func prepare_battle_intro(entry_source: String = "menu", start_wave: int = 1) -> void:
	var hero_data: Dictionary = get_selected_hero()
	var preset: Dictionary = get_quick_start_preset(start_wave)
	var intro_title := String(preset.get("title", "残卷一·入墨"))
	var subtitle_template := String(preset.get("subtitle_template", "%s 执笔，落字入卷。"))
	pending_battle_intro = {
		"entry": entry_source,
		"title": intro_title,
		"subtitle": subtitle_template % String(hero_data["name"]),
		"tip": String(preset.get("tip", "先收第一枚偏旁，尽快合出首个成字。")),
		"glyph": String(hero_data["glyph"]),
		"hero_id": String(hero_data["id"]),
		"start_wave": int(preset.get("start_wave", 1)),
		"recordable": bool(preset.get("recordable", true)),
		"start_preset": preset
	}
	chapter_progress = {
		"title": intro_title,
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


func get_hero_starting_radicals(hero_id: String = selected_hero) -> Array[String]:
	var hero_data: Dictionary = get_hero_data(hero_id)
	var radicals: Array[String] = []
	var raw_radicals: Variant = hero_data.get("starting_radicals", [])
	if raw_radicals is Array:
		for radical_variant in raw_radicals:
			var radical := String(radical_variant)
			if RADICALS.has(radical):
				radicals.append(radical)
	return radicals


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
	var start_wave := maxi(1, int(summary.get("start_wave", 1)))
	var leaderboard_view := _normalize_leaderboard_view(
		String(summary.get("leaderboard_view", "")),
		start_wave,
		bool(summary.get("recordable", true))
	)
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
		"start_wave": start_wave,
		"leaderboard_view": leaderboard_view,
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
		if int(entry.get("start_wave", 1)) != start_wave:
			continue
		if get_local_leaderboard_view(entry) != leaderboard_view:
			continue
		last_recorded_leaderboard_run = entry.duplicate(true)
		break


func get_local_leaderboard(limit: int = 5, view: String = "all") -> Array[Dictionary]:
	_ensure_local_leaderboard_loaded()

	var entries: Array[Dictionary] = []
	var normalized_view := _normalize_leaderboard_filter(view)
	for entry in local_leaderboard:
		if normalized_view != "all" and get_local_leaderboard_view(entry) != normalized_view:
			continue
		entries.append(entry.duplicate(true))
		if limit > 0 and entries.size() >= limit:
			break
	return entries


func get_local_leaderboard_count(view: String = "all") -> int:
	_ensure_local_leaderboard_loaded()

	var normalized_view := _normalize_leaderboard_filter(view)
	if normalized_view == "all":
		return local_leaderboard.size()

	var count := 0
	for entry in local_leaderboard:
		if get_local_leaderboard_view(entry) == normalized_view:
			count += 1
	return count


func get_local_leaderboard_view(entry: Dictionary) -> String:
	return _normalize_leaderboard_view(
		String(entry.get("leaderboard_view", "")),
		int(entry.get("start_wave", 1)),
		bool(entry.get("recordable", true))
	)


func get_last_recorded_leaderboard_run() -> Dictionary:
	return last_recorded_leaderboard_run.duplicate(true)


func get_leaderboard_identity() -> Dictionary:
	_ensure_leaderboard_identity_loaded()
	return leaderboard_identity.duplicate(true)


func get_leaderboard_device_alias() -> String:
	_ensure_leaderboard_identity_loaded()
	var device_alias := String(leaderboard_identity.get("device_alias", "")).strip_edges()
	if not device_alias.is_empty():
		return device_alias
	return _build_random_wuxia_name()


func get_preferred_leaderboard_name() -> String:
	_ensure_leaderboard_identity_loaded()
	var custom_name := String(leaderboard_identity.get("custom_name", "")).strip_edges()
	if not custom_name.is_empty():
		return custom_name
	return get_leaderboard_device_alias()


func sanitize_leaderboard_name(raw_name: String) -> String:
	return _sanitize_leaderboard_name(raw_name)


func set_preferred_leaderboard_name(raw_name: String) -> String:
	_ensure_leaderboard_identity_loaded()
	leaderboard_identity["custom_name"] = _sanitize_leaderboard_name(raw_name)
	if String(leaderboard_identity.get("device_alias", "")).strip_edges().is_empty():
		leaderboard_identity["device_alias"] = _build_random_wuxia_name()
	_save_leaderboard_identity()
	return get_preferred_leaderboard_name()


func clear_preferred_leaderboard_name() -> String:
	_ensure_leaderboard_identity_loaded()
	leaderboard_identity["custom_name"] = ""
	_save_leaderboard_identity()
	return get_preferred_leaderboard_name()


func generate_random_wuxia_name() -> String:
	return _build_random_wuxia_name()


func get_battle_settings() -> Dictionary:
	return battle_settings.duplicate(true)


func set_battle_setting(key: String, value: Variant) -> Dictionary:
	var next_settings := battle_settings.duplicate(true)
	next_settings[key] = value
	battle_settings = _sanitize_battle_settings(next_settings)
	_save_battle_settings()
	return battle_settings.duplicate(true)


func get_launcher_theme() -> String:
	return _sanitize_launcher_theme(launcher_theme)


func set_launcher_theme(raw_theme: String) -> String:
	launcher_theme = _sanitize_launcher_theme(raw_theme)
	_save_launcher_theme()
	return launcher_theme


func get_launcher_language() -> String:
	return _sanitize_launcher_language(launcher_language)


func set_launcher_language(raw_language: String) -> String:
	launcher_language = _sanitize_launcher_language(raw_language)
	_save_launcher_theme()
	return launcher_language


func update_last_recorded_run_player_name(raw_name: String) -> String:
	if last_recorded_leaderboard_run.is_empty():
		return ""

	var hero_id := String(last_recorded_leaderboard_run.get("hero_id", selected_hero))
	var recorded_at: int = int(last_recorded_leaderboard_run.get("recorded_at", 0))
	var start_wave := int(last_recorded_leaderboard_run.get("start_wave", 1))
	var leaderboard_view := get_local_leaderboard_view(last_recorded_leaderboard_run)
	var resolved_name := _resolve_run_player_name(raw_name, hero_id, recorded_at)
	var updated := false

	for index in range(local_leaderboard.size()):
		var entry: Dictionary = local_leaderboard[index]
		if int(entry.get("recorded_at", 0)) != recorded_at:
			continue
		if String(entry.get("hero_id", selected_hero)) != hero_id:
			continue
		if int(entry.get("start_wave", 1)) != start_wave:
			continue
		if get_local_leaderboard_view(entry) != leaderboard_view:
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


func _ensure_leaderboard_identity_loaded() -> void:
	if leaderboard_identity.is_empty():
		_load_leaderboard_identity()


func _load_leaderboard_identity() -> void:
	var should_save := not FileAccess.file_exists(LEADERBOARD_IDENTITY_PATH)
	var raw_identity: Variant = {}

	if FileAccess.file_exists(LEADERBOARD_IDENTITY_PATH):
		var file := FileAccess.open(LEADERBOARD_IDENTITY_PATH, FileAccess.READ)
		if file != null:
			var parsed: Variant = JSON.parse_string(file.get_as_text())
			if parsed is Dictionary:
				raw_identity = parsed
			else:
				should_save = true
		else:
			should_save = true

	var raw_dictionary: Dictionary = raw_identity if raw_identity is Dictionary else {}
	leaderboard_identity = {
		"device_alias": _sanitize_leaderboard_name(String(raw_dictionary.get("device_alias", ""))),
		"custom_name": _sanitize_leaderboard_name(String(raw_dictionary.get("custom_name", "")))
	}
	if String(leaderboard_identity.get("device_alias", "")).strip_edges().is_empty():
		leaderboard_identity["device_alias"] = _build_random_wuxia_name()
		should_save = true
	if should_save:
		_save_leaderboard_identity()


func _save_leaderboard_identity() -> void:
	var file := FileAccess.open(LEADERBOARD_IDENTITY_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(leaderboard_identity))


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


func _load_battle_settings() -> void:
	battle_settings = DEFAULT_BATTLE_SETTINGS.duplicate(true)

	if not FileAccess.file_exists(BATTLE_SETTINGS_PATH):
		return

	var file := FileAccess.open(BATTLE_SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return

	battle_settings = _sanitize_battle_settings(JSON.parse_string(file.get_as_text()))


func _save_battle_settings() -> void:
	var file := FileAccess.open(BATTLE_SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		return

	file.store_string(JSON.stringify(battle_settings))


func _load_launcher_theme() -> void:
	launcher_theme = DEFAULT_LAUNCHER_THEME
	launcher_language = DEFAULT_LAUNCHER_LANGUAGE

	if not FileAccess.file_exists(LAUNCHER_THEME_PATH):
		return

	var file := FileAccess.open(LAUNCHER_THEME_PATH, FileAccess.READ)
	if file == null:
		return

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		launcher_theme = _sanitize_launcher_theme(String(parsed.get("theme", launcher_theme)))
		launcher_language = _sanitize_launcher_language(String(parsed.get("language", launcher_language)))
	elif parsed is String:
		launcher_theme = _sanitize_launcher_theme(String(parsed))


func _save_launcher_theme() -> void:
	var file := FileAccess.open(LAUNCHER_THEME_PATH, FileAccess.WRITE)
	if file == null:
		return

	file.store_string(JSON.stringify({
		"theme": launcher_theme,
		"language": launcher_language
	}))


func _normalize_leaderboard_entry(raw_entry: Variant) -> Dictionary:
	if not (raw_entry is Dictionary):
		return {}

	var data := raw_entry as Dictionary
	var hero_id := String(data.get("hero_id", selected_hero))
	var hero_data: Dictionary = get_hero_data(hero_id)
	var recorded_at: int = maxi(0, int(data.get("recorded_at", 0)))
	var start_wave := maxi(1, int(data.get("start_wave", 1)))
	var leaderboard_view := _normalize_leaderboard_view(
		String(data.get("leaderboard_view", "")),
		start_wave,
		bool(data.get("recordable", true))
	)
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
		"start_wave": start_wave,
		"leaderboard_view": leaderboard_view,
		"recorded_at": recorded_at
	}
	return entry


func _normalize_leaderboard_filter(view: String) -> String:
	if view == "manual" or view == "test":
		return view
	return "all"


func _normalize_leaderboard_view(raw_view: String, start_wave: int = 1, main_board_eligible: bool = true) -> String:
	if raw_view == "test":
		return "test"
	if raw_view == "manual":
		return "manual"
	if start_wave > 1 or not main_board_eligible:
		return "test"
	return "manual"


func _resolve_run_player_name(raw_name: String, hero_id: String, recorded_at: int) -> String:
	var trimmed_name := raw_name.strip_edges()
	if not trimmed_name.is_empty():
		return _sanitize_leaderboard_name(trimmed_name)
	var preferred_name := get_preferred_leaderboard_name()
	if not preferred_name.is_empty():
		return preferred_name
	return _build_fallback_player_name(hero_id, recorded_at)


func _build_fallback_player_name(hero_id: String, recorded_at: int) -> String:
	var base_key := "%s:%d" % [hero_id, recorded_at]
	var surname_index: int = abs(hash("%s:surname" % base_key)) % FALLBACK_RUN_NAME_SURNAMES.size()
	var given_index: int = abs(hash("%s:given" % base_key)) % FALLBACK_RUN_NAME_GIVENS.size()
	return "%s%s" % [
		FALLBACK_RUN_NAME_SURNAMES[surname_index],
		FALLBACK_RUN_NAME_GIVENS[given_index]
	]


func _build_random_wuxia_name() -> String:
	var timestamp := Time.get_unix_time_from_system()
	var tick_seed := Time.get_ticks_usec()
	var surname_index: int = abs(hash("%d:%d:surname" % [timestamp, tick_seed])) % FALLBACK_RUN_NAME_SURNAMES.size()
	var given_index: int = abs(hash("%d:%d:given" % [tick_seed, timestamp])) % FALLBACK_RUN_NAME_GIVENS.size()
	return "%s%s" % [
		FALLBACK_RUN_NAME_SURNAMES[surname_index],
		FALLBACK_RUN_NAME_GIVENS[given_index]
	]


func _sanitize_leaderboard_name(raw_name: String) -> String:
	var compact := raw_name.strip_edges().replace("\r", " ").replace("\n", " ").replace("\t", " ")
	while compact.find("  ") != -1:
		compact = compact.replace("  ", " ")
	if compact.length() > LEADERBOARD_NAME_LIMIT:
		compact = compact.substr(0, LEADERBOARD_NAME_LIMIT)
	return compact


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


func _sanitize_battle_settings(raw_settings: Variant) -> Dictionary:
	var sanitized: Dictionary = DEFAULT_BATTLE_SETTINGS.duplicate(true)
	if not (raw_settings is Dictionary):
		return sanitized

	var data := raw_settings as Dictionary
	var performance_mode := String(data.get("performance_mode", sanitized["performance_mode"]))
	if not BATTLE_PERFORMANCE_MODES.has(performance_mode):
		performance_mode = String(sanitized["performance_mode"])

	var ambient_density := String(data.get("ambient_glyph_density", sanitized["ambient_glyph_density"]))
	if not BATTLE_AMBIENT_DENSITIES.has(ambient_density):
		ambient_density = String(sanitized["ambient_glyph_density"])

	sanitized["performance_mode"] = performance_mode
	sanitized["enemy_health_bars"] = bool(data.get("enemy_health_bars", sanitized["enemy_health_bars"]))
	sanitized["ambient_glyph_density"] = ambient_density
	sanitized["visual_effects"] = bool(data.get("visual_effects", sanitized["visual_effects"]))
	sanitized["enemy_detail"] = bool(data.get("enemy_detail", sanitized["enemy_detail"]))
	return sanitized


func _sanitize_launcher_theme(raw_theme: String) -> String:
	if LAUNCHER_THEME_IDS.has(raw_theme):
		return raw_theme
	return DEFAULT_LAUNCHER_THEME


func _sanitize_launcher_language(raw_language: String) -> String:
	if LAUNCHER_LANGUAGE_IDS.has(raw_language):
		return raw_language
	return DEFAULT_LAUNCHER_LANGUAGE


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
