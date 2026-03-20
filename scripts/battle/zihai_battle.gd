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
const CJKFont := preload("res://scripts/core/cjk_font.gd")
const DEFAULT_BATTLE_TIP := "击倒字灵收集字力与补给，升级时三选一偏旁。靠近砚台按 E 磨词。"
const BOSS_SPAWN_TIMES := [65.0, 130.0]
const MAP_WORLD_RADIUS := 28.0
const BIG_WAVE_INTERVAL := 5
const BASE_ENEMY_CAP := 28
const MAX_REGULAR_ENEMY_CAP := 38
const BIG_WAVE_ENEMY_CAP := 46

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

var radical_counts: Dictionary = {}
var skill_levels: Dictionary = {}
var word_skill_levels: Dictionary = {}
var word_progress: Dictionary = {}
var inkstones: Array[Node3D] = []
var active_inkstone: Node3D = null
var battle_intro: Dictionary = {}

var level: int = 1
var experience: int = 0
var experience_target: int = 4
var pending_level_choices: int = 0


func _ready() -> void:
	rng.randomize()
	battle_intro = Session.consume_battle_intro()
	radical_counts = Session.build_empty_radicals()
	skill_levels = Session.build_empty_recipe_levels()
	word_skill_levels = Session.build_empty_word_levels()
	word_progress = Session.build_empty_word_progress()
	_setup_input_map()
	_setup_environment()
	_build_ground()
	_spawn_player()
	_spawn_props()
	_spawn_hud()
	_sync_hud()
	_start_opening_sequence()
	set_process(true)


func _process(delta: float) -> void:
	_update_camera(delta)

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

	elapsed_time += delta
	var new_threat_level: int = 1 + int(elapsed_time / 30.0)
	if new_threat_level > threat_level:
		for advanced_level in range(threat_level + 1, new_threat_level + 1):
			_on_threat_level_advanced(advanced_level)
	threat_level = new_threat_level
	_update_boss_flow()

	spawn_timer -= delta
	var enemy_cap := _enemy_cap()
	if spawn_timer <= 0.0 and _enemy_count() < enemy_cap:
		var available_slots: int = max(enemy_cap - _enemy_count(), 0)
		for _index in range(min(_spawn_batch_size(), available_slots)):
			_spawn_enemy()
		spawn_interval = _current_spawn_interval()
		spawn_timer = spawn_interval

	hud.set_status(elapsed_time, kills, threat_level)


func _exit_tree() -> void:
	Engine.time_scale = 1.0


func _spawn_player() -> void:
	var hero_data: Dictionary = Session.get_selected_hero()
	player = HERO_SCENE.instantiate()
	player.configure(hero_data)
	add_child(player)
	player.fire_projectile.connect(_on_player_fire_projectile)
	player.request_wave.connect(_on_player_request_wave)
	player.request_slash.connect(_on_player_request_slash)
	player.health_changed.connect(_on_player_health_changed)
	player.defeated.connect(_on_player_defeated)


func _spawn_hud() -> void:
	hud = BATTLE_HUD_SCENE.instantiate()
	add_child(hud)
	hud.configure(Session.get_selected_hero())
	hud.radical_choice_selected.connect(_on_radical_choice_selected)
	hud.word_choice_selected.connect(_on_word_choice_selected)
	hud.pause_requested.connect(_on_hud_pause_requested)
	hud.pause_resume_requested.connect(_on_hud_pause_resume_requested)
	hud.restart_requested.connect(_on_hud_restart_requested)
	hud.return_menu_requested.connect(_on_hud_return_menu_requested)
	hud.map_toggle_requested.connect(_on_hud_map_toggle_requested)
	_spawn_touch_controls()


func _spawn_touch_controls() -> void:
	touch_controls = TOUCH_CONTROLS_OVERLAY.new()
	add_child(touch_controls)
	touch_controls.movement_input_changed.connect(_on_hud_movement_input_changed)
	touch_controls.interact_requested.connect(_on_hud_interact_requested)


