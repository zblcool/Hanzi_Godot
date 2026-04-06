extends Area2D

signal request_word_bolt(origin: Vector2, direction: Vector2, character: String, damage: float, speed: float)
signal request_slash(start_position: Vector2, end_position: Vector2, width: float, damage: float, label: String)
signal request_wave(origin: Vector2, radius: float, damage: float, slow_strength: float, push_strength: float, label: String)
signal health_changed(current: float, maximum: float)
signal defeated

const CJKFont := preload("res://scripts/cjk_font.gd")
const BOLT_GLYPHS := ["字", "文", "言", "诗", "书", "墨", "印", "诀"]

@export var move_speed := 260.0
@export var max_health := 100.0
@export var attack_interval := 0.72
@export var attack_damage := 20.0
@export var attack_speed := 620.0

var health := 0.0
var attack_cooldown := 0.0
var invulnerability_time := 0.0
var is_defeated := false
var controls_enabled := true
var room_bounds := Rect2(-560.0, -340.0, 1120.0, 680.0)

var bonus_move_speed := 0.0
var attack_damage_bonus := 0.0
var attack_rate_multiplier := 1.0
var projectile_speed_bonus := 0.0
var projectile_count := 1
var projectile_scale_bonus := 0.0
var base_damage_reduction := 0.0

var rest_level := 0
var rest_heal_rate := 0.0
var rest_damage_reduction := 0.0
var rest_field_radius := 0.0
var rest_field_slow := 0.0

var guard_level := 0
var guard_radius := 0.0
var guard_slow := 0.0
var guard_attack_bonus := 0.0

var move_level := 0
var slash_damage := 0.0
var slash_width := 34.0
var slash_threshold := 9999.0

var wave_level := 0
var wave_damage := 0.0
var wave_radius := 0.0
var wave_slow := 0.0
var wave_push := 0.0
var wave_cooldown_max := 999.0
var wave_cooldown := 0.0

var chant_level := 0
var echo_chance := 0.0
var echo_delay := 0.35
var echo_damage_multiplier := 0.65
var word_wind_walk := false
var word_heart_mind := false

var stationary_time := 0.0
var rest_tick := 0.0
var movement_meter := 0.0
var slash_counter := 0
var glyph_index := 0
var insignia_glyph := "文"
var echo_queue: Array = []

var rng := RandomNumberGenerator.new()
var draw_font: Font


func _ready() -> void:
	add_to_group("player")
	rng.randomize()
	health = max_health
	draw_font = _build_font()
	health_changed.emit(health, max_health)
	set_physics_process(true)
	queue_redraw()


func set_controls_enabled(enabled: bool) -> void:
	controls_enabled = enabled
	if not enabled:
		echo_queue.clear()
	queue_redraw()


func configure_room(bounds: Rect2) -> void:
	room_bounds = bounds
	_clamp_to_room()
	queue_redraw()


func apply_progression_snapshot(snapshot: Dictionary) -> void:
	var previous_max_health = max_health

	bonus_move_speed = float(snapshot.get("move_speed_bonus", 0.0))
	attack_damage_bonus = float(snapshot.get("attack_damage_bonus", 0.0))
	attack_rate_multiplier = max(1.0, float(snapshot.get("attack_rate_multiplier", 1.0)))
	projectile_speed_bonus = float(snapshot.get("projectile_speed_bonus", 0.0))
	projectile_count = max(1, 1 + int(snapshot.get("extra_projectiles", 0)))
	projectile_scale_bonus = float(snapshot.get("projectile_scale_bonus", 0.0))
	base_damage_reduction = float(snapshot.get("damage_reduction", 0.0))

	rest_level = int(snapshot.get("rest_level", 0))
	rest_heal_rate = float(snapshot.get("rest_heal_rate", 0.0))
	rest_damage_reduction = float(snapshot.get("rest_damage_reduction", 0.0))
	rest_field_radius = float(snapshot.get("rest_field_radius", 0.0))
	rest_field_slow = float(snapshot.get("rest_field_slow", 0.0))

	guard_level = int(snapshot.get("guard_level", 0))
	guard_radius = float(snapshot.get("guard_radius", 0.0))
	guard_slow = float(snapshot.get("guard_slow", 0.0))
	guard_attack_bonus = float(snapshot.get("guard_attack_bonus", 0.0))

	move_level = int(snapshot.get("move_level", 0))
	slash_damage = float(snapshot.get("slash_damage", 0.0))
	slash_width = float(snapshot.get("slash_width", 34.0))
	slash_threshold = float(snapshot.get("slash_threshold", 9999.0))

	wave_level = int(snapshot.get("wave_level", 0))
	wave_damage = float(snapshot.get("wave_damage", 0.0))
	wave_radius = float(snapshot.get("wave_radius", 0.0))
	wave_slow = float(snapshot.get("wave_slow", 0.0))
	wave_push = float(snapshot.get("wave_push", 0.0))
	wave_cooldown_max = float(snapshot.get("wave_cooldown", 999.0))
	wave_cooldown = min(wave_cooldown, wave_cooldown_max)

	chant_level = int(snapshot.get("chant_level", 0))
	echo_chance = float(snapshot.get("echo_chance", 0.0))
	echo_delay = float(snapshot.get("echo_delay", 0.35))
	echo_damage_multiplier = float(snapshot.get("echo_damage_multiplier", 0.65))

	var word_lookup: Dictionary = snapshot.get("word_skills_lookup", {})
	word_wind_walk = word_lookup.has("wind_walk")
	word_heart_mind = word_lookup.has("heart_mind")
	insignia_glyph = str(snapshot.get("core_glyph", "文"))

	max_health = 100.0 + float(snapshot.get("max_health_bonus", 0.0))
	if max_health > previous_max_health:
		health = min(max_health, health + (max_health - previous_max_health))
	else:
		health = min(health, max_health)

	health_changed.emit(health, max_health)
	queue_redraw()


