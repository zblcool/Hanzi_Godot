extends Node3D

const HERO_SCENE := preload("res://scenes/entities/hero.tscn")
const ENEMY_SCENE := preload("res://scenes/entities/enemy.tscn")
const INK_BOLT_SCENE := preload("res://scenes/entities/ink_bolt.tscn")
const XP_ORB_SCENE := preload("res://scenes/entities/xp_orb.tscn")
const SUPPLY_PICKUP_SCENE := preload("res://scenes/entities/supply_pickup.tscn")
const BUSH_ZONE_SCENE := preload("res://scenes/entities/bush_zone.tscn")
const GROUND_HAZARD_SCENE := preload("res://scenes/entities/ground_hazard.tscn")
const LINE_HAZARD_SCENE := preload("res://scenes/entities/line_hazard.tscn")
const ENEMY_BOLT_SCENE := preload("res://scenes/entities/enemy_bolt.tscn")
const INKSTONE_SCENE := preload("res://scenes/entities/inkstone_altar.tscn")
const TREASURE_CHEST_SCENE := preload("res://scenes/entities/treasure_chest.tscn")
const BATTLE_HUD_SCENE := preload("res://scenes/ui/battle_hud.tscn")
const TOUCH_CONTROLS_OVERLAY := preload("res://scripts/ui/touch_controls_overlay.gd")
const BattleAudio := preload("res://scripts/core/battle_audio.gd")
const CJKFont := preload("res://scripts/core/cjk_font.gd")
const HanziLocalization := preload("res://scripts/core/hanzi_localization.gd")
const GROUND_SURFACE_SHADER := preload("res://assets/shaders/ink_ground.gdshader")
const SHANSHUI_BACKDROP_SHADER := preload("res://assets/shaders/shanshui_backdrop.gdshader")
const DEFAULT_BATTLE_TIP := "击倒字灵收集字力与补给，升级时三选一偏旁。靠近砚台按 E 磨词。"
const BOSS_SPAWN_TIMES := [65.0, 130.0]
const MAP_WORLD_RADIUS := 28.0
const BIG_WAVE_INTERVAL := 5
const FIELD_PHASE_WAVE_SPAN := 4
const FIELD_PHASE_TRANSITION_TIME := 1.6
const FIELD_PHASE_STAMP_LIMIT := 6
const FIELD_PHASE_GLYPH_SEQUENCE := ["天", "地", "玄", "黄", "宇", "宙", "洪", "荒"]
const BASE_ENEMY_CAP := 28
const MAX_REGULAR_ENEMY_CAP := 38
const BIG_WAVE_ENEMY_CAP := 46
const ENEMY_UTILITY_ACTIVE_LIMIT := 2
const ENEMY_POTION_ACTIVE_LIMIT := 2
const HEALTH_POTION_DROP_METER_STEP := 0.05
const HEALTH_POTION_HEAL_RATIO := 0.3
const CHAMBER_INTERLUDE_REST_HEAL_RATIO := 0.24
const CHAMBER_INTERLUDE_REST_BRUSH_DURATION := 8.0
const CHAMBER_SCROLL_ECHO_FURY_DROP_DURATION := 8.0
const CHAMBER_SCROLL_ECHO_PRESSURE_PAPER_CHANCE := 0.3
const CHAMBER_SCROLL_ECHO_BASIC_PAPER_CHANCE := 0.12
const CHAMBER_INTERLUDE_REST_ECHO_HEAL_RATIO := 0.08
const CHAMBER_INTERLUDE_REST_ECHO_BRUSH_DURATION := 4.0
const TREE_FADE_RADIUS := 2.65
const TREE_FADE_ALPHA := 0.28
const TREE_FADE_SPEED := 4.8
const MAP_FOG_CELL_SIZE := 2.0
const MAP_FOG_REVEAL_RADIUS := 5.2
const AMBIENT_GLYPH_POOL := ["字", "海", "卷", "墨", "山", "月", "火", "木", "风", "雷", "隐", "锋"]
const PERFORMANCE_FOG_DENSITY := {"performance": 0.009, "balanced": 0.012, "quality": 0.014}
const PERFORMANCE_GROUND_DETAIL_COUNTS := {"performance": 6, "balanced": 12, "quality": 18}
const PERFORMANCE_WAVE_SHARDS := {"performance": 2, "balanced": 4, "quality": 6}
const PERFORMANCE_INTRO_SYMBOLS := {"performance": 3, "balanced": 4, "quality": 6}
const PERFORMANCE_BOSS_SYMBOLS := {"performance": 4, "balanced": 6, "quality": 8}
const PERFORMANCE_SLASH_AFTERIMAGES := {"performance": 2, "balanced": 3, "quality": 4}
const PERFORMANCE_IMPACT_AFTERIMAGES := {"performance": 2, "balanced": 3, "quality": 4}
const ENEMY_DETAIL_DISTANCE := {"performance": 18.0, "balanced": 22.0, "quality": 26.0}
const ENEMY_DETAIL_REFRESH_INTERVAL := 0.12
const SOUNDTRACK_LIBRARY := {
	"mosslightCanopy": {
		"title": "苔月幽林",
		"mood": "16-bit 静夜丛林",
		"accent": Color(0.56, 0.84, 0.72, 1.0)
	},
	"fireflyFootpath": {
		"title": "萤火小径",
		"mood": "16-bit 轻快巡游",
		"accent": Color(0.98, 0.76, 0.42, 1.0)
	}
}
const ENEMY_ENTRANCE_TAUNTS := {
	"elite": [
		"魇潮已至，退无可退。",
		"把名字留在败卷里。",
		"这一页写你的败笔。"
	],
	"boss": [
		"残卷深处，不留活笔。",
		"你会写进我的卷底。",
		"到此为止，执笔者。"
	]
}
const FIELD_PHASE_THEMES := [
	{
		"id": "stelaeGrove",
		"name": "碑林",
		"accent": Color(0.72, 0.88, 0.78, 1.0),
		"ground_glow": Color(0.7, 0.86, 0.78, 1.0),
		"ground_shadow": Color(0.16, 0.22, 0.2, 1.0),
		"environment_bg": Color(0.82, 0.79, 0.7, 1.0),
		"environment_ambient": Color(0.78, 0.82, 0.74, 1.0),
		"environment_fog": Color(0.8, 0.84, 0.78, 1.0),
		"ambient_visibility": 0.96,
		"fog_density_scale": 1.0,
		"ambient_drift": Vector2(0.08, -0.04),
		"backdrop_mountain": Color(0.42, 0.42, 0.36, 0.78),
		"backdrop_mist": Color(0.88, 0.9, 0.84, 0.4),
		"backdrop_paper": Color(0.92, 0.9, 0.82, 0.22),
		"backdrop_alpha": 0.98,
		"cue": "字境·碑林",
		"tip": "碑林压阵，石色字痕会留在你当时落脚的位置。"
	},
	{
		"id": "inkTide",
		"name": "墨潮",
		"accent": Color(0.64, 0.82, 1.0, 1.0),
		"ground_glow": Color(0.56, 0.8, 0.98, 1.0),
		"ground_shadow": Color(0.1, 0.16, 0.24, 1.0),
		"environment_bg": Color(0.8, 0.79, 0.74, 1.0),
		"environment_ambient": Color(0.74, 0.82, 0.88, 1.0),
		"environment_fog": Color(0.72, 0.8, 0.88, 1.0),
		"ambient_visibility": 0.9,
		"fog_density_scale": 1.08,
		"ambient_drift": Vector2(0.05, -0.12),
		"backdrop_mountain": Color(0.34, 0.42, 0.5, 0.76),
		"backdrop_mist": Color(0.82, 0.9, 0.98, 0.44),
		"backdrop_paper": Color(0.84, 0.9, 0.98, 0.24),
		"backdrop_alpha": 1.04,
		"cue": "字境·墨潮",
		"tip": "墨潮翻卷，地表会偏向水墨青蓝，古纹像潮线一样缓慢游动。"
	},
	{
		"id": "thunderScript",
		"name": "雷纹",
		"accent": Color(0.9, 0.95, 1.0, 1.0),
		"ground_glow": Color(0.86, 0.92, 1.0, 1.0),
		"ground_shadow": Color(0.18, 0.2, 0.3, 1.0),
		"environment_bg": Color(0.82, 0.81, 0.77, 1.0),
		"environment_ambient": Color(0.84, 0.88, 0.92, 1.0),
		"environment_fog": Color(0.82, 0.86, 0.94, 1.0),
		"ambient_visibility": 1.08,
		"fog_density_scale": 1.14,
		"ambient_drift": Vector2(0.14, -0.05),
		"backdrop_mountain": Color(0.4, 0.42, 0.54, 0.8),
		"backdrop_mist": Color(0.88, 0.92, 0.98, 0.48),
		"backdrop_paper": Color(0.92, 0.94, 1.0, 0.24),
		"backdrop_alpha": 1.06,
		"cue": "字境·雷纹",
		"tip": "雷纹显形，雾色会更冷更亮，环境字阵也会抬高可见度。"
	},
	{
		"id": "ancientScroll",
		"name": "残卷",
		"accent": Color(1.0, 0.84, 0.56, 1.0),
		"ground_glow": Color(0.96, 0.78, 0.5, 1.0),
		"ground_shadow": Color(0.28, 0.18, 0.1, 1.0),
		"environment_bg": Color(0.88, 0.79, 0.66, 1.0),
		"environment_ambient": Color(0.86, 0.8, 0.7, 1.0),
		"environment_fog": Color(0.9, 0.82, 0.7, 1.0),
		"ambient_visibility": 1.04,
		"fog_density_scale": 0.94,
		"ambient_drift": Vector2(0.09, -0.03),
		"backdrop_mountain": Color(0.58, 0.48, 0.38, 0.8),
		"backdrop_mist": Color(0.96, 0.88, 0.78, 0.42),
		"backdrop_paper": Color(0.98, 0.92, 0.84, 0.22),
		"backdrop_alpha": 0.96,
		"cue": "字境·残卷",
		"tip": "残卷回暖，纸本山水会偏回赭金，巨字像旧墨一样烙在地上。"
	}
]
const CHAMBER_ORDER := ["entry_court", "slip_archive"]
const CHAMBER_LAYOUTS := {
	"entry_court": {
		"name": "入卷前庭",
		"english_name": "Entry Court",
		"glyph": "庭",
		"accent": Color(0.96, 0.82, 0.54, 1.0),
		"tip": "这是开卷前庭，树阵、卷架与补给点还保持第一层较开阔的铺陈。",
		"english_tip": "This is the opening court: a wider first chamber where trees, racks, and supplies still sit in their broad entry spread.",
		"trees": [
			Vector3(-9.0, 0.0, -7.0),
			Vector3(11.0, 0.0, -11.0),
			Vector3(-14.0, 0.0, 9.0),
			Vector3(15.0, 0.0, 7.0),
			Vector3(3.0, 0.0, 14.0),
			Vector3(-2.0, 0.0, -15.0)
		],
		"bushes": [
			Vector3(-6.0, 0.0, 4.0),
			Vector3(7.0, 0.0, -3.0),
			Vector3(-12.0, 0.0, -1.0),
			Vector3(10.0, 0.0, 11.0)
		],
		"inkstones": [
			Vector3(0.0, 0.0, 8.5),
			Vector3(-10.0, 0.0, 12.0)
		],
		"chests": [
			{
				"position": Vector3(-5.0, 0.0, 15.0),
				"drops": {"paper": 5.0, "ink": 14.0}
			},
			{
				"position": Vector3(13.5, 0.0, -9.5),
				"drops": {"paper": 4.0, "seal": 1.0}
			}
		],
		"stelae": [
			{"position": Vector3(-18.0, 0.0, -12.0), "glyph": "海", "tint": Color(0.56, 0.84, 1.0, 1.0)},
			{"position": Vector3(18.0, 0.0, -6.0), "glyph": "明", "tint": Color(1.0, 0.86, 0.48, 1.0)},
			{"position": Vector3(-16.0, 0.0, 14.0), "glyph": "休", "tint": Color(0.64, 0.92, 0.72, 1.0)},
			{"position": Vector3(15.0, 0.0, 15.0), "glyph": "卷", "tint": Color(0.9, 0.68, 0.42, 1.0)}
		],
		"scroll_racks": [
			{"position": Vector3(-8.0, 0.0, -16.0), "yaw": 18.0},
			{"position": Vector3(12.0, 0.0, -14.0), "yaw": -28.0},
			{"position": Vector3(16.0, 0.0, 2.0), "yaw": 42.0}
		],
		"ink_pools": [
			{"position": Vector3(-15.0, 0.0, 3.0), "radius": 1.6, "tint": Color(0.28, 0.7, 0.82, 1.0)},
			{"position": Vector3(13.0, 0.0, 12.0), "radius": 1.2, "tint": Color(0.76, 0.44, 0.94, 1.0)},
			{"position": Vector3(4.0, 0.0, -17.0), "radius": 1.45, "tint": Color(0.98, 0.72, 0.4, 1.0)}
		],
		"brush_pickups": [
			Vector3(-17.0, 0.0, -4.0),
			Vector3(9.0, 0.0, 16.5)
		],
		"break_beacon_position": Vector3(0.0, 0.0, 1.0),
		"utility_pickups": [
			{"position": Vector3(-11.5, 0.0, 0.5), "supply_id": "magnet"},
			{"position": Vector3(14.5, 0.0, 4.5), "supply_id": "fury"}
		],
		"exit_objective": {
			"id": "seal_cleanup",
			"name": "封门清印",
			"english_name": "Seal Cleanup",
			"glyph": "封",
			"tip": "卷主退散后，还要先收束散落的三枚封印，卷间抉择才会真正打开。",
			"english_tip": "Once the scroll lord falls, gather the three ward seals scattered across Entry Court before the between-chambers choice can open.",
			"pickup_positions": [
				Vector3(-15.0, 0.0, -2.5),
				Vector3(1.5, 0.0, 16.0),
				Vector3(14.0, 0.0, -12.5)
			]
		}
	},
	"slip_archive": {
		"name": "简库中庭",
		"english_name": "Slip Archive",
		"glyph": "简",
		"accent": Color(0.92, 0.84, 0.66, 1.0),
		"tip": "更深一层会推入简库中庭，卷架与碑刻挤得更近，补给点和砚台也会重排成新的房间读法。",
		"english_tip": "The next layer opens into Slip Archive, where racks and stelae crowd the room more tightly and the supply / inkstone rhythm is fully re-seeded.",
		"trees": [
			Vector3(-16.0, 0.0, -13.0),
			Vector3(16.0, 0.0, -12.0),
			Vector3(-17.0, 0.0, 10.0),
			Vector3(14.0, 0.0, 15.0)
		],
		"bushes": [
			Vector3(-4.0, 0.0, -11.0),
			Vector3(6.5, 0.0, -7.5),
			Vector3(-13.0, 0.0, 2.0),
			Vector3(11.0, 0.0, 6.0),
			Vector3(0.5, 0.0, 14.0)
		],
		"inkstones": [
			Vector3(-7.5, 0.0, 11.5),
			Vector3(9.5, 0.0, -1.5)
		],
		"chests": [
			{
				"position": Vector3(-13.5, 0.0, 6.0),
				"drops": {"paper": 6.0, "ink": 12.0}
			},
			{
				"position": Vector3(14.0, 0.0, 13.0),
				"drops": {"paper": 4.0, "seal": 2.0}
			}
		],
		"stelae": [
			{"position": Vector3(-18.0, 0.0, -6.0), "glyph": "简", "tint": Color(0.94, 0.82, 0.58, 1.0)},
			{"position": Vector3(-2.0, 0.0, -16.0), "glyph": "牍", "tint": Color(0.72, 0.86, 1.0, 1.0)},
			{"position": Vector3(17.0, 0.0, -8.0), "glyph": "卷", "tint": Color(1.0, 0.74, 0.48, 1.0)},
			{"position": Vector3(-15.0, 0.0, 15.0), "glyph": "典", "tint": Color(0.66, 0.92, 0.76, 1.0)},
			{"position": Vector3(12.0, 0.0, 16.0), "glyph": "墨", "tint": Color(0.82, 0.72, 1.0, 1.0)}
		],
		"scroll_racks": [
			{"position": Vector3(-10.5, 0.0, -15.5), "yaw": 22.0},
			{"position": Vector3(7.5, 0.0, -14.0), "yaw": -18.0},
			{"position": Vector3(15.5, 0.0, -1.5), "yaw": 38.0},
			{"position": Vector3(-2.5, 0.0, 4.0), "yaw": -42.0},
			{"position": Vector3(8.0, 0.0, 15.5), "yaw": 14.0}
		],
		"ink_pools": [
			{"position": Vector3(-15.0, 0.0, -0.5), "radius": 1.35, "tint": Color(0.36, 0.76, 0.88, 1.0)},
			{"position": Vector3(12.5, 0.0, 8.5), "radius": 1.15, "tint": Color(0.82, 0.52, 0.98, 1.0)},
			{"position": Vector3(2.5, 0.0, -16.0), "radius": 1.5, "tint": Color(0.96, 0.74, 0.46, 1.0)}
		],
		"brush_pickups": [
			Vector3(-12.0, 0.0, -8.0),
			Vector3(11.0, 0.0, 15.5)
		],
		"utility_pickups": [
			{"position": Vector3(-8.5, 0.0, 2.5), "supply_id": "magnet"},
			{"position": Vector3(13.5, 0.0, -5.5), "supply_id": "fury"}
		],
		"phrase_events": [
			{
				"id": "wind_rain_same_boat",
				"text": "风雨同舟",
				"english_text": "Same Boat Through Storms",
				"glyph": "舟",
				"position": Vector3(10.5, 0.0, -11.0),
				"guardian_position": Vector3(6.8, 0.0, -9.2),
				"guardian_glyph": "舟",
				"guardian_name": "风雨守舟",
				"english_guardian_name": "Sentence Guardian",
				"tint": Color(0.76, 0.86, 1.0, 1.0),
				"guardian_tint": Color(0.58, 0.74, 0.96, 1.0),
				"reward_type": "heal",
				"reward_amount": 18.0,
				"discover_radius": 6.2
			},
			{
				"id": "sea_moon_rises",
				"text": "海上生明月",
				"english_text": "Moon Rises Over Sea",
				"glyph": "月",
				"position": Vector3(-5.5, 0.0, 12.8),
				"guardian_position": Vector3(-0.8, 0.0, 10.6),
				"guardian_type": "archer",
				"guardian_health_scale": 1.34,
				"guardian_glyph": "月",
				"guardian_name": "海月守望",
				"english_guardian_name": "Moonwatch Archer",
				"tint": Color(0.9, 0.93, 1.0, 1.0),
				"guardian_tint": Color(0.58, 0.68, 0.96, 1.0),
				"reward_type": "xp",
				"reward_amount": 16.0,
				"discover_radius": 6.4
			},
			{
				"id": "mountain_water_long",
				"text": "山高水长",
				"english_text": "Mountains High, Waters Long",
				"glyph": "川",
				"position": Vector3(-12.6, 0.0, -4.8),
				"guardian_position": Vector3(-8.2, 0.0, -7.2),
				"guardian_type": "tank",
				"guardian_health_scale": 1.48,
				"guardian_glyph": "川",
				"guardian_name": "山水长卫",
				"english_guardian_name": "Longflow Sentinel",
				"tint": Color(0.88, 0.96, 0.9, 1.0),
				"guardian_tint": Color(0.58, 0.78, 0.62, 1.0),
				"reward_type": "reveal",
				"reward_amount": 0.8,
				"discover_radius": 6.3
			},
			{
				"id": "bright_moon_glance",
				"text": "举头望明月",
				"english_text": "Raise Your Head to the Bright Moon",
				"glyph": "望",
				"position": Vector3(5.8, 0.0, 7.6),
				"guardian_position": Vector3(9.4, 0.0, 4.8),
				"guardian_health_scale": 1.12,
				"guardian_glyph": "望",
				"guardian_name": "望月守句",
				"english_guardian_name": "Moonward Guardian",
				"tint": Color(1.0, 0.94, 0.84, 1.0),
				"guardian_tint": Color(0.88, 0.72, 0.48, 1.0),
				"reward_type": "radical",
				"reward_radical": "月",
				"reward_amount": 1.0,
				"discover_radius": 6.1
			}
		]
	}
}

@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var camera_rig: Node3D = $CameraRig
@onready var camera: Camera3D = $CameraRig/Camera3D
@onready var ground_root: Node3D = $Ground
@onready var props_root: Node3D = $Props
@onready var enemies_root: Node3D = $Enemies
@onready var pickups_root: Node3D = $Pickups
@onready var projectiles_root: Node3D = $Projectiles
@onready var effects_root: Node3D = $Effects

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var player = null
var hud = null
var touch_controls = null
var battle_audio = null

var elapsed_time: float = 0.0
var spawn_timer: float = 0.0
var spawn_interval: float = 1.35
var kills: int = 0
var threat_level: int = 1
var game_over: bool = false
var levelup_active: bool = false
var word_choice_active: bool = false
var paused: bool = false
var map_overlay_active: bool = false
var opening_time: float = 0.0
var last_announced_threat_level: int = 1
var boss_spawn_index: int = 0
var active_boss = null
var current_chamber_id: String = "entry_court"
var chamber_break_pending := false
var chamber_interlude_offer: Dictionary = {}
var chamber_modifier_id: String = ""
var chamber_modifier_expires_after_bosses: int = 0
var room_objective_id: String = ""
var room_objective_total: int = 0
var room_objective_remaining: int = 0
var chamber_break_beacon_active := false

var radical_counts: Dictionary = {}
var skill_levels: Dictionary = {}
var word_skill_levels: Dictionary = {}
var word_progress: Dictionary = {}
var inkstones: Array[Node3D] = []
var tree_fade_entries: Array[Dictionary] = []
var active_inkstone: Node3D = null
var battle_intro: Dictionary = {}
var explored_map_cells: Dictionary = {}
var map_reveal_radius_bonus: float = 0.0
var enemy_kills_by_type: Dictionary = {}
var battle_settings: Dictionary = {}
var decorative_effects_root: Node3D
var ambient_glyph_root: Node3D
var ambient_glyph_entries: Array[Dictionary] = []
var ground_detail_nodes: Array[Node3D] = []
var ground_surface_materials: Array = []
var ground_ripple_focus: Vector3 = Vector3.ZERO
var backdrop_root: Node3D
var backdrop_material_entries: Array[Dictionary] = []
var backdrop_mist_material: StandardMaterial3D
var field_phase_previous_theme: Dictionary = {}
var field_phase_target_theme: Dictionary = {}
var field_phase_previous_glyph: String = "天"
var field_phase_target_glyph: String = "天"
var field_phase_transition: float = 1.0
var field_phase_ambient_visibility: float = 1.0
var field_phase_stamp_root: Node3D
var field_phase_stamp_entries: Array[Dictionary] = []
var current_soundtrack_id: String = ""
var current_soundtrack_cue: String = ""
var health_potion_drop_meter: float = 0.0
var enemy_detail_refresh_timer: float = 0.0
var callout_history: Dictionary = {}
var phrase_events: Array[Dictionary] = []
var low_health_callout_ready := true
var first_recipe_callout_shown := false
var first_word_callout_shown := false
var elite_taunt_cooldown := 0.0
var last_player_health_value: float = 0.0

var level: int = 1
var experience: int = 0
var experience_target: int = 4
var pending_level_choices: int = 0


func _is_english() -> bool:
	return Session.get_launcher_language() == "en"


func _localized_hero_data(hero_data: Dictionary) -> Dictionary:
	return HanziLocalization.localized_hero_data(String(hero_data.get("id", "")), Session.get_launcher_language())


func _localized_radical_data(radical: String) -> Dictionary:
	return HanziLocalization.localized_radical_data(radical, Session.get_launcher_language())


func _localized_recipe_data(recipe_id: String) -> Dictionary:
	return HanziLocalization.localized_recipe_data(recipe_id, Session.get_launcher_language())


func _localized_word_data(word_id: String) -> Dictionary:
	return HanziLocalization.localized_word_data(word_id, Session.get_launcher_language())


func _localized_enemy_data(enemy_id: String) -> Dictionary:
	return HanziLocalization.localized_enemy_data(enemy_id, Session.get_launcher_language())


func _localized_field_phase_theme(theme: Dictionary) -> Dictionary:
	return HanziLocalization.localized_field_phase_theme(theme, Session.get_launcher_language())


func _localized_soundtrack_entry(track_id: String) -> Dictionary:
	return HanziLocalization.localized_soundtrack_entry(track_id, Session.get_launcher_language(), SOUNDTRACK_LIBRARY)


func _localized_soundtrack_cue(cue: String) -> String:
	return HanziLocalization.localized_soundtrack_cue(cue, Session.get_launcher_language())


func _default_battle_tip() -> String:
	if _is_english():
		return "Defeat glyph spirits to collect ink power and supplies. Choose one of three radicals on level-up, then press E near the inkstone to refine phrases."
	return DEFAULT_BATTLE_TIP


func _weapon_core_label() -> String:
	if _is_english():
		return "Blade Arc" if Session.selected_hero == "xia" else "Brush Edge"
	return "剑势" if Session.selected_hero == "xia" else "笔锋"


func _localized_intro_title(start_wave: int, fallback: String) -> String:
	return HanziLocalization.localized_intro_title(start_wave, fallback, Session.get_launcher_language())


func _localized_intro_tip(start_wave: int, fallback: String) -> String:
	return HanziLocalization.localized_intro_tip(start_wave, fallback, Session.get_launcher_language())


func _current_scroll_label() -> String:
	return "Scroll I" if _is_english() else "残卷一"


func _boss_stage_label(stage_index: int) -> String:
	if stage_index <= 0:
		return "First Scroll Lord" if _is_english() else "首卷主"
	return "Deeper Scroll Lord" if _is_english() else "深层卷主"