func _spawn_props() -> void:
	var tree_positions := [
		Vector3(-9.0, 0.0, -7.0),
		Vector3(11.0, 0.0, -11.0),
		Vector3(-14.0, 0.0, 9.0),
		Vector3(15.0, 0.0, 7.0),
		Vector3(3.0, 0.0, 14.0),
		Vector3(-2.0, 0.0, -15.0)
	]
	for position_variant in tree_positions:
		_create_tree(position_variant)

	var bush_positions := [
		Vector3(-6.0, 0.0, 4.0),
		Vector3(7.0, 0.0, -3.0),
		Vector3(-12.0, 0.0, -1.0),
		Vector3(10.0, 0.0, 11.0)
	]
	for bush_position_variant in bush_positions:
		var bush = BUSH_ZONE_SCENE.instantiate()
		bush.position = bush_position_variant
		bush.configure(player, 2.25)
		bush.activated.connect(_on_bush_activated)
		bush.add_to_group("map_bush")
		props_root.add_child(bush)

	var inkstone_positions := [
		Vector3(0.0, 0.0, 8.5),
		Vector3(-10.0, 0.0, 12.0)
	]
	for inkstone_position in inkstone_positions:
		var inkstone = INKSTONE_SCENE.instantiate()
		inkstone.position = inkstone_position
		inkstone.add_to_group("map_inkstone")
		props_root.add_child(inkstone)
		inkstones.append(inkstone)

	var chest_data := [
		{
			"position": Vector3(-5.0, 0.0, 15.0),
			"drops": {"paper": 5.0, "ink": 14.0}
		},
		{
			"position": Vector3(13.5, 0.0, -9.5),
			"drops": {"paper": 4.0, "seal": 1.0}
		}
	]
	for chest_variant in chest_data:
		var chest = TREASURE_CHEST_SCENE.instantiate()
		chest.position = chest_variant["position"]
		chest.configure(player, chest_variant["drops"])
		chest.opened.connect(_on_treasure_chest_opened)
		props_root.add_child(chest)

	var stela_data := [
		{"position": Vector3(-18.0, 0.0, -12.0), "glyph": "海", "tint": Color(0.56, 0.84, 1.0, 1.0)},
		{"position": Vector3(18.0, 0.0, -6.0), "glyph": "明", "tint": Color(1.0, 0.86, 0.48, 1.0)},
		{"position": Vector3(-16.0, 0.0, 14.0), "glyph": "休", "tint": Color(0.64, 0.92, 0.72, 1.0)},
		{"position": Vector3(15.0, 0.0, 15.0), "glyph": "卷", "tint": Color(0.9, 0.68, 0.42, 1.0)}
	]
	for stela_variant in stela_data:
		_create_stela(stela_variant["position"], String(stela_variant["glyph"]), Color(stela_variant["tint"]))

	var scroll_racks := [
		{"position": Vector3(-8.0, 0.0, -16.0), "yaw": 18.0},
		{"position": Vector3(12.0, 0.0, -14.0), "yaw": -28.0},
		{"position": Vector3(16.0, 0.0, 2.0), "yaw": 42.0}
	]
	for rack_variant in scroll_racks:
		_create_scroll_rack(rack_variant["position"], float(rack_variant["yaw"]))

	var ink_pools := [
		{"position": Vector3(-15.0, 0.0, 3.0), "radius": 1.6, "tint": Color(0.28, 0.7, 0.82, 1.0)},
		{"position": Vector3(13.0, 0.0, 12.0), "radius": 1.2, "tint": Color(0.76, 0.44, 0.94, 1.0)},
		{"position": Vector3(4.0, 0.0, -17.0), "radius": 1.45, "tint": Color(0.98, 0.72, 0.4, 1.0)}
	]
	for pool_variant in ink_pools:
		_create_ink_pool(pool_variant["position"], float(pool_variant["radius"]), Color(pool_variant["tint"]))


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
	enemy.defeated.connect(_on_enemy_defeated)
	enemy.request_hazard.connect(_on_enemy_request_hazard)
	enemy.request_line_hazard.connect(_on_enemy_request_line_hazard)
	enemy.request_projectile.connect(_on_enemy_request_projectile)
	enemies_root.add_child(enemy)
	if enemy_type == "elite":
		hud.show_banner("精英现身", Color(0.94, 0.42, 0.52, 1.0), 2.0)


