extends Node2D

const PLAYER_SCENE := preload("res://scenes/entities/player.tscn")
const ENEMY_SCENE := preload("res://scenes/entities/enemy.tscn")
const WORD_BOLT_SCENE := preload("res://scenes/entities/word_bolt.tscn")
const XP_ORB_SCENE := preload("res://scenes/entities/xp_orb.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")
const ProgressionDirectorScript := preload("res://scripts/systems/progression_director.gd")
const CJKFont := preload("res://scripts/cjk_font.gd")

@onready var enemies_root: Node2D = $Enemies
@onready var projectiles_root: Node2D = $Projectiles
@onready var pickups_root: Node2D = $Pickups

var player
var hud
var progression := ProgressionDirectorScript.new()
var current_snapshot: Dictionary = {}
var room_templates: Array = []
var rng := RandomNumberGenerator.new()
var draw_font: Font

var elapsed_time := 0.0
var kills := 0
var game_over := false

var room_index := -1
var active_room: Dictionary = {}
var room_elapsed := 0.0
var room_kills := 0
var room_complete := false
var spawn_timer := 0.0
var elite_spawned := false
var elite_target = null

var selection_mode := ""
var selection_options: Array = []

var effect_zones: Array = []
var burst_effects: Array = []
var thunder_timer := 999.0
var sprout_timer := 999.0
var storm_timer := 999.0


func _ready() -> void:
	rng.randomize()
	draw_font = CJKFont.get_font()
	room_templates = _build_room_templates()
	_setup_input_map()
	_spawn_player()
	_spawn_hud()
	_refresh_progression_state()
	_start_next_room()
	set_process(true)
	set_physics_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	if game_over:
		if Input.is_action_just_pressed("restart"):
			get_tree().reload_current_scene()
		queue_redraw()
		return

	if not selection_mode.is_empty():
		_handle_selection_input()

	_update_burst_effects(delta)
	_sync_hud()
	queue_redraw()


func _physics_process(delta: float) -> void:
	if game_over or not selection_mode.is_empty():
		return

	elapsed_time += delta
	room_elapsed += delta

	_update_spawning(delta)
	_process_passive_systems(delta)
	_process_effect_zones(delta)
	_check_room_completion()
	_sync_hud()
	queue_redraw()