func _boss_reveal_title(stage_index: int, boss_name: String) -> String:
	if stage_index <= 0:
		if _is_english():
			return "%s enters the field" % boss_name
		return "%s压阵而至" % boss_name
	if _is_english():
		return "%s descends deeper" % boss_name
	return "%s自深卷降阵" % boss_name


func _boss_spawn_reveal_detail(stage_index: int) -> String:
	if stage_index <= 0:
		return "Large forbidden arrays arrive first. Dodge the opening layer, then punish the recovery." if _is_english() else "先躲开场的大禁阵，再抓卷主回气时的空档。"
	return "This deeper lord chains volleys, charges, and forbidden arrays into one longer rhythm." if _is_english() else "更深的卷主会把弹幕、冲锋和禁阵连成更长一套节奏。"


func _boss_defeat_reveal_title(completed_bosses: int) -> String:
	if completed_bosses >= BOSS_SPAWN_TIMES.size():
		return "Both scroll lords have fallen" if _is_english() else "两位卷主皆已崩散"
	return "The deeper layer unfolds" if _is_english() else "更深一层正在翻开"


func _boss_defeat_reveal_detail(completed_bosses: int) -> String:
	if completed_bosses >= BOSS_SPAWN_TIMES.size():
		return "Chapter target secured. Keep fighting only to test how far this build can still climb." if _is_english() else "本卷目标已经定住，后续战斗主要用于继续测试这条 build 的上限。"
	return "Gather the scattered supplies, then prepare for the next scroll lord and denser mixed waves." if _is_english() else "先收拢散落补给，再准备迎接下一位卷主和更密的混编字潮。"


func _boss_defeat_kicker(completed_bosses: int) -> String:
	if completed_bosses >= BOSS_SPAWN_TIMES.size():
		return _current_scroll_label()
	return "%s · %s" % [_current_scroll_label(), "Layer Break" if _is_english() else "破卷入深层"]


func _chamber_break_title() -> String:
	return "%s · %s" % [_current_scroll_label(), "Chamber Break" if _is_english() else "卷间缓冲"]


func _chamber_interlude_options() -> Array[Dictionary]:
	var reward_radical := String(chamber_interlude_offer.get("reward_radical", "日"))
	if _is_english():
		return [
			{"id": "reward", "label": "Reward · Radical %s" % reward_radical},
			{"id": "event", "label": "Event · Scroll Echo"},
			{"id": "recovery", "label": "Recovery · Short Rest"}
		]
	return [
		{"id": "reward", "label": "奖励 · 偏旁「%s」" % reward_radical},
		{"id": "event", "label": "异事 · 残卷回响"},
		{"id": "recovery", "label": "修整 · 歇笔回气"}
	]


func _pick_chamber_interlude_radical() -> String:
	var candidates: Array[String] = []
	for radical_variant in Session.RADICAL_ORDER:
		var radical := String(radical_variant)
		if radical.is_empty():
			continue
		candidates.append(radical)
	if candidates.is_empty():
		return "日"
	return candidates[rng.randi_range(0, candidates.size() - 1)]


func _clear_chamber_modifier() -> void:
	chamber_modifier_id = ""
	chamber_modifier_expires_after_bosses = 0


func _arm_chamber_modifier(modifier_id: String) -> void:
	chamber_modifier_id = modifier_id
	chamber_modifier_expires_after_bosses = int(Session.chapter_progress.get("completed_bosses", 0)) + 1


func _arm_scroll_echo_modifier() -> void:
	_arm_chamber_modifier("scroll_echo")


func _scroll_echo_modifier_active() -> bool:
	return chamber_modifier_id == "scroll_echo"


func _reward_supply_modifier_active() -> bool:
	return chamber_modifier_id == "reward_supply"


func _short_rest_modifier_active() -> bool:
	return chamber_modifier_id == "short_rest"


func _chamber_id_for_completed_bosses(completed_bosses: int) -> String:
	var chamber_index := mini(maxi(completed_bosses, 0), CHAMBER_ORDER.size() - 1)
	return String(CHAMBER_ORDER[chamber_index])


func _current_chamber_data() -> Dictionary:
	var chamber_variant: Variant = CHAMBER_LAYOUTS.get(current_chamber_id, CHAMBER_LAYOUTS.get(String(CHAMBER_ORDER[0]), {}))
	if chamber_variant is Dictionary:
		return chamber_variant as Dictionary
	return {}


func _localized_chamber_name(chamber_id: String) -> String:
	var chamber_variant: Variant = CHAMBER_LAYOUTS.get(chamber_id, {})
	if chamber_variant is Dictionary:
		var chamber_data := chamber_variant as Dictionary
		return String(chamber_data.get("english_name" if _is_english() else "name", chamber_id))
	return chamber_id


func _current_chamber_name() -> String:
	return _localized_chamber_name(current_chamber_id)


func _current_chamber_tip() -> String:
	var chamber_data := _current_chamber_data()
	return String(chamber_data.get("english_tip" if _is_english() else "tip", _default_battle_tip()))


func _current_chamber_accent() -> Color:
	var chamber_data := _current_chamber_data()
	return Color(chamber_data.get("accent", Color(0.96, 0.82, 0.54, 1.0)))


func _current_chamber_glyph() -> String:
	var chamber_data := _current_chamber_data()
	return String(chamber_data.get("glyph", "界"))


func _current_chamber_exit_objective() -> Dictionary:
	var chamber_data := _current_chamber_data()
	var objective_variant: Variant = chamber_data.get("exit_objective", {})
	if objective_variant is Dictionary:
		return objective_variant as Dictionary
	return {}


func _localized_room_objective_name(objective: Dictionary) -> String:
	return String(objective.get("english_name" if _is_english() else "name", ""))


func _room_objective_active() -> bool:
	return not room_objective_id.is_empty() and room_objective_remaining > 0


func _room_objective_status_text(objective: Dictionary, remaining: int) -> String:
	var objective_name := _localized_room_objective_name(objective)
	var base_tip := String(objective.get("english_tip" if _is_english() else "tip", _current_chamber_tip()))
	if _is_english():
		return "%s · %s Remaining seals %d/%d." % [objective_name, base_tip, remaining, room_objective_total]
	return "%s · %s 当前还差 %d / %d 枚封印。" % [objective_name, base_tip, remaining, room_objective_total]


func _clear_room_objective_state() -> void:
	room_objective_id = ""
	room_objective_total = 0
	room_objective_remaining = 0


func _clear_chamber_break_beacon_state() -> void:
	chamber_break_beacon_active = false


func _current_chamber_break_beacon_position() -> Vector3:
	var chamber_data := _current_chamber_data()
	var beacon_position_variant: Variant = chamber_data.get("break_beacon_position", Vector3.ZERO)
	if beacon_position_variant is Vector3:
		return beacon_position_variant
	return Vector3.ZERO


func _spawn_chamber_break_beacon() -> void:
	if chamber_break_beacon_active or not chamber_break_pending:
		return
	chamber_break_beacon_active = true
	var accent := _current_chamber_accent()
	_spawn_world_supply_pickup(
		_current_chamber_break_beacon_position(),
		"beacon",
		0.0,
		{
			"chamber_break_beacon": true,
			"chamber_break_beacon_glyph": "奖"
		}
	)
	if hud != null:
		hud.show_banner(
			"Reward Beacon Raised" if _is_english() else "卷间奖印显形",
			accent,
			1.8
		)
		hud.show_reveal(
			"Reward Beacon" if _is_english() else "卷间奖印",
			_current_chamber_name(),
			(
				"The chamber break is nearby now. Reach the reward beacon to resolve one between-chambers choice."
				if _is_english()
				else "卷间抉择已经显在附近。先走到这枚奖印前，才能真正定下下一条路。"
			),
			accent,
			"奖",
			2.5
		)
		hud.set_tip(
			"The chamber reward beacon is now active. Walk to it before the next chamber choice can resolve."
			if _is_english()
			else "卷间奖印已经亮起。先亲自走到奖印前，卷间抉择才会真正打开。"
		)
	_log_battle_event(
		"Reward Beacon · Reach the chamber prize" if _is_english() else "卷间奖印 · 靠近后再定下一路",
		accent
	)


func _try_start_chamber_exit_objective() -> bool:
	if _room_objective_active():
		return true
	var objective := _current_chamber_exit_objective()
	var objective_id := String(objective.get("id", ""))
	var pickup_positions: Array = objective.get("pickup_positions", [])
	if objective_id.is_empty() or pickup_positions.is_empty():
		return false
	room_objective_id = objective_id
	room_objective_total = pickup_positions.size()
	room_objective_remaining = room_objective_total
	var accent := _current_chamber_accent()
	var glyph := String(objective.get("glyph", "封"))
	for position_variant in pickup_positions:
		if position_variant is Vector3:
			_spawn_world_supply_pickup(
				position_variant,
				"seal",
				0.0,
				{
					"room_objective_id": objective_id,
					"room_objective_glyph": glyph
				}
			)
	if hud != null:
		hud.show_banner(
			("Room Objective  %s" if _is_english() else "房间目标  %s") % _localized_room_objective_name(objective),
			accent,
			1.9
		)
		hud.show_reveal(
			"Room Objective" if _is_english() else "房间目标",
			_localized_room_objective_name(objective),
			_room_objective_status_text(objective, room_objective_remaining),
			accent,
			glyph,
			2.6
		)
		hud.set_tip(_room_objective_status_text(objective, room_objective_remaining))
	_log_battle_event(
		("Room Objective · %s" if _is_english() else "房间目标 · %s") % _localized_room_objective_name(objective),
		accent
	)
	return true


func _advance_room_objective(pickup_ref, tint: Color) -> bool:
	if pickup_ref == null or not is_instance_valid(pickup_ref):
		return false
	var objective_id := String(pickup_ref.get_meta("room_objective_id", ""))
	if objective_id.is_empty() or objective_id != room_objective_id:
		return false
	var objective := _current_chamber_exit_objective()
	var objective_name := _localized_room_objective_name(objective)
	var accent := _current_chamber_accent().lerp(tint, 0.4)
	room_objective_remaining = max(room_objective_remaining - 1, 0)
	if room_objective_remaining > 0:
		if hud != null:
			hud.show_banner(
				("%s  %d seals remain" if _is_english() else "%s  还差 %d 枚") % [objective_name, room_objective_remaining],
				accent,
				1.45
			)
			hud.set_tip(_room_objective_status_text(objective, room_objective_remaining))
		_log_battle_event(
			("%s · %d seals remain" if _is_english() else "%s · 尚余 %d 枚封印") % [objective_name, room_objective_remaining],
			accent
		)
		return true

	var glyph := String(pickup_ref.get_meta("room_objective_glyph", objective.get("glyph", "封")))
	_clear_room_objective_state()
	if hud != null:
		hud.show_banner(
			("%s  Reward beacon raised" if _is_english() else "%s  奖印显形") % objective_name,
			accent,
			1.7
		)
		hud.set_tip(
			"The seals are bound. Reach the reward beacon before the between-chambers choice can resolve."
			if _is_english()
			else "封印已经收束。先走到奖印前，卷间抉择才会真正打开。"
		)
	_log_battle_event(
		("%s complete · Reward beacon raised" if _is_english() else "%s完成 · 奖印显形") % objective_name,
		accent
	)
	_spawn_chamber_break_beacon()
	return true


func _setup_phrase_events() -> void:
	phrase_events.clear()
	for chamber_id_variant in CHAMBER_ORDER:
		var chamber_id := String(chamber_id_variant)
		var chamber_variant: Variant = CHAMBER_LAYOUTS.get(chamber_id, {})
		if not (chamber_variant is Dictionary):
			continue
		var chamber_data := chamber_variant as Dictionary
		var chamber_phrase_events: Array = chamber_data.get("phrase_events", [])
		for event_variant in chamber_phrase_events:
			if not (event_variant is Dictionary):
				continue
			var phrase_event := (event_variant as Dictionary).duplicate(true)
			phrase_event["chamber_id"] = chamber_id
			phrase_event["discovered"] = false
			phrase_event["guardian_spawned"] = false
			phrase_event["guardian_defeated"] = false
			phrase_event["reward_granted"] = false
			phrase_events.append(phrase_event)


func _phrase_events_for_chamber(chamber_id: String = "") -> Array[Dictionary]:
	var chamber_events: Array[Dictionary] = []
	var target_chamber := current_chamber_id if chamber_id.is_empty() else chamber_id
	for phrase_event in phrase_events:
		if String(phrase_event.get("chamber_id", "")) == target_chamber:
			chamber_events.append(phrase_event)
	return chamber_events


func _find_phrase_event(event_id: String) -> Dictionary:
	for phrase_event in phrase_events:
		if String(phrase_event.get("id", "")) == event_id:
			return phrase_event
	return {}


func _phrase_event_display_text(phrase_event: Dictionary) -> String:
	return String(phrase_event.get("english_text" if _is_english() else "text", phrase_event.get("text", "")))


func _phrase_event_reward_copy(phrase_event: Dictionary) -> String:
	var reward_type := String(phrase_event.get("reward_type", "heal"))
	var reward_amount := int(round(float(phrase_event.get("reward_amount", 0.0))))
	match reward_type:
		"heal":
			return ("restore %d vitality" if _is_english() else "回复 %d 点气血") % reward_amount
		"xp":
			return ("gain %d ink" if _is_english() else "获得 %d 点字墨") % reward_amount
		"reveal":
			return "widen nearby fog reveal" if _is_english() else "扩开附近迷雾显形"
		"radical":
			var reward_radical := String(phrase_event.get("reward_radical", "日"))
			return ("gain radical %s" if _is_english() else "获得偏旁「%s」") % reward_radical
		_:
			return "claim the sentence reward" if _is_english() else "领取句阵赏赐"


func _update_phrase_events() -> void:
	if not is_instance_valid(player):
		return

	for phrase_event in _phrase_events_for_chamber():
		if bool(phrase_event.get("reward_granted", false)) or bool(phrase_event.get("guardian_defeated", false)):
			continue
		if bool(phrase_event.get("discovered", false)):
			if not bool(phrase_event.get("guardian_spawned", false)):
				_spawn_phrase_guardian(phrase_event)
			continue

		var event_position: Vector3 = phrase_event.get("position", Vector3.ZERO)
		var discover_radius := float(phrase_event.get("discover_radius", 6.2))
		if player.global_position.distance_to(event_position) > discover_radius:
			continue

		phrase_event["discovered"] = true
		var accent := Color(phrase_event.get("tint", Color(0.76, 0.86, 1.0, 1.0)))
		var phrase_text := _phrase_event_display_text(phrase_event)
		var reward_copy := _phrase_event_reward_copy(phrase_event)
		if hud != null:
			hud.show_banner(
				("Sentence Guardian · %s" if _is_english() else "句阵守卫 · %s") % phrase_text,
				accent,
				1.7
			)
			hud.show_reveal(
				"Guarded Phrase" if _is_english() else "守句现身",
				phrase_text,
				("Defeat the guardian to %s." if _is_english() else "击败守句魁首，即可%s。") % reward_copy,
				accent,
				String(phrase_event.get("guardian_glyph", phrase_event.get("glyph", "句"))),
				2.8
			)
			hud.set_tip(
				("The guarded phrase `%s` has surfaced in this chamber. Defeat its guardian to %s." if _is_english() else "这段房间里已经显出「%s」句阵。击败守句魁首后，就能%s。")
				% [phrase_text, reward_copy]
			)
		_log_battle_event(("Phrase Guardian · %s" if _is_english() else "句阵守卫 · %s") % phrase_text, accent)
		_spawn_phrase_guardian(phrase_event)


func _spawn_phrase_guardian(phrase_event: Dictionary) -> void:
	if bool(phrase_event.get("guardian_spawned", false)) or bool(phrase_event.get("guardian_defeated", false)) or not is_instance_valid(player):
		return

	var guardian = ENEMY_SCENE.instantiate()
	var guardian_position: Vector3 = phrase_event.get("guardian_position", Vector3.ZERO)
	var guardian_type := String(phrase_event.get("guardian_type", "elite"))
	guardian.position = guardian_position
	guardian.configure(guardian_type, 1.05 + elapsed_time / 78.0, player)
	guardian.enemy_name = String(
		phrase_event.get(
			"english_guardian_name" if _is_english() else "guardian_name",
			"Sentence Guardian" if _is_english() else "守句魁首"
		)
	)
	guardian.glyph = String(phrase_event.get("guardian_glyph", "句"))
	guardian.tint = Color(phrase_event.get("guardian_tint", phrase_event.get("tint", Color(0.72, 0.2, 0.34, 1.0))))
	guardian.max_health *= maxf(float(phrase_event.get("guardian_health_scale", 0.92)), 0.35)
	guardian.health = guardian.max_health
	guardian.display_health = guardian.health
	if guardian.has_method("set_health_bar_visible"):
		guardian.set_health_bar_visible(bool(battle_settings.get("enemy_health_bars", true)))
	if guardian.has_method("set_detail_visible"):
		guardian.set_detail_visible(_should_show_enemy_detail(guardian))
	guardian.defeated.connect(_on_enemy_defeated)
	if guardian.has_signal("damaged"):
		guardian.damaged.connect(_on_enemy_damaged)
	guardian.defeated.connect(Callable(self, "_on_phrase_guardian_defeated").bind(String(phrase_event.get("id", ""))))
	guardian.request_hazard.connect(_on_enemy_request_hazard)
	guardian.request_line_hazard.connect(_on_enemy_request_line_hazard)
	guardian.request_projectile.connect(_on_enemy_request_projectile)
	enemies_root.add_child(guardian)
	phrase_event["guardian_spawned"] = true
	_spawn_wave_effect(
		guardian.global_position,
		3.8,
		Color(phrase_event.get("guardian_tint", phrase_event.get("tint", Color(0.76, 0.86, 1.0, 1.0)))),
		String(phrase_event.get("guardian_glyph", "句"))
	)


func _on_phrase_guardian_defeated(_world_position: Vector3, _enemy_type: String, event_id: String) -> void:
	var phrase_event := _find_phrase_event(event_id)
	if phrase_event.is_empty():
		return
	phrase_event["guardian_defeated"] = true
	phrase_event["guardian_spawned"] = false
	_grant_phrase_event_reward(phrase_event)


func _grant_phrase_event_reward(phrase_event: Dictionary) -> void:
	if bool(phrase_event.get("reward_granted", false)):
		return
	phrase_event["reward_granted"] = true

	var reward_type := String(phrase_event.get("reward_type", "heal"))
	var reward_amount := float(phrase_event.get("reward_amount", 0.0))
	var accent := Color(phrase_event.get("tint", Color(0.76, 0.86, 1.0, 1.0)))
	var phrase_text := _phrase_event_display_text(phrase_event)
	var reward_copy := _phrase_event_reward_copy(phrase_event)

	match reward_type:
		"heal":
			if is_instance_valid(player):
				player.heal(reward_amount)
		"xp":
			_gain_experience(int(round(reward_amount)))
		"reveal":
			map_reveal_radius_bonus += maxf(reward_amount, 0.8)
			if is_instance_valid(player):
				_reveal_map_around_position(player.global_position)
		"radical":
			_apply_radical_choice(String(phrase_event.get("reward_radical", _pick_chamber_interlude_radical())))

	var phrase_position: Vector3 = phrase_event.get("position", Vector3.ZERO)
	_spawn_wave_effect(
		phrase_position,
		3.4,
		accent,
		String(phrase_event.get("glyph", phrase_event.get("guardian_glyph", "句")))
	)
	if hud != null:
		hud.show_banner(
			("Phrase Revealed · %s" if _is_english() else "句成异动 · %s") % phrase_text,
			accent,
			1.9
		)
		hud.show_reveal(
			"Verse Revealed" if _is_english() else "句成异动",
			phrase_text,
			("Reward · %s" if _is_english() else "奖励 · %s") % reward_copy,
			accent,
			String(phrase_event.get("glyph", phrase_event.get("guardian_glyph", "句"))),
			2.7
		)
		hud.set_tip(
			("The guarded phrase `%s` is now yours. The sentence reward will %s." if _is_english() else "「%s」句阵已经显成，句阵赏赐会为你%s。")
			% [phrase_text, reward_copy]
		)
	_log_battle_event(("Phrase Revealed · %s · %s" if _is_english() else "句成异动 · %s · %s") % [phrase_text, reward_copy], accent)
	_sync_hud()


func _next_chamber_id_after_interlude() -> String:
	var current_index := CHAMBER_ORDER.find(current_chamber_id)
	if current_index == -1:
		return String(CHAMBER_ORDER[0])
	return String(CHAMBER_ORDER[mini(current_index + 1, CHAMBER_ORDER.size() - 1)])


func _chamber_interlude_title() -> String:
	return "%s · %s" % [_current_scroll_label(), "Between Chambers" if _is_english() else "卷间抉择"]


func _chamber_preview_pressure_copy(next_wave: int) -> String:
	if _is_big_wave(next_wave):
		return "Enemy cap and spawn rate both rise together." if _is_english() else "刷怪速度和场上字灵上限都会一起抬高。"
	match next_wave:
		2:
			return "Ranged pressure starts mixing into the tide." if _is_english() else "弓手会开始混进字潮，远程牵制变多。"
		3:
			return "Dashes and ground arrays start overlapping." if _is_english() else "突刺和地阵会开始叠在一起施压。"
		4:
			return "Charge lines start cutting through mixed waves." if _is_english() else "冲锋线会开始切穿混编字潮。"
		_:
			return "Elites begin anchoring the pack more often." if _is_english() else "魁首会更常压阵，混编节奏会更硬。"


func _chamber_preview_threat_ids(next_wave: int) -> Array[String]:
	if next_wave >= 5:
		return ["elite", "cavalry", "ritualist"]
	if next_wave >= 4:
		return ["cavalry", "ritualist", "assassin"]
	if next_wave >= 3:
		return ["assassin", "ritualist", "archer"]
	if next_wave >= 2:
		return ["archer", "tank", "swift"]
	return ["swift", "basic"]


func _chamber_preview_threat_names(next_wave: int) -> Array[String]:
	var names: Array[String] = []
	for enemy_id_variant in _chamber_preview_threat_ids(next_wave):
		var enemy_id := String(enemy_id_variant)
		var enemy_data := _localized_enemy_data(enemy_id)
		names.append(String(enemy_data.get("name", enemy_id)))
	return names


func _chamber_interlude_preview_lines(next_wave: int) -> Array[String]:
	var localized_next_theme := _localized_field_phase_theme(_field_phase_theme_for_wave(next_wave))
	var next_theme_name := String(localized_next_theme.get("name", "Inkfield" if _is_english() else "字境"))
	var next_chamber_id := String(chamber_interlude_offer.get("next_chamber_id", _next_chamber_id_after_interlude()))
	var next_chamber_name := _localized_chamber_name(next_chamber_id)
	var threat_joiner := ", " if _is_english() else " / "
	var threat_mix := threat_joiner.join(PackedStringArray(_chamber_preview_threat_names(next_wave)))
	if _is_english():
		return [
			"Chamber · %s" % next_chamber_name,
			"Next Wave · %d%s" % [next_wave, " · Major Surge" if _is_big_wave(next_wave) else ""],
			"Realm · %s" % next_theme_name,
			"Pressure · %s" % _chamber_preview_pressure_copy(next_wave),
			"Threat Mix · %s" % threat_mix
		]
	return [
		"下一房间 · %s" % next_chamber_name,
		"下一波 · 第 %d 波%s" % [next_wave, " · 大潮压境" if _is_big_wave(next_wave) else ""],
		"字境 · %s" % next_theme_name,
		"压境重点 · %s" % _chamber_preview_pressure_copy(next_wave),
		"威胁混编 · %s" % threat_mix
	]


func _chamber_interlude_body(next_wave: int) -> String:
	var reward_radical := String(chamber_interlude_offer.get("reward_radical", "日"))
	var next_chamber_id := String(chamber_interlude_offer.get("next_chamber_id", _next_chamber_id_after_interlude()))
	var next_chamber_name := _localized_chamber_name(next_chamber_id)
	if _is_english():
		return "The first scroll lord is gone and the chamber has gone quiet. The run is about to shift into %s.\n\nCheck the next push below, then choose one:\nReward keeps radical %s and lifts paper / seal drops through the next chamber.\nEvent carries a Scroll Echo forward so pressure enemies echo extra paper and elites can drop %d s of Swift Edict until the next scroll lord.\nRecovery restores %d%% vitality, clears stun, and grants %d s of brush haste now, then repeats a smaller %d%% recovery echo on later wave pushes." % [
			next_chamber_name,
			reward_radical,
			int(round(CHAMBER_SCROLL_ECHO_FURY_DROP_DURATION)),
			int(round(CHAMBER_INTERLUDE_REST_HEAL_RATIO * 100.0)),
			int(round(CHAMBER_INTERLUDE_REST_BRUSH_DURATION)),
			int(round(CHAMBER_INTERLUDE_REST_ECHO_HEAL_RATIO * 100.0))
		]
	return "首位卷主已散，当前房间也暂时清空，下一段会推入「%s」。\n\n先看下方下一段预览，再定一项：\n奖励 · 偏旁补给：带走偏旁「%s」，而且下一段敌人会更常掉残纸 / 战印。\n异事 · 残卷回响：给下一段挂上一层掉落偏向，让压境敌群额外回响残纸，精英也能额外吐出 %d 秒疾书令，持续到下一位卷主。\n修整 · 歇笔回气：先回复 %d%% 气血、解除眩晕并获得 %d 秒文笔提速，后面每逢字潮推进还会再补一小口气。" % [
		next_chamber_name,
		reward_radical,
		int(round(CHAMBER_SCROLL_ECHO_FURY_DROP_DURATION)),
		int(round(CHAMBER_INTERLUDE_REST_HEAL_RATIO * 100.0)),
		int(round(CHAMBER_INTERLUDE_REST_BRUSH_DURATION))
	]