func _spawn_boss(stage_index: int) -> void:
	if not is_instance_valid(player):
		return

	var boss = ENEMY_SCENE.instantiate()
	var angle: float = rng.randf_range(0.0, TAU)
	var distance: float = rng.randf_range(16.0, 19.0)
	boss.position = player.global_position + Vector3(cos(angle), 0.0, sin(angle)) * distance
	boss.configure("boss", 1.35 + elapsed_time / 68.0 + float(stage_index) * 0.2, player)
	boss.defeated.connect(_on_enemy_defeated)
	boss.request_hazard.connect(_on_enemy_request_hazard)
	boss.request_line_hazard.connect(_on_enemy_request_line_hazard)
	boss.request_projectile.connect(_on_enemy_request_projectile)
	enemies_root.add_child(boss)
	active_boss = boss
	spawn_timer = max(spawn_timer, 1.4)

	var tint: Color = _boss_banner_color(stage_index)
	hud.show_banner("卷主现身", tint, 2.4)
	hud.set_tip(_boss_stage_tip(stage_index))
	hud.show_boss(String(boss.enemy_name), String(boss.glyph), tint, boss.max_health)
	_spawn_wave_effect(boss.global_position, 6.2, tint, String(boss.glyph))
	_spawn_boss_entrance_effect(boss.global_position, String(boss.glyph), tint)


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
		return "卷主踏入墨阵。先躲大范围禁阵，再抓它施法后的空档。"
	return "更深的卷主现身了。它会把弹幕、冲锋和禁阵叠在一起。"


func _on_player_fire_projectile(origin: Vector3, direction: Vector3, damage: float, speed: float, glyph: String, tint: Color) -> void:
	var bolt = INK_BOLT_SCENE.instantiate()
	bolt.configure(origin, direction, damage, speed, glyph, tint)
	bolt.impact.connect(_on_projectile_impact)
	projectiles_root.add_child(bolt)


func _on_player_request_wave(origin: Vector3, radius: float, damage: float, tint: Color, label: String) -> void:
	_spawn_wave_effect(origin, radius, tint, label)
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


func _on_enemy_defeated(world_position: Vector3, enemy_type: String) -> void:
	kills += 1
	_spawn_enemy_death_effect(world_position, enemy_type)
	_spawn_xp_orb(world_position, _xp_value_for_enemy(enemy_type))
	_spawn_supply_drops(world_position, enemy_type)
	if enemy_type == "boss":
		active_boss = null
		hud.hide_boss()
		_on_boss_defeated(world_position)
	if kills % 14 == 0:
		hud.show_banner("字潮再涨", Color(0.95, 0.62, 0.36, 1.0), 1.7)


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


func _spawn_supply_drops(world_position: Vector3, enemy_type: String) -> void:
	_spawn_supply_bundle(world_position, _build_supply_drops(enemy_type))


func _spawn_supply_bundle(world_position: Vector3, drops: Dictionary) -> void:
	var active_supply_ids: Array[String] = []
	for supply_id_variant in ["paper", "ink", "seal"]:
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
		pickup.collected.connect(_on_supply_collected)
		pickups_root.add_child(pickup)


