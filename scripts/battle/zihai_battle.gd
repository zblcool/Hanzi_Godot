extends Node3D

const HERO_SCENE := preload("res://scenes/entities/hero.tscn")
const ENEMY_SCENE := preload("res://scenes/entities/enemy.tscn")
const INK_BOLT_SCENE := preload("res://scenes/entities/ink_bolt.tscn")
const XP_ORB_SCENE := preload("res://scenes/entities/xp_orb.tscn")
const BUSH_ZONE_SCENE := preload("res://scenes/entities/bush_zone.tscn")
const GROUND_HAZARD_SCENE := preload("res://scenes/entities/ground_hazard.tscn")
const INKSTONE_SCENE := preload("res://scenes/entities/inkstone_altar.tscn")
const BATTLE_HUD_SCENE := preload("res://scenes/ui/battle_hud.tscn")
const CJKFont := preload("res://scripts/core/cjk_font.gd")
const DEFAULT_BATTLE_TIP := "击倒字灵收集字力，升级时三选一偏旁。靠近砚台按 E 磨词。"

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

var elapsed_time: float = 0.0
var spawn_timer: float = 0.0
var spawn_interval: float = 1.35
var kills: int = 0
var threat_level: int = 1
var game_over: bool = false
var levelup_active: bool = false
var word_choice_active: bool = false

var radical_counts: Dictionary = {}
var skill_levels: Dictionary = {}
var word_skill_levels: Dictionary = {}
var word_progress: Dictionary = {}
var inkstones: Array[Node3D] = []
var active_inkstone: Node3D = null

var level: int = 1
var experience: int = 0
var experience_target: int = 4
var pending_level_choices: int = 0


func _ready() -> void:
	rng.randomize()
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
	hud.show_banner("字海初开", Color(1.0, 0.84, 0.54, 1.0), 2.2)
	hud.set_tip(DEFAULT_BATTLE_TIP)
	set_process(true)


func _process(delta: float) -> void:
	_update_camera(delta)

	if Input.is_action_just_pressed("return_menu"):
		get_tree().change_scene_to_file(Session.ZIHAI_MENU_SCENE)
		return

	if game_over:
		if Input.is_action_just_pressed("restart_run"):
			get_tree().reload_current_scene()
		return

	if levelup_active or word_choice_active:
		return

	_update_inkstone_interaction()

	elapsed_time += delta
	threat_level = 1 + int(elapsed_time / 30.0)

	spawn_timer -= delta
	if spawn_timer <= 0.0 and _enemy_count() < 46:
		var spawn_batch: int = 1
		if elapsed_time > 55.0:
			spawn_batch = 2
		for _index in range(spawn_batch):
			_spawn_enemy()
		spawn_interval = max(0.42, 1.35 - elapsed_time * 0.012)
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
		props_root.add_child(bush)

	var inkstone_positions := [
		Vector3(0.0, 0.0, 8.5),
		Vector3(-10.0, 0.0, 12.0)
	]
	for inkstone_position in inkstone_positions:
		var inkstone = INKSTONE_SCENE.instantiate()
		inkstone.position = inkstone_position
		props_root.add_child(inkstone)
		inkstones.append(inkstone)


func _spawn_enemy() -> void:
	if not is_instance_valid(player):
		return

	var enemy = ENEMY_SCENE.instantiate()
	var angle: float = rng.randf_range(0.0, TAU)
	var distance: float = rng.randf_range(18.0, 26.0)
	var offset := Vector3(cos(angle), 0.0, sin(angle)) * distance
	enemy.position = player.global_position + offset
	enemy.configure(_pick_enemy_type(), 1.0 + elapsed_time / 75.0, player)
	enemy.defeated.connect(_on_enemy_defeated)
	enemy.request_hazard.connect(_on_enemy_request_hazard)
	enemies_root.add_child(enemy)