func _apply_chamber_modifier_wave_echo(new_threat_level: int) -> void:
	if not _short_rest_modifier_active() or not is_instance_valid(player):
		return
	player.heal(player.max_health * CHAMBER_INTERLUDE_REST_ECHO_HEAL_RATIO)
	if player.has_method("clear_stun"):
		player.clear_stun()
	player.apply_brush_haste(CHAMBER_INTERLUDE_REST_ECHO_BRUSH_DURATION)
	hud.show_banner(
		("Short Rest  Echo heal %d%%" if _is_english() else "歇笔回气  再补 %d%% 气血") % int(round(CHAMBER_INTERLUDE_REST_ECHO_HEAL_RATIO * 100.0)),
		Color(0.62, 0.9, 0.74, 1.0),
		1.6
	)
	_log_battle_event(
		("Wave %d · Short Rest echoes again" if _is_english() else "第 %d 波 · 歇笔回气再次回响") % new_threat_level,
		Color(0.62, 0.9, 0.74, 1.0)
	)


func _ready() -> void:
	rng.randomize()
	battle_intro = Session.consume_battle_intro()
	battle_settings = Session.get_battle_settings()
	radical_counts = Session.build_empty_radicals()
	skill_levels = Session.build_empty_recipe_levels()
	word_skill_levels = Session.build_empty_word_levels()
	word_progress = Session.build_empty_word_progress()
	enemy_kills_by_type = Session.build_empty_enemy_counts()
	_setup_input_map()
	_setup_environment()
	_build_ground()
	_spawn_battle_audio()
	_spawn_player()
	_apply_intro_preset()
	last_player_health_value = player.health if is_instance_valid(player) else 0.0
	current_chamber_id = _chamber_id_for_completed_bosses(int(Session.chapter_progress.get("completed_bosses", 0)))
	_setup_phrase_events()
	_spawn_props()
	_reveal_map_around_position(player.global_position)
	_spawn_hud()
	_ensure_decorative_effects_root()
	_reset_field_phase_state(threat_level)
	_apply_battle_settings()
	_sync_hud()
	_prime_soundtrack_ui()
	_start_opening_sequence()
	set_process(true)


func _process(delta: float) -> void:
	_update_camera(delta)
	_update_ground_shader(delta)
	_update_tree_fade(delta)
	_update_ambient_glyphs(delta)
	_update_field_phase(delta)
	_update_field_phase_stamps()

	if game_over:
		if Input.is_action_just_pressed("restart_run"):
			Engine.time_scale = 1.0
			get_tree().reload_current_scene()
		elif Input.is_action_just_pressed("return_menu"):
			Engine.time_scale = 1.0
			get_tree().change_scene_to_file(Session.ZIHAI_MENU_SCENE)
		return

	if map_overlay_active:
		if Input.is_action_just_pressed("return_menu") or Input.is_action_just_pressed("toggle_map"):
			_set_map_overlay(false)
		return

	if paused:
		if Input.is_action_just_pressed("return_menu") or Input.is_action_just_pressed("interact"):
			if hud != null and hud.has_method("is_settings_menu_open") and hud.is_settings_menu_open():
				hud.return_to_pause_menu()
			elif hud != null and hud.has_method("is_pause_menu_open") and hud.is_pause_menu_open():
				_set_paused(false)
		elif Input.is_action_just_pressed("restart_run"):
			Engine.time_scale = 1.0
			get_tree().reload_current_scene()
		return

	if levelup_active or word_choice_active:
		return

	if Input.is_action_just_pressed("toggle_map"):
		_set_map_overlay(true)
		return

	if Input.is_action_just_pressed("return_menu"):
		_set_paused(true)
		return

	if opening_time > 0.0:
		opening_time = max(opening_time - delta, 0.0)
		return

	_update_inkstone_interaction()
	_update_phrase_events()
	_reveal_map_around_position(player.global_position)
	if _room_objective_active():
		hud.set_status(elapsed_time, kills, threat_level)
		return

	elapsed_time += delta
	var new_threat_level: int = 1 + int(elapsed_time / 30.0)
	if new_threat_level > threat_level:
		for advanced_level in range(threat_level + 1, new_threat_level + 1):
			_on_threat_level_advanced(advanced_level)
	threat_level = new_threat_level
	_update_boss_flow()
	if chamber_break_pending and active_boss == null and _enemy_count() == 0:
		if not _try_start_chamber_exit_objective():
			_spawn_chamber_break_beacon()
			return

	if not chamber_break_pending:
		spawn_timer -= delta
		var enemy_cap := _enemy_cap()
		if spawn_timer <= 0.0 and _enemy_count() < enemy_cap:
			var available_slots: int = max(enemy_cap - _enemy_count(), 0)
			for _index in range(min(_spawn_batch_size(), available_slots)):
				_spawn_enemy()
			spawn_interval = _current_spawn_interval()
			spawn_timer = spawn_interval

	enemy_detail_refresh_timer = max(enemy_detail_refresh_timer - delta, 0.0)
	if enemy_detail_refresh_timer <= 0.0:
		_refresh_enemy_detail_visibility()
		enemy_detail_refresh_timer = ENEMY_DETAIL_REFRESH_INTERVAL
	elite_taunt_cooldown = max(elite_taunt_cooldown - delta, 0.0)

	hud.set_status(elapsed_time, kills, threat_level)


func _exit_tree() -> void:
	Engine.time_scale = 1.0


func _spawn_battle_audio() -> void:
	battle_audio = BattleAudio.new()
	battle_audio.name = "BattleAudio"
	add_child(battle_audio)
	if battle_audio.has_signal("soundtrack_rotated"):
		battle_audio.soundtrack_rotated.connect(_on_battle_audio_soundtrack_rotated)


func _play_attack_sfx(kind: String, intensity: float = 1.0) -> void:
	if battle_audio != null and battle_audio.has_method("play_attack"):
		battle_audio.play_attack(kind, intensity)


func _play_enemy_hit_sfx(enemy_type: String, hit_radius: float) -> void:
	if battle_audio != null and battle_audio.has_method("play_enemy_hit"):
		battle_audio.play_enemy_hit(enemy_type, hit_radius)


func _play_enemy_defeat_sfx(enemy_type: String) -> void:
	if battle_audio != null and battle_audio.has_method("play_enemy_defeat"):
		battle_audio.play_enemy_defeat(enemy_type)


func _play_pickup_sfx(supply_id: String, amount: float = 0.0) -> void:
	if battle_audio != null and battle_audio.has_method("play_pickup"):
		battle_audio.play_pickup(supply_id, amount)


func _play_player_hurt_sfx(severity: float = 1.0) -> void:
	if battle_audio != null and battle_audio.has_method("play_player_hurt"):
		battle_audio.play_player_hurt(severity)


func _play_cue_sfx(kind: String, intensity: float = 1.0) -> void:
	if battle_audio != null and battle_audio.has_method("play_cue"):
		battle_audio.play_cue(kind, intensity)


func _spawn_player() -> void:
	var hero_data: Dictionary = Session.get_selected_hero()
	player = HERO_SCENE.instantiate()
	player.configure(hero_data)
	add_child(player)
	player.fire_projectile.connect(_on_player_fire_projectile)
	player.request_wave.connect(_on_player_request_wave)
	player.request_slash.connect(_on_player_request_slash)
	player.request_thunder.connect(_on_player_request_thunder)
	player.health_changed.connect(_on_player_health_changed)
	player.defeated.connect(_on_player_defeated)


func _spawn_hud() -> void:
	hud = BATTLE_HUD_SCENE.instantiate()
	add_child(hud)
	hud.configure(Session.get_selected_hero())
	hud.set_battle_settings(battle_settings)
	hud.set_test_tools_enabled(_test_tools_enabled())
	hud.radical_choice_selected.connect(_on_radical_choice_selected)
	hud.word_choice_selected.connect(_on_word_choice_selected)
	hud.pause_requested.connect(_on_hud_pause_requested)
	hud.pause_resume_requested.connect(_on_hud_pause_resume_requested)
	hud.chamber_interlude_selected.connect(_on_hud_chamber_interlude_selected)
	hud.restart_requested.connect(_on_hud_restart_requested)
	hud.return_menu_requested.connect(_on_hud_return_menu_requested)
	hud.map_toggle_requested.connect(_on_hud_map_toggle_requested)
	hud.test_next_wave_requested.connect(_on_hud_test_next_wave_requested)
	hud.battle_setting_changed.connect(_on_hud_battle_setting_changed)
	_spawn_touch_controls()


func _prime_soundtrack_ui() -> void:
	var track_id := "fireflyFootpath" if threat_level >= 4 or elapsed_time >= 60.0 else "mosslightCanopy"
	var cue := "试阵预热" if elapsed_time > 0.0 or threat_level > 1 else "待入曲"
	_set_soundtrack(track_id, cue, false, true, false)


func _log_battle_event(text: String, color: Color = Color(0.88, 0.92, 0.97, 1.0)) -> void:
	if hud == null or not hud.has_method("push_event_log"):
		return
	hud.push_event_log(text, color)


func _pick_callout_line(pool: Array, history_key: String) -> String:
	if pool.is_empty():
		return ""

	var previous := String(callout_history.get(history_key, ""))
	var candidates: Array[String] = []
	for entry in pool:
		var text := String(entry).strip_edges()
		if text.is_empty():
			continue
		if text != previous:
			candidates.append(text)

	var source: Array[String] = []
	for candidate in candidates:
		source.append(candidate)
	if source.is_empty():
		for entry in pool:
			var fallback := String(entry).strip_edges()
			if not fallback.is_empty():
				source.append(fallback)
	if source.is_empty():
		return ""

	var selected := source[rng.randi_range(0, source.size() - 1)]
	callout_history[history_key] = selected
	return selected


func _show_battle_callout(title: String, text: String, accent: Color, log_prefix: String = "", duration: float = 3.1) -> void:
	var trimmed_text := text.strip_edges()
	if trimmed_text.is_empty():
		return
	if hud != null and hud.has_method("show_callout"):
		hud.show_callout(title, trimmed_text, accent, duration)
	var log_text := trimmed_text if log_prefix.is_empty() else "%s%s" % [log_prefix, trimmed_text]
	_log_battle_event(log_text, accent)


func _show_hero_callout(context: String, duration: float = 3.2) -> void:
	var hero_data: Dictionary = Session.get_selected_hero()
	var quote_groups: Dictionary = hero_data.get("battle_quotes", {})
	var pool: Array = quote_groups.get(context, [])
	var line := _pick_callout_line(pool, "hero_%s" % context)
	if line.is_empty():
		return
	var localized_hero := _localized_hero_data(hero_data)
	var hero_name := String(localized_hero.get("name", "Scribe" if _is_english() else "执笔者"))
	var accent: Color = hero_data.get("accent", Color(0.92, 0.76, 0.48, 1.0))
	_show_battle_callout(
		("%s Responds" % hero_name) if _is_english() else "%s应声" % hero_name,
		line,
		accent,
		("%s: " % hero_name) if _is_english() else "%s：" % hero_name,
		duration
	)


func _show_enemy_taunt(enemy_name: String, enemy_type: String, tint: Color, duration: float = 2.9) -> void:
	var pool: Array = ENEMY_ENTRANCE_TAUNTS.get(enemy_type, [])
	var line := _pick_callout_line(pool, "enemy_%s" % enemy_type)
	if line.is_empty():
		return
	_show_battle_callout(
		("%s Challenges You" % enemy_name) if _is_english() else "%s叫阵" % enemy_name,
		line,
		tint,
		("%s: " % enemy_name) if _is_english() else "%s：" % enemy_name,
		duration
	)


func _test_tools_enabled() -> bool:
	return OS.is_debug_build() or not bool(battle_intro.get("recordable", true))


func _set_soundtrack(track_id: String, cue: String, announce: bool = true, force: bool = false, sync_music: bool = true) -> void:
	if hud == null or not SOUNDTRACK_LIBRARY.has(track_id):
		return

	var should_announce := announce and (force or current_soundtrack_id != track_id or current_soundtrack_cue != cue)
	current_soundtrack_id = track_id
	current_soundtrack_cue = cue
	var track: Dictionary = _localized_soundtrack_entry(track_id)
	var accent := Color(track.get("accent", Color(1.0, 1.0, 1.0, 1.0)))
	hud.set_soundtrack(
		String(track.get("title", track_id)),
		String(track.get("mood", "")),
		_localized_soundtrack_cue(cue),
		accent,
		should_announce
	)
	if sync_music and battle_audio != null and battle_audio.has_method("set_music_track"):
		battle_audio.set_music_track(track_id)


func _on_battle_audio_soundtrack_rotated(track_id: String) -> void:
	_set_soundtrack(track_id, "巡游换曲", true, true, false)


func _spawn_touch_controls() -> void:
	touch_controls = TOUCH_CONTROLS_OVERLAY.new()
	add_child(touch_controls)
	touch_controls.movement_input_changed.connect(_on_hud_movement_input_changed)
	touch_controls.interact_requested.connect(_on_hud_interact_requested)
	touch_controls.pause_requested.connect(_on_hud_pause_requested)


func _clear_chamber_scene(clear_pickups: bool = false) -> void:
	tree_fade_entries.clear()
	inkstones.clear()
	active_inkstone = null
	_clear_chamber_break_beacon_state()
	for child in props_root.get_children():
		if is_instance_valid(child) and not child.is_queued_for_deletion():
			child.queue_free()
	if clear_pickups:
		for root in [pickups_root, projectiles_root, effects_root]:
			for child in root.get_children():
				if is_instance_valid(child) and not child.is_queued_for_deletion():
					child.queue_free()


func _spawn_props() -> void:
	var chamber_data := _current_chamber_data()
	var tree_positions: Array = chamber_data.get("trees", [])
	for position_variant in tree_positions:
		_create_tree(position_variant)

	var bush_positions: Array = chamber_data.get("bushes", [])
	for bush_position_variant in bush_positions:
		var bush = BUSH_ZONE_SCENE.instantiate()
		bush.position = bush_position_variant
		bush.configure(player, 2.25)
		bush.activated.connect(_on_bush_activated)
		bush.add_to_group("map_bush")
		props_root.add_child(bush)

	var inkstone_positions: Array = chamber_data.get("inkstones", [])
	for inkstone_position in inkstone_positions:
		var inkstone = INKSTONE_SCENE.instantiate()
		inkstone.position = inkstone_position
		inkstone.add_to_group("map_inkstone")
		props_root.add_child(inkstone)
		inkstones.append(inkstone)

	var chest_data: Array = chamber_data.get("chests", [])
	for chest_variant in chest_data:
		var chest = TREASURE_CHEST_SCENE.instantiate()
		chest.position = chest_variant["position"]
		chest.configure(player, chest_variant["drops"])
		chest.opened.connect(_on_treasure_chest_opened)
		props_root.add_child(chest)

	var stela_data: Array = chamber_data.get("stelae", [])
	for stela_variant in stela_data:
		_create_stela(stela_variant["position"], String(stela_variant["glyph"]), Color(stela_variant["tint"]))

	for phrase_event in _phrase_events_for_chamber():
		_create_phrase_stela(phrase_event)

	var scroll_racks: Array = chamber_data.get("scroll_racks", [])
	for rack_variant in scroll_racks:
		_create_scroll_rack(rack_variant["position"], float(rack_variant["yaw"]))

	var ink_pools: Array = chamber_data.get("ink_pools", [])
	for pool_variant in ink_pools:
		_create_ink_pool(pool_variant["position"], float(pool_variant["radius"]), Color(pool_variant["tint"]))

	var brush_pickups: Array = chamber_data.get("brush_pickups", [])
	for brush_position in brush_pickups:
		_spawn_world_supply_pickup(brush_position, "brush")

	var utility_pickups: Array = chamber_data.get("utility_pickups", [])
	for pickup_variant in utility_pickups:
		var pickup_position: Vector3 = pickup_variant["position"]
		_spawn_world_supply_pickup(pickup_position, String(pickup_variant["supply_id"]))


func _transition_to_chamber(next_chamber_id: String) -> void:
	if next_chamber_id.is_empty() or next_chamber_id == current_chamber_id:
		return
	_clear_room_objective_state()
	_clear_chamber_break_beacon_state()
	current_chamber_id = next_chamber_id
	_clear_chamber_scene(true)
	_spawn_props()
	if is_instance_valid(player):
		var reset_position: Vector3 = player.global_position
		reset_position.x = 0.0
		reset_position.z = 0.0
		player.global_position = reset_position
		player.rotation.y = 0.0
		player.look_direction = Vector3(0.0, 0.0, -1.0)
		player.set_external_move_input(Vector2.ZERO)
	explored_map_cells.clear()
	if is_instance_valid(player):
		_reveal_map_around_position(player.global_position)
	var chamber_name := _current_chamber_name()
	var chamber_accent := _current_chamber_accent()
	if hud != null:
		hud.show_banner(
			("Next Chamber · %s" if _is_english() else "下一房间 · %s") % chamber_name,
			chamber_accent,
			2.0
		)
		hud.show_reveal(
			"Between Chambers" if _is_english() else "卷间换房",
			chamber_name,
			_current_chamber_tip(),
			chamber_accent,
			_current_chamber_glyph(),
			2.9
		)
		hud.set_tip(_current_chamber_tip())
	_log_battle_event(("Chamber Shift · %s" if _is_english() else "房间更替 · %s") % chamber_name, chamber_accent)


func _spawn_enemy() -> void:
	if not is_instance_valid(player):
		return

	var enemy = ENEMY_SCENE.instantiate()
	var angle: float = rng.randf_range(0.0, TAU)
	var distance: float = rng.randf_range(18.0, 26.0)
	var offset := Vector3(cos(angle), 0.0, sin(angle)) * distance
	enemy.position = player.global_position + offset
	var enemy_type: String = _pick_enemy_type()
	enemy.configure(enemy_type, 1.0 + elapsed_time / 75.0, player)
	if enemy.has_method("set_health_bar_visible"):
		enemy.set_health_bar_visible(bool(battle_settings.get("enemy_health_bars", true)))
	if enemy.has_method("set_detail_visible"):
		enemy.set_detail_visible(_should_show_enemy_detail(enemy))
	enemy.defeated.connect(_on_enemy_defeated)
	if enemy.has_signal("damaged"):
		enemy.damaged.connect(_on_enemy_damaged)
	enemy.request_hazard.connect(_on_enemy_request_hazard)
	enemy.request_line_hazard.connect(_on_enemy_request_line_hazard)
	enemy.request_projectile.connect(_on_enemy_request_projectile)
	enemies_root.add_child(enemy)
	if enemy_type == "elite":
		hud.show_banner("Elite Incoming" if _is_english() else "精英现身", Color(0.94, 0.42, 0.52, 1.0), 2.0)
		if elite_taunt_cooldown <= 0.0:
			_show_enemy_taunt(String(enemy.enemy_name), enemy_type, Color(enemy.tint), 2.7)
			elite_taunt_cooldown = 18.0


func _spawn_boss(stage_index: int) -> void:
	if not is_instance_valid(player):
		return

	var boss = ENEMY_SCENE.instantiate()
	var angle: float = rng.randf_range(0.0, TAU)
	var distance: float = rng.randf_range(16.0, 19.0)
	boss.position = player.global_position + Vector3(cos(angle), 0.0, sin(angle)) * distance
	boss.configure("boss", 1.35 + elapsed_time / 68.0 + float(stage_index) * 0.2, player)
	if boss.has_method("set_health_bar_visible"):
		boss.set_health_bar_visible(bool(battle_settings.get("enemy_health_bars", true)))
	if boss.has_method("set_detail_visible"):
		boss.set_detail_visible(_should_show_enemy_detail(boss))
	boss.defeated.connect(_on_enemy_defeated)
	if boss.has_signal("damaged"):
		boss.damaged.connect(_on_enemy_damaged)
	boss.request_hazard.connect(_on_enemy_request_hazard)
	boss.request_line_hazard.connect(_on_enemy_request_line_hazard)
	boss.request_projectile.connect(_on_enemy_request_projectile)
	enemies_root.add_child(boss)
	active_boss = boss
	spawn_timer = max(spawn_timer, 1.4)

	var tint: Color = _boss_banner_color(stage_index)
	hud.show_banner("Boss Appears" if _is_english() else "卷主现身", tint, 2.4)
	hud.set_tip(_boss_stage_tip(stage_index))
	hud.show_boss(String(boss.enemy_name), String(boss.glyph), tint, boss.max_health)
	hud.show_reveal(
		"%s · %s" % [_current_scroll_label(), _boss_stage_label(stage_index)],
		_boss_reveal_title(stage_index, String(boss.enemy_name)),
		_boss_spawn_reveal_detail(stage_index),
		tint,
		String(boss.glyph),
		3.2
	)
	_log_battle_event(("Boss Appears · %s" if _is_english() else "卷主现身 · %s") % String(boss.enemy_name), tint)
	_show_enemy_taunt(String(boss.enemy_name), "boss", tint, 3.1)
	_set_soundtrack("fireflyFootpath", "卷主压阵", true, true)
	_play_cue_sfx("boss_appear", 1.08)
	_spawn_wave_effect(boss.global_position, 6.2, tint, String(boss.glyph))
	_spawn_boss_entrance_effect(boss.global_position, String(boss.glyph), tint)


func _apply_battle_settings() -> void:
	if hud != null:
		hud.set_battle_settings(battle_settings)
	_apply_performance_mode_visuals()
	_apply_enemy_health_bar_setting()
	_apply_visual_effect_setting()
	_apply_enemy_detail_setting()
	_rebuild_ambient_glyphs()
	if not field_phase_target_theme.is_empty():
		_apply_field_phase_theme_blend(field_phase_previous_theme, field_phase_target_theme, _field_phase_blend_value())


func _apply_performance_mode_visuals() -> void:
	var performance_mode := _performance_mode()
	if world_environment.environment != null:
		world_environment.environment.fog_density = float(PERFORMANCE_FOG_DENSITY.get(performance_mode, PERFORMANCE_FOG_DENSITY["balanced"]))

	var detail_count: int = int(PERFORMANCE_GROUND_DETAIL_COUNTS.get(performance_mode, PERFORMANCE_GROUND_DETAIL_COUNTS["balanced"]))
	for index in range(ground_detail_nodes.size()):
		var detail_node := ground_detail_nodes[index]
		if is_instance_valid(detail_node):
			detail_node.visible = index < detail_count


func _apply_enemy_health_bar_setting() -> void:
	var should_show: bool = bool(battle_settings.get("enemy_health_bars", true))
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if is_instance_valid(enemy) and enemy.has_method("set_health_bar_visible"):
			enemy.set_health_bar_visible(should_show)


func _apply_visual_effect_setting() -> void:
	_ensure_decorative_effects_root()
	if decorative_effects_root != null:
		decorative_effects_root.visible = _visual_effects_enabled()
	if field_phase_stamp_root != null:
		field_phase_stamp_root.visible = _visual_effects_enabled()
	if not _visual_effects_enabled():
		_clear_decorative_effects()


func _apply_enemy_detail_setting() -> void:
	enemy_detail_refresh_timer = 0.0
	_refresh_enemy_detail_visibility()


func _ensure_decorative_effects_root() -> void:
	if decorative_effects_root != null and is_instance_valid(decorative_effects_root):
		return
	decorative_effects_root = Node3D.new()
	decorative_effects_root.name = "DecorativeEffects"
	add_child(decorative_effects_root)


func _clear_decorative_effects() -> void:
	if decorative_effects_root != null and is_instance_valid(decorative_effects_root):
		for child in decorative_effects_root.get_children():
			if is_instance_valid(child) and not child.is_queued_for_deletion():
				child.queue_free()
	if field_phase_stamp_root != null and is_instance_valid(field_phase_stamp_root):
		for child in field_phase_stamp_root.get_children():
			if is_instance_valid(child) and not child.is_queued_for_deletion():
				child.queue_free()
	field_phase_stamp_entries.clear()


func _visual_effects_enabled() -> bool:
	return bool(battle_settings.get("visual_effects", true))


func _enemy_detail_enabled() -> bool:
	return bool(battle_settings.get("enemy_detail", true))


func _enemy_detail_distance() -> float:
	return float(ENEMY_DETAIL_DISTANCE.get(_performance_mode(), ENEMY_DETAIL_DISTANCE["balanced"]))


func _should_show_enemy_detail(enemy: Node3D) -> bool:
	if _enemy_detail_enabled() or not is_instance_valid(player):
		return true
	var detail_distance: float = _enemy_detail_distance()
	return player.global_position.distance_squared_to(enemy.global_position) <= detail_distance * detail_distance


func _refresh_enemy_detail_visibility() -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if is_instance_valid(enemy) and enemy.has_method("set_detail_visible"):
			enemy.set_detail_visible(_should_show_enemy_detail(enemy))


func _rebuild_ambient_glyphs() -> void:
	if ambient_glyph_root == null:
		ambient_glyph_root = Node3D.new()
		ambient_glyph_root.name = "AmbientGlyphs"
		ground_root.add_child(ambient_glyph_root)

	for entry in ambient_glyph_entries:
		var root_node = entry.get("root", null)
		if root_node is Node3D and is_instance_valid(root_node):
			(root_node as Node3D).queue_free()
	ambient_glyph_entries.clear()

	var target_count: int = _ambient_glyph_target_count()
	for _index in range(target_count):
		var glyph_root := Node3D.new()
		var base_position := Vector3(
			rng.randf_range(-34.0, 34.0),
			rng.randf_range(1.8, 3.7),
			rng.randf_range(-34.0, 34.0)
		)
		glyph_root.position = base_position
		ambient_glyph_root.add_child(glyph_root)

		var glyph_label := Label3D.new()
		glyph_label.text = String(AMBIENT_GLYPH_POOL[rng.randi_range(0, AMBIENT_GLYPH_POOL.size() - 1)])
		glyph_label.font = CJKFont.get_font()
		glyph_label.font_size = rng.randi_range(18, 30)
		glyph_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		glyph_label.modulate = Color(0.72, 0.82, 0.92, rng.randf_range(0.16, 0.32))
		glyph_root.add_child(glyph_label)

		ambient_glyph_entries.append({
			"root": glyph_root,
			"label": glyph_label,
			"base_position": base_position,
			"drift_speed": rng.randf_range(0.3, 0.8),
			"drift_phase": rng.randf_range(0.0, TAU),
			"yaw_speed": rng.randf_range(8.0, 18.0)
		})