func _draw() -> void:
	if active_room.is_empty():
		return

	var room_bounds: Rect2 = active_room.get("bounds", Rect2(-560.0, -340.0, 1120.0, 680.0))
	var objective: String = str(active_room.get("objective", "purge"))
	var border_color = Color(0.88, 0.63, 0.32, 0.82)
	if objective == "survive":
		border_color = Color(0.4, 0.72, 0.94, 0.82)
	elif objective == "elite":
		border_color = Color(0.92, 0.45, 0.34, 0.92)

	draw_rect(room_bounds, Color(0.05, 0.05, 0.08, 1.0), true)
	draw_rect(room_bounds, border_color, false, 5.0)

	var cell = 64.0
	var start_x: float = room_bounds.position.x
	var end_x: float = room_bounds.end.x
	var start_y: float = room_bounds.position.y
	var end_y: float = room_bounds.end.y
	var x = start_x
	while x <= end_x:
		var line_color = Color(0.12, 0.12, 0.16, 0.55)
		if int((x - start_x) / cell) % 4 == 0:
			line_color = Color(border_color.r * 0.55, border_color.g * 0.55, border_color.b * 0.55, 0.5)
		draw_line(Vector2(x, start_y), Vector2(x, end_y), line_color, 1.0)
		x += cell

	var y = start_y
	while y <= end_y:
		var line_color = Color(0.12, 0.12, 0.16, 0.55)
		if int((y - start_y) / cell) % 4 == 0:
			line_color = Color(border_color.r * 0.55, border_color.g * 0.55, border_color.b * 0.55, 0.5)
		draw_line(Vector2(start_x, y), Vector2(end_x, y), line_color, 1.0)
		y += cell

	for zone in effect_zones:
		var zone_position: Vector2 = zone.get("position", Vector2.ZERO)
		var radius = float(zone.get("radius", 32.0))
		var color: Color = zone.get("color", Color(0.6, 0.8, 1.0, 0.2))
		draw_circle(zone_position, radius, color)
		draw_arc(zone_position, radius, -PI, PI, 32, Color(color.r, color.g, color.b, min(0.95, color.a + 0.2)), 2.0)
		var label = str(zone.get("label", ""))
		if draw_font != null and not label.is_empty():
			draw_string(draw_font, zone_position + Vector2(-10.0, 7.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, Color(1.0, 0.98, 0.92, 0.95))

	for burst in burst_effects:
		var burst_type = str(burst.get("type", "ring"))
		var time_left = float(burst.get("time", 0.0))
		var duration = max(0.001, float(burst.get("duration", 0.2)))
		var t = 1.0 - clamp(time_left / duration, 0.0, 1.0)
		var color: Color = burst.get("color", Color(1.0, 0.9, 0.6, 0.8))
		color.a *= 1.0 - t * 0.75

		if burst_type == "slash":
			var from_pos: Vector2 = burst.get("from", Vector2.ZERO)
			var to_pos: Vector2 = burst.get("to", Vector2.ZERO)
			var width = float(burst.get("width", 24.0))
			draw_line(from_pos, to_pos, color, width * (1.0 - t * 0.45))
		else:
			var burst_position: Vector2 = burst.get("position", Vector2.ZERO)
			var radius = float(burst.get("radius", 40.0)) * (0.55 + t * 0.45)
			draw_arc(burst_position, radius, -PI, PI, 34, color, 3.0)
			if burst_type == "strike":
				draw_line(burst_position + Vector2(0.0, -radius), burst_position + Vector2(0.0, radius), color, 2.0)
			if draw_font != null:
				var label = str(burst.get("label", ""))
				if not label.is_empty():
					draw_string(draw_font, burst_position + Vector2(-16.0, -radius - 4.0), label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, Color(1.0, 0.96, 0.9, color.a))


func _spawn_player() -> void:
	player = PLAYER_SCENE.instantiate()
	player.global_position = Vector2.ZERO
	add_child(player)
	player.request_word_bolt.connect(_spawn_word_bolt)
	player.request_slash.connect(_on_player_slash)
	player.request_wave.connect(_on_player_wave)
	player.health_changed.connect(Callable(self, "_on_player_health_changed"))
	player.defeated.connect(_on_player_defeated)


func _spawn_hud() -> void:
	hud = HUD_SCENE.instantiate()
	add_child(hud)
	hud.set_tip("WASD / 方向键移动。房间结算时用数字键选择字路与偏旁。")


func _spawn_word_bolt(origin: Vector2, direction: Vector2, character: String, damage: float, speed: float) -> void:
	var word_bolt = WORD_BOLT_SCENE.instantiate()
	word_bolt.global_position = origin
	word_bolt.direction = direction
	word_bolt.character = character
	word_bolt.damage = damage
	word_bolt.speed = speed
	projectiles_root.add_child(word_bolt)


func _on_player_slash(start_position: Vector2, end_position: Vector2, width: float, damage: float, label: String) -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		var distance = _distance_point_to_segment(enemy.global_position, start_position, end_position)
		if distance <= width:
			enemy.take_damage(damage)
			var push_direction = (enemy.global_position - start_position).normalized()
			enemy.apply_knockback(push_direction * 180.0)

	_add_burst({
		"type": "slash",
		"from": start_position,
		"to": end_position,
		"width": width,
		"duration": 0.16,
		"time": 0.16,
		"color": Color(0.98, 0.82, 0.45, 0.68),
		"label": label
	})


func _on_player_wave(origin: Vector2, radius: float, damage: float, slow_strength: float, push_strength: float, label: String) -> void:
	_apply_radius_hit(origin, radius, damage, slow_strength, push_strength)
	_add_burst({
		"type": "wave",
		"position": origin,
		"radius": radius,
		"duration": 0.34,
		"time": 0.34,
		"color": Color(0.56, 0.88, 1.0, 0.85),
		"label": label
	})


func _on_enemy_defeated(world_position: Vector2, xp_value: int, _enemy_character: String, was_elite: bool) -> void:
	kills += 1
	room_kills += 1

	var orb = XP_ORB_SCENE.instantiate()
	orb.global_position = world_position
	orb.player = player
	orb.value = xp_value
	orb.character = ["字", "文", "墨", "灵"][rng.randi_range(0, 3)]
	orb.collected.connect(_on_orb_collected)
	pickups_root.call_deferred("add_child", orb)

	if was_elite and str(active_room.get("objective", "")) == "elite":
		call_deferred("_complete_room", "守门字灵已灭，通路重开。")
		return

	if str(active_room.get("objective", "")) == "purge":
		if room_kills >= int(active_room.get("target_value", 12)):
			call_deferred("_complete_room", "房内墨潮被压下去了。")
	elif kills % 14 == 0:
		hud.show_message("字潮加剧：敌群更密，读位要更快。", 2.2)


func _on_orb_collected(value: int) -> void:
	var messages = progression.add_experience(value)
	_refresh_progression_state()
	if not messages.is_empty():
		hud.show_message(str(messages[messages.size() - 1]), 2.4)


func _on_player_health_changed(current: float, maximum: float) -> void:
	hud.set_health(current, maximum)


func _on_player_defeated() -> void:
	game_over = true
	selection_mode = ""
	selection_options.clear()
	hud.set_game_over(true)


func _start_next_room() -> void:
	selection_mode = ""
	selection_options.clear()
	hud.hide_choice_overlay()
	player.set_controls_enabled(true)
	_clear_runtime_entities()
	effect_zones.clear()
	burst_effects.clear()

	room_index += 1
	var template: Dictionary = room_templates[room_index % room_templates.size()].duplicate(true)
	var cycle = int(room_index / float(room_templates.size()))

	active_room = template
	active_room["cycle"] = cycle
	active_room["difficulty_scale"] = 1.0 + cycle * 0.28
	if str(active_room.get("objective", "")) == "purge":
		active_room["target_value"] = int(template.get("target_value", 12)) + cycle * 3
	elif str(active_room.get("objective", "")) == "survive":
		active_room["target_value"] = float(template.get("target_value", 20.0)) + cycle * 3.0
	else:
		active_room["target_value"] = 1

	room_elapsed = 0.0
	room_kills = 0
	room_complete = false
	spawn_timer = 0.35
	elite_spawned = false
	elite_target = null
	thunder_timer = min(1.0, float(current_snapshot.get("thunder_cooldown", 999.0)))
	sprout_timer = 1.2
	storm_timer = 3.8

	var room_bounds: Rect2 = active_room.get("bounds", Rect2(-560.0, -340.0, 1120.0, 680.0))
	player.global_position = room_bounds.get_center()
	player.configure_room(room_bounds)

	hud.show_message("进入 %s" % str(active_room.get("name", "新房间")), 2.2)
	_sync_hud()


func _complete_room(message: String) -> void:
	if room_complete:
		return

	room_complete = true
	player.set_controls_enabled(false)
	progression.grant_room_reward()
	_refresh_progression_state()
	_clear_runtime_entities()

	if message != "":
		hud.show_message(message, 2.2)

	_open_selection_or_continue()


func _open_selection_or_continue() -> void:
	if progression.needs_route_choice():
		selection_mode = "route"
		selection_options = progression.get_route_options()
		hud.show_choice_overlay(
			"字路立意",
			"这一段 run 要先定方向。按数字键选择字路，之后偏旁和字诀会更偏向对应路线。",
			selection_options
		)
		return

	if progression.has_pending_rewards():
		selection_mode = "rune"
		selection_options = progression.get_reward_options(rng, 3)
		hud.show_choice_overlay(
			"房间结算 · 选偏旁",
			"本房可把成长决策集中结算。按数字键选择一个偏旁，让它继续推动合字、进阶字与词技。",
			selection_options
		)
		return

	_start_next_room()


func _handle_selection_input() -> void:
	var option_index = -1
	if Input.is_action_just_pressed("choice_1"):
		option_index = 0
	elif Input.is_action_just_pressed("choice_2"):
		option_index = 1
	elif Input.is_action_just_pressed("choice_3"):
		option_index = 2
	elif Input.is_action_just_pressed("choice_4"):
		option_index = 3

	if option_index < 0 or option_index >= selection_options.size():
		return

	var choice: Dictionary = selection_options[option_index]
	if selection_mode == "route":
		var route_result: Dictionary = progression.choose_route(str(choice.get("id", "")))
		_refresh_progression_state()
		hud.show_message(_pick_summary_message(route_result.get("messages", [])), 2.8)
	elif selection_mode == "rune":
		var reward_result: Dictionary = progression.apply_reward_choice(str(choice.get("id", "")))
		_refresh_progression_state()
		hud.show_message(str(reward_result.get("summary", "")), 3.0)
	else:
		return

	_open_selection_or_continue()


func _update_spawning(delta: float) -> void:
	if room_complete:
		return

	var live_enemies = get_tree().get_nodes_in_group("enemies").size()
	if live_enemies >= int(active_room.get("enemy_cap", 10)):
		return

	if str(active_room.get("objective", "")) == "elite" and not elite_spawned and room_elapsed >= 1.2:
		_spawn_enemy("elite", true)
		elite_spawned = true

	spawn_timer -= delta
	if spawn_timer > 0.0:
		return

	var archetype_id = _pick_weighted_archetype(active_room.get("archetypes", []))
	_spawn_enemy(archetype_id, false)
	var difficulty_scale = float(active_room.get("difficulty_scale", 1.0))
	spawn_timer = max(0.35, float(active_room.get("spawn_interval", 1.0)) / difficulty_scale)


func _spawn_enemy(archetype_id: String, elite_mode: bool) -> void:
	if player == null:
		return

	var enemy = ENEMY_SCENE.instantiate()
	enemy.global_position = _random_spawn_position(active_room.get("bounds", Rect2(-560.0, -340.0, 1120.0, 680.0)))
	enemy.target = player
	_configure_enemy(enemy, archetype_id, elite_mode)
	enemy.defeated.connect(_on_enemy_defeated)
	enemies_root.add_child(enemy)
	if elite_mode:
		elite_target = enemy


func _configure_enemy(enemy, archetype_id: String, elite_mode: bool) -> void:
	var difficulty_scale = float(active_room.get("difficulty_scale", 1.0))

	match archetype_id:
		"skitter":
			enemy.character = ["魇", "魅", "祟"][rng.randi_range(0, 2)]
			enemy.max_health = (22.0 + elapsed_time * 0.5) * difficulty_scale
			enemy.move_speed = (110.0 + elapsed_time * 0.35) * min(1.45, 1.0 + difficulty_scale * 0.08)
			enemy.touch_damage = 6.0 + difficulty_scale * 0.8
			enemy.experience_value = 1
			enemy.scale = Vector2.ONE * rng.randf_range(0.85, 1.0)
			enemy.base_color = Color(0.42, 0.18, 0.46, 1.0)
			enemy.outline_color = Color(0.96, 0.78, 0.96, 0.85)
			enemy.role_name = "突袭"
		"brute":
			enemy.character = ["骨", "煞", "垒"][rng.randi_range(0, 2)]
			enemy.max_health = (42.0 + elapsed_time * 0.8) * difficulty_scale
			enemy.move_speed = 74.0 + elapsed_time * 0.18
			enemy.touch_damage = 10.0 + difficulty_scale * 1.2
			enemy.experience_value = 2
			enemy.scale = Vector2.ONE * rng.randf_range(1.08, 1.28)
			enemy.base_color = Color(0.48, 0.22, 0.12, 1.0)
			enemy.outline_color = Color(1.0, 0.82, 0.54, 0.9)
			enemy.role_name = "压阵"
		_:
			enemy.character = ["夜", "影", "咒"][rng.randi_range(0, 2)]
			enemy.max_health = (30.0 + elapsed_time * 0.65) * difficulty_scale
			enemy.move_speed = 92.0 + elapsed_time * 0.24
			enemy.touch_damage = 8.0 + difficulty_scale
			enemy.experience_value = 1
			enemy.scale = Vector2.ONE * rng.randf_range(0.95, 1.12)
			enemy.base_color = Color(0.2, 0.24, 0.42, 1.0)
			enemy.outline_color = Color(0.88, 0.94, 1.0, 0.88)
			enemy.role_name = "追迫"

	if elite_mode:
		enemy.character = "守"
		enemy.is_elite = true
		enemy.max_health = 180.0 * difficulty_scale + elapsed_time * 1.2
		enemy.move_speed = 84.0 + elapsed_time * 0.18
		enemy.touch_damage = 14.0 + difficulty_scale * 1.5
		enemy.experience_value = 6
		enemy.scale = Vector2.ONE * 1.35
		enemy.base_color = Color(0.52, 0.16, 0.14, 1.0)
		enemy.outline_color = Color(1.0, 0.8, 0.42, 0.95)
		enemy.role_name = "守门"


func _process_passive_systems(delta: float) -> void:
	var thunder_level = int(current_snapshot.get("thunder_level", 0))
	if thunder_level > 0:
		thunder_timer -= delta
		if thunder_timer <= 0.0:
			thunder_timer = float(current_snapshot.get("thunder_cooldown", 4.0))
			_cast_thunder(false)

	var sprout_level = int(current_snapshot.get("sprout_level", 0))
	if sprout_level > 0:
		sprout_timer -= delta
		if sprout_timer <= 0.0:
			sprout_timer = float(current_snapshot.get("sprout_cooldown", 6.0))
			_spawn_sprout_zone()

	var word_lookup: Dictionary = current_snapshot.get("word_skills_lookup", {})
	if word_lookup.has("thunder_rain") or word_lookup.has("flame_rain"):
		storm_timer -= delta
		if storm_timer <= 0.0:
			storm_timer = 4.6
			_cast_room_storm(word_lookup.has("flame_rain"))

	_apply_player_auras(delta)


func _process_effect_zones(delta: float) -> void:
	for index in range(effect_zones.size() - 1, -1, -1):
		var zone: Dictionary = effect_zones[index]
		zone["time"] = float(zone.get("time", 0.0)) - delta
		if float(zone.get("time", 0.0)) <= 0.0:
			effect_zones.remove_at(index)
			continue
		effect_zones[index] = zone

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		for zone in effect_zones:
			var center: Vector2 = zone.get("position", Vector2.ZERO)
			var radius = float(zone.get("radius", 24.0))
			if enemy.global_position.distance_to(center) > radius:
				continue
			var slow_strength = float(zone.get("slow", 0.0))
			var damage_per_second = float(zone.get("damage", 0.0))
			if slow_strength > 0.0:
				enemy.apply_slow(slow_strength, 0.18)
			if damage_per_second > 0.0:
				enemy.take_damage(damage_per_second * delta, false)


func _apply_player_auras(delta: float) -> void:
	if player == null:
		return

	var guard_radius = player.get_guard_radius()
	var guard_damage = float(current_snapshot.get("guard_array_damage", 0.0))
	if guard_radius > 0.0:
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
				continue
			if enemy.global_position.distance_to(player.global_position) > guard_radius:
				continue
			enemy.apply_slow(player.get_guard_slow_strength(), 0.18)
			if guard_damage > 0.0:
				enemy.take_damage(guard_damage * delta, false)

	var rest_radius = player.get_rest_field_radius()
	if rest_radius > 0.0:
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
				continue
			if enemy.global_position.distance_to(player.global_position) > rest_radius:
				continue
			enemy.apply_slow(player.get_rest_field_slow(), 0.18)


func _cast_thunder(is_storm: bool) -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return

	var target_enemy = _pick_clustered_enemy(enemies)
	if target_enemy == null:
		return

	var strike_position: Vector2 = target_enemy.global_position
	var strike_radius = float(current_snapshot.get("thunder_radius", 60.0))
	var strike_damage = float(current_snapshot.get("thunder_damage", 24.0))
	var label = "雷"
	var color = Color(0.7, 0.9, 1.0, 0.92)
	if is_storm:
		label = "雷雨"
	if _is_word_skill_active("flame_rain") and is_storm:
		label = "焰雨"
		color = Color(1.0, 0.66, 0.34, 0.92)

	_apply_radius_hit(strike_position, strike_radius, strike_damage, 0.0, 120.0)
	_add_burst({
		"type": "strike",
		"position": strike_position,
		"radius": strike_radius,
		"duration": 0.26,
		"time": 0.26,
		"color": color,
		"label": label
	})

	var chain_count = int(current_snapshot.get("thunder_chain", 0))
	if chain_count > 0:
		var chained = 0
		for enemy in enemies:
			if enemy == target_enemy or not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
				continue
			if enemy.global_position.distance_to(strike_position) > strike_radius * 1.8:
				continue
			enemy.take_damage(strike_damage * 0.55, false)
			enemy.apply_slow(0.18, 0.2)
			chained += 1
			if chained >= chain_count:
				break

	if float(current_snapshot.get("thunder_zone_duration", 0.0)) > 0.0:
		effect_zones.append({
			"position": strike_position,
			"radius": strike_radius * 0.7,
			"damage": float(current_snapshot.get("thunder_zone_damage", 0.0)),
			"slow": float(current_snapshot.get("thunder_zone_slow", 0.0)),
			"time": float(current_snapshot.get("thunder_zone_duration", 0.0)),
			"color": Color(0.42, 0.72, 1.0, 0.14),
			"label": "导"
		})


func _spawn_sprout_zone() -> void:
	var anchor = player.global_position
	var enemies = get_tree().get_nodes_in_group("enemies")
	if not enemies.is_empty():
		var nearest_enemy = _pick_clustered_enemy(enemies)
		if nearest_enemy != null:
			anchor = nearest_enemy.global_position

	effect_zones.append({
		"position": anchor,
		"radius": float(current_snapshot.get("sprout_radius", 46.0)),
		"damage": float(current_snapshot.get("sprout_damage", 8.0)),
		"slow": float(current_snapshot.get("sprout_slow", 0.16)),
		"time": 4.4,
		"color": Color(0.42, 0.82, 0.48, 0.15),
		"label": "苗"
	})


func _cast_room_storm(use_flame: bool) -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return

	var casts = 4
	for cast_index in range(casts):
		if enemies.is_empty():
			break
		var target_enemy = enemies[rng.randi_range(0, enemies.size() - 1)]
		if not is_instance_valid(target_enemy) or target_enemy.is_queued_for_deletion():
			continue
		_cast_thunder(true)
		if use_flame:
			effect_zones.append({
				"position": target_enemy.global_position,
				"radius": 42.0,
				"damage": 12.0,
				"slow": 0.08,
				"time": 2.0,
				"color": Color(1.0, 0.46, 0.24, 0.18),
				"label": "焰"
			})


func _check_room_completion() -> void:
	if room_complete:
		return

	var objective = str(active_room.get("objective", "purge"))
	if objective == "survive":
		if room_elapsed >= float(active_room.get("target_value", 20.0)):
			_complete_room("封印松开了，先结算这一房。")
	elif objective == "elite" and elite_spawned and (elite_target == null or not is_instance_valid(elite_target)):
		_complete_room("守门字灵倒下，字路前进了一段。")


func _refresh_progression_state() -> void:
	current_snapshot = progression.get_snapshot()
	player.apply_progression_snapshot(current_snapshot)
	_sync_hud()


func _sync_hud() -> void:
	if hud == null:
		return

	if player != null:
		hud.set_health(player.health, player.max_health)
	hud.set_progress(
		int(current_snapshot.get("experience", 0)),
		int(current_snapshot.get("experience_target", 6)),
		int(current_snapshot.get("level", 1))
	)
	hud.set_runtime(elapsed_time, kills)
	hud.set_room_info(
		str(active_room.get("name", "起墨室")),
		_get_objective_text(),
		str(active_room.get("modifier_text", "稳住阵脚，读清来向。"))
	)
	hud.set_build_snapshot(current_snapshot)


func _get_objective_text() -> String:
	var objective = str(active_room.get("objective", "purge"))
	if objective == "survive":
		var target_seconds = float(active_room.get("target_value", 20.0))
		return "坚守 %.0f / %.0f 秒" % [room_elapsed, target_seconds]
	if objective == "elite":
		if elite_target != null and is_instance_valid(elite_target):
			return "击破守门怪「%s」" % str(elite_target.character)
		return "守门怪将要现身"
	return "击破 %d / %d 个字灵" % [room_kills, int(active_room.get("target_value", 12))]


func _clear_runtime_entities() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy):
			enemy.queue_free()
	_clear_children(projectiles_root)
	_clear_children(pickups_root)