func heal(amount: float) -> void:
	if amount <= 0.0 or is_defeated:
		return

	health = min(max_health, health + amount)
	health_changed.emit(health, max_health)


func receive_hit(amount: float) -> void:
	if is_defeated or invulnerability_time > 0.0:
		return

	var final_damage = amount * (1.0 - _get_total_damage_reduction())
	health = max(0.0, health - final_damage)
	invulnerability_time = 0.42
	health_changed.emit(health, max_health)
	queue_redraw()

	if health <= 0.0:
		is_defeated = true
		defeated.emit()


func get_guard_radius() -> float:
	if guard_level <= 0:
		return 0.0
	return guard_radius


func get_guard_slow_strength() -> float:
	return guard_slow


func get_rest_field_radius() -> float:
	if rest_level < 3:
		return 0.0
	if health <= 0.0 or max_health <= 0.0:
		return 0.0
	if stationary_time < 0.5:
		return 0.0
	if health / max_health > 0.4:
		return 0.0
	return rest_field_radius


func get_rest_field_slow() -> float:
	return rest_field_slow


func _physics_process(delta: float) -> void:
	if is_defeated:
		return

	_update_echo_queue(delta)

	if not controls_enabled:
		invulnerability_time = max(invulnerability_time - delta, 0.0)
		queue_redraw()
		return

	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_direction.length_squared() > 1.0:
		input_direction = input_direction.normalized()

	var previous_position = global_position
	var effective_speed = move_speed + bonus_move_speed
	global_position += input_direction * effective_speed * delta
	_clamp_to_room()

	var moved_distance = previous_position.distance_to(global_position)
	_update_stationary_state(delta, input_direction, moved_distance)
	_update_move_skill(previous_position, moved_distance)
	_process_rest(delta)

	attack_cooldown = max(attack_cooldown - delta, 0.0)
	invulnerability_time = max(invulnerability_time - delta, 0.0)
	wave_cooldown = max(wave_cooldown - delta, 0.0)

	if attack_cooldown <= 0.0:
		_fire_at_closest_enemy()

	if wave_level > 0 and wave_cooldown <= 0.0:
		wave_cooldown = wave_cooldown_max
		var wave_label = "波"
		if wave_level >= 3:
			wave_label = "潮"
		request_wave.emit(global_position, wave_radius, wave_damage, wave_slow, wave_push, wave_label)

	queue_redraw()


func _update_echo_queue(delta: float) -> void:
	for index in range(echo_queue.size() - 1, -1, -1):
		var echo_entry: Dictionary = echo_queue[index]
		echo_entry["delay"] = float(echo_entry.get("delay", 0.0)) - delta
		echo_queue[index] = echo_entry
		if float(echo_entry.get("delay", 0.0)) > 0.0:
			continue

		var repeat_count = int(echo_entry.get("count", 1))
		for repeat_index in range(repeat_count):
			var glyph = "念"
			if repeat_index > 0:
				glyph = "心"
			_fire_at_closest_enemy(float(echo_entry.get("damage_multiplier", 0.65)), false, glyph)
		echo_queue.remove_at(index)


func _update_stationary_state(delta: float, input_direction: Vector2, moved_distance: float) -> void:
	if input_direction.length() < 0.05 or moved_distance < 1.0:
		stationary_time += delta
		return

	stationary_time = 0.0
	rest_tick = 0.0


func _update_move_skill(previous_position: Vector2, moved_distance: float) -> void:
	if move_level <= 0 or moved_distance <= 0.0:
		return

	movement_meter += moved_distance
	var required_distance = slash_threshold
	if required_distance <= 0.0:
		return

	while movement_meter >= required_distance:
		movement_meter -= required_distance
		slash_counter += 1
		var emitted_damage = slash_damage
		var emitted_width = slash_width
		var slash_label = "行"

		if move_level >= 3 and slash_counter % 3 == 0:
			emitted_damage *= 1.55
			emitted_width += 10.0
			slash_label = "疾"
		if word_wind_walk:
			emitted_damage *= 1.28
			emitted_width += 6.0
			slash_label = "风行"

		request_slash.emit(previous_position, global_position, emitted_width, emitted_damage, slash_label)