func _build_supply_drops(enemy_type: String) -> Dictionary:
	var drops := {
		"paper": 0.0,
		"ink": 0.0,
		"seal": 0.0
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

	return drops


func _add_supply_drop(drops: Dictionary, supply_id: String, amount: float) -> void:
	drops[supply_id] = float(drops.get(supply_id, 0.0)) + amount


func _on_xp_collected(value: int) -> void:
	_gain_experience(value)


func _on_supply_collected(world_position: Vector3, supply_id: String, amount: float, tint: Color, label: String) -> void:
	var pulse_radius: float = 1.05
	match supply_id:
		"paper":
			var xp_gain: int = int(round(amount))
			_gain_experience(xp_gain)
			hud.show_banner("拾得残纸  +%d 字墨" % xp_gain, tint, 1.45)
		"ink":
			if is_instance_valid(player):
				player.heal(amount)
				hud.show_banner("拾得墨团  回气 %d" % int(round(amount)), tint, 1.5)
			pulse_radius = 1.12
		"seal":
			if is_instance_valid(player):
				var blade_gain: int = max(1, int(round(amount)))
				player.apply_blade_upgrade(blade_gain)
				hud.show_banner(
					"拾得战印  %s +%d" % ["剑势" if Session.selected_hero == "xia" else "笔锋", blade_gain],
					tint,
					1.7
				)
			pulse_radius = 1.22

	_spawn_wave_effect(world_position, pulse_radius, tint, label)
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
		return score

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
	var radical_data: Dictionary = Session.get_radical_data(radical)
	var color: Color = Session.RADICAL_COLORS[radical]
	var headline: String = String(radical_data["description"])
	if radical == "刂":
		headline = "直接强化%s。" % ("剑势" if Session.selected_hero == "xia" else "笔锋")
	else:
		var recipe_id: String = Session.get_recipe_id_for_radical(radical)
		var recipe: Dictionary = Session.get_recipe_data(recipe_id)
		var level_value: int = int(skill_levels.get(recipe_id, 0))
		var max_level: int = int(recipe["max_level"])
		if level_value <= 0:
			var partner: String = _get_partner_radical(recipe_id, radical)
			if int(radical_counts.get(partner, 0)) > 0:
				headline = "补上最后一笔，立成「%s」。" % String(recipe["display"])
			else:
				headline = "收集成字，通往「%s」。" % String(recipe["display"])
		elif level_value < max_level:
			headline = "提升「%s」 Lv.%d -> Lv.%d。" % [String(recipe["display"]), level_value, level_value + 1]
		else:
			var word: Dictionary = Session.get_word_data(String(recipe["word_id"]))
			var word_level: int = int(word_skill_levels.get(word["id"], 0))
			var stock: int = _count_recipe_radicals(recipe["radicals"]) + 1
			if word_level <= 0:
				headline = "为「%s」添一枚余材，可去砚台磨词 %d/%d。" % [
					String(word["display"]),
					min(int(word_progress.get(word["id"], 0)) + 1, int(word["unlock_cost"])),
					int(word["unlock_cost"])
				]
			else:
				headline = "补充词材，可在砚台将「%s」升到 Lv.%d。当前余材 %d。" % [
					String(word["display"]),
					min(word_level + 1, int(word["max_level"])),
					stock
				]

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
		hud.show_banner("%s 入%s" % [radical, "剑势" if Session.selected_hero == "xia" else "笔锋"], Session.RADICAL_COLORS[radical], 1.8)
		_sync_hud()
		return

	radical_counts[radical] = int(radical_counts.get(radical, 0)) + 1
	hud.show_banner("领悟 %s" % radical, Session.RADICAL_COLORS[radical], 1.2)
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
	var recipe: Dictionary = Session.get_recipe_data(recipe_id)
	if new_level == 1:
		hud.show_banner("合字成型  %s" % String(recipe["display"]), recipe["color"], 2.3)
	else:
		hud.show_banner("%s 进为 Lv.%d" % [String(recipe["display"]), new_level], recipe["color"], 1.7)


func _set_word_level(word_id: String, new_level: int) -> void:
	word_skill_levels[word_id] = new_level
	player.set_word_skill_level(word_id, new_level)
	var word: Dictionary = Session.get_word_data(word_id)
	if new_level == 1:
		hud.show_banner("词技成型  %s" % String(word["display"]), word["color"], 2.5)
	else:
		hud.show_banner("%s 进为 Lv.%d" % [String(word["display"]), new_level], word["color"], 1.8)


func _has_recipe_parts(radicals: Array) -> bool:
	for radical_variant in radicals:
		var radical := String(radical_variant)
		if int(radical_counts.get(radical, 0)) <= 0:
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
	for radical_variant in recipe["radicals"]:
		var recipe_radical := String(radical_variant)
		if recipe_radical != radical:
			return recipe_radical
	return ""


func _on_enemy_request_hazard(target_position: Vector3, radius: float, warning_time: float, active_time: float, damage: float, tint: Color, label: String) -> void:
	var hazard = GROUND_HAZARD_SCENE.instantiate()
	hazard.configure(player, target_position, radius, warning_time, active_time, damage, tint, label)
	effects_root.add_child(hazard)


func _on_enemy_request_line_hazard(origin: Vector3, direction: Vector3, length: float, width: float, warning_time: float, active_time: float, damage: float, tint: Color, label: String, stun_time: float) -> void:
	var hazard = LINE_HAZARD_SCENE.instantiate()
	hazard.configure(player, origin, direction, length, width, warning_time, active_time, damage, tint, label, stun_time)
	effects_root.add_child(hazard)


func _on_enemy_request_projectile(origin: Vector3, direction: Vector3, speed: float, damage: float, glyph: String, tint: Color, life_time: float, hit_radius: float, stun_time: float) -> void:
	var bolt = ENEMY_BOLT_SCENE.instantiate()
	bolt.configure(player, origin, direction, speed, damage, glyph, tint, life_time, hit_radius, stun_time)
	bolt.impact.connect(_on_projectile_impact)
	projectiles_root.add_child(bolt)


func _on_projectile_impact(world_position: Vector3, tint: Color, label: String) -> void:
	_spawn_wave_effect(world_position, 0.95, tint, label)


func _spawn_wave_effect(origin: Vector3, radius: float, tint: Color, label: String) -> void:
	var effect_root := Node3D.new()
	effect_root.position = Vector3(origin.x, 0.05, origin.z)
	effects_root.add_child(effect_root)

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

	var inner_ring := MeshInstance3D.new()
	var inner_mesh := CylinderMesh.new()
	inner_mesh.top_radius = radius * 0.78
	inner_mesh.bottom_radius = radius * 0.78
	inner_mesh.height = 0.06
	inner_ring.mesh = inner_mesh
	var inner_material := StandardMaterial3D.new()
	inner_material.albedo_color = Color(tint.r, tint.g, tint.b, 0.5)
	inner_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	inner_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	inner_material.emission_enabled = true
	inner_material.emission = tint
	inner_ring.material_override = inner_material
	inner_ring.position = Vector3(0.0, 0.01, 0.0)
	effect_root.add_child(inner_ring)

	var shard_root := Node3D.new()
	effect_root.add_child(shard_root)
	for index in range(4):
		var shard := MeshInstance3D.new()
		var shard_mesh := BoxMesh.new()
		shard_mesh.size = Vector3(max(0.12, radius * 0.12), 0.04, max(0.28, radius * 0.22))
		shard.mesh = shard_mesh
		var angle: float = TAU * float(index) / 4.0
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
	tween.parallel().tween_property(inner_ring, "rotation_degrees:y", -36.0, 0.28)
	tween.parallel().tween_property(shard_root, "rotation_degrees:y", 42.0, 0.28)
	tween.tween_callback(effect_root.queue_free)


func _spawn_enemy_death_effect(world_position: Vector3, enemy_type: String) -> void:
	var tint: Color = _enemy_effect_color(enemy_type)
	var glyph_text: String = _enemy_effect_glyph(enemy_type)
	var effect_root := Node3D.new()
	effect_root.position = world_position + Vector3(0.0, 0.16, 0.0)
	effects_root.add_child(effect_root)

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
	var effect_root := Node3D.new()
	effect_root.position = world_position + Vector3(0.0, 0.2, 0.0)
	effects_root.add_child(effect_root)

	for index in range(6):
		var symbol_root := Node3D.new()
		var angle: float = TAU * float(index) / 6.0
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


func _on_player_defeated() -> void:
	game_over = true
	paused = false
	map_overlay_active = false
	active_boss = null
	Engine.time_scale = 0.0
	hud.hide_map_overlay()
	hud.hide_boss()
	hud.show_banner("字海沉没", Color(1.0, 0.76, 0.58, 1.0), 2.0)
	Session.last_run_summary = {
		"elapsed": elapsed_time,
		"kills": kills,
		"threat": threat_level,
		"level": level,
		"bosses": int(Session.chapter_progress.get("completed_bosses", 0)),
		"chapter_complete": bool(Session.chapter_progress.get("chapter_complete", false))
	}
	Session.record_local_run(Session.last_run_summary, Session.selected_hero)
	hud.set_game_over("墨潮吞没了你。按 R 立即重开，或按 Esc 返回二级菜单。", elapsed_time, kills, threat_level, level)


func _on_bush_activated(message: String) -> void:
	hud.set_tip(message)


func _on_treasure_chest_opened(world_position: Vector3, drops: Dictionary) -> void:
	_spawn_supply_bundle(world_position, drops)
	hud.show_banner("宝箱开启", Color(1.0, 0.84, 0.52, 1.0), 1.7)
	hud.set_tip("宝箱散出补给。先收残纸与墨团，再决定是压等级还是补状态。")


func _sync_hud() -> void:
	var blade_level: int = 0
	if is_instance_valid(player):
		hud.set_health(player.health, player.max_health)
		blade_level = player.blade_level
	hud.set_progress(level, experience, experience_target)
	hud.set_status(elapsed_time, kills, threat_level)
	hud.set_radicals(radical_counts)
	hud.set_skills(skill_levels, word_skill_levels, word_progress, blade_level, Session.selected_hero)


func _start_opening_sequence() -> void:
	opening_time = 1.65
	spawn_timer = 1.2
	var hero_data: Dictionary = Session.get_selected_hero()
	var accent: Color = hero_data["accent"]
	var intro_title: String = "残卷一·入墨"
	var intro_tip: String = "先收第一枚偏旁，尽快合出首个成字。"
	if not battle_intro.is_empty():
		intro_title = String(battle_intro.get("title", intro_title))
		intro_tip = "%s 先收第一枚偏旁，尽快合出首个成字。" % String(battle_intro.get("subtitle", "执笔者已入卷。"))
	hud.show_banner("%s  ·  %s 入卷" % [intro_title, String(hero_data["name"])], accent, 2.6)
	hud.set_tip(intro_tip)
	_spawn_wave_effect(player.global_position, 3.3, accent, String(hero_data["glyph"]))
	_spawn_intro_symbols(String(hero_data["glyph"]), accent)


func _on_boss_defeated(world_position: Vector3) -> void:
	var completed_bosses: int = int(Session.chapter_progress.get("completed_bosses", 0)) + 1
	Session.chapter_progress["completed_bosses"] = completed_bosses
	if completed_bosses >= BOSS_SPAWN_TIMES.size():
		Session.chapter_progress["chapter_complete"] = true
		hud.show_banner("残卷一暂定", Color(1.0, 0.88, 0.58, 1.0), 2.6)
		hud.set_tip("本卷两位卷主都已崩散，章节目标完成。继续战斗可测试成长上限。")
	else:
		hud.show_banner("卷主退散", Color(1.0, 0.84, 0.52, 1.0), 2.2)
		hud.set_tip("卷主崩散，残卷继续翻开。抓紧收补给并准备迎接更深的一层。")
	_spawn_wave_effect(world_position, 7.2, Color(1.0, 0.74, 0.46, 1.0), "破")
	_gain_experience(12)


func _on_threat_level_advanced(new_threat_level: int) -> void:
	last_announced_threat_level = new_threat_level
	if not is_instance_valid(player):
		return

	var tint: Color = _threat_level_color(new_threat_level)
	var wave_glyph := _threat_level_glyph(new_threat_level)
	if _is_big_wave(new_threat_level):
		hud.show_banner("字潮第 %d 波 · 大潮" % new_threat_level, tint, 2.35)
		spawn_timer = min(spawn_timer, 0.16)
	else:
		hud.show_banner("字潮第 %d 波" % new_threat_level, tint, 1.85)
	hud.set_tip(_threat_level_tip(new_threat_level))
	_spawn_wave_effect(player.global_position, (6.4 if _is_big_wave(new_threat_level) else 4.6) + float(new_threat_level) * 0.45, tint, wave_glyph)
	_spawn_intro_symbols(wave_glyph, tint)


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
		return "大潮压境。刷怪频率和场上敌量上限同时抬高，先清外围远程，再留技能处理中心重压。"
	match new_threat_level:
		2:
			return "字潮抬升。弓手开始混入阵线，注意被远程拉扯。"
		3:
			return "字潮再涨。忍与阵师入场，突刺和地阵会一起施压。"
		4:
			return "墨骑踏阵。保持走位，不要在冲锋预警线里停太久。"
		_:
			return "魁首开始现身，补给和成词节奏都要提前准备。"


func _spawn_intro_symbols(glyph: String, tint: Color) -> void:
	var root := Node3D.new()
	root.position = player.global_position + Vector3(0.0, 0.4, 0.0)
	effects_root.add_child(root)

	for index in range(4):
		var symbol_root := Node3D.new()
		var angle: float = TAU * float(index) / 4.0
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

	return {
		"world_radius": MAP_WORLD_RADIUS,
		"player": _map_point(player.global_position if is_instance_valid(player) else Vector3.ZERO),
		"player_heading": _map_direction(player.look_direction if is_instance_valid(player) else Vector3(0.0, 0.0, -1.0)),
		"markers": markers,
		"enemies": enemies,
		"summary": "敌群 %d  ·  砚台 %d  ·  草丛 %d  ·  地标 %d" % [enemies.size(), inkstone_count, bush_count, landmark_count]
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


func _on_hud_pause_resume_requested() -> void:
	_set_paused(false)


func _on_hud_pause_requested() -> void:
	_set_paused(true)


func _on_hud_map_toggle_requested() -> void:
	_set_map_overlay(not map_overlay_active)


func _on_hud_movement_input_changed(input_vector: Vector2) -> void:
	if is_instance_valid(player):
		player.set_external_move_input(input_vector)


func _on_hud_interact_requested() -> void:
	if game_over or map_overlay_active or levelup_active or word_choice_active:
		return
	if paused:
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
	var previous_inkstone: Node3D = active_inkstone
	active_inkstone = _find_nearby_inkstone()
	if active_inkstone == null:
		if previous_inkstone != null:
			hud.set_tip(DEFAULT_BATTLE_TIP)
		return

	if _has_grindable_words():
		hud.set_tip("靠近砚台，按 E 磨词。词技只会在这里成型。")
		if Input.is_action_just_pressed("interact"):
			_handle_inkstone_interact()
	else:
		hud.set_tip("砚台静候。先把合字升满，再带着相关偏旁来磨词。")
		if Input.is_action_just_pressed("interact"):
			_handle_inkstone_interact()


func _handle_inkstone_interact() -> void:
	if active_inkstone == null:
		return
	if _has_grindable_words():
		_present_word_choices()
	else:
		hud.show_banner("砚上无字可磨", Color(0.7, 0.84, 1.0, 1.0), 1.5)


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
	var total: int = 0
	for radical_variant in radicals:
		var radical := String(radical_variant)
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
	var word: Dictionary = Session.get_word_data(word_id)
	var recipe_id: String = String(word["recipe_id"])
	var recipe: Dictionary = Session.get_recipe_data(recipe_id)
	var word_level: int = int(word_skill_levels.get(word_id, 0))
	var stock: int = _count_recipe_radicals(recipe["radicals"])
	var headline: String
	if word_level <= 0:
		headline = "磨词 %d/%d" % [
			min(int(word_progress.get(word_id, 0)) + 1, int(word["unlock_cost"])),
			int(word["unlock_cost"])
		]
	else:
		headline = "词技升级  Lv.%d -> Lv.%d" % [word_level, min(word_level + 1, int(word["max_level"]))]

	return {
		"word_id": word_id,
		"display": String(word["display"]),
		"title": String(word["title"]),
		"headline": headline,
		"description": "%s\n当前余材：%d 枚，来自「%s」。" % [
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
	var word: Dictionary = Session.get_word_data(word_id)
	var recipe: Dictionary = Session.get_recipe_data(String(word["recipe_id"]))
	var stored_radical: String = _find_available_recipe_radical(recipe["radicals"])
	if stored_radical.is_empty():
		hud.show_banner("余材不足", Color(word["color"]), 1.4)
		return

	radical_counts[stored_radical] = int(radical_counts.get(stored_radical, 0)) - 1
	var word_level: int = int(word_skill_levels.get(word_id, 0))
	if word_level <= 0:
		word_progress[word_id] = int(word_progress.get(word_id, 0)) + 1
		if int(word_progress[word_id]) >= int(word["unlock_cost"]):
			word_progress[word_id] = int(word["unlock_cost"])
			_set_word_level(word_id, 1)
		else:
			hud.show_banner("%s 磨词 %d/%d" % [
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
	environment.background_color = Color(0.05, 0.07, 0.09, 1.0)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.7, 0.75, 0.8, 1.0)
	environment.ambient_light_energy = 0.85
	environment.fog_enabled = true
	environment.fog_density = 0.012
	environment.fog_light_color = Color(0.12, 0.16, 0.2, 1.0)
	world_environment.environment = environment


func _build_ground() -> void:
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(180.0, 180.0)
	floor.mesh = plane
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color(0.11, 0.12, 0.13, 1.0)
	floor_material.roughness = 1.0
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
		var mound_material := StandardMaterial3D.new()
		mound_material.albedo_color = Color(0.15, 0.16, 0.17, 1.0)
		mound_material.roughness = 1.0
		mound.material_override = mound_material
		ground_root.add_child(mound)


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
	trunk.material_override = trunk_material
	tree_root.add_child(trunk)

	var canopy_material := StandardMaterial3D.new()
	canopy_material.albedo_color = Color(0.19, 0.31, 0.21, 1.0)
	canopy_material.roughness = 0.94
	canopy_material.emission_enabled = true
	canopy_material.emission = Color(0.08, 0.16, 0.1, 1.0)
	canopy_material.emission_energy_multiplier = 0.2

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
	lantern.material_override = lantern_material
	tree_root.add_child(lantern)


func _create_stela(position: Vector3, glyph: String, tint: Color) -> void:
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