func _clear_children(root: Node) -> void:
	for child in root.get_children():
		child.queue_free()


func _random_spawn_position(bounds: Rect2) -> Vector2:
	var side = rng.randi_range(0, 3)
	match side:
		0:
			return Vector2(rng.randf_range(bounds.position.x + 24.0, bounds.end.x - 24.0), bounds.position.y + 28.0)
		1:
			return Vector2(rng.randf_range(bounds.position.x + 24.0, bounds.end.x - 24.0), bounds.end.y - 28.0)
		2:
			return Vector2(bounds.position.x + 28.0, rng.randf_range(bounds.position.y + 24.0, bounds.end.y - 24.0))
		_:
			return Vector2(bounds.end.x - 28.0, rng.randf_range(bounds.position.y + 24.0, bounds.end.y - 24.0))


func _pick_weighted_archetype(entries: Array) -> String:
	if entries.is_empty():
		return "stalker"

	var total_weight = 0.0
	for entry in entries:
		total_weight += float(entry.get("weight", 1.0))

	var roll = rng.randf_range(0.0, total_weight)
	var cursor = 0.0
	for entry in entries:
		cursor += float(entry.get("weight", 1.0))
		if roll <= cursor:
			return str(entry.get("id", "stalker"))
	return str(entries[0].get("id", "stalker"))