func _update_ambient_glyphs(_delta: float) -> void:
	if ambient_glyph_entries.is_empty():
		return

	for entry in ambient_glyph_entries:
		var glyph_root = entry.get("root", null)
		var glyph_label = entry.get("label", null)
		if not (glyph_root is Node3D) or not is_instance_valid(glyph_root):
			continue
		var base_position: Vector3 = entry.get("base_position", Vector3.ZERO)
		var drift_speed: float = float(entry.get("drift_speed", 0.5))
		var drift_phase: float = float(entry.get("drift_phase", 0.0))
		var yaw_speed: float = float(entry.get("yaw_speed", 10.0))
		var bob := sin(elapsed_time * drift_speed + drift_phase)
		(glyph_root as Node3D).position = base_position + Vector3(0.0, bob * 0.28, 0.0)
		(glyph_root as Node3D).rotation_degrees.y = fmod(elapsed_time * yaw_speed + drift_phase * 30.0, 360.0)
		if glyph_label is Label3D and is_instance_valid(glyph_label):
			var alpha := (0.14 + (bob * 0.5 + 0.5) * 0.16) * field_phase_ambient_visibility
			(glyph_label as Label3D).modulate.a = alpha


func _ambient_glyph_target_count() -> int:
	var base_count: int = 0
	match String(battle_settings.get("ambient_glyph_density", "medium")):
		"off":
			base_count = 0
		"high":
			base_count = 12
		_:
			base_count = 7

	match _performance_mode():
		"performance":
			return maxi(0, int(round(float(base_count) * 0.72)))
		"quality":
			return int(round(float(base_count) * 1.35))
		_:
			return base_count


func _performance_mode() -> String:
	var mode := String(battle_settings.get("performance_mode", "balanced"))
	if Session.BATTLE_PERFORMANCE_MODES.has(mode):
		return mode
	return "balanced"


func _is_big_wave(wave_index: int = threat_level) -> bool:
	return wave_index > 0 and wave_index % BIG_WAVE_INTERVAL == 0


func _enemy_cap() -> int:
	var cap := BASE_ENEMY_CAP + maxi(threat_level - 1, 0) * 2
	cap = min(cap, BIG_WAVE_ENEMY_CAP if _is_big_wave() else MAX_REGULAR_ENEMY_CAP)
	if is_instance_valid(active_boss) and not active_boss.is_queued_for_deletion():
		cap = min(cap, 24)
	return cap


func _spawn_batch_size() -> int:
	var batch := 1
	if threat_level >= 3:
		batch += 1
	if elapsed_time > 90.0:
		batch += 1
	if _is_big_wave():
		batch += 2
	return batch


func _current_spawn_interval() -> float:
	var interval: float = max(0.46, 1.35 - elapsed_time * 0.012)
	if _is_big_wave():
		interval *= 0.72
	if is_instance_valid(active_boss) and not active_boss.is_queued_for_deletion():
		interval *= 1.12
	return max(interval, 0.3)


func _pick_enemy_type() -> String:
	var roll: float = rng.randf()
	if elapsed_time < 18.0:
		return "basic" if roll < 0.72 else "swift"
	if elapsed_time < 36.0:
		if roll < 0.38:
			return "basic"
		if roll < 0.62:
			return "swift"
		if roll < 0.82:
			return "tank"
		return "archer"
	if elapsed_time < 64.0:
		if roll < 0.24:
			return "basic"
		if roll < 0.42:
			return "swift"
		if roll < 0.58:
			return "tank"
		if roll < 0.74:
			return "archer"
		if roll < 0.89:
			return "assassin"
		return "ritualist"
	if elapsed_time < 95.0:
		if roll < 0.16:
			return "basic"
		if roll < 0.3:
			return "swift"
		if roll < 0.44:
			return "tank"
		if roll < 0.58:
			return "archer"
		if roll < 0.73:
			return "assassin"
		if roll < 0.88:
			return "ritualist"
		return "cavalry"
	if roll < 0.12:
		return "basic"
	if roll < 0.23:
		return "swift"
	if roll < 0.35:
		return "tank"
	if roll < 0.49:
		return "archer"
	if roll < 0.64:
		return "assassin"
	if roll < 0.78:
		return "ritualist"
	if roll < 0.93:
		return "cavalry"
	return "elite"


func _update_boss_flow() -> void:
	if is_instance_valid(active_boss) and not active_boss.is_queued_for_deletion():
		hud.set_boss_health(active_boss.health, active_boss.max_health)
	else:
		if active_boss != null:
			active_boss = null
			hud.hide_boss()

	if boss_spawn_index < BOSS_SPAWN_TIMES.size() and elapsed_time >= float(BOSS_SPAWN_TIMES[boss_spawn_index]) and active_boss == null:
		_spawn_boss(boss_spawn_index)
		boss_spawn_index += 1


func _boss_banner_color(stage_index: int) -> Color:
	if stage_index <= 0:
		return Color(0.9, 0.38, 0.28, 1.0)
	return Color(0.86, 0.28, 0.42, 1.0)


func _boss_stage_tip(stage_index: int) -> String:
	if stage_index <= 0:
		if _is_english():
			return "The scroll lord has entered the inkfield. Dodge the large forbidden arrays first, then punish the gaps after each cast."
		return "卷主踏入墨阵。先躲大范围禁阵，再抓它施法后的空档。"
	if _is_english():
		return "A deeper scroll lord has appeared. It layers volleys, charges, and forbidden arrays into one sequence."
	return "更深的卷主现身了。它会把弹幕、冲锋和禁阵叠在一起。"


func _on_player_fire_projectile(origin: Vector3, direction: Vector3, damage: float, speed: float, glyph: String, tint: Color) -> void:
	var bolt = INK_BOLT_SCENE.instantiate()
	bolt.configure(origin, direction, damage, speed, glyph, tint)
	bolt.impact.connect(_on_player_projectile_impact)
	projectiles_root.add_child(bolt)
	if glyph == "炎":
		_play_attack_sfx("flame_burst", 1.0 + damage / 28.0)
	elif glyph == "月" or glyph == "日":
		_play_attack_sfx("bright_volley", 0.9 + damage / 30.0)
	else:
		_play_attack_sfx("scholar_shot", 0.92 + speed / 28.0)


func _on_player_request_wave(origin: Vector3, radius: float, damage: float, tint: Color, label: String) -> void:
	_spawn_wave_effect(origin, radius, tint, label)
	match label:
		"休":
			_play_attack_sfx("rest_wave", 1.0 + radius / 8.0)
		"忍":
			_play_attack_sfx("resolve_guard", 1.0 + damage / 28.0)
		_:
			_play_attack_sfx("sea_wave", 0.96 + radius / 10.0)
	for node in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		var distance: float = origin.distance_to(node.global_position)
		var enemy_radius: float = 1.0
		if node.has_method("get_hit_radius"):
			enemy_radius = node.get_hit_radius()
		if distance <= radius + enemy_radius:
			node.take_damage(damage)


func _on_player_request_slash(origin: Vector3, forward: Vector3, radius: float, damage: float, arc_dot: float, tint: Color, label: String) -> void:
	_spawn_wave_effect(origin + forward * radius * 0.35, radius * 0.7, tint, label)
	_spawn_slash_afterimages(origin, forward, radius, tint, label)
	if label == "忍":
		_play_attack_sfx("resolve_guard", 1.0 + damage / 30.0)
	else:
		_play_attack_sfx("sword_slash", 0.96 + radius / 8.0)
	for node in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		var offset: Vector3 = node.global_position - origin
		offset.y = 0.0
		var distance: float = offset.length()
		if distance > radius + node.get_hit_radius():
			continue
		var direction: Vector3 = offset.normalized()
		if direction.dot(forward) < arc_dot:
			continue
		node.take_damage(damage)


func _on_player_request_thunder(target_count: int, damage: float, splash_radius: float, splash_damage: float, tint: Color, label: String) -> void:
	_play_attack_sfx("thunder_strike", 1.0 + float(target_count) * 0.05 + splash_radius * 0.08)
	var targets: Array = _collect_nearest_enemies(target_count)
	for target in targets:
		if not is_instance_valid(target) or target.is_queued_for_deletion():
			continue
		_spawn_wave_effect(target.global_position, 1.1 + splash_radius * 0.25, tint, label)
		target.take_damage(damage)
		if splash_radius > 0.0 and splash_damage > 0.0:
			_damage_enemies_in_radius(target.global_position, splash_radius, splash_damage, target)