func _process_rest(delta: float) -> void:
	if rest_level <= 0 or stationary_time < 0.75:
		rest_tick = 0.0
		return

	rest_tick -= delta
	if rest_tick > 0.0:
		return

	rest_tick = 0.25
	heal(rest_heal_rate * 0.25)


func _fire_at_closest_enemy(damage_multiplier: float = 1.0, allow_echo: bool = true, override_glyph: String = "") -> bool:
	var enemy_nodes = get_tree().get_nodes_in_group("enemies")
	var closest_enemy: Node2D
	var closest_distance = INF

	for enemy in enemy_nodes:
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		var distance = global_position.distance_squared_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy

	if closest_enemy == null:
		return false

	attack_cooldown = attack_interval / attack_rate_multiplier

	var base_damage = (attack_damage + attack_damage_bonus) * damage_multiplier
	if guard_level >= 3:
		base_damage *= 1.0 + guard_attack_bonus

	var projectile_speed = attack_speed + projectile_speed_bonus
	var forward: Vector2 = (closest_enemy.global_position - global_position).normalized()
	var total_projectiles = projectile_count
	if word_wind_walk and move_level > 0:
		total_projectiles += 1

	var spread_step = 0.20 + projectile_scale_bonus * 0.1
	for index in range(total_projectiles):
		var offset = float(index) - float(total_projectiles - 1) * 0.5
		var direction = forward.rotated(offset * spread_step)
		var glyph = override_glyph
		if glyph.is_empty():
			glyph = BOLT_GLYPHS[glyph_index % BOLT_GLYPHS.size()]
		glyph_index += 1
		request_word_bolt.emit(global_position + direction * 24.0, direction, glyph, base_damage, projectile_speed)

	if allow_echo and chant_level > 0 and rng.randf() <= echo_chance:
		var echo_count = 1
		if word_heart_mind and (health / max_health <= 0.5 or rng.randf() <= 0.25):
			echo_count = 2
		echo_queue.append({
			"delay": echo_delay,
			"damage_multiplier": echo_damage_multiplier,
			"count": echo_count
		})

	return true


func _get_total_damage_reduction() -> float:
	var reduction = base_damage_reduction
	if stationary_time >= 0.75:
		reduction += rest_damage_reduction
	return clamp(reduction, 0.0, 0.75)


func _clamp_to_room() -> void:
	var margin = 22.0
	global_position.x = clamp(global_position.x, room_bounds.position.x + margin, room_bounds.end.x - margin)
	global_position.y = clamp(global_position.y, room_bounds.position.y + margin, room_bounds.end.y - margin)


func _draw() -> void:
	if guard_level > 0 and guard_radius > 0.0:
		draw_circle(Vector2.ZERO, guard_radius, Color(0.22, 0.33, 0.54, 0.08))
		draw_arc(Vector2.ZERO, guard_radius, -PI, PI, 48, Color(0.62, 0.86, 1.0, 0.32), 2.0)

	var rest_radius = get_rest_field_radius()
	if rest_radius > 0.0:
		draw_circle(Vector2.ZERO, rest_radius, Color(0.46, 0.8, 0.56, 0.1))
		draw_arc(Vector2.ZERO, rest_radius, -PI, PI, 40, Color(0.88, 1.0, 0.82, 0.5), 2.0)

	var body_color = Color(0.96, 0.92, 0.84)
	if invulnerability_time > 0.0:
		body_color = Color(1.0, 0.78, 0.62)
	elif stationary_time >= 0.75 and rest_level > 0:
		body_color = Color(0.9, 0.98, 0.84)

	draw_circle(Vector2.ZERO, 18.0, body_color)
	draw_arc(Vector2.ZERO, 23.0, -PI * 0.85, PI * 0.85, 40, Color(0.78, 0.24, 0.15, 0.95), 3.2)
	draw_circle(Vector2.ZERO, 4.5, Color(0.14, 0.12, 0.11, 0.95))

	if wave_level > 0 and wave_cooldown_max < 900.0:
		var ready_ratio: float = 1.0 - clamp(wave_cooldown / wave_cooldown_max, 0.0, 1.0)
		draw_arc(Vector2.ZERO, 28.0, -PI * 0.5, -PI * 0.5 + TAU * ready_ratio, 28, Color(0.58, 0.9, 1.0, 0.9), 2.2)

	if draw_font != null:
		draw_string(draw_font, Vector2(-10.0, 8.0), insignia_glyph, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 22, Color(0.08, 0.07, 0.07))


func _build_font() -> Font:
	return CJKFont.get_font()