func _pick_clustered_enemy(enemies: Array):
	var best_enemy = null
	var best_score = -INF

	for candidate in enemies:
		if not is_instance_valid(candidate) or candidate.is_queued_for_deletion():
			continue
		var score = -candidate.global_position.distance_squared_to(player.global_position) * 0.002
		for other in enemies:
			if other == candidate or not is_instance_valid(other) or other.is_queued_for_deletion():
				continue
			if other.global_position.distance_to(candidate.global_position) <= 96.0:
				score += 1.0
		if score > best_score:
			best_score = score
			best_enemy = candidate

	return best_enemy


func _apply_radius_hit(center: Vector2, radius: float, damage: float, slow_strength: float, push_strength: float) -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		var offset: Vector2 = enemy.global_position - center
		var distance = offset.length()
		if distance > radius:
			continue
		enemy.take_damage(damage)
		if slow_strength > 0.0:
			enemy.apply_slow(slow_strength, 0.2)
		if push_strength > 0.0 and distance > 0.0:
			enemy.apply_knockback(offset.normalized() * push_strength)


func _distance_point_to_segment(point: Vector2, segment_start: Vector2, segment_end: Vector2) -> float:
	var segment = segment_end - segment_start
	if segment.length_squared() <= 0.001:
		return point.distance_to(segment_start)
	var t = clamp((point - segment_start).dot(segment) / segment.length_squared(), 0.0, 1.0)
	var closest = segment_start + segment * t
	return point.distance_to(closest)