func _collect_nearest_enemies(max_count: int) -> Array:
	var remaining: Array = []
	for node in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		remaining.append(node)

	var picked: Array = []
	while picked.size() < max_count and not remaining.is_empty():
		var nearest_index: int = 0
		var nearest_distance: float = INF
		for index in range(remaining.size()):
			var candidate = remaining[index]
			var distance: float = player.global_position.distance_squared_to(candidate.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_index = index
		picked.append(remaining[nearest_index])
		remaining.remove_at(nearest_index)
	return picked


func _damage_enemies_in_radius(origin: Vector3, radius: float, damage: float, excluded = null) -> void:
	if radius <= 0.0 or damage <= 0.0:
		return
	for node in get_tree().get_nodes_in_group("enemy"):
		if node == excluded or not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		var enemy_radius: float = 1.0
		if node.has_method("get_hit_radius"):
			enemy_radius = node.get_hit_radius()
		if origin.distance_to(node.global_position) <= radius + enemy_radius:
			node.take_damage(damage)


func _on_enemy_defeated(world_position: Vector3, enemy_type: String) -> void:
	kills += 1
	enemy_kills_by_type[enemy_type] = int(enemy_kills_by_type.get(enemy_type, 0)) + 1
	_play_enemy_defeat_sfx(enemy_type)
	_spawn_enemy_death_effect(world_position, enemy_type)
	_spawn_xp_orb(world_position, _xp_value_for_enemy(enemy_type))
	_spawn_supply_drops(world_position, enemy_type)
	if enemy_type == "boss":
		active_boss = null
		hud.hide_boss()
		_on_boss_defeated(world_position)
	if kills % 14 == 0:
		hud.show_banner("The Tide Surges Higher" if _is_english() else "字潮再涨", Color(0.95, 0.62, 0.36, 1.0), 1.7)


func _on_enemy_damaged(_world_position: Vector3, enemy_type: String, hit_radius: float) -> void:
	_play_enemy_hit_sfx(enemy_type, hit_radius)


func _xp_value_for_enemy(enemy_type: String) -> int:
	match enemy_type:
		"swift":
			return 2
		"tank":
			return 3
		"archer":
			return 2
		"assassin":
			return 3
		"cavalry":
			return 4
		"ritualist":
			return 3
		"elite":
			return 6
		"boss":
			return 14
		_:
			return 1


func _spawn_xp_orb(world_position: Vector3, xp_value: int) -> void:
	var orb = XP_ORB_SCENE.instantiate()
	orb.position = world_position + Vector3(0.0, 0.45, 0.0)
	orb.configure(player, xp_value)
	orb.collected.connect(_on_xp_collected)
	pickups_root.add_child(orb)


func _spawn_world_supply_pickup(world_position: Vector3, supply_id: String, amount: float = -1.0, pickup_meta: Dictionary = {}) -> void:
	var pickup = SUPPLY_PICKUP_SCENE.instantiate()
	pickup.position = world_position + Vector3(0.0, 0.45, 0.0)
	pickup.configure(player, supply_id, amount)
	for meta_key_variant in pickup_meta.keys():
		var meta_key := String(meta_key_variant)
		if meta_key.is_empty():
			continue
		pickup.set_meta(meta_key, pickup_meta[meta_key_variant])
	pickup.collected.connect(_on_supply_collected.bind(pickup))
	pickups_root.add_child(pickup)


func _spawn_supply_drops(world_position: Vector3, enemy_type: String) -> void:
	_spawn_supply_bundle(world_position, _build_supply_drops(enemy_type))


func _spawn_supply_bundle(world_position: Vector3, drops: Dictionary) -> void:
	var active_supply_ids: Array[String] = []
	for supply_id_variant in ["paper", "ink", "seal", "magnet", "fury", "potion"]:
		var supply_id := String(supply_id_variant)
		if float(drops.get(supply_id, 0.0)) > 0.0:
			active_supply_ids.append(supply_id)

	for index in range(active_supply_ids.size()):
		var supply_id: String = active_supply_ids[index]
		var pickup = SUPPLY_PICKUP_SCENE.instantiate()
		var angle: float = TAU * float(index) / max(1.0, float(active_supply_ids.size()))
		angle += rng.randf_range(-0.22, 0.22)
		var radius: float = 0.55 + rng.randf_range(0.0, 0.34)
		pickup.position = world_position + Vector3(cos(angle) * radius, 0.45, sin(angle) * radius)
		pickup.configure(player, supply_id, float(drops[supply_id]))
		pickup.collected.connect(_on_supply_collected.bind(pickup))
		pickups_root.add_child(pickup)


func _build_supply_drops(enemy_type: String) -> Dictionary:
	var drops := {
		"paper": 0.0,
		"ink": 0.0,
		"seal": 0.0,
		"magnet": 0.0,
		"fury": 0.0,
		"potion": 0.0
	}

	match enemy_type:
		"swift":
			if rng.randf() < 0.12:
				_add_supply_drop(drops, "paper", 2.0)
		"tank":
			if rng.randf() < 0.28:
				_add_supply_drop(drops, "ink", 15.0)
		"archer":
			if rng.randf() < 0.24:
				_add_supply_drop(drops, "paper", 3.0)
		"assassin":
			if rng.randf() < 0.18:
				_add_supply_drop(drops, "paper", 3.0)
			if rng.randf() < 0.12:
				_add_supply_drop(drops, "seal", 1.0)
		"cavalry":
			if rng.randf() < 0.26:
				_add_supply_drop(drops, "paper", 4.0)
			if rng.randf() < 0.2:
				_add_supply_drop(drops, "seal", 1.0)
		"ritualist":
			if rng.randf() < 0.24:
				_add_supply_drop(drops, "paper", 3.0)
			if rng.randf() < 0.16:
				_add_supply_drop(drops, "ink", 14.0)
		"elite":
			_add_supply_drop(drops, "paper", 6.0)
			_add_supply_drop(drops, "seal", 1.0)
			_add_supply_drop(drops, "ink", 22.0)
		"boss":
			_add_supply_drop(drops, "paper", 10.0)
			_add_supply_drop(drops, "seal", 2.0)
			_add_supply_drop(drops, "ink", 34.0)
		_:
			if rng.randf() < 0.1:
				_add_supply_drop(drops, "paper", 2.0)

	if kills > 0 and kills % 12 == 0:
		_add_supply_drop(drops, "paper", 3.0)
	if kills > 0 and kills % 21 == 0:
		_add_supply_drop(drops, "ink", 16.0)

	_apply_chamber_modifier_supply_drops(enemy_type, drops)
	_add_enemy_utility_drop(drops, enemy_type)
	_add_health_potion_drop(drops)
	return drops


func _apply_chamber_modifier_supply_drops(enemy_type: String, drops: Dictionary) -> void:
	if _reward_supply_modifier_active():
		match enemy_type:
			"elite":
				_add_supply_drop(drops, "paper", 2.0)
				_add_supply_drop(drops, "seal", 1.0)
			"boss":
				_add_supply_drop(drops, "paper", 4.0)
				_add_supply_drop(drops, "seal", 1.0)
			_:
				if rng.randf() < 0.16:
					_add_supply_drop(drops, "paper", 1.0)

	if not _scroll_echo_modifier_active() or enemy_type == "boss":
		return

	var pressure_enemy: bool = enemy_type in ["archer", "assassin", "cavalry", "ritualist"]
	if enemy_type == "elite":
		_add_supply_drop(drops, "paper", 2.0)
		if _count_active_supply_pickups(["fury"]) < ENEMY_UTILITY_ACTIVE_LIMIT and float(drops.get("fury", 0.0)) <= 0.0:
			_add_supply_drop(drops, "fury", CHAMBER_SCROLL_ECHO_FURY_DROP_DURATION)
		return

	if pressure_enemy:
		if rng.randf() < CHAMBER_SCROLL_ECHO_PRESSURE_PAPER_CHANCE:
			_add_supply_drop(drops, "paper", 2.0)
	elif rng.randf() < CHAMBER_SCROLL_ECHO_BASIC_PAPER_CHANCE:
		_add_supply_drop(drops, "paper", 1.0)


func _add_supply_drop(drops: Dictionary, supply_id: String, amount: float) -> void:
	drops[supply_id] = float(drops.get(supply_id, 0.0)) + amount


func _add_enemy_utility_drop(drops: Dictionary, enemy_type: String) -> void:
	if enemy_type == "boss":
		_add_supply_drop(drops, "magnet", 1.0)
		_add_supply_drop(drops, "fury", 10.0)
		return

	if _count_active_supply_pickups(["magnet", "fury"]) >= ENEMY_UTILITY_ACTIVE_LIMIT:
		return

	var pickup_id := "magnet" if rng.randf() < 0.5 else "fury"
	var pickup_amount := 1.0 if pickup_id == "magnet" else 10.0
	if enemy_type == "elite":
		if rng.randf() < 0.7:
			_add_supply_drop(drops, pickup_id, pickup_amount)
		return

	if rng.randf() < 0.035:
		_add_supply_drop(drops, pickup_id, pickup_amount)


func _add_health_potion_drop(drops: Dictionary) -> void:
	if _count_active_supply_pickups(["potion"]) >= ENEMY_POTION_ACTIVE_LIMIT:
		return

	health_potion_drop_meter = min(1.0, health_potion_drop_meter + HEALTH_POTION_DROP_METER_STEP)
	if rng.randf() >= health_potion_drop_meter:
		return

	_add_supply_drop(drops, "potion", HEALTH_POTION_HEAL_RATIO)
	health_potion_drop_meter = max(0.0, health_potion_drop_meter - 1.0)


func _count_active_supply_pickups(supply_ids: Array[String]) -> int:
	var total := 0
	for pickup in pickups_root.get_children():
		if not is_instance_valid(pickup) or pickup.is_queued_for_deletion():
			continue
		if not pickup.has_method("get_supply_id"):
			continue
		var active_supply_id := String(pickup.get_supply_id())
		if supply_ids.has(active_supply_id):
			total += 1
	return total


func _on_xp_collected(value: int) -> void:
	_gain_experience(value)


func _collect_all_xp_pickups() -> int:
	var total_xp := 0
	for pickup in pickups_root.get_children():
		if not is_instance_valid(pickup) or pickup.is_queued_for_deletion():
			continue
		if pickup.has_method("collect_now"):
			total_xp += int(pickup.collect_now())
	return total_xp


func _on_supply_collected(world_position: Vector3, supply_id: String, amount: float, tint: Color, label: String, pickup_ref = null) -> void:
	var pulse_radius: float = 1.05
	var event_text := ""
	var pulse_label := label
	var objective_pickup_consumed := _advance_room_objective(pickup_ref, tint)
	if objective_pickup_consumed and pickup_ref != null and is_instance_valid(pickup_ref):
		pulse_label = String(pickup_ref.get_meta("room_objective_glyph", label))
	if objective_pickup_consumed and is_equal_approx(amount, 0.0):
		_spawn_wave_effect(world_position, 1.18, tint, pulse_label)
		_sync_hud()
		return
	if pickup_ref != null and is_instance_valid(pickup_ref) and bool(pickup_ref.get_meta("chamber_break_beacon", false)):
		chamber_break_beacon_active = false
		pulse_label = String(pickup_ref.get_meta("chamber_break_beacon_glyph", label))
		_spawn_wave_effect(world_position, 1.36, tint, pulse_label)
		_open_chamber_break_gate()
		_sync_hud()
		return
	match supply_id:
		"paper":
			var xp_gain: int = int(round(amount))
			_gain_experience(xp_gain)
			hud.show_banner(("Paper Scrap  +%d Ink" if _is_english() else "拾得残纸  +%d 字墨") % xp_gain, tint, 1.45)
			event_text = ("Paper Scrap · +%d Ink" if _is_english() else "拾得残纸 · +%d 字墨") % xp_gain
		"ink":
			if is_instance_valid(player):
				player.heal(amount)
				hud.show_banner(("Ink Cluster  Heal %d" if _is_english() else "拾得墨团  回气 %d") % int(round(amount)), tint, 1.5)
				event_text = ("Ink Cluster · Heal %d" if _is_english() else "拾得墨团 · 回气 %d") % int(round(amount))
			pulse_radius = 1.12
		"seal":
			if is_instance_valid(player):
				var blade_gain: int = max(1, int(round(amount)))
				player.apply_blade_upgrade(blade_gain)
				hud.show_banner(
					("%s  %s +%d" % ["Battle Seal", _weapon_core_label(), blade_gain]) if _is_english() else "拾得战印  %s +%d" % [_weapon_core_label(), blade_gain],
					tint,
					1.7
				)
				event_text = ("Battle Seal · %s +%d" if _is_english() else "拾得战印 · %s +%d") % [_weapon_core_label(), blade_gain]
			pulse_radius = 1.22
		"magnet":
			var gathered_xp: int = _collect_all_xp_pickups()
			if gathered_xp > 0:
				_gain_experience(gathered_xp)
				hud.show_banner(("Ink Magnet  Gathered %d Ink" if _is_english() else "拾得聚墨符  收束 %d 字墨") % gathered_xp, tint, 1.8)
				event_text = ("Ink Magnet · Gathered %d Ink" if _is_english() else "拾得聚墨符 · 收束 %d 字墨") % gathered_xp
			else:
				hud.show_banner("Ink Magnet  No loose ink remains" if _is_english() else "拾得聚墨符  场上已无散墨", tint, 1.6)
				event_text = "Ink Magnet · No loose ink remains" if _is_english() else "拾得聚墨符 · 场上已无散墨"
			hud.set_tip("The ink magnet recalls every loose ink pickup on the field, making it ideal after a long kite around the arena." if _is_english() else "聚墨符会把战场上遗落的字墨尽数回收，适合在绕场之后一口气补等级。")
			pulse_radius = 1.26
		"fury":
			if is_instance_valid(player):
				var duration: float = max(amount, 10.0)
				player.apply_fury_haste(duration)
				hud.show_banner(("Swift Edict  Attack and move speed up for %d s" if _is_english() else "拾得疾书令  攻速移速提升 %d 秒") % int(round(duration)), tint, 1.85)
				hud.set_tip("Swift Edict boosts attack and movement speed for a short burst, which is perfect for forcing elites or sweeping pickups." if _is_english() else "疾书令会短时间拉高攻速与移速，适合强开精英或抢一波散落补给。")
				event_text = ("Swift Edict · Speed up for %d s" if _is_english() else "拾得疾书令 · 提速 %d 秒") % int(round(duration))
			pulse_radius = 1.24
		"potion":
			if is_instance_valid(player):
				var heal_ratio := clampf(amount if amount > 0.0 else HEALTH_POTION_HEAL_RATIO, 0.12, 0.9)
				player.heal(player.max_health * heal_ratio)
				hud.show_banner(("Spring Pill  Restore %d%% Vitality" if _is_english() else "拾得回春丹  回复 %d%% 气血") % int(round(heal_ratio * 100.0)), tint, 1.8)
				hud.set_tip("Spring Pill heals a percentage of your maximum vitality, making it ideal after tanking an elite or boss pattern." if _is_english() else "回春丹会按最大气血比例回气，适合硬吃一波精英或卷主技能后迅速稳住局势。")
				event_text = ("Spring Pill · Restore %d%% Vitality" if _is_english() else "拾得回春丹 · 回复 %d%% 气血") % int(round(heal_ratio * 100.0))
			pulse_radius = 1.22
		"brush":
			if is_instance_valid(player):
				var duration: float = max(amount, 6.0)
				player.apply_brush_haste(duration)
				hud.show_banner(("Writers Brush  Mobility up for %d s" if _is_english() else "拾得文笔  机动提升 %d 秒") % int(round(duration)), tint, 1.7)
				hud.set_tip("The writer's brush speeds you up for a short window, which is ideal for dragging the crowd or scooping supplies." if _is_english() else "文笔加身，短时间内移动更快，适合拉扯敌群和抢补给。")
				event_text = ("Writers Brush · Mobility up for %d s" if _is_english() else "拾得文笔 · 机动提升 %d 秒") % int(round(duration))
			pulse_radius = 1.18

	if not event_text.is_empty():
		_log_battle_event(event_text, tint)
	_play_pickup_sfx(supply_id, amount)
	_spawn_wave_effect(world_position, pulse_radius, tint, pulse_label)
	_sync_hud()


func _gain_experience(value: int) -> void:
	experience += value
	var leveled_up: bool = false
	while experience >= experience_target:
		experience -= experience_target
		level += 1
		pending_level_choices += 1
		experience_target = int(round(float(experience_target) * 1.28)) + 2
		leveled_up = true

	_sync_hud()

	if leveled_up and not levelup_active:
		_present_levelup_choices()


func _present_levelup_choices() -> void:
	if levelup_active or pending_level_choices <= 0 or game_over:
		return
	levelup_active = true
	Engine.time_scale = 0.0
	var choices: Array[Dictionary] = _build_radical_choices()
	hud.show_radical_choices(level, choices, pending_level_choices)


func _build_radical_choices() -> Array[Dictionary]:
	var candidates: Array[String] = []
	var weights: Dictionary = {}
	for radical_variant in Session.RADICAL_ORDER:
		var radical := String(radical_variant)
		candidates.append(radical)
		weights[radical] = _score_radical_choice(radical)

	var picked: Array[String] = []
	while picked.size() < 3 and not candidates.is_empty():
		var total_weight := 0.0
		for candidate_variant in candidates:
			var candidate := String(candidate_variant)
			total_weight += float(weights.get(candidate, 1.0))

		var roll: float = rng.randf() * max(total_weight, 0.001)
		var running := 0.0
		var selected := String(candidates[0])
		for candidate_variant in candidates:
			var candidate := String(candidate_variant)
			running += float(weights.get(candidate, 1.0))
			if roll <= running:
				selected = candidate
				break
		picked.append(selected)
		candidates.erase(selected)

	var choices: Array[Dictionary] = []
	for radical_variant in picked:
		var radical := String(radical_variant)
		choices.append(_build_choice_data(radical))
	return choices


func _score_radical_choice(radical: String) -> float:
	var score := 1.0 + rng.randf_range(0.0, 0.15)
	if radical == "刂":
		score += 1.6 if Session.selected_hero == "xia" else 0.95
		score += min(0.75, float(player.blade_level) * 0.08)

	var recipe_id: String = Session.get_recipe_id_for_radical(radical)
	if recipe_id.is_empty():
		return score

	var recipe: Dictionary = Session.get_recipe_data(recipe_id)
	var current_level: int = int(skill_levels.get(recipe_id, 0))
	var max_level: int = int(recipe["max_level"])
	if current_level <= 0:
		var partner_radical: String = _get_partner_radical(recipe_id, radical)
		if int(radical_counts.get(partner_radical, 0)) > 0:
			score += 3.0
		else:
			score += 1.35
	elif current_level < max_level:
		score += 2.2 - float(current_level) * 0.28
	else:
		var word_id: String = String(recipe["word_id"])
		var word: Dictionary = Session.get_word_data(word_id)
		var word_level: int = int(word_skill_levels.get(word_id, 0))
		if word_level <= 0:
			score += 1.8 + float(word_progress.get(word_id, 0)) * 0.45
		elif word_level < int(word["max_level"]):
			score += 1.25 - float(word_level) * 0.1
		else:
			score += 0.4
	return score


func _build_choice_data(radical: String) -> Dictionary:
	var radical_data: Dictionary = _localized_radical_data(radical)
	var color: Color = Session.RADICAL_COLORS[radical]
	var headline: String = String(radical_data["description"])
	if radical != "刂" or not Session.get_recipe_id_for_radical(radical).is_empty():
		var recipe_id: String = Session.get_recipe_id_for_radical(radical)
		if not recipe_id.is_empty():
			var recipe: Dictionary = _localized_recipe_data(recipe_id)
			var level_value: int = int(skill_levels.get(recipe_id, 0))
			var max_level: int = int(recipe["max_level"])
			if level_value <= 0:
				var partner: String = _get_partner_radical(recipe_id, radical)
				if int(radical_counts.get(partner, 0)) > 0:
					headline = ("Complete the final stroke and form `%s` immediately." if _is_english() else "补上最后一笔，立成「%s」。") % String(recipe["display"])
				else:
					headline = ("Collect toward `%s` and open this glyph route." if _is_english() else "收集成字，通往「%s」。") % String(recipe["display"])
			elif level_value < max_level:
				headline = ("Upgrade `%s` Lv.%d -> Lv.%d." if _is_english() else "提升「%s」 Lv.%d -> Lv.%d。") % [String(recipe["display"]), level_value, level_value + 1]
			else:
				var word: Dictionary = _localized_word_data(String(recipe["word_id"]))
				var word_level: int = int(word_skill_levels.get(word["id"], 0))
				var stock: int = _count_recipe_radicals(recipe["radicals"]) + 1
				if word_level <= 0:
					headline = ("Add one more stock to `%s`, then refine it at the inkstone %d/%d." if _is_english() else "为「%s」添一枚余材，可去砚台磨词 %d/%d。") % [
						String(word["display"]),
						min(int(word_progress.get(word["id"], 0)) + 1, int(word["unlock_cost"])),
						int(word["unlock_cost"])
					]
				else:
					headline = ("Add more phrase stock to raise `%s` to Lv.%d at the inkstone. Current stock %d." if _is_english() else "补充词材，可在砚台将「%s」升到 Lv.%d。当前余材 %d。") % [
						String(word["display"]),
						min(word_level + 1, int(word["max_level"])),
						stock
					]
	if radical == "刂":
		headline += (" Also strengthen %s." if _is_english() else " 并强化%s。") % _weapon_core_label()

	return {
		"radical": radical,
		"name": String(radical_data["name"]),
		"headline": headline,
		"description": String(radical_data["description"]),
		"color": color
	}


func _on_radical_choice_selected(radical: String) -> void:
	if not levelup_active:
		return

	pending_level_choices = max(0, pending_level_choices - 1)
	_apply_radical_choice(radical)
	hud.hide_choice_overlay()
	levelup_active = false
	Engine.time_scale = 1.0

	if pending_level_choices > 0:
		_present_levelup_choices()


func _apply_radical_choice(radical: String) -> void:
	if radical == "刂":
		radical_counts[radical] = int(radical_counts.get(radical, 0)) + 1
		player.apply_blade_upgrade()
		hud.show_banner(("%s into %s" if _is_english() else "%s 入%s") % [radical, _weapon_core_label()], Session.RADICAL_COLORS[radical], 1.8)
		_resolve_growth_chains()
		_sync_hud()
		return

	radical_counts[radical] = int(radical_counts.get(radical, 0)) + 1
	hud.show_banner(("Attuned %s" if _is_english() else "领悟 %s") % radical, Session.RADICAL_COLORS[radical], 1.2)
	_resolve_growth_chains()
	_sync_hud()


func _resolve_growth_chains() -> void:
	var changed: bool = true
	while changed:
		changed = false
		for recipe_id_variant in Session.RECIPE_ORDER:
			var recipe_id := String(recipe_id_variant)
			var recipe: Dictionary = Session.get_recipe_data(recipe_id)
			var recipe_level: int = int(skill_levels.get(recipe_id, 0))
			var recipe_radicals: Array = recipe["radicals"]
			var max_level: int = int(recipe["max_level"])

			if recipe_level <= 0 and _has_recipe_parts(recipe_radicals):
				for radical_variant in recipe_radicals:
					var radical := String(radical_variant)
					radical_counts[radical] = int(radical_counts.get(radical, 0)) - 1
				_set_recipe_level(recipe_id, 1)
				changed = true
				break

			var stored_radical: String = _find_available_recipe_radical(recipe_radicals)
			if stored_radical.is_empty():
				continue

			if recipe_level > 0 and recipe_level < max_level:
				radical_counts[stored_radical] = int(radical_counts.get(stored_radical, 0)) - 1
				_set_recipe_level(recipe_id, recipe_level + 1)
				changed = true
				break


func _set_recipe_level(recipe_id: String, new_level: int) -> void:
	skill_levels[recipe_id] = new_level
	player.set_skill_level(recipe_id, new_level)
	var recipe: Dictionary = _localized_recipe_data(recipe_id)
	if new_level == 1:
		hud.show_banner(("Glyph Formed  %s" if _is_english() else "合字成型  %s") % String(recipe["display"]), recipe["color"], 2.3)
		hud.show_reveal(
			"Glyph Formed" if _is_english() else "合字成型",
			String(recipe["title"]),
			String(recipe["description"]),
			Color(recipe["color"]),
			String(recipe["display"]),
			2.6
		)
		_log_battle_event(("Glyph Formed · %s" if _is_english() else "合字成型 · %s") % String(recipe["display"]), Color(recipe["color"]))
		if not first_recipe_callout_shown:
			first_recipe_callout_shown = true
			_show_hero_callout("recipe_unlock")
	else:
		hud.show_banner(("%s rises to Lv.%d" if _is_english() else "%s 进为 Lv.%d") % [String(recipe["display"]), new_level], recipe["color"], 1.7)
		_log_battle_event(("%s reaches Lv.%d" if _is_english() else "%s 升至 Lv.%d") % [String(recipe["display"]), new_level], Color(recipe["color"]))


func _set_word_level(word_id: String, new_level: int) -> void:
	word_skill_levels[word_id] = new_level
	player.set_word_skill_level(word_id, new_level)
	var word: Dictionary = _localized_word_data(word_id)
	if new_level == 1:
		hud.show_banner(("Phrase Art Formed  %s" if _is_english() else "词技成型  %s") % String(word["display"]), word["color"], 2.5)
		hud.show_reveal(
			"Phrase Art Formed" if _is_english() else "词技成型",
			String(word["title"]),
			String(word["description"]),
			Color(word["color"]),
			String(word["display"]),
			2.9
		)
		_log_battle_event(("Phrase Art Formed · %s" if _is_english() else "词技成型 · %s") % String(word["display"]), Color(word["color"]))
		if not first_word_callout_shown:
			first_word_callout_shown = true
			_show_hero_callout("word_unlock")
	else:
		hud.show_banner(("%s rises to Lv.%d" if _is_english() else "%s 进为 Lv.%d") % [String(word["display"]), new_level], word["color"], 1.8)
		_log_battle_event(("%s reaches Lv.%d" if _is_english() else "%s 升至 Lv.%d") % [String(word["display"]), new_level], Color(word["color"]))


func _has_recipe_parts(radicals: Array) -> bool:
	var requirements: Dictionary = _build_radical_requirement_counts(radicals)
	for radical_variant in requirements.keys():
		var radical := String(radical_variant)
		if int(radical_counts.get(radical, 0)) < int(requirements[radical_variant]):
			return false
	return true


func _find_available_recipe_radical(radicals: Array) -> String:
	for radical_variant in radicals:
		var radical := String(radical_variant)
		if int(radical_counts.get(radical, 0)) > 0:
			return radical
	return ""


func _get_partner_radical(recipe_id: String, radical: String) -> String:
	var recipe: Dictionary = Session.get_recipe_data(recipe_id)
	var same_count: int = 0
	for radical_variant in recipe["radicals"]:
		var recipe_radical := String(radical_variant)
		if recipe_radical == radical:
			same_count += 1
		if recipe_radical != radical:
			return recipe_radical
	if same_count > 1:
		return radical
	return ""


func _build_radical_requirement_counts(radicals: Array) -> Dictionary:
	var requirements: Dictionary = {}
	for radical_variant in radicals:
		var radical := String(radical_variant)
		requirements[radical] = int(requirements.get(radical, 0)) + 1
	return requirements


func _on_enemy_request_hazard(target_position: Vector3, radius: float, warning_time: float, active_time: float, damage: float, tint: Color, label: String) -> void:
	_play_cue_sfx("ground_warning", 0.86 + radius / 6.0)
	var hazard = GROUND_HAZARD_SCENE.instantiate()
	hazard.configure(player, target_position, radius, warning_time, active_time, damage, tint, label)
	hazard.activated.connect(_on_enemy_ground_hazard_activated)
	effects_root.add_child(hazard)


func _on_enemy_request_line_hazard(origin: Vector3, direction: Vector3, length: float, width: float, warning_time: float, active_time: float, damage: float, tint: Color, label: String, stun_time: float) -> void:
	_play_cue_sfx("line_warning", 0.84 + width / 3.0 + length / 48.0)
	var hazard = LINE_HAZARD_SCENE.instantiate()
	hazard.configure(player, origin, direction, length, width, warning_time, active_time, damage, tint, label, stun_time)
	hazard.activated.connect(_on_enemy_line_hazard_activated)
	effects_root.add_child(hazard)


func _on_enemy_request_projectile(origin: Vector3, direction: Vector3, speed: float, damage: float, glyph: String, tint: Color, life_time: float, hit_radius: float, stun_time: float) -> void:
	var bolt = ENEMY_BOLT_SCENE.instantiate()
	bolt.configure(player, origin, direction, speed, damage, glyph, tint, life_time, hit_radius, stun_time)
	bolt.impact.connect(_on_projectile_impact)
	projectiles_root.add_child(bolt)


func _on_enemy_ground_hazard_activated(radius: float, _label: String) -> void:
	_play_cue_sfx("ground_bloom", 0.9 + radius / 7.0)


func _on_enemy_line_hazard_activated(length: float, width: float, _label: String) -> void:
	_play_cue_sfx("line_release", 0.9 + width / 3.2 + length / 52.0)


func _on_player_projectile_impact(world_position: Vector3, tint: Color, label: String) -> void:
	_on_projectile_impact(world_position, tint, label)
	_spawn_player_impact_afterimages(world_position, tint, label)


func _on_projectile_impact(world_position: Vector3, tint: Color, label: String) -> void:
	_spawn_wave_effect(world_position, 0.95, tint, label)


func _spawn_wave_effect(origin: Vector3, radius: float, tint: Color, label: String) -> void:
	if not _visual_effects_enabled():
		return
	_ensure_decorative_effects_root()
	var effect_root := Node3D.new()
	effect_root.position = Vector3(origin.x, 0.05, origin.z)
	decorative_effects_root.add_child(effect_root)
	var performance_mode := _performance_mode()

	var outer_ring := MeshInstance3D.new()
	var outer_mesh := CylinderMesh.new()
	outer_mesh.top_radius = radius
	outer_mesh.bottom_radius = radius
	outer_mesh.height = 0.04
	outer_ring.mesh = outer_mesh
	var outer_material := StandardMaterial3D.new()
	outer_material.albedo_color = Color(tint.r, tint.g, tint.b, 0.24)
	outer_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	outer_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	outer_material.emission_enabled = true
	outer_material.emission = tint.lightened(0.12)
	outer_ring.material_override = outer_material
	effect_root.add_child(outer_ring)

	var inner_ring: MeshInstance3D = null
	var inner_material := StandardMaterial3D.new()
	inner_material.albedo_color = Color(tint.r, tint.g, tint.b, 0.5)
	inner_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	inner_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	inner_material.emission_enabled = true
	inner_material.emission = tint
	if performance_mode != "performance":
		inner_ring = MeshInstance3D.new()
		var inner_mesh := CylinderMesh.new()
		inner_mesh.top_radius = radius * 0.78
		inner_mesh.bottom_radius = radius * 0.78
		inner_mesh.height = 0.06
		inner_ring.mesh = inner_mesh
		inner_ring.material_override = inner_material
		inner_ring.position = Vector3(0.0, 0.01, 0.0)
		effect_root.add_child(inner_ring)

	var shard_root := Node3D.new()
	effect_root.add_child(shard_root)
	var shard_count: int = int(PERFORMANCE_WAVE_SHARDS.get(performance_mode, PERFORMANCE_WAVE_SHARDS["balanced"]))
	for index in range(shard_count):
		var shard := MeshInstance3D.new()
		var shard_mesh := BoxMesh.new()
		shard_mesh.size = Vector3(max(0.12, radius * 0.12), 0.04, max(0.28, radius * 0.22))
		shard.mesh = shard_mesh
		var angle: float = TAU * float(index) / float(shard_count)
		shard.position = Vector3(cos(angle) * radius * 0.34, 0.03, sin(angle) * radius * 0.34)
		shard.rotation_degrees.y = rad_to_deg(angle)
		shard.material_override = inner_material
		shard_root.add_child(shard)

	var glyph := Label3D.new()
	glyph.text = label
	glyph.font = CJKFont.get_font()
	glyph.font_size = 32
	glyph.position = Vector3(0.0, 0.12, 0.0)
	glyph.modulate = Color(1.0, 0.95, 0.88, 0.96)
	glyph.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	effect_root.add_child(glyph)

	var tween := create_tween()
	tween.parallel().tween_property(effect_root, "scale", Vector3(1.18, 1.0, 1.18), 0.28)
	tween.parallel().tween_property(outer_ring, "rotation_degrees:y", 28.0, 0.28)
	if inner_ring != null:
		tween.parallel().tween_property(inner_ring, "rotation_degrees:y", -36.0, 0.28)
	tween.parallel().tween_property(shard_root, "rotation_degrees:y", 42.0, 0.28)
	tween.tween_callback(effect_root.queue_free)


func _spawn_slash_afterimages(origin: Vector3, forward: Vector3, radius: float, tint: Color, label: String) -> void:
	if not _visual_effects_enabled():
		return
	var direction := forward
	direction.y = 0.0
	if direction.length_squared() < 0.001:
		direction = Vector3.FORWARD
	direction = direction.normalized()
	var count: int = int(PERFORMANCE_SLASH_AFTERIMAGES.get(_performance_mode(), PERFORMANCE_SLASH_AFTERIMAGES["balanced"]))
	for index in range(count):
		var spread := 0.0 if count <= 1 else (float(index) / float(count - 1) - 0.5)
		var slash_direction := direction.rotated(Vector3.UP, spread * 0.54).normalized()
		var glyph_text := label if index == maxi(0, int(floor(float(count - 1) * 0.5))) else "刂"
		var distance := minf(radius * (0.42 + absf(spread) * 0.12), radius - 0.35)
		distance = maxf(distance, 1.15 + absf(spread) * 0.26)
		_spawn_afterimage_glyph(
			origin + slash_direction * distance,
			glyph_text,
			tint.lightened(0.08 + absf(spread) * 0.1),
			slash_direction,
			1.0 - absf(spread) * 0.12,
			1.08 + absf(spread) * 0.12,
			0.42
		)


func _spawn_player_impact_afterimages(world_position: Vector3, tint: Color, label: String) -> void:
	if not _visual_effects_enabled():
		return
	var count: int = int(PERFORMANCE_IMPACT_AFTERIMAGES.get(_performance_mode(), PERFORMANCE_IMPACT_AFTERIMAGES["balanced"]))
	for index in range(count):
		var angle: float = TAU * float(index) / float(max(count, 1))
		var drift := Vector3(cos(angle), 0.0, sin(angle))
		var glyph_text := label if index == 0 else "丶"
		_spawn_afterimage_glyph(
			world_position + drift * 0.18,
			glyph_text,
			tint.lightened(0.16),
			drift,
			0.72 if index > 0 else 0.82,
			0.56,
			0.32
		)


func _spawn_afterimage_glyph(
	world_position: Vector3,
	glyph_text: String,
	tint: Color,
	drift_direction: Vector3,
	size: float,
	height_offset: float,
	duration: float
) -> void:
	if not _visual_effects_enabled():
		return
	_ensure_decorative_effects_root()
	var root := Node3D.new()
	root.position = world_position + Vector3(0.0, height_offset, 0.0)
	decorative_effects_root.add_child(root)

	var normalized_drift := drift_direction
	normalized_drift.y = 0.0
	if normalized_drift.length_squared() < 0.001:
		normalized_drift = Vector3.FORWARD
	normalized_drift = normalized_drift.normalized()

	var disc := MeshInstance3D.new()
	var disc_mesh := CylinderMesh.new()
	disc_mesh.top_radius = 0.18 * size
	disc_mesh.bottom_radius = 0.18 * size
	disc_mesh.height = 0.04
	disc.mesh = disc_mesh
	var disc_material := StandardMaterial3D.new()
	disc_material.albedo_color = Color(tint.r * 0.2, tint.g * 0.2, tint.b * 0.22, 0.2)
	disc_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	disc_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	disc_material.emission_enabled = true
	disc_material.emission = tint
	disc_material.emission_energy_multiplier = 0.16
	disc.material_override = disc_material
	root.add_child(disc)

	var glyph := Label3D.new()
	glyph.text = glyph_text
	glyph.font = CJKFont.get_font()
	glyph.font_size = int(round(34.0 * size))
	glyph.position = Vector3(0.0, 0.03, 0.0)
	glyph.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	glyph.modulate = Color(1.0, 0.95, 0.88, 0.92)
	root.add_child(glyph)

	var tween := create_tween()
	var travel_target := root.position + normalized_drift * (0.72 + size * 0.18) + Vector3(0.0, 0.42 + size * 0.08, 0.0)
	tween.parallel().tween_property(root, "position", travel_target, duration)
	tween.parallel().tween_property(root, "scale", Vector3.ONE * (1.18 + size * 0.12), duration)
	tween.parallel().tween_property(glyph, "modulate:a", 0.0, duration)
	tween.tween_callback(root.queue_free)


func _spawn_enemy_death_effect(world_position: Vector3, enemy_type: String) -> void:
	if not _visual_effects_enabled():
		return
	_ensure_decorative_effects_root()
	var tint: Color = _enemy_effect_color(enemy_type)
	var glyph_text: String = _enemy_effect_glyph(enemy_type)
	var effect_root := Node3D.new()
	effect_root.position = world_position + Vector3(0.0, 0.16, 0.0)
	decorative_effects_root.add_child(effect_root)

	var ring := MeshInstance3D.new()
	var ring_mesh := CylinderMesh.new()
	ring_mesh.top_radius = 0.64
	ring_mesh.bottom_radius = 0.64
	ring_mesh.height = 0.04
	ring.mesh = ring_mesh
	var ring_material := StandardMaterial3D.new()
	ring_material.albedo_color = Color(tint.r, tint.g, tint.b, 0.34)
	ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	ring_material.emission_enabled = true
	ring_material.emission = tint
	ring.material_override = ring_material
	effect_root.add_child(ring)

	var shard_root := Node3D.new()
	effect_root.add_child(shard_root)
	for index in range(5):
		var shard := MeshInstance3D.new()
		var shard_mesh := BoxMesh.new()
		shard_mesh.size = Vector3(0.12, 0.04, 0.26)
		shard.mesh = shard_mesh
		var angle: float = TAU * float(index) / 5.0
		shard.position = Vector3(cos(angle) * 0.32, 0.08, sin(angle) * 0.32)
		shard.rotation_degrees = Vector3(18.0, rad_to_deg(angle), 22.0)
		shard.material_override = ring_material
		shard_root.add_child(shard)

	var glyph := Label3D.new()
	glyph.text = glyph_text
	glyph.font = CJKFont.get_font()
	glyph.font_size = 28
	glyph.position = Vector3(0.0, 0.12, 0.0)
	glyph.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	glyph.modulate = Color(1.0, 0.95, 0.88, 0.94)
	effect_root.add_child(glyph)

	var tween := create_tween()
	tween.parallel().tween_property(effect_root, "scale", Vector3(1.28, 1.0, 1.28), 0.32)
	tween.parallel().tween_property(effect_root, "position:y", effect_root.position.y + 0.26, 0.32)
	tween.parallel().tween_property(ring, "rotation_degrees:y", 34.0, 0.32)
	tween.parallel().tween_property(shard_root, "rotation_degrees:y", -54.0, 0.32)
	tween.parallel().tween_property(glyph, "modulate:a", 0.0, 0.32)
	tween.tween_callback(effect_root.queue_free)


func _spawn_boss_entrance_effect(world_position: Vector3, glyph_text: String, tint: Color) -> void:
	if not _visual_effects_enabled():
		return
	_ensure_decorative_effects_root()
	var effect_root := Node3D.new()
	effect_root.position = world_position + Vector3(0.0, 0.2, 0.0)
	decorative_effects_root.add_child(effect_root)
	var symbol_count: int = int(PERFORMANCE_BOSS_SYMBOLS.get(_performance_mode(), PERFORMANCE_BOSS_SYMBOLS["balanced"]))

	for index in range(symbol_count):
		var symbol_root := Node3D.new()
		var angle: float = TAU * float(index) / float(symbol_count)
		symbol_root.position = Vector3(cos(angle) * 2.3, 0.0, sin(angle) * 2.3)
		effect_root.add_child(symbol_root)

		var disc := MeshInstance3D.new()
		var disc_mesh := CylinderMesh.new()
		disc_mesh.top_radius = 0.42
		disc_mesh.bottom_radius = 0.42
		disc_mesh.height = 0.05
		disc.mesh = disc_mesh
		var disc_material := StandardMaterial3D.new()
		disc_material.albedo_color = Color(0.05, 0.06, 0.08, 0.86)
		disc_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		disc_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		disc_material.emission_enabled = true
		disc_material.emission = tint.darkened(0.18)
		disc.material_override = disc_material
		symbol_root.add_child(disc)

		var label := Label3D.new()
		label.text = glyph_text
		label.font = CJKFont.get_font()
		label.font_size = 28
		label.position = Vector3(0.0, 0.04, 0.0)
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.modulate = Color(1.0, 0.95, 0.86, 0.96)
		symbol_root.add_child(label)

		var tween := create_tween()
		tween.parallel().tween_property(symbol_root, "position:y", 1.4, 0.95)
		tween.parallel().tween_property(symbol_root, "scale", Vector3(1.28, 1.0, 1.28), 0.95)
		tween.parallel().tween_property(label, "modulate:a", 0.0, 0.95)

	var cleanup_tween := create_tween()
	cleanup_tween.tween_interval(0.98)
	cleanup_tween.tween_callback(effect_root.queue_free)


func _enemy_effect_color(enemy_type: String) -> Color:
	match enemy_type:
		"swift":
			return Color(0.98, 0.54, 0.32, 1.0)
		"tank":
			return Color(0.58, 0.66, 0.78, 1.0)
		"archer":
			return Color(0.9, 0.68, 0.34, 1.0)
		"assassin":
			return Color(0.88, 0.42, 0.58, 1.0)
		"cavalry":
			return Color(0.9, 0.34, 0.26, 1.0)
		"ritualist":
			return Color(0.66, 0.48, 0.96, 1.0)
		"elite":
			return Color(0.88, 0.34, 0.48, 1.0)
		"boss":
			return Color(0.96, 0.42, 0.28, 1.0)
		_:
			return Color(0.82, 0.42, 0.32, 1.0)


func _enemy_effect_glyph(enemy_type: String) -> String:
	match enemy_type:
		"swift":
			return "迅"
		"tank":
			return "甲"
		"archer":
			return "弓"
		"assassin":
			return "忍"
		"cavalry":
			return "骑"
		"ritualist":
			return "阵"
		"elite":
			return "魁"
		"boss":
			return "卷"
		_:
			return "魇"


func _on_player_health_changed(current: float, maximum: float) -> void:
	hud.set_health(current, maximum)
	if current < last_player_health_value:
		_play_player_hurt_sfx((last_player_health_value - current) / maxf(maximum, 1.0))
	last_player_health_value = current
	var health_ratio: float = current / maxf(maximum, 0.001)
	if health_ratio <= 0.35 and low_health_callout_ready:
		low_health_callout_ready = false
		_show_hero_callout("low_health", 3.0)
	elif health_ratio >= 0.58:
		low_health_callout_ready = true


func _on_player_defeated() -> void:
	game_over = true
	paused = false
	map_overlay_active = false
	active_boss = null
	Engine.time_scale = 0.0
	hud.hide_map_overlay()
	hud.hide_boss()
	hud.show_banner("The Ink Sea Sinks" if _is_english() else "字海沉没", Color(1.0, 0.76, 0.58, 1.0), 2.0)
	Session.last_run_summary = _build_run_summary()
	var start_wave := maxi(1, int(Session.last_run_summary.get("start_wave", 1)))
	var recordable := bool(Session.last_run_summary.get("recordable", true))
	var leaderboard_view := "manual" if recordable and start_wave <= 1 else "test"
	if recordable or start_wave > 1:
		Session.record_local_run(Session.last_run_summary, Session.selected_hero)
		if leaderboard_view == "test":
			hud.set_game_over(
				"This test-run result has been written to the test board and will not affect the main-scroll board. Press R to restart immediately, or Esc to return to the sub-menu." if _is_english() else "试阵记录已写入试阵榜，不会影响主卷榜。按 R 立即重开，或按 Esc 返回二级菜单。",
				elapsed_time,
				kills,
				threat_level,
				level,
				leaderboard_view
			)
		else:
			hud.set_game_over(
				"The ink tide swallowed you. Press R to restart immediately, or Esc to return to the sub-menu." if _is_english() else "墨潮吞没了你。按 R 立即重开，或按 Esc 返回二级菜单。",
				elapsed_time,
				kills,
				threat_level,
				level,
				leaderboard_view
			)
	else:
		hud.set_game_over(
			"This shortcut run will not be written into the leaderboard. Press R to restart immediately, or Esc to return to the sub-menu." if _is_english() else "这次捷径不会写入排行榜。按 R 立即重开，或按 Esc 返回二级菜单。",
			elapsed_time,
			kills,
			threat_level,
			level,
			leaderboard_view
		)


func _build_run_summary() -> Dictionary:
	var blade_level: int = 0
	if is_instance_valid(player):
		blade_level = player.blade_level

	return {
		"elapsed": elapsed_time,
		"kills": kills,
		"threat": threat_level,
		"level": level,
		"start_wave": int(battle_intro.get("start_wave", 1)),
		"recordable": bool(battle_intro.get("recordable", true)),
		"bosses": int(Session.chapter_progress.get("completed_bosses", 0)),
		"chapter_complete": bool(Session.chapter_progress.get("chapter_complete", false)),
		"radicals": radical_counts.duplicate(true),
		"recipes": skill_levels.duplicate(true),
		"words": word_skill_levels.duplicate(true),
		"blade_level": blade_level,
		"enemy_kills": enemy_kills_by_type.duplicate(true)
	}


func _on_bush_activated(message: String) -> void:
	hud.set_tip(message)


func _on_treasure_chest_opened(world_position: Vector3, drops: Dictionary) -> void:
	_spawn_supply_bundle(world_position, drops)
	hud.show_banner("Chest Opened" if _is_english() else "宝箱开启", Color(1.0, 0.84, 0.52, 1.0), 1.7)
	hud.set_tip("The chest spills supplies across the field. Grab paper scraps and ink first, then decide whether to push levels or recover." if _is_english() else "宝箱散出补给。先收残纸与墨团，再决定是压等级还是补状态。")
	_log_battle_event("Chest Opened · Supplies scattered" if _is_english() else "宝箱开启 · 补给散落", Color(1.0, 0.84, 0.52, 1.0))


func _sync_hud() -> void:
	var blade_level: int = 0
	if is_instance_valid(player):
		hud.set_health(player.health, player.max_health)
		blade_level = player.blade_level
	hud.set_progress(level, experience, experience_target)
	hud.set_status(elapsed_time, kills, threat_level)
	hud.set_radicals(radical_counts)
	hud.set_skills(skill_levels, word_skill_levels, word_progress, blade_level, Session.selected_hero)


func _apply_intro_preset() -> void:
	if battle_intro.is_empty() or not battle_intro.has("start_preset") or not is_instance_valid(player):
		return

	var preset_variant: Variant = battle_intro.get("start_preset", {})
	if not (preset_variant is Dictionary):
		return

	var preset := preset_variant as Dictionary
	var preset_elapsed: float = max(0.0, float(preset.get("elapsed_time", 0.0)))
	elapsed_time = preset_elapsed
	level = maxi(1, int(preset.get("level", level)))
	experience = maxi(0, int(preset.get("experience", experience)))
	experience_target = maxi(1, int(preset.get("experience_target", experience_target)))
	threat_level = maxi(1, int(preset.get("start_wave", 1)))
	last_announced_threat_level = threat_level
	boss_spawn_index = _boss_spawn_index_for_elapsed(preset_elapsed)
	var skipped_bosses := mini(boss_spawn_index, BOSS_SPAWN_TIMES.size())
	Session.chapter_progress["completed_bosses"] = skipped_bosses
	Session.chapter_progress["chapter_complete"] = skipped_bosses >= BOSS_SPAWN_TIMES.size()

	for radical in radical_counts.keys():
		radical_counts[radical] = 0
	var preset_radicals: Dictionary = preset.get("radicals", {})
	for radical_variant in preset_radicals.keys():
		var radical := String(radical_variant)
		radical_counts[radical] = maxi(0, int(preset_radicals[radical_variant]))
	for radical in Session.get_hero_starting_radicals():
		radical_counts[radical] = int(radical_counts.get(radical, 0)) + 1
		if radical == "刂":
			player.apply_blade_upgrade()

	for recipe_id in skill_levels.keys():
		skill_levels[recipe_id] = 0
	var preset_recipes: Dictionary = preset.get("recipes", {})
	for recipe_id_variant in preset_recipes.keys():
		var recipe_id := String(recipe_id_variant)
		var recipe_level := maxi(0, int(preset_recipes[recipe_id_variant]))
		skill_levels[recipe_id] = recipe_level
		player.set_skill_level(recipe_id, recipe_level)

	for word_id in word_skill_levels.keys():
		word_skill_levels[word_id] = 0
	var preset_words: Dictionary = preset.get("words", {})
	for word_id_variant in preset_words.keys():
		var word_id := String(word_id_variant)
		var word_level := maxi(0, int(preset_words[word_id_variant]))
		word_skill_levels[word_id] = word_level
		player.set_word_skill_level(word_id, word_level)

	for word_id in word_progress.keys():
		word_progress[word_id] = 0
	var preset_word_progress: Dictionary = preset.get("word_progress", {})
	for word_id_variant in preset_word_progress.keys():
		word_progress[String(word_id_variant)] = maxi(0, int(preset_word_progress[word_id_variant]))

	var blade_target := maxi(0, int(preset.get("blade_level", 0)))
	for _blade_index in range(blade_target):
		player.apply_blade_upgrade()

	player.health = player.max_health
	player.health_changed.emit(player.health, player.max_health)


func _boss_spawn_index_for_elapsed(time_value: float) -> int:
	var next_index := 0
	for spawn_time in BOSS_SPAWN_TIMES:
		if time_value >= float(spawn_time):
			next_index += 1
	return next_index


func _start_opening_sequence() -> void:
	opening_time = 1.65
	spawn_timer = 1.2
	var hero_data: Dictionary = Session.get_selected_hero()
	var localized_hero: Dictionary = _localized_hero_data(hero_data)
	var accent: Color = hero_data["accent"]
	var start_wave := 1
	if not battle_intro.is_empty():
		start_wave = int(battle_intro.get("start_wave", 1))
	var intro_title: String = _localized_intro_title(start_wave, "残卷一·入墨")
	var intro_tip: String = _localized_intro_tip(start_wave, "先收第一枚偏旁，尽快合出首个成字。")
	if not battle_intro.is_empty():
		intro_title = String(battle_intro.get("title", intro_title))
		intro_tip = String(battle_intro.get("tip", intro_tip))
		if _is_english():
			intro_title = _localized_intro_title(start_wave, intro_title)
			intro_tip = _localized_intro_tip(start_wave, intro_tip)
	var intro_suffix := "enters the scroll" if _is_english() else "入卷"
	hud.show_banner("%s  ·  %s %s" % [intro_title, String(localized_hero["name"]), intro_suffix], accent, 2.6)
	hud.set_tip(intro_tip)
	var soundtrack_track := "mosslightCanopy"
	var soundtrack_cue := "入卷铺陈"
	if threat_level >= 4 or elapsed_time >= 60.0:
		soundtrack_track = "fireflyFootpath"
		soundtrack_cue = "试阵开卷"
	_set_soundtrack(soundtrack_track, soundtrack_cue, true, true)
	_play_cue_sfx("run_start", 1.0)
	_log_battle_event("%s · %s %s" % [intro_title, String(localized_hero["name"]), "enters the scroll" if _is_english() else "入卷"], accent)
	_spawn_wave_effect(player.global_position, 3.3, accent, String(hero_data["glyph"]))
	_spawn_intro_symbols(String(hero_data["glyph"]), accent)
	_show_hero_callout("intro", 3.0)


func _clear_active_wave_for_test_jump() -> void:
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			enemy.queue_free()

	active_boss = null
	if hud != null:
		hud.hide_boss()

	for child in projectiles_root.get_children():
		if is_instance_valid(child) and not child.is_queued_for_deletion():
			child.queue_free()
	for child in effects_root.get_children():
		if is_instance_valid(child) and not child.is_queued_for_deletion():
			child.queue_free()
	_clear_decorative_effects()


func _jump_to_next_wave_for_test() -> void:
	if not _test_tools_enabled() or not is_instance_valid(player):
		return

	var next_wave := threat_level + 1
	var target_elapsed := maxf(elapsed_time + 0.05, float(next_wave - 1) * 30.0 + 0.05)
	_clear_active_wave_for_test_jump()
	opening_time = 0.0
	spawn_timer = 0.08
	elapsed_time = target_elapsed
	_on_threat_level_advanced(next_wave)
	threat_level = next_wave
	_update_boss_flow()
	_sync_hud()
	if hud != null:
		hud.show_banner(("Test Jump · Wave %d" if _is_english() else "试阵跃迁 · 第 %d 波") % next_wave, _threat_level_color(next_wave), 1.95)
		hud.set_tip(("The current enemies, hazards, and projectiles were cleared and the run jumped to wave %d so you can inspect pacing, effect density, and FPS." if _is_english() else "已清空当前敌群并切到第 %d 波，可继续观察刷怪节奏、演出密度和 FPS。") % next_wave)
		_log_battle_event(("Test Jump · Wave %d" if _is_english() else "试阵跃迁 · 第 %d 波") % next_wave, _threat_level_color(next_wave))


func _on_boss_defeated(world_position: Vector3) -> void:
	var completed_bosses: int = int(Session.chapter_progress.get("completed_bosses", 0)) + 1
	Session.chapter_progress["completed_bosses"] = completed_bosses
	_play_cue_sfx("boss_defeat", 1.0)
	if chamber_modifier_expires_after_bosses > 0 and completed_bosses >= chamber_modifier_expires_after_bosses:
		_clear_chamber_modifier()
	if completed_bosses >= BOSS_SPAWN_TIMES.size():
		chamber_break_pending = false
		Session.chapter_progress["chapter_complete"] = true
		hud.show_banner("Scroll I Secured" if _is_english() else "残卷一暂定", Color(1.0, 0.88, 0.58, 1.0), 2.6)
		hud.show_reveal(
			_current_scroll_label(),
			_boss_defeat_reveal_title(completed_bosses),
			_boss_defeat_reveal_detail(completed_bosses),
			Color(1.0, 0.88, 0.58, 1.0),
			"定",
			3.35
		)
		hud.set_tip("Both scroll lords have collapsed. The chapter goal is complete, and you can keep fighting to test the build ceiling." if _is_english() else "本卷两位卷主都已崩散，章节目标完成。继续战斗可测试成长上限。")
		_log_battle_event("Scroll I Secured · Bosses gone" if _is_english() else "残卷一暂定 · 卷主尽散", Color(1.0, 0.88, 0.58, 1.0))
		_set_soundtrack("mosslightCanopy", "残卷暂定", true, true)
		_show_hero_callout("chapter_complete", 3.2)
	else:
		chamber_break_pending = true
		hud.show_banner("Boss Dispersed" if _is_english() else "卷主退散", Color(1.0, 0.84, 0.52, 1.0), 2.2)
		hud.show_reveal(
			_boss_defeat_kicker(completed_bosses),
			_boss_defeat_reveal_title(completed_bosses),
			_boss_defeat_reveal_detail(completed_bosses),
			Color(1.0, 0.84, 0.52, 1.0),
			"破",
			3.1
		)
		hud.set_tip("The scroll lord has fallen. Clear the lingering glyph spirits and a chamber break will open before the run pushes deeper." if _is_english() else "卷主崩散后，先清掉残留字灵；战场安静下来后，会先停在卷间缓冲再继续入深层。")
		_log_battle_event("Boss Dispersed · The scroll unfolds deeper" if _is_english() else "卷主退散 · 残卷继续翻开", Color(1.0, 0.84, 0.52, 1.0))
		_set_soundtrack("mosslightCanopy", "残卷回气", true, true)
		_show_hero_callout("boss_defeat", 3.0)
	_spawn_wave_effect(world_position, 7.2, Color(1.0, 0.74, 0.46, 1.0), "破")
	_gain_experience(12)


func _open_chamber_break_gate() -> void:
	if game_over or not chamber_break_pending:
		return
	chamber_break_pending = false
	chamber_interlude_offer = {
		"reward_radical": _pick_chamber_interlude_radical(),
		"next_chamber_id": _next_chamber_id_after_interlude()
	}
	if map_overlay_active:
		_set_map_overlay(false)
	paused = true
	Engine.time_scale = 0.0
	if hud != null and hud.has_method("show_chamber_interlude"):
		var next_wave := maxi(threat_level + 1, 2)
		hud.show_chamber_interlude(
			_chamber_interlude_title(),
			_chamber_interlude_body(next_wave),
			_chamber_interlude_options(),
			_chamber_interlude_preview_lines(next_wave)
		)
	_log_battle_event("Between Chambers · Choose one route" if _is_english() else "卷间抉择 · 先定一条路", Color(0.96, 0.82, 0.54, 1.0))


func _field_phase_theme_for_wave(wave: int) -> Dictionary:
	var safe_wave := maxi(1, wave)
	var index := int(floor(float(safe_wave - 1) / float(FIELD_PHASE_WAVE_SPAN))) % FIELD_PHASE_THEMES.size()
	return FIELD_PHASE_THEMES[index]


func _field_phase_glyph_for_wave(wave: int) -> String:
	var safe_wave := maxi(1, wave)
	var index := int(floor(float(safe_wave - 1) / float(FIELD_PHASE_WAVE_SPAN))) % FIELD_PHASE_GLYPH_SEQUENCE.size()
	return FIELD_PHASE_GLYPH_SEQUENCE[index]


func _field_phase_blend_value() -> float:
	return _ease_in_out(field_phase_transition)


func _ease_in_out(value: float) -> float:
	var clamped_value: float = clamp(value, 0.0, 1.0)
	if clamped_value < 0.5:
		return 2.0 * clamped_value * clamped_value
	return 1.0 - pow(-2.0 * clamped_value + 2.0, 2.0) * 0.5


func _reset_field_phase_state(wave: int = 1) -> void:
	var theme := _field_phase_theme_for_wave(wave)
	var glyph := _field_phase_glyph_for_wave(wave)
	field_phase_previous_theme = theme
	field_phase_target_theme = theme
	field_phase_previous_glyph = glyph
	field_phase_target_glyph = glyph
	field_phase_transition = 1.0
	_apply_field_phase_theme_blend(theme, theme, 1.0)


func _set_field_phase_for_wave(wave: int, announce: bool = true) -> void:
	var next_theme := _field_phase_theme_for_wave(wave)
	var next_glyph := _field_phase_glyph_for_wave(wave)
	if String(field_phase_target_theme.get("id", "")) == String(next_theme.get("id", "")) and field_phase_target_glyph == next_glyph:
		return

	field_phase_previous_theme = field_phase_target_theme if not field_phase_target_theme.is_empty() else next_theme
	field_phase_target_theme = next_theme
	field_phase_previous_glyph = field_phase_target_glyph
	field_phase_target_glyph = next_glyph
	field_phase_transition = 0.0

	if not announce or not is_instance_valid(player):
		return

	var stamp_position: Vector3 = _field_phase_stamp_position()
	_spawn_field_phase_stamp(stamp_position, next_glyph, next_theme)
	_spawn_wave_effect(stamp_position, 5.1, Color(next_theme.get("accent", Color(1.0, 1.0, 1.0, 1.0))), next_glyph)
	_play_cue_sfx("realm_shift", 1.0)
	if hud != null:
		var localized_theme := _localized_field_phase_theme(next_theme)
		hud.show_banner(("Realm Shift · %s" if _is_english() else "字境相变 · %s") % String(localized_theme.get("name", "Realm" if _is_english() else "字境")), Color(next_theme.get("accent", Color(1.0, 1.0, 1.0, 1.0))), 2.6)
		hud.show_reveal(
			"Realm Shift" if _is_english() else "字境相变",
			String(localized_theme.get("name", "Realm" if _is_english() else "字境")),
			String(localized_theme.get("tip", "")),
			Color(next_theme.get("accent", Color(1.0, 1.0, 1.0, 1.0))),
			next_glyph,
			3.0
		)
		hud.set_tip(("Wave %d enters %s. %s" if _is_english() else "第 %d 波切入%s。%s") % [wave, String(localized_theme.get("name", "Realm" if _is_english() else "字境")), String(localized_theme.get("tip", ""))])
		_log_battle_event(("Realm Shift · %s" if _is_english() else "字境相变 · %s") % String(localized_theme.get("name", "Realm" if _is_english() else "字境")), Color(next_theme.get("accent", Color(1.0, 1.0, 1.0, 1.0))))
	var soundtrack_track: String = current_soundtrack_id if not current_soundtrack_id.is_empty() else "mosslightCanopy"
	_set_soundtrack(soundtrack_track, String(next_theme.get("cue", "字境相变")), true, true)


func _update_field_phase(delta: float) -> void:
	if field_phase_target_theme.is_empty():
		return
	if field_phase_transition < 1.0:
		field_phase_transition = min(field_phase_transition + delta / FIELD_PHASE_TRANSITION_TIME, 1.0)
	_apply_field_phase_theme_blend(field_phase_previous_theme, field_phase_target_theme, _field_phase_blend_value())


func _field_phase_stamp_position() -> Vector3:
	var forward := Vector3(0.0, 0.0, -1.0)
	if is_instance_valid(player):
		var look_variant: Variant = player.get("look_direction")
		if look_variant is Vector3:
			forward = look_variant
	if forward.length_squared() < 0.001:
		forward = Vector3(0.0, 0.0, -1.0)
	forward = forward.normalized()
	var side := Vector3.UP.cross(forward).normalized()
	var position: Vector3 = player.global_position + forward * 2.4 + side * 0.42
	position.x = clamp(position.x, -MAP_WORLD_RADIUS + 3.2, MAP_WORLD_RADIUS - 3.2)
	position.z = clamp(position.z, -MAP_WORLD_RADIUS + 3.2, MAP_WORLD_RADIUS - 3.2)
	position.y = 0.05
	return position


func _spawn_field_phase_stamp(world_position: Vector3, glyph_text: String, theme: Dictionary) -> void:
	if not _visual_effects_enabled():
		return
	if field_phase_stamp_root == null:
		field_phase_stamp_root = Node3D.new()
		field_phase_stamp_root.name = "FieldPhaseStamps"
		ground_root.add_child(field_phase_stamp_root)

	var accent := Color(theme.get("accent", Color(1.0, 1.0, 1.0, 1.0)))
	var stamp_root := Node3D.new()
	stamp_root.position = world_position
	field_phase_stamp_root.add_child(stamp_root)

	var base_disc := MeshInstance3D.new()
	var base_disc_mesh := CylinderMesh.new()
	base_disc_mesh.top_radius = 3.2
	base_disc_mesh.bottom_radius = 3.2
	base_disc_mesh.height = 0.04
	base_disc.mesh = base_disc_mesh
	var base_disc_material := StandardMaterial3D.new()
	base_disc_material.albedo_color = Color(accent.r * 0.28, accent.g * 0.3, accent.b * 0.26, 0.18)
	base_disc_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	base_disc_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	base_disc_material.emission_enabled = true
	base_disc_material.emission = accent
	base_disc_material.emission_energy_multiplier = 0.3
	base_disc.material_override = base_disc_material
	stamp_root.add_child(base_disc)

	var outer_disc := MeshInstance3D.new()
	var outer_disc_mesh := CylinderMesh.new()
	outer_disc_mesh.top_radius = 4.6
	outer_disc_mesh.bottom_radius = 4.6
	outer_disc_mesh.height = 0.02
	outer_disc.mesh = outer_disc_mesh
	outer_disc.position.y = 0.01
	var outer_disc_material := StandardMaterial3D.new()
	outer_disc_material.albedo_color = Color(accent.r, accent.g, accent.b, 0.07)
	outer_disc_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	outer_disc_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	outer_disc_material.emission_enabled = true
	outer_disc_material.emission = Color(accent.r * 0.82, accent.g * 0.82, accent.b * 0.82, 1.0)
	outer_disc_material.emission_energy_multiplier = 0.18
	outer_disc.material_override = outer_disc_material
	stamp_root.add_child(outer_disc)

	for line_index in range(3):
		var line := MeshInstance3D.new()
		var line_mesh := BoxMesh.new()
		line_mesh.size = Vector3(0.22, 0.02, 4.8 - float(line_index) * 0.7)
		line.mesh = line_mesh
		line.position.y = 0.03
		line.rotation_degrees.y = 28.0 + float(line_index) * 46.0
		var line_material := StandardMaterial3D.new()
		line_material.albedo_color = Color(accent.r * 0.42, accent.g * 0.42, accent.b * 0.42, 0.16)
		line_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		line_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		line_material.emission_enabled = true
		line_material.emission = accent
		line_material.emission_energy_multiplier = 0.12
		line.material_override = line_material
		stamp_root.add_child(line)

	var glyph := Label3D.new()
	glyph.text = glyph_text
	glyph.font = CJKFont.get_font()
	glyph.font_size = 112
	glyph.scale = Vector3(3.8, 3.8, 3.8)
	glyph.position = Vector3(0.0, 0.05, 0.0)
	glyph.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	glyph.modulate = Color(1.0, 0.96, 0.88, 0.46)
	stamp_root.add_child(glyph)

	field_phase_stamp_entries.append({
		"root": stamp_root,
		"glyph": glyph,
		"outer_disc": outer_disc,
		"base_position": world_position,
		"base_scale": outer_disc.scale,
		"phase": rng.randf_range(0.0, TAU)
	})
	while field_phase_stamp_entries.size() > FIELD_PHASE_STAMP_LIMIT:
		var oldest_entry: Dictionary = field_phase_stamp_entries.pop_front()
		var oldest_root = oldest_entry.get("root", null)
		if oldest_root is Node3D and is_instance_valid(oldest_root):
			(oldest_root as Node3D).queue_free()


func _update_field_phase_stamps() -> void:
	if field_phase_stamp_entries.is_empty():
		return
	for entry in field_phase_stamp_entries:
		var root_variant = entry.get("root", null)
		var glyph_variant = entry.get("glyph", null)
		var disc_variant = entry.get("outer_disc", null)
		if not (root_variant is Node3D) or not is_instance_valid(root_variant):
			continue
		var root := root_variant as Node3D
		var base_position: Vector3 = entry.get("base_position", root.position)
		var phase: float = float(entry.get("phase", 0.0))
		root.position = base_position + Vector3(0.0, sin(elapsed_time * 0.16 + phase) * 0.01, 0.0)
		root.rotation_degrees.y = sin(elapsed_time * 0.08 + phase) * 5.0
		if glyph_variant is Label3D and is_instance_valid(glyph_variant):
			var glyph_label := glyph_variant as Label3D
			glyph_label.modulate.a = 0.34 + (sin(elapsed_time * 0.3 + phase) * 0.5 + 0.5) * 0.16
		if disc_variant is MeshInstance3D and is_instance_valid(disc_variant):
			var outer_disc := disc_variant as MeshInstance3D
			var base_scale: Vector3 = entry.get("base_scale", Vector3.ONE)
			var pulse := 1.0 + sin(elapsed_time * 0.44 + phase) * 0.08
			outer_disc.scale = base_scale * pulse


func _on_threat_level_advanced(new_threat_level: int) -> void:
	last_announced_threat_level = new_threat_level
	if not is_instance_valid(player):
		return

	var tint: Color = _threat_level_color(new_threat_level)
	var wave_glyph := _threat_level_glyph(new_threat_level)
	if _is_big_wave(new_threat_level):
		hud.show_banner(("Glyph Tide Wave %d · Major Surge" if _is_english() else "字潮第 %d 波 · 大潮") % new_threat_level, tint, 2.35)
		_log_battle_event(("Wave %d · Major Surge" if _is_english() else "第 %d 波 · 大潮压境") % new_threat_level, tint)
		spawn_timer = min(spawn_timer, 0.16)
		_set_soundtrack("fireflyFootpath", "大潮压境", true, true)
		_play_cue_sfx("wave_major", 1.0 + float(new_threat_level) * 0.02)
	else:
		hud.show_banner(("Glyph Tide Wave %d" if _is_english() else "字潮第 %d 波") % new_threat_level, tint, 1.85)
		_log_battle_event(("Wave %d · Tide Advances" if _is_english() else "第 %d 波 · 字潮推进") % new_threat_level, tint)
		if new_threat_level == 2:
			_set_soundtrack("fireflyFootpath", "字潮提速", true, true)
		_play_cue_sfx("wave_step", 0.92 + float(new_threat_level) * 0.02)
	hud.set_tip(_threat_level_tip(new_threat_level))
	_spawn_wave_effect(player.global_position, (6.4 if _is_big_wave(new_threat_level) else 4.6) + float(new_threat_level) * 0.45, tint, wave_glyph)
	_spawn_intro_symbols(wave_glyph, tint)
	if new_threat_level > 1 and (new_threat_level - 1) % FIELD_PHASE_WAVE_SPAN == 0:
		_set_field_phase_for_wave(new_threat_level, true)
	_apply_chamber_modifier_wave_echo(new_threat_level)


func _threat_level_color(new_threat_level: int) -> Color:
	if _is_big_wave(new_threat_level):
		return Color(0.98, 0.56, 0.3, 1.0)
	match new_threat_level:
		2:
			return Color(0.96, 0.74, 0.42, 1.0)
		3:
			return Color(0.68, 0.6, 0.98, 1.0)
		4:
			return Color(0.92, 0.4, 0.3, 1.0)
		_:
			return Color(0.94, 0.42, 0.52, 1.0)


func _threat_level_glyph(new_threat_level: int) -> String:
	if _is_big_wave(new_threat_level):
		return "潮"
	match new_threat_level:
		2:
			return "弓"
		3:
			return "阵"
		4:
			return "骑"
		_:
			return "魁"


func _threat_level_tip(new_threat_level: int) -> String:
	if _is_big_wave(new_threat_level):
		if _is_english():
			return "A major surge is here. Spawn rate and enemy cap both rise, so clear the outer ranged threats before spending skills on the center crush."
		return "大潮压境。刷怪频率和场上敌量上限同时抬高，先清外围远程，再留技能处理中心重压。"
	match new_threat_level:
		2:
			if _is_english():
				return "The tide rises. Archers start entering the line, so watch for ranged pressure while kiting."
			return "字潮抬升。弓手开始混入阵线，注意被远程拉扯。"
		3:
			if _is_english():
				return "The tide swells again. Assassins and ritualists join the wave, so dashes and ground arrays will overlap."
			return "字潮再涨。忍与阵师入场，突刺和地阵会一起施压。"
		4:
			if _is_english():
				return "Ink cavalry has entered the field. Keep moving and do not stand inside the charge line for too long."
			return "墨骑踏阵。保持走位，不要在冲锋预警线里停太久。"
		_:
			if _is_english():
				return "Elites begin appearing more often, so prepare supplies and phrase timing before the next pressure spike."
			return "魁首开始现身，补给和成词节奏都要提前准备。"


func _spawn_intro_symbols(glyph: String, tint: Color) -> void:
	if not _visual_effects_enabled():
		return
	_ensure_decorative_effects_root()
	var root := Node3D.new()
	root.position = player.global_position + Vector3(0.0, 0.4, 0.0)
	decorative_effects_root.add_child(root)
	var symbol_count: int = int(PERFORMANCE_INTRO_SYMBOLS.get(_performance_mode(), PERFORMANCE_INTRO_SYMBOLS["balanced"]))

	for index in range(symbol_count):
		var symbol_root := Node3D.new()
		var angle: float = TAU * float(index) / float(symbol_count)
		symbol_root.position = Vector3(cos(angle) * 1.7, 0.0, sin(angle) * 1.7)
		root.add_child(symbol_root)

		var disc := MeshInstance3D.new()
		var disc_mesh := CylinderMesh.new()
		disc_mesh.top_radius = 0.36
		disc_mesh.bottom_radius = 0.36
		disc_mesh.height = 0.05
		disc.mesh = disc_mesh
		var disc_material := StandardMaterial3D.new()
		disc_material.albedo_color = Color(0.05, 0.07, 0.09, 0.84)
		disc_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		disc_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		disc_material.emission_enabled = true
		disc_material.emission = tint.darkened(0.2)
		disc.material_override = disc_material
		symbol_root.add_child(disc)

		var label := Label3D.new()
		label.text = glyph
		label.font = CJKFont.get_font()
		label.font_size = 26
		label.position = Vector3(0.0, 0.04, 0.0)
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.modulate = Color(1.0, 0.95, 0.86, 0.96)
		symbol_root.add_child(label)

		var tween := create_tween()
		tween.parallel().tween_property(symbol_root, "position:y", 1.15, 0.72)
		tween.parallel().tween_property(symbol_root, "scale", Vector3(1.16, 1.0, 1.16), 0.72)
		tween.parallel().tween_property(label, "modulate:a", 0.0, 0.72)
	var cleanup_tween := create_tween()
	cleanup_tween.tween_interval(0.74)
	cleanup_tween.tween_callback(root.queue_free)


func _set_paused(should_pause: bool) -> void:
	if game_over:
		return
	if should_pause and map_overlay_active:
		_set_map_overlay(false)
	paused = should_pause
	Engine.time_scale = 0.0 if paused else 1.0
	if paused:
		hud.show_pause_menu(elapsed_time, kills, threat_level, level)
	else:
		hud.hide_state_overlay()


func _set_map_overlay(should_show: bool) -> void:
	if game_over:
		return
	if should_show:
		if paused or levelup_active or word_choice_active:
			return
		map_overlay_active = true
		Engine.time_scale = 0.0
		hud.show_map_overlay(_build_map_snapshot())
		return

	map_overlay_active = false
	Engine.time_scale = 1.0
	hud.hide_map_overlay()


func _build_map_snapshot() -> Dictionary:
	var markers: Array[Dictionary] = []
	_append_map_group(markers, "map_tree", "tree", Color(0.44, 0.7, 0.48, 1.0))
	_append_map_group(markers, "map_bush", "bush", Color(0.58, 0.88, 0.64, 1.0))
	_append_map_group(markers, "map_inkstone", "inkstone", Color(0.96, 0.78, 0.46, 1.0))
	_append_map_group(markers, "map_chest", "chest", Color(0.98, 0.76, 0.46, 1.0))
	_append_map_group(markers, "map_stela", "stela", Color(0.64, 0.86, 1.0, 1.0))
	_append_map_group(markers, "map_scroll_rack", "scroll_rack", Color(0.94, 0.86, 0.66, 1.0))
	_append_map_group(markers, "map_ink_pool", "ink_pool", Color(0.7, 0.5, 0.98, 1.0))

	var enemies: Array[Dictionary] = []
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		var enemy_type: String = String(enemy.get("enemy_type"))
		enemies.append({
			"position": _map_point(enemy.global_position),
			"kind": "boss" if enemy_type == "boss" else "enemy",
			"color": _map_enemy_color(enemy_type)
		})

	var inkstone_count: int = get_tree().get_nodes_in_group("map_inkstone").size()
	var bush_count: int = get_tree().get_nodes_in_group("map_bush").size()
	var landmark_count: int = (
		get_tree().get_nodes_in_group("map_tree").size() +
		get_tree().get_nodes_in_group("map_chest").size() +
		get_tree().get_nodes_in_group("map_stela").size() +
		get_tree().get_nodes_in_group("map_scroll_rack").size() +
		get_tree().get_nodes_in_group("map_ink_pool").size()
	)
	var chamber_name := _current_chamber_name()

	return {
		"world_radius": MAP_WORLD_RADIUS,
		"fog_cell_size": MAP_FOG_CELL_SIZE,
		"explored_cells": explored_map_cells.keys(),
		"player": _map_point(player.global_position if is_instance_valid(player) else Vector3.ZERO),
		"player_heading": _map_direction(player.look_direction if is_instance_valid(player) else Vector3(0.0, 0.0, -1.0)),
		"markers": markers,
		"enemies": enemies,
		"summary": (
			"%s  ·  Enemies %d  ·  Inkstones %d  ·  Bushes %d  ·  Landmarks %d  ·  Explored %d%%"
			if _is_english()
			else "%s  ·  敌群 %d  ·  砚台 %d  ·  草丛 %d  ·  地标 %d  ·  探索 %d%%"
		) % [chamber_name, enemies.size(), inkstone_count, bush_count, landmark_count, _map_exploration_percent()]
	}


func _append_map_group(markers: Array[Dictionary], group_name: String, kind: String, color: Color) -> void:
	for node in get_tree().get_nodes_in_group(group_name):
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		markers.append({
			"position": _map_point(node.global_position),
			"kind": kind,
			"color": color
		})


func _map_point(world_position: Vector3) -> Vector2:
	return Vector2(world_position.x, world_position.z)


func _map_direction(world_direction: Vector3) -> Vector2:
	var flat := Vector2(world_direction.x, world_direction.z)
	if flat.length_squared() < 0.001:
		return Vector2(0.0, -1.0)
	return flat.normalized()


func _map_enemy_color(enemy_type: String) -> Color:
	match enemy_type:
		"boss":
			return Color(0.98, 0.78, 0.48, 1.0)
		"elite":
			return Color(0.92, 0.34, 0.46, 1.0)
		"ritualist":
			return Color(0.7, 0.52, 1.0, 1.0)
		"assassin":
			return Color(0.92, 0.48, 0.66, 1.0)
		"cavalry":
			return Color(0.98, 0.5, 0.34, 1.0)
		"tank":
			return Color(0.68, 0.76, 0.88, 1.0)
		"archer":
			return Color(0.96, 0.72, 0.4, 1.0)
		_:
			return Color(0.92, 0.42, 0.34, 1.0)


func _reveal_map_around_position(world_position: Vector3) -> void:
	var center := _map_point(world_position)
	var fog_reveal_radius := MAP_FOG_REVEAL_RADIUS + maxf(map_reveal_radius_bonus, 0.0)
	var min_cell := _map_fog_cell_from_world(center - Vector2.ONE * fog_reveal_radius)
	var max_cell := _map_fog_cell_from_world(center + Vector2.ONE * fog_reveal_radius)
	var reveal_radius: float = fog_reveal_radius + MAP_FOG_CELL_SIZE * 0.42
	for cell_x in range(min_cell.x, max_cell.x + 1):
		for cell_y in range(min_cell.y, max_cell.y + 1):
			var cell := Vector2i(cell_x, cell_y)
			if _map_fog_cell_center(cell).distance_to(center) <= reveal_radius:
				explored_map_cells[cell] = true


func _map_fog_cell_from_world(point: Vector2) -> Vector2i:
	var safe_extent: float = MAP_WORLD_RADIUS - 0.001
	var clamped_x: float = clamp(point.x, -MAP_WORLD_RADIUS, safe_extent)
	var clamped_y: float = clamp(point.y, -MAP_WORLD_RADIUS, safe_extent)
	return Vector2i(
		int(floor((clamped_x + MAP_WORLD_RADIUS) / MAP_FOG_CELL_SIZE)),
		int(floor((clamped_y + MAP_WORLD_RADIUS) / MAP_FOG_CELL_SIZE))
	)


func _map_fog_cell_center(cell: Vector2i) -> Vector2:
	return Vector2(
		-MAP_WORLD_RADIUS + (float(cell.x) + 0.5) * MAP_FOG_CELL_SIZE,
		-MAP_WORLD_RADIUS + (float(cell.y) + 0.5) * MAP_FOG_CELL_SIZE
	)


func _map_exploration_percent() -> int:
	var cells_per_axis := maxi(1, int(ceil((MAP_WORLD_RADIUS * 2.0) / MAP_FOG_CELL_SIZE)))
	var total_cells := cells_per_axis * cells_per_axis
	return int(round(float(explored_map_cells.size()) / float(total_cells) * 100.0))


func _on_hud_pause_resume_requested() -> void:
	_set_paused(false)


func _on_hud_chamber_interlude_selected(choice_id: String) -> void:
	if game_over or not paused:
		return
	var next_chamber_id := String(chamber_interlude_offer.get("next_chamber_id", current_chamber_id))

	match choice_id:
		"reward":
			var reward_radical := String(chamber_interlude_offer.get("reward_radical", "日"))
			var reward_color := Color(Session.RADICAL_COLORS.get(reward_radical, Color(0.94, 0.72, 0.4, 1.0)))
			_arm_chamber_modifier("reward_supply")
			_apply_radical_choice(reward_radical)
			hud.show_banner(
				("Radical Cache  Next chamber drops rise" if _is_english() else "偏旁补给  下一段残纸更盛"),
				reward_color,
				1.8
			)
			hud.set_tip(("Radical supply secured. `%s` now enters the next chamber, and enemy drops there will carry more paper and seals." if _is_english() else "偏旁补给已经带上，「%s」会跟着你继续入深层，下一段敌人也会带来更多残纸和战印。") % reward_radical)
			_log_battle_event(("Between Chambers · Radical supply %s" if _is_english() else "卷间抉择 · 偏旁补给 %s") % reward_radical, reward_color)
		"event":
			_arm_scroll_echo_modifier()
			hud.show_banner(
				"Scroll Echo Armed" if _is_english() else "残卷回响已挂载",
				Color(0.96, 0.62, 0.34, 1.0),
				1.9
			)
			hud.set_tip(
				"This chamber choice now carries into the next chamber: pressure enemies echo extra paper, and elites can drop Swift Edict until the next scroll lord."
				if _is_english()
				else "这次卷间异事会一路带进下一段：压境敌群会额外回响残纸，精英也能多吐一枚疾书令，持续到下一位卷主。"
			)
			_log_battle_event(
				"Between Chambers · Scroll Echo armed for the next chamber" if _is_english() else "卷间抉择 · 残卷回响会一路带进下一段",
				Color(0.96, 0.62, 0.34, 1.0)
			)
		"recovery":
			_arm_chamber_modifier("short_rest")
			if is_instance_valid(player):
				player.heal(player.max_health * CHAMBER_INTERLUDE_REST_HEAL_RATIO)
				if player.has_method("clear_stun"):
					player.clear_stun()
				player.apply_brush_haste(CHAMBER_INTERLUDE_REST_BRUSH_DURATION)
			hud.show_banner(
				("Short Rest  Restore %d%% Vitality" if _is_english() else "歇笔回气  回复 %d%% 气血") % int(round(CHAMBER_INTERLUDE_REST_HEAL_RATIO * 100.0)),
				Color(0.62, 0.9, 0.74, 1.0),
				1.9
			)
			hud.set_tip(("Short rest restores vitality, clears stun, and gives %d s of brush haste now; later wave pushes in the next chamber also echo smaller recovery." if _is_english() else "歇笔修整会先回气、解眩晕，并补上 %d 秒文笔提速；下一段后续字潮推进时还会再回一小口气。") % int(round(CHAMBER_INTERLUDE_REST_BRUSH_DURATION)))
			_log_battle_event(
				("Between Chambers · Short Rest %d%%" if _is_english() else "卷间抉择 · 歇笔回气 %d%%") % int(round(CHAMBER_INTERLUDE_REST_HEAL_RATIO * 100.0)),
				Color(0.62, 0.9, 0.74, 1.0)
			)
		_:
			return

	chamber_interlude_offer.clear()
	_transition_to_chamber(next_chamber_id)
	_sync_hud()
	_set_paused(false)


func _on_hud_pause_requested() -> void:
	_set_paused(true)


func _on_hud_map_toggle_requested() -> void:
	_set_map_overlay(not map_overlay_active)


func _on_hud_test_next_wave_requested() -> void:
	if game_over or paused or map_overlay_active or levelup_active or word_choice_active or chamber_break_pending:
		return
	_jump_to_next_wave_for_test()


func _on_hud_battle_setting_changed(_setting_key: String, _value: Variant) -> void:
	battle_settings = Session.get_battle_settings()
	_apply_battle_settings()


func _on_hud_movement_input_changed(input_vector: Vector2) -> void:
	if is_instance_valid(player):
		player.set_external_move_input(input_vector)


func _on_hud_interact_requested() -> void:
	if game_over or map_overlay_active or levelup_active or word_choice_active:
		return
	if paused:
		if hud != null and hud.has_method("is_settings_menu_open") and hud.is_settings_menu_open():
			hud.return_to_pause_menu()
		elif hud != null and hud.has_method("is_pause_menu_open") and hud.is_pause_menu_open():
			_set_paused(false)
		return
	if active_inkstone != null:
		_handle_inkstone_interact()


func _on_hud_restart_requested() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()


func _on_hud_return_menu_requested() -> void:
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file(Session.ZIHAI_MENU_SCENE)


func _update_inkstone_interaction() -> void:
	if _room_objective_active():
		active_inkstone = null
		return
	var previous_inkstone: Node3D = active_inkstone
	active_inkstone = _find_nearby_inkstone()
	if active_inkstone == null:
		if previous_inkstone != null:
			hud.set_tip(_default_battle_tip())
		return

	if _has_grindable_words():
		hud.set_tip("Move close to the inkstone and press E to refine phrases. Phrase arts can only be formed here." if _is_english() else "靠近砚台，按 E 磨词。词技只会在这里成型。")
		if Input.is_action_just_pressed("interact"):
			_handle_inkstone_interact()
	else:
		hud.set_tip("The inkstone waits. Max a fused glyph first, then bring its related radicals here for phrase refinement." if _is_english() else "砚台静候。先把合字升满，再带着相关偏旁来磨词。")
		if Input.is_action_just_pressed("interact"):
			_handle_inkstone_interact()


func _handle_inkstone_interact() -> void:
	if active_inkstone == null:
		return
	if _has_grindable_words():
		_present_word_choices()
	else:
		hud.show_banner("No glyph is ready for the inkstone" if _is_english() else "砚上无字可磨", Color(0.7, 0.84, 1.0, 1.0), 1.5)


func _find_nearby_inkstone() -> Node3D:
	if not is_instance_valid(player):
		return null
	var nearest: Node3D = null
	var nearest_distance := 3.4
	for inkstone in inkstones:
		if not is_instance_valid(inkstone):
			continue
		var distance: float = player.global_position.distance_to(inkstone.global_position)
		if distance <= nearest_distance:
			nearest = inkstone
			nearest_distance = distance
	return nearest


func _has_grindable_words() -> bool:
	for word_id_variant in Session.WORD_ORDER:
		if _can_grind_word(String(word_id_variant)):
			return true
	return false


func _can_grind_word(word_id: String) -> bool:
	var word: Dictionary = Session.get_word_data(word_id)
	var word_level: int = int(word_skill_levels.get(word_id, 0))
	if word_level >= int(word["max_level"]):
		return false

	var recipe_id: String = String(word["recipe_id"])
	var recipe: Dictionary = Session.get_recipe_data(recipe_id)
	if int(skill_levels.get(recipe_id, 0)) < int(recipe["max_level"]):
		return false

	return _count_recipe_radicals(recipe["radicals"]) > 0


func _count_recipe_radicals(radicals: Array) -> int:
	var seen: Dictionary = {}
	var total: int = 0
	for radical_variant in radicals:
		var radical := String(radical_variant)
		if seen.has(radical):
			continue
		seen[radical] = true
		total += max(0, int(radical_counts.get(radical, 0)))
	return total


func _present_word_choices() -> void:
	var choices: Array[Dictionary] = _build_word_choices()
	if choices.is_empty():
		return
	word_choice_active = true
	Engine.time_scale = 0.0
	hud.show_word_choices(choices)


func _build_word_choices() -> Array[Dictionary]:
	var choices: Array[Dictionary] = []
	for word_id_variant in Session.WORD_ORDER:
		var word_id := String(word_id_variant)
		if _can_grind_word(word_id):
			choices.append(_build_word_choice_data(word_id))
	return choices


func _build_word_choice_data(word_id: String) -> Dictionary:
	var word: Dictionary = _localized_word_data(word_id)
	var recipe_id: String = String(word["recipe_id"])
	var recipe: Dictionary = _localized_recipe_data(recipe_id)
	var word_level: int = int(word_skill_levels.get(word_id, 0))
	var stock: int = _count_recipe_radicals(recipe["radicals"])
	var headline: String
	if word_level <= 0:
		headline = ("Refine %d/%d" if _is_english() else "磨词 %d/%d") % [
			min(int(word_progress.get(word_id, 0)) + 1, int(word["unlock_cost"])),
			int(word["unlock_cost"])
		]
	else:
		headline = ("Phrase Upgrade  Lv.%d -> Lv.%d" if _is_english() else "词技升级  Lv.%d -> Lv.%d") % [word_level, min(word_level + 1, int(word["max_level"]))]

	return {
		"word_id": word_id,
		"display": String(word["display"]),
		"title": String(word["title"]),
		"headline": headline,
		"description": ("%s\nCurrent stock: %d, drawn from `%s`." if _is_english() else "%s\n当前余材：%d 枚，来自「%s」。") % [
			String(word["description"]),
			stock,
			String(recipe["display"])
		],
		"color": Color(word["color"])
	}


func _on_word_choice_selected(word_id: String) -> void:
	if not word_choice_active:
		return

	_apply_word_choice(word_id)
	word_choice_active = false
	Engine.time_scale = 1.0
	hud.hide_choice_overlay()
	_sync_hud()


func _apply_word_choice(word_id: String) -> void:
	var word: Dictionary = _localized_word_data(word_id)
	var recipe: Dictionary = _localized_recipe_data(String(word["recipe_id"]))
	var stored_radical: String = _find_available_recipe_radical(recipe["radicals"])
	if stored_radical.is_empty():
		hud.show_banner("Not enough stock" if _is_english() else "余材不足", Color(word["color"]), 1.4)
		return

	radical_counts[stored_radical] = int(radical_counts.get(stored_radical, 0)) - 1
	var word_level: int = int(word_skill_levels.get(word_id, 0))
	if word_level <= 0:
		word_progress[word_id] = int(word_progress.get(word_id, 0)) + 1
		if int(word_progress[word_id]) >= int(word["unlock_cost"]):
			word_progress[word_id] = int(word["unlock_cost"])
			_set_word_level(word_id, 1)
		else:
			hud.show_banner(("%s refine %d/%d" if _is_english() else "%s 磨词 %d/%d") % [
				String(word["display"]),
				int(word_progress[word_id]),
				int(word["unlock_cost"])
			], word["color"], 1.6)
	elif word_level < int(word["max_level"]):
		_set_word_level(word_id, word_level + 1)


func _update_camera(delta: float) -> void:
	if not is_instance_valid(player):
		return
	var target_position := Vector3(player.global_position.x, 0.0, player.global_position.z)
	camera_rig.global_position = camera_rig.global_position.lerp(target_position, clamp(delta * 4.5, 0.0, 1.0))
	camera.look_at(player.global_position + Vector3(0.0, 0.8, 0.0), Vector3.UP)


func _setup_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.82, 0.79, 0.7, 1.0)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.78, 0.82, 0.74, 1.0)
	environment.ambient_light_energy = 0.8
	environment.fog_enabled = true
	environment.fog_density = 0.012
	environment.fog_light_color = Color(0.8, 0.84, 0.78, 1.0)
	world_environment.environment = environment