func _pick_enemy_type() -> String:
	var roll: float = rng.randf()
	if elapsed_time < 22.0:
		return "basic" if roll < 0.72 else "swift"
	if elapsed_time < 48.0:
		if roll < 0.45:
			return "basic"
		if roll < 0.72:
			return "swift"
		if roll < 0.88:
			return "tank"
		return "ritualist"
	if roll < 0.32:
		return "basic"
	if roll < 0.56:
		return "swift"
	if roll < 0.76:
		return "tank"
	return "ritualist"


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
	_spawn_xp_orb(world_position, _xp_value_for_enemy(enemy_type))
	if kills % 14 == 0:
		hud.show_banner("字潮再涨", Color(0.95, 0.62, 0.36, 1.0), 1.7)


func _xp_value_for_enemy(enemy_type: String) -> int:
	match enemy_type:
		"swift":
			return 2
		"tank":
			return 3
		"ritualist":
			return 3
		_:
			return 1


func _spawn_xp_orb(world_position: Vector3, xp_value: int) -> void:
	var orb = XP_ORB_SCENE.instantiate()
	orb.position = world_position + Vector3(0.0, 0.45, 0.0)
	orb.configure(player, xp_value)
	orb.collected.connect(_on_xp_collected)
	pickups_root.add_child(orb)


func _on_xp_collected(value: int) -> void:
	_gain_experience(value)


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


func _on_projectile_impact(world_position: Vector3, tint: Color, label: String) -> void:
	_spawn_wave_effect(world_position, 0.95, tint, label)


func _spawn_wave_effect(origin: Vector3, radius: float, tint: Color, label: String) -> void:
	var effect_root := Node3D.new()
	effect_root.position = Vector3(origin.x, 0.05, origin.z)
	effects_root.add_child(effect_root)

	var ring := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.05
	ring.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(tint.r, tint.g, tint.b, 0.42)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	ring.material_override = material
	effect_root.add_child(ring)

	var glyph := Label3D.new()
	glyph.text = label
	glyph.font = CJKFont.get_font()
	glyph.font_size = 32
	glyph.position = Vector3(0.0, 0.12, 0.0)
	glyph.modulate = Color(1.0, 0.95, 0.88, 0.96)
	effect_root.add_child(glyph)

	var tween := create_tween()
	tween.tween_property(effect_root, "scale", Vector3(1.12, 1.0, 1.12), 0.26)
	tween.tween_callback(effect_root.queue_free)


func _on_player_health_changed(current: float, maximum: float) -> void:
	hud.set_health(current, maximum)


func _on_player_defeated() -> void:
	game_over = true
	Engine.time_scale = 1.0
	hud.show_banner("字海沉没", Color(1.0, 0.76, 0.58, 1.0), 2.0)
	hud.set_game_over("墨潮吞没了你。\n按 R 立即重开，或按 Esc 返回二级菜单。")


func _on_bush_activated(message: String) -> void:
	hud.set_tip(message)


func _sync_hud() -> void:
	var blade_level: int = 0
	if is_instance_valid(player):
		hud.set_health(player.health, player.max_health)
		blade_level = player.blade_level
	hud.set_progress(level, experience, experience_target)
	hud.set_status(elapsed_time, kills, threat_level)
	hud.set_radicals(radical_counts)
	hud.set_skills(skill_levels, word_skill_levels, word_progress, blade_level, Session.selected_hero)


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
			_present_word_choices()
	else:
		hud.set_tip("砚台静候。先把合字升满，再带着相关偏旁来磨词。")
		if Input.is_action_just_pressed("interact"):
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

	var canopy := MeshInstance3D.new()
	var canopy_mesh := SphereMesh.new()
	canopy_mesh.radius = 1.7
	canopy_mesh.height = 2.9
	canopy.mesh = canopy_mesh
	canopy.position = Vector3(0.0, 3.05, 0.0)
	var canopy_material := StandardMaterial3D.new()
	canopy_material.albedo_color = Color(0.19, 0.31, 0.21, 1.0)
	canopy.material_override = canopy_material
	tree_root.add_child(canopy)


func _enemy_count() -> int:
	return get_tree().get_nodes_in_group("enemy").size()


func _setup_input_map() -> void:
	_ensure_action("move_forward", [KEY_W, KEY_UP])
	_ensure_action("move_back", [KEY_S, KEY_DOWN])
	_ensure_action("move_left", [KEY_A, KEY_LEFT])
	_ensure_action("move_right", [KEY_D, KEY_RIGHT])
	_ensure_action("interact", [KEY_E])
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