func _add_burst(effect: Dictionary) -> void:
	burst_effects.append(effect)


func _update_burst_effects(delta: float) -> void:
	for index in range(burst_effects.size() - 1, -1, -1):
		var effect: Dictionary = burst_effects[index]
		effect["time"] = float(effect.get("time", 0.0)) - delta
		if float(effect.get("time", 0.0)) <= 0.0:
			burst_effects.remove_at(index)
			continue
		burst_effects[index] = effect


func _pick_summary_message(messages: Variant) -> String:
	if messages is Array and not messages.is_empty():
		return str(messages[messages.size() - 1])
	return "这一笔已经落下。"


func _is_word_skill_active(word_skill_id: String) -> bool:
	var lookup: Dictionary = current_snapshot.get("word_skills_lookup", {})
	return lookup.has(word_skill_id)


func _build_room_templates() -> Array:
	return [
		{
			"id": "sealed_scriptorium",
			"name": "封匣书库",
			"objective": "purge",
			"target_value": 12,
			"spawn_interval": 0.94,
			"enemy_cap": 10,
			"bounds": Rect2(-540.0, -320.0, 1080.0, 640.0),
			"modifier_text": "先用清怪把空间抢回来，再谈字路展开。",
			"archetypes": [
				{"id": "skitter", "weight": 1.4},
				{"id": "stalker", "weight": 1.0},
				{"id": "brute", "weight": 0.5}
			]
		},
		{
			"id": "rain_gallery",
			"name": "雨廊偏殿",
			"objective": "survive",
			"target_value": 22.0,
			"spawn_interval": 0.72,
			"enemy_cap": 12,
			"bounds": Rect2(-620.0, -280.0, 1240.0, 560.0),
			"modifier_text": "这一房考的是读位与持续控场，别被边线逼死。",
			"archetypes": [
				{"id": "skitter", "weight": 1.8},
				{"id": "stalker", "weight": 1.1},
				{"id": "brute", "weight": 0.35}
			]
		},
		{
			"id": "narrow_archive",
			"name": "字灯阵室",
			"objective": "purge",
			"target_value": 18,
			"spawn_interval": 0.66,
			"enemy_cap": 13,
			"bounds": Rect2(-460.0, -360.0, 920.0, 720.0),
			"modifier_text": "房间更窄，近身压力更大，领域与击退更有价值。",
			"archetypes": [
				{"id": "brute", "weight": 0.95},
				{"id": "stalker", "weight": 1.2},
				{"id": "skitter", "weight": 0.9}
			]
		},
		{
			"id": "gate_room",
			"name": "守墨门",
			"objective": "elite",
			"target_value": 1,
			"spawn_interval": 0.9,
			"enemy_cap": 8,
			"bounds": Rect2(-560.0, -300.0, 1120.0, 600.0),
			"modifier_text": "守门怪会带着杂兵入场，优先找输出窗口。",
			"archetypes": [
				{"id": "stalker", "weight": 1.0},
				{"id": "brute", "weight": 0.7},
				{"id": "skitter", "weight": 0.9}
			]
		}
	]


func _setup_input_map() -> void:
	_ensure_action("move_up", [KEY_W, KEY_UP])
	_ensure_action("move_down", [KEY_S, KEY_DOWN])
	_ensure_action("move_left", [KEY_A, KEY_LEFT])
	_ensure_action("move_right", [KEY_D, KEY_RIGHT])
	_ensure_action("restart", [KEY_R])
	_ensure_action("choice_1", [KEY_1, KEY_KP_1])
	_ensure_action("choice_2", [KEY_2, KEY_KP_2])
	_ensure_action("choice_3", [KEY_3, KEY_KP_3])
	_ensure_action("choice_4", [KEY_4, KEY_KP_4])


func _ensure_action(action_name: StringName, keycodes: Array[int]) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	if InputMap.action_get_events(action_name).is_empty():
		for keycode in keycodes:
			var event = InputEventKey.new()
			event.physical_keycode = keycode
			InputMap.action_add_event(action_name, event)