func _build_ground() -> void:
	ground_detail_nodes.clear()
	ground_surface_materials.clear()
	backdrop_material_entries.clear()
	field_phase_stamp_entries.clear()
	ground_ripple_focus = Vector3.ZERO
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(180.0, 180.0)
	floor.mesh = plane
	var floor_material := _make_ground_material(
		Color(0.28, 0.25, 0.2, 1.0),
		Color(0.42, 0.5, 0.43, 1.0),
		Color(0.74, 0.69, 0.58, 1.0),
		0.2,
		0.34,
		0.16,
		0.0
	)
	floor.material_override = floor_material
	ground_root.add_child(floor)

	for index in range(18):
		var mound := MeshInstance3D.new()
		var mound_mesh := SphereMesh.new()
		mound_mesh.radius = rng.randf_range(1.5, 3.8)
		mound_mesh.height = mound_mesh.radius * 1.4
		mound.mesh = mound_mesh
		mound.position = Vector3(
			rng.randf_range(-42.0, 42.0),
			-rng.randf_range(0.8, 1.4),
			rng.randf_range(-42.0, 42.0)
		)
		mound.scale = Vector3(1.2, 0.4, 1.0 + randf() * 0.8)
		var mound_material := _make_ground_material(
			Color(0.24, 0.21, 0.18, 1.0),
			Color(0.36, 0.42, 0.39, 1.0),
			Color(0.56, 0.52, 0.46, 1.0),
			0.08,
			0.24,
			0.06,
			float(index) * 0.41
		)
		mound.material_override = mound_material
		ground_root.add_child(mound)
		ground_detail_nodes.append(mound)

	field_phase_stamp_root = Node3D.new()
	field_phase_stamp_root.name = "FieldPhaseStamps"
	ground_root.add_child(field_phase_stamp_root)

	ambient_glyph_root = Node3D.new()
	ambient_glyph_root.name = "AmbientGlyphs"
	ground_root.add_child(ambient_glyph_root)
	_build_shanshui_backdrop()


func _make_ground_material(base_color: Color, ink_color: Color, paper_color: Color, ripple_strength: float, detail_mix: float, emission_strength: float, phase_offset: float) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = GROUND_SURFACE_SHADER
	material.set_shader_parameter("base_color", base_color)
	material.set_shader_parameter("ink_color", ink_color)
	material.set_shader_parameter("paper_color", paper_color)
	material.set_shader_parameter("ripple_strength", ripple_strength)
	material.set_shader_parameter("detail_mix", detail_mix)
	material.set_shader_parameter("emission_strength", emission_strength)
	material.set_shader_parameter("phase_offset", phase_offset)
	material.set_shader_parameter("focus_position", Vector3.ZERO)
	material.set_shader_parameter("ambient_drift", Vector2(0.12, -0.08))
	material.set_shader_parameter("theme_glow_color", Color(0.72, 0.88, 0.78, 1.0))
	material.set_shader_parameter("theme_shadow_color", Color(0.16, 0.22, 0.2, 1.0))
	material.set_shader_parameter("ambient_visibility", 1.0)
	material.set_shader_parameter("phase_presence", 1.0)
	ground_surface_materials.append(material)
	return material


func _update_ground_shader(delta: float) -> void:
	if ground_surface_materials.is_empty() or not is_instance_valid(player):
		return
	var target_focus := Vector3(player.global_position.x, 0.0, player.global_position.z)
	if ground_ripple_focus == Vector3.ZERO:
		ground_ripple_focus = target_focus
	else:
		ground_ripple_focus = ground_ripple_focus.lerp(target_focus, clamp(delta * 1.7, 0.0, 1.0))
	for material_variant in ground_surface_materials:
		var material: ShaderMaterial = material_variant
		if material == null:
			continue
		material.set_shader_parameter("focus_position", ground_ripple_focus)


func _base_fog_density() -> float:
	return float(PERFORMANCE_FOG_DENSITY.get(_performance_mode(), PERFORMANCE_FOG_DENSITY["balanced"]))


func _apply_field_phase_theme_blend(from_theme: Dictionary, to_theme: Dictionary, blend: float) -> void:
	if world_environment.environment == null:
		return

	var environment := world_environment.environment
	var background_from := Color(from_theme.get("environment_bg", environment.background_color))
	var background_to := Color(to_theme.get("environment_bg", environment.background_color))
	environment.background_color = background_from.lerp(background_to, blend)

	var ambient_from := Color(from_theme.get("environment_ambient", environment.ambient_light_color))
	var ambient_to := Color(to_theme.get("environment_ambient", environment.ambient_light_color))
	environment.ambient_light_color = ambient_from.lerp(ambient_to, blend)
	environment.ambient_light_energy = lerpf(0.78, 0.84, blend)

	var fog_from := Color(from_theme.get("environment_fog", environment.fog_light_color))
	var fog_to := Color(to_theme.get("environment_fog", environment.fog_light_color))
	environment.fog_light_color = fog_from.lerp(fog_to, blend)
	environment.fog_density = _base_fog_density() * lerpf(float(from_theme.get("fog_density_scale", 1.0)), float(to_theme.get("fog_density_scale", 1.0)), blend)

	field_phase_ambient_visibility = lerpf(float(from_theme.get("ambient_visibility", 1.0)), float(to_theme.get("ambient_visibility", 1.0)), blend)

	var drift_from := Vector2(from_theme.get("ambient_drift", Vector2(0.12, -0.08)))
	var drift_to := Vector2(to_theme.get("ambient_drift", Vector2(0.12, -0.08)))
	var glow_from := Color(from_theme.get("ground_glow", Color(0.72, 0.88, 0.78, 1.0)))
	var glow_to := Color(to_theme.get("ground_glow", Color(0.72, 0.88, 0.78, 1.0)))
	var shadow_from := Color(from_theme.get("ground_shadow", Color(0.16, 0.22, 0.2, 1.0)))
	var shadow_to := Color(to_theme.get("ground_shadow", Color(0.16, 0.22, 0.2, 1.0)))
	for material_variant in ground_surface_materials:
		var material: ShaderMaterial = material_variant
		if material == null:
			continue
		material.set_shader_parameter("ambient_drift", drift_from.lerp(drift_to, blend))
		material.set_shader_parameter("theme_glow_color", glow_from.lerp(glow_to, blend))
		material.set_shader_parameter("theme_shadow_color", shadow_from.lerp(shadow_to, blend))
		material.set_shader_parameter("ambient_visibility", field_phase_ambient_visibility)
		material.set_shader_parameter("phase_presence", 1.0)

	_apply_field_phase_backdrop_blend(from_theme, to_theme, blend)


func _apply_field_phase_backdrop_blend(from_theme: Dictionary, to_theme: Dictionary, blend: float) -> void:
	for entry in backdrop_material_entries:
		var material_variant = entry.get("material", null)
		if not (material_variant is ShaderMaterial):
			continue
		var material := material_variant as ShaderMaterial
		var layer_index: int = int(entry.get("layer_index", 0))
		var layer_mix: float = clamp(0.58 - float(layer_index) * 0.09, 0.32, 0.58)
		var base_mountain := Color(entry.get("mountain", Color(0.4, 0.34, 0.27, 0.78)))
		var base_mist := Color(entry.get("mist", Color(0.9, 0.84, 0.74, 0.34)))
		var base_paper := Color(entry.get("paper", Color(0.94, 0.86, 0.72, 0.18)))
		var alpha_base: float = float(entry.get("alpha", 0.8))
		var mountain_from := base_mountain.lerp(Color(from_theme.get("backdrop_mountain", base_mountain)), layer_mix)
		var mountain_to := base_mountain.lerp(Color(to_theme.get("backdrop_mountain", base_mountain)), layer_mix)
		var mist_from := base_mist.lerp(Color(from_theme.get("backdrop_mist", base_mist)), layer_mix)
		var mist_to := base_mist.lerp(Color(to_theme.get("backdrop_mist", base_mist)), layer_mix)
		var paper_from := base_paper.lerp(Color(from_theme.get("backdrop_paper", base_paper)), layer_mix)
		var paper_to := base_paper.lerp(Color(to_theme.get("backdrop_paper", base_paper)), layer_mix)
		material.set_shader_parameter("mountain_color", mountain_from.lerp(mountain_to, blend))
		material.set_shader_parameter("mist_color", mist_from.lerp(mist_to, blend))
		material.set_shader_parameter("paper_tint", paper_from.lerp(paper_to, blend))
		material.set_shader_parameter(
			"alpha_strength",
			alpha_base * lerpf(float(from_theme.get("backdrop_alpha", 1.0)), float(to_theme.get("backdrop_alpha", 1.0)), blend)
		)

	if backdrop_mist_material != null:
		var mist_from := Color(from_theme.get("backdrop_mist", Color(0.95, 0.9, 0.82, 0.22)))
		var mist_to := Color(to_theme.get("backdrop_mist", Color(0.95, 0.9, 0.82, 0.22)))
		var paper_from := Color(from_theme.get("backdrop_paper", Color(0.95, 0.9, 0.82, 0.22)))
		var paper_to := Color(to_theme.get("backdrop_paper", Color(0.95, 0.9, 0.82, 0.22)))
		backdrop_mist_material.albedo_color = paper_from.lerp(paper_to, blend)
		backdrop_mist_material.emission = mist_from.lerp(mist_to, blend)


func _build_shanshui_backdrop() -> void:
	if is_instance_valid(backdrop_root):
		backdrop_root.queue_free()

	backdrop_root = Node3D.new()
	backdrop_root.name = "ShanshuiBackdrop"
	ground_root.add_child(backdrop_root)

	var layers := [
		{
			"radius": 52.0,
			"height": 11.0,
			"width": 28.0,
			"elevation": 5.0,
			"mountain": Color(0.4, 0.34, 0.27, 0.78),
			"mist": Color(0.9, 0.84, 0.74, 0.34),
			"paper": Color(0.94, 0.86, 0.72, 0.18),
			"alpha": 0.9,
			"phase_step": 0.6
		},
		{
			"radius": 46.0,
			"height": 9.4,
			"width": 24.0,
			"elevation": 4.2,
			"mountain": Color(0.5, 0.43, 0.34, 0.66),
			"mist": Color(0.94, 0.88, 0.8, 0.4),
			"paper": Color(0.98, 0.92, 0.82, 0.2),
			"alpha": 0.8,
			"phase_step": 1.1
		},
		{
			"radius": 39.5,
			"height": 7.8,
			"width": 20.0,
			"elevation": 3.4,
			"mountain": Color(0.56, 0.47, 0.38, 0.5),
			"mist": Color(0.98, 0.92, 0.86, 0.42),
			"paper": Color(0.99, 0.95, 0.88, 0.18),
			"alpha": 0.68,
			"phase_step": 1.7
		}
	]

	for layer_index in range(layers.size()):
		var layer: Dictionary = layers[layer_index]
		for segment_index in range(6):
			var plane := MeshInstance3D.new()
			var mesh := PlaneMesh.new()
			mesh.size = Vector2(float(layer["width"]), float(layer["height"]))
			plane.mesh = mesh
			var angle: float = TAU * float(segment_index) / 6.0 + float(layer_index) * 0.22
			var radius: float = float(layer["radius"])
			plane.position = Vector3(cos(angle) * radius, float(layer["elevation"]), sin(angle) * radius)
			plane.rotation.y = angle + PI
			var material := ShaderMaterial.new()
			material.shader = SHANSHUI_BACKDROP_SHADER
			material.set_shader_parameter("mountain_color", Color(layer["mountain"]))
			material.set_shader_parameter("mist_color", Color(layer["mist"]))
			material.set_shader_parameter("paper_tint", Color(layer["paper"]))
			material.set_shader_parameter("alpha_strength", float(layer["alpha"]))
			material.set_shader_parameter("phase_offset", float(segment_index) * float(layer["phase_step"]) + float(layer_index) * 1.8)
			material.set_shader_parameter("ridge_height", 0.54 - float(layer_index) * 0.08)
			plane.material_override = material
			backdrop_root.add_child(plane)
			backdrop_material_entries.append({
				"material": material,
				"layer_index": layer_index,
				"mountain": Color(layer["mountain"]),
				"mist": Color(layer["mist"]),
				"paper": Color(layer["paper"]),
				"alpha": float(layer["alpha"])
			})

	var mist_disc := MeshInstance3D.new()
	var mist_mesh := CylinderMesh.new()
	mist_mesh.top_radius = 58.0
	mist_mesh.bottom_radius = 58.0
	mist_mesh.height = 0.12
	mist_disc.mesh = mist_mesh
	mist_disc.position = Vector3(0.0, 0.16, 0.0)
	var mist_material := StandardMaterial3D.new()
	mist_material.albedo_color = Color(0.95, 0.9, 0.82, 0.22)
	mist_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mist_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mist_material.emission_enabled = true
	mist_material.emission = Color(0.88, 0.82, 0.72, 1.0)
	mist_material.emission_energy_multiplier = 0.12
	mist_disc.material_override = mist_material
	backdrop_mist_material = mist_material
	backdrop_root.add_child(mist_disc)


func _create_tree(position: Vector3) -> void:
	var tree_root := Node3D.new()
	tree_root.position = position
	tree_root.add_to_group("map_tree")
	props_root.add_child(tree_root)

	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.24
	trunk_mesh.bottom_radius = 0.3
	trunk_mesh.height = 2.6
	trunk.mesh = trunk_mesh
	trunk.position = Vector3(0.0, 1.3, 0.0)
	var trunk_material := StandardMaterial3D.new()
	trunk_material.albedo_color = Color(0.26, 0.17, 0.1, 1.0)
	_prepare_tree_material_for_fade(trunk_material)
	trunk.material_override = trunk_material
	tree_root.add_child(trunk)

	var canopy_material := StandardMaterial3D.new()
	canopy_material.albedo_color = Color(0.19, 0.31, 0.21, 1.0)
	canopy_material.roughness = 0.94
	canopy_material.emission_enabled = true
	canopy_material.emission = Color(0.08, 0.16, 0.1, 1.0)
	canopy_material.emission_energy_multiplier = 0.2
	_prepare_tree_material_for_fade(canopy_material)

	var canopy_offsets := [
		Vector3(0.0, 3.08, 0.0),
		Vector3(-0.84, 2.86, 0.26),
		Vector3(0.72, 2.78, -0.18)
	]
	var canopy_scales := [1.0, 0.72, 0.62]
	for index in range(canopy_offsets.size()):
		var canopy := MeshInstance3D.new()
		var canopy_mesh := SphereMesh.new()
		canopy_mesh.radius = 1.7 * canopy_scales[index]
		canopy_mesh.height = canopy_mesh.radius * 1.65
		canopy.mesh = canopy_mesh
		canopy.position = canopy_offsets[index]
		canopy.material_override = canopy_material
		tree_root.add_child(canopy)

	var lantern := MeshInstance3D.new()
	var lantern_mesh := CylinderMesh.new()
	lantern_mesh.top_radius = 0.16
	lantern_mesh.bottom_radius = 0.2
	lantern_mesh.height = 0.26
	lantern.mesh = lantern_mesh
	lantern.position = Vector3(0.58, 2.08, 0.22)
	var lantern_material := StandardMaterial3D.new()
	lantern_material.albedo_color = Color(0.9, 0.82, 0.62, 1.0)
	lantern_material.emission_enabled = true
	lantern_material.emission = Color(0.96, 0.84, 0.46, 1.0)
	lantern_material.emission_energy_multiplier = 0.5
	_prepare_tree_material_for_fade(lantern_material)
	lantern.material_override = lantern_material
	tree_root.add_child(lantern)

	tree_fade_entries.append({
		"root": tree_root,
		"materials": [trunk_material, canopy_material, lantern_material],
		"base_colors": [
			trunk_material.albedo_color,
			canopy_material.albedo_color,
			lantern_material.albedo_color
		],
		"base_emission_energy": [
			trunk_material.emission_energy_multiplier,
			canopy_material.emission_energy_multiplier,
			lantern_material.emission_energy_multiplier
		],
		"alpha": 1.0
	})


func _update_tree_fade(delta: float) -> void:
	if tree_fade_entries.is_empty():
		return

	if not is_instance_valid(player):
		return

	var player_position: Vector3 = player.global_position
	player_position.y = 0.0
	for index in range(tree_fade_entries.size()):
		var entry: Dictionary = tree_fade_entries[index]
		var tree_root = entry.get("root", null)
		if not is_instance_valid(tree_root):
			continue

		var tree_position: Vector3 = tree_root.global_position
		tree_position.y = 0.0
		var distance_ratio: float = clamp(player_position.distance_to(tree_position) / TREE_FADE_RADIUS, 0.0, 1.0)
		var target_alpha: float = lerpf(TREE_FADE_ALPHA, 1.0, distance_ratio)
		var current_alpha: float = float(entry.get("alpha", 1.0))
		var next_alpha: float = move_toward(current_alpha, target_alpha, delta * TREE_FADE_SPEED)
		if is_equal_approx(next_alpha, current_alpha):
			continue

		entry["alpha"] = next_alpha
		tree_fade_entries[index] = entry
		_apply_tree_alpha(entry, next_alpha)


func _prepare_tree_material_for_fade(material: StandardMaterial3D) -> void:
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED


func _apply_tree_alpha(entry: Dictionary, alpha: float) -> void:
	var materials: Array = entry.get("materials", [])
	var base_colors: Array = entry.get("base_colors", [])
	var base_emission_energy: Array = entry.get("base_emission_energy", [])
	for material_index in range(materials.size()):
		var material: StandardMaterial3D = materials[material_index]
		if material == null:
			continue

		var base_color: Color = base_colors[material_index]
		material.albedo_color = Color(base_color.r, base_color.g, base_color.b, alpha)
		if material.emission_enabled:
			var base_energy: float = float(base_emission_energy[material_index])
			material.emission_energy_multiplier = max(base_energy * alpha, 0.08)


func _create_phrase_stela(phrase_event: Dictionary) -> void:
	var phrase_position: Vector3 = phrase_event.get("position", Vector3.ZERO)
	var stela_root := _create_stela(
		phrase_position,
		String(phrase_event.get("glyph", "句")),
		Color(phrase_event.get("tint", Color(0.76, 0.86, 1.0, 1.0)))
	)
	var phrase_label := Label3D.new()
	phrase_label.text = String(phrase_event.get("text", ""))
	phrase_label.font = CJKFont.get_font()
	phrase_label.font_size = 20
	phrase_label.position = Vector3(0.0, 3.36, 0.0)
	phrase_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	phrase_label.modulate = Color(1.0, 0.96, 0.88, 0.96)
	stela_root.add_child(phrase_label)

	var badge_label := Label3D.new()
	badge_label.text = "Guarded Phrase" if _is_english() else "句阵守卫"
	badge_label.font = CJKFont.get_font()
	badge_label.font_size = 12
	badge_label.position = Vector3(0.0, 3.7, 0.0)
	badge_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	badge_label.modulate = Color(0.84, 0.92, 1.0, 0.92)
	stela_root.add_child(badge_label)


func _create_stela(position: Vector3, glyph: String, tint: Color) -> Node3D:
	var stela_root := Node3D.new()
	stela_root.position = position
	stela_root.add_to_group("map_stela")
	props_root.add_child(stela_root)

	var stone_material := StandardMaterial3D.new()
	stone_material.albedo_color = Color(0.22, 0.24, 0.28, 1.0)
	stone_material.roughness = 0.96

	var accent_material := StandardMaterial3D.new()
	accent_material.albedo_color = Color(0.3, 0.34, 0.4, 1.0)
	accent_material.roughness = 0.92
	accent_material.emission_enabled = true
	accent_material.emission = tint.darkened(0.34)

	var base := MeshInstance3D.new()
	var base_mesh := BoxMesh.new()
	base_mesh.size = Vector3(1.82, 0.28, 1.26)
	base.mesh = base_mesh
	base.position = Vector3(0.0, 0.14, 0.0)
	base.material_override = accent_material
	stela_root.add_child(base)

	var slab := MeshInstance3D.new()
	var slab_mesh := BoxMesh.new()
	slab_mesh.size = Vector3(1.08, 2.54, 0.34)
	slab.mesh = slab_mesh
	slab.position = Vector3(0.0, 1.5, 0.0)
	slab.material_override = stone_material
	stela_root.add_child(slab)

	var cap := MeshInstance3D.new()
	var cap_mesh := BoxMesh.new()
	cap_mesh.size = Vector3(1.34, 0.18, 0.5)
	cap.mesh = cap_mesh
	cap.position = Vector3(0.0, 2.86, 0.0)
	cap.material_override = accent_material
	stela_root.add_child(cap)

	var glyph_root := Node3D.new()
	glyph_root.position = Vector3(0.0, 2.38, 0.0)
	stela_root.add_child(glyph_root)

	var disc := MeshInstance3D.new()
	var disc_mesh := CylinderMesh.new()
	disc_mesh.top_radius = 0.42
	disc_mesh.bottom_radius = 0.42
	disc_mesh.height = 0.05
	disc.mesh = disc_mesh
	var disc_material := StandardMaterial3D.new()
	disc_material.albedo_color = Color(0.04, 0.06, 0.08, 0.86)
	disc_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	disc_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	disc_material.emission_enabled = true
	disc_material.emission = tint.darkened(0.28)
	disc.material_override = disc_material
	glyph_root.add_child(disc)

	var ring := MeshInstance3D.new()
	var ring_mesh := CylinderMesh.new()
	ring_mesh.top_radius = 0.5
	ring_mesh.bottom_radius = 0.5
	ring_mesh.height = 0.02
	ring.mesh = ring_mesh
	ring.position = Vector3(0.0, 0.03, 0.0)
	var ring_material := StandardMaterial3D.new()
	ring_material.albedo_color = Color(tint.r, tint.g, tint.b, 0.3)
	ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	ring_material.emission_enabled = true
	ring_material.emission = tint
	ring.material_override = ring_material
	glyph_root.add_child(ring)

	var glyph_label := Label3D.new()
	glyph_label.text = glyph
	glyph_label.font = CJKFont.get_font()
	glyph_label.font_size = 30
	glyph_label.position = Vector3(0.0, 0.03, 0.0)
	glyph_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	glyph_label.modulate = Color(1.0, 0.95, 0.86, 0.96)
	glyph_root.add_child(glyph_label)

	for index in range(2):
		var strip := MeshInstance3D.new()
		var strip_mesh := BoxMesh.new()
		strip_mesh.size = Vector3(0.28, 0.04, 0.64)
		strip.mesh = strip_mesh
		strip.position = Vector3(-0.26 + float(index) * 0.52, 0.24, 0.36)
		strip.rotation_degrees = Vector3(18.0, -12.0 + float(index) * 18.0, 0.0)
		strip.material_override = ring_material
		stela_root.add_child(strip)

	var glyph_tween := create_tween().set_loops()
	glyph_tween.tween_property(glyph_root, "position:y", 2.52, 1.8).from(2.38)
	glyph_tween.tween_property(glyph_root, "position:y", 2.38, 1.8)
	var spin_tween := create_tween().set_loops()
	spin_tween.tween_property(glyph_root, "rotation_degrees:y", 360.0, 8.0).from(0.0)
	return stela_root


func _create_scroll_rack(position: Vector3, yaw: float) -> void:
	var rack_root := Node3D.new()
	rack_root.position = position
	rack_root.rotation_degrees.y = yaw
	rack_root.add_to_group("map_scroll_rack")
	props_root.add_child(rack_root)

	var wood_material := StandardMaterial3D.new()
	wood_material.albedo_color = Color(0.34, 0.22, 0.14, 1.0)
	wood_material.roughness = 0.92

	var paper_material := StandardMaterial3D.new()
	paper_material.albedo_color = Color(0.96, 0.92, 0.82, 1.0)
	paper_material.roughness = 0.8
	paper_material.emission_enabled = true
	paper_material.emission = Color(0.18, 0.18, 0.12, 1.0)

	for side in [-0.48, 0.48]:
		var post := MeshInstance3D.new()
		var post_mesh := BoxMesh.new()
		post_mesh.size = Vector3(0.12, 1.66, 0.12)
		post.mesh = post_mesh
		post.position = Vector3(side, 0.83, 0.0)
		post.material_override = wood_material
		rack_root.add_child(post)

	var beam := MeshInstance3D.new()
	var beam_mesh := BoxMesh.new()
	beam_mesh.size = Vector3(1.18, 0.1, 0.14)
	beam.mesh = beam_mesh
	beam.position = Vector3(0.0, 1.58, 0.0)
	beam.material_override = wood_material
	rack_root.add_child(beam)

	for index in range(3):
		var scroll := MeshInstance3D.new()
		var scroll_mesh := BoxMesh.new()
		scroll_mesh.size = Vector3(0.86, 0.06, 0.32)
		scroll.mesh = scroll_mesh
		scroll.position = Vector3(0.0, 1.3 - float(index) * 0.34, 0.0)
		scroll.rotation_degrees = Vector3(0.0, 0.0, 6.0 - float(index) * 5.0)
		scroll.material_override = paper_material
		rack_root.add_child(scroll)

	var tag_root := Node3D.new()
	tag_root.position = Vector3(0.0, 1.18, 0.28)
	rack_root.add_child(tag_root)
	var tag := MeshInstance3D.new()
	var tag_mesh := BoxMesh.new()
	tag_mesh.size = Vector3(0.26, 0.42, 0.04)
	tag.mesh = tag_mesh
	tag.material_override = paper_material
	tag_root.add_child(tag)

	var tag_label := Label3D.new()
	tag_label.text = "卷"
	tag_label.font = CJKFont.get_font()
	tag_label.font_size = 20
	tag_label.position = Vector3(0.0, 0.0, 0.04)
	tag_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tag_label.modulate = Color(0.2, 0.16, 0.12, 0.94)
	tag_root.add_child(tag_label)

	var sway_tween := create_tween().set_loops()
	sway_tween.tween_property(tag_root, "rotation_degrees:z", 8.0, 1.4).from(-8.0)
	sway_tween.tween_property(tag_root, "rotation_degrees:z", -8.0, 1.4)


func _create_ink_pool(position: Vector3, radius: float, tint: Color) -> void:
	var pool_root := Node3D.new()
	pool_root.position = position
	pool_root.add_to_group("map_ink_pool")
	props_root.add_child(pool_root)

	var pool := MeshInstance3D.new()
	var pool_mesh := CylinderMesh.new()
	pool_mesh.top_radius = radius
	pool_mesh.bottom_radius = radius * 0.96
	pool_mesh.height = 0.04
	pool.mesh = pool_mesh
	pool.position = Vector3(0.0, 0.02, 0.0)
	var pool_material := StandardMaterial3D.new()
	pool_material.albedo_color = Color(tint.r * 0.18, tint.g * 0.18, tint.b * 0.22, 0.78)
	pool_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pool_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	pool_material.roughness = 0.18
	pool_material.emission_enabled = true
	pool_material.emission = tint.darkened(0.18)
	pool.material_override = pool_material
	pool_root.add_child(pool)

	var ring := MeshInstance3D.new()
	var ring_mesh := CylinderMesh.new()
	ring_mesh.top_radius = radius * 0.72
	ring_mesh.bottom_radius = radius * 0.72
	ring_mesh.height = 0.02
	ring.mesh = ring_mesh
	ring.position = Vector3(0.0, 0.04, 0.0)
	var ring_material := StandardMaterial3D.new()
	ring_material.albedo_color = Color(tint.r, tint.g, tint.b, 0.24)
	ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	ring_material.emission_enabled = true
	ring_material.emission = tint
	ring.material_override = ring_material
	pool_root.add_child(ring)

	for index in range(3):
		var shard := MeshInstance3D.new()
		var shard_mesh := BoxMesh.new()
		shard_mesh.size = Vector3(0.22, 0.04, 0.48)
		shard.mesh = shard_mesh
		var angle: float = TAU * float(index) / 3.0
		shard.position = Vector3(cos(angle) * radius * 0.56, 0.05, sin(angle) * radius * 0.56)
		shard.rotation_degrees = Vector3(12.0, rad_to_deg(angle) + 18.0, 0.0)
		shard.material_override = ring_material
		pool_root.add_child(shard)

	var glyph := Label3D.new()
	glyph.text = "墨"
	glyph.font = CJKFont.get_font()
	glyph.font_size = 22
	glyph.position = Vector3(0.0, 0.12, 0.0)
	glyph.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	glyph.modulate = Color(1.0, 0.94, 0.86, 0.86)
	pool_root.add_child(glyph)

	var pulse_tween := create_tween().set_loops()
	pulse_tween.tween_property(ring, "scale", Vector3(1.1, 1.0, 1.1), 2.2).from(Vector3(0.94, 1.0, 0.94))
	pulse_tween.tween_property(ring, "scale", Vector3(0.94, 1.0, 0.94), 2.2)


func _enemy_count() -> int:
	return get_tree().get_nodes_in_group("enemy").size()


func _setup_input_map() -> void:
	_ensure_action("move_forward", [KEY_W, KEY_UP])
	_ensure_action("move_back", [KEY_S, KEY_DOWN])
	_ensure_action("move_left", [KEY_A, KEY_LEFT])
	_ensure_action("move_right", [KEY_D, KEY_RIGHT])
	_ensure_action("interact", [KEY_E])
	_ensure_action("toggle_map", [KEY_M, KEY_TAB])
	_ensure_action("restart_run", [KEY_R])
	_ensure_action("return_menu", [KEY_ESCAPE])


func _ensure_action(action_name: StringName, keycodes: Array[int]) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	if InputMap.action_get_events(action_name).is_empty():
		for keycode in keycodes:
			var event := InputEventKey.new()
			event.physical_keycode = keycode
			InputMap.action_add_event(action_name, event)
