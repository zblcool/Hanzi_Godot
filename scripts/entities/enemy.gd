extends Node3D

const CJKFont := preload("res://scripts/core/cjk_font.gd")

signal defeated(world_position: Vector3, enemy_type: String)
signal request_hazard(target_position: Vector3, radius: float, warning_time: float, active_time: float, damage: float, tint: Color, label: String)
signal request_line_hazard(origin: Vector3, direction: Vector3, length: float, width: float, warning_time: float, active_time: float, damage: float, tint: Color, label: String, stun_time: float)
signal request_projectile(origin: Vector3, direction: Vector3, speed: float, damage: float, glyph: String, tint: Color, life_time: float, hit_radius: float, stun_time: float)

var enemy_type: String = "basic"
var enemy_name: String = "魇卒"
var glyph: String = "魇"
var player = null

var difficulty_scale: float = 1.0
var ground_height: float = 0.56
var move_speed: float = 3.6
var max_health: float = 24.0
var health: float = 24.0
var display_health: float = 24.0
var contact_damage: float = 8.0
var preferred_min_distance: float = 7.5
var preferred_max_distance: float = 11.0
var hit_radius: float = 1.0
var tint: Color = Color(0.74, 0.24, 0.2, 1.0)

var attack_cooldown: float = 0.0
var ability_cooldown: float = 0.0
var dash_time: float = 0.0
var windup_time: float = 0.0
var hit_flash_time: float = 0.0
var drift_time: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO
var pending_direction: Vector3 = Vector3.ZERO
var pending_action: String = ""
var dash_speed_multiplier: float = 1.0
var dash_damage: float = 0.0
var dash_stun_time: float = 0.0
var dash_hit_ready: bool = false
var strafe_sign: float = 1.0
var elite_skill_index: int = 0
var elite_spin_angle: float = 0.0
var is_dead: bool = false

var body_material: StandardMaterial3D
var accent_material: StandardMaterial3D
var health_bar_back_material: StandardMaterial3D
var health_bar_fill_material: StandardMaterial3D
var label_node: Label3D
var body_node: MeshInstance3D
var head_node: MeshInstance3D
var visual_root: Node3D
var glyph_root: Node3D
var glyph_ring_node: MeshInstance3D
var health_bar_root: Node3D
var health_bar_fill_node: MeshInstance3D
var left_arm_node: MeshInstance3D
var right_arm_node: MeshInstance3D
var left_leg_node: MeshInstance3D
var right_leg_node: MeshInstance3D
var rear_left_leg_node: MeshInstance3D
var rear_right_leg_node: MeshInstance3D
var gait_amount: float = 0.0
var health_bar_width: float = 1.08


func configure(kind: String, difficulty: float, player_ref) -> void:
	enemy_type = kind
	player = player_ref
	difficulty_scale = difficulty
	strafe_sign = -1.0 if int(get_instance_id()) % 2 == 0 else 1.0
	_apply_type_stats()
	health = max_health
	display_health = health


func _ready() -> void:
	add_to_group("enemy")
	_build_visuals()
	_update_health_bar(0.0)
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	if is_dead or not is_instance_valid(player):
		return

	var was_winding: bool = windup_time > 0.0
	var was_dashing: bool = dash_time > 0.0

	attack_cooldown = max(attack_cooldown - delta, 0.0)
	ability_cooldown = max(ability_cooldown - delta, 0.0)
	dash_time = max(dash_time - delta, 0.0)
	windup_time = max(windup_time - delta, 0.0)
	hit_flash_time = max(hit_flash_time - delta, 0.0)
	drift_time += delta

	if was_winding and windup_time <= 0.0 and not pending_action.is_empty():
		_execute_pending_action()
	if was_dashing and dash_time <= 0.0:
		dash_hit_ready = false

	var motion: Vector3 = Vector3.ZERO
	var player_hidden: bool = false
	if player.has_method("is_hidden_in_bush"):
		player_hidden = player.is_hidden_in_bush()

	var distance: float = INF
	var direction: Vector3 = Vector3.ZERO
	if not player_hidden:
		var offset: Vector3 = player.global_position - global_position
		offset.y = 0.0
		distance = offset.length()
		if distance > 0.001:
			direction = offset.normalized()

	if dash_time > 0.0:
		motion = dash_direction * (move_speed * dash_speed_multiplier)
	elif windup_time > 0.0:
		if pending_direction.length_squared() > 0.01:
			_face_direction(pending_direction, delta)
	elif not player_hidden:
		motion = _compute_motion(direction, distance)
		_handle_contact_attack(distance)

	global_position += motion * delta
	global_position.y = ground_height

	if dash_time > 0.0:
		_handle_dash_collision()

	if motion.length_squared() > 0.01:
		_face_direction(motion.normalized(), delta)
	var motion_reference: float = move_speed * (dash_speed_multiplier if dash_time > 0.0 else 1.0)
	gait_amount = clamp(motion.length() / max(motion_reference, 0.001), 0.0, 1.8)

	_update_visual_state()
	_update_health_bar(delta)


func take_damage(amount: float) -> void:
	if is_dead:
		return
	health = max(0.0, health - amount)
	hit_flash_time = 0.14
	if health <= 0.0:
		is_dead = true
		defeated.emit(global_position, enemy_type)
		queue_free()


func get_hit_radius() -> float:
	return hit_radius


func _apply_type_stats() -> void:
	enemy_name = "魇卒"
	glyph = "魇"
	move_speed = 3.8 + difficulty_scale * 0.22
	max_health = 24.0 + difficulty_scale * 8.0
	contact_damage = 8.0 + difficulty_scale * 1.35
	preferred_min_distance = 7.5
	preferred_max_distance = 11.0
	hit_radius = 1.02
	tint = Color(0.72, 0.22, 0.18, 1.0)

	match enemy_type:
		"swift":
			enemy_name = "疾卒"
			glyph = "迅"
			move_speed = 5.2 + difficulty_scale * 0.34
			max_health = 18.0 + difficulty_scale * 6.5
			contact_damage = 7.5 + difficulty_scale * 1.15
			hit_radius = 0.86
			tint = Color(0.96, 0.45, 0.26, 1.0)
		"tank":
			enemy_name = "墨甲"
			glyph = "甲"
			move_speed = 2.8 + difficulty_scale * 0.18
			max_health = 38.0 + difficulty_scale * 12.0
			contact_damage = 12.0 + difficulty_scale * 1.8
			hit_radius = 1.28
			tint = Color(0.45, 0.51, 0.62, 1.0)
		"archer":
			enemy_name = "弓手"
			glyph = "弓"
			move_speed = 3.4 + difficulty_scale * 0.2
			max_health = 20.0 + difficulty_scale * 7.0
			contact_damage = 8.0 + difficulty_scale * 1.3
			preferred_min_distance = 8.5
			preferred_max_distance = 13.8
			hit_radius = 0.92
			tint = Color(0.85, 0.58, 0.28, 1.0)
		"assassin":
			enemy_name = "忍"
			glyph = "忍"
			move_speed = 5.5 + difficulty_scale * 0.38
			max_health = 17.0 + difficulty_scale * 6.5
			contact_damage = 9.0 + difficulty_scale * 1.3
			preferred_min_distance = 5.8
			preferred_max_distance = 8.8
			hit_radius = 0.84
			tint = Color(0.82, 0.36, 0.52, 1.0)
		"cavalry":
			enemy_name = "墨骑"
			glyph = "骑"
			move_speed = 4.4 + difficulty_scale * 0.24
			max_health = 35.0 + difficulty_scale * 11.0
			contact_damage = 13.0 + difficulty_scale * 1.8
			preferred_min_distance = 8.0
			preferred_max_distance = 14.5
			hit_radius = 1.24
			tint = Color(0.82, 0.28, 0.2, 1.0)
		"ritualist":
			enemy_name = "阵师"
			glyph = "阵"
			move_speed = 3.2 + difficulty_scale * 0.2
			max_health = 22.0 + difficulty_scale * 8.0
			contact_damage = 6.0 + difficulty_scale * 1.2
			preferred_min_distance = 8.6
			preferred_max_distance = 12.8
			hit_radius = 0.96
			tint = Color(0.57, 0.37, 0.86, 1.0)
		"elite":
			enemy_name = "魁首"
			glyph = "魁"
			move_speed = 4.0 + difficulty_scale * 0.22
			max_health = 82.0 + difficulty_scale * 16.0
			contact_damage = 14.0 + difficulty_scale * 2.1
			preferred_min_distance = 8.0
			preferred_max_distance = 14.5
			hit_radius = 1.46
			tint = Color(0.72, 0.2, 0.34, 1.0)
		"boss":
			enemy_name = "卷主"
			glyph = "卷"
			move_speed = 3.5 + difficulty_scale * 0.18
			max_health = 248.0 + difficulty_scale * 36.0
			contact_damage = 18.0 + difficulty_scale * 2.6
			preferred_min_distance = 9.0
			preferred_max_distance = 16.5
			hit_radius = 1.82
			tint = Color(0.84, 0.32, 0.22, 1.0)


func _compute_motion(direction: Vector3, distance: float) -> Vector3:
	match enemy_type:
		"swift":
			return _compute_swift_motion(direction)
		"archer":
			return _compute_archer_motion(direction, distance)
		"assassin":
			return _compute_assassin_motion(direction, distance)
		"cavalry":
			return _compute_cavalry_motion(direction, distance)
		"ritualist":
			return _compute_ritualist_motion(direction, distance)
		"elite":
			return _compute_elite_motion(direction, distance)
		"boss":
			return _compute_boss_motion(direction, distance)
		"tank":
			return direction * move_speed
		_:
			return direction * move_speed


func _compute_swift_motion(direction: Vector3) -> Vector3:
	var lateral := Vector3(-direction.z, 0.0, direction.x)
	var wobble: float = sin(drift_time * 5.2 + float(int(get_instance_id()) % 11)) * 0.35
	var motion := direction + lateral * wobble
	return motion.normalized() * move_speed


func _compute_archer_motion(direction: Vector3, distance: float) -> Vector3:
	if ability_cooldown <= 0.0 and distance < 16.0:
		_start_archer_shot(direction)

	var lateral := Vector3(-direction.z, 0.0, direction.x) * strafe_sign
	var motion := Vector3.ZERO
	if distance < preferred_min_distance:
		motion = -direction + lateral * 0.45
	elif distance > preferred_max_distance:
		motion = direction * 0.8 + lateral * 0.18
	else:
		motion = lateral
	return motion.normalized() * move_speed


func _compute_assassin_motion(direction: Vector3, distance: float) -> Vector3:
	if ability_cooldown <= 0.0 and distance < 10.5:
		_start_assassin_dash(direction)
		return Vector3.ZERO

	var lateral := Vector3(-direction.z, 0.0, direction.x) * strafe_sign
	var motion := lateral
	if distance < preferred_min_distance:
		motion = -direction * 0.45 + lateral
	elif distance > preferred_max_distance:
		motion = direction * 1.05
	return motion.normalized() * move_speed


func _compute_cavalry_motion(direction: Vector3, distance: float) -> Vector3:
	if ability_cooldown <= 0.0 and distance < 17.5:
		_start_cavalry_charge(direction)
		return Vector3.ZERO

	var lateral := Vector3(-direction.z, 0.0, direction.x) * strafe_sign
	var motion := lateral
	if distance < preferred_min_distance:
		motion = -direction + lateral * 0.55
	elif distance > preferred_max_distance:
		motion = direction + lateral * 0.2
	return motion.normalized() * move_speed


func _compute_ritualist_motion(direction: Vector3, distance: float) -> Vector3:
	var motion := Vector3.ZERO
	if distance < preferred_min_distance:
		motion = -direction * move_speed
	elif distance > preferred_max_distance:
		motion = direction * move_speed
	else:
		motion = Vector3(-direction.z, 0.0, direction.x) * strafe_sign * move_speed * 0.45

	if ability_cooldown <= 0.0 and distance < 15.0:
		request_hazard.emit(player.global_position, 2.8, 1.05, 2.4, contact_damage * 0.9 + 4.0, tint, "阵")
		ability_cooldown = 4.8
	return motion


func _compute_elite_motion(direction: Vector3, distance: float) -> Vector3:
	if ability_cooldown <= 0.0 and distance < 20.0:
		_start_elite_skill(direction)
		return Vector3.ZERO

	var lateral := Vector3(-direction.z, 0.0, direction.x) * strafe_sign
	var motion := lateral
	if distance < preferred_min_distance:
		motion = -direction * 0.82 + lateral * 0.5
	elif distance > preferred_max_distance:
		motion = direction * 0.72
	return motion.normalized() * move_speed


func _compute_boss_motion(direction: Vector3, distance: float) -> Vector3:
	if ability_cooldown <= 0.0 and distance < 24.0:
		_start_boss_skill(direction)
		return Vector3.ZERO

	var lateral := Vector3(-direction.z, 0.0, direction.x) * strafe_sign
	var motion := lateral * 0.55
	if distance < preferred_min_distance:
		motion = -direction * 0.76 + lateral * 0.42
	elif distance > preferred_max_distance:
		motion = direction * 0.8
	return motion.normalized() * move_speed


func _handle_contact_attack(distance: float) -> void:
	if attack_cooldown > 0.0:
		return
	if enemy_type == "archer" or enemy_type == "ritualist":
		return
	if distance > hit_radius + 1.0:
		return
	if player.has_method("receive_damage"):
		player.receive_damage(contact_damage)
	if enemy_type == "boss":
		attack_cooldown = 0.72
	else:
		attack_cooldown = 0.85 if enemy_type == "elite" else 1.0


func _handle_dash_collision() -> void:
	if not dash_hit_ready or not is_instance_valid(player):
		return
	var distance: float = global_position.distance_to(player.global_position)
	if distance > hit_radius + 1.0:
		return

	if player.has_method("receive_damage"):
		player.receive_damage(dash_damage)
	if dash_stun_time > 0.0 and player.has_method("apply_stun"):
		player.apply_stun(dash_stun_time)
	dash_hit_ready = false
	attack_cooldown = 1.0


func _start_archer_shot(direction: Vector3) -> void:
	if direction.length_squared() <= 0.001:
		return
	pending_action = "archer_shot"
	pending_direction = direction
	windup_time = 0.38
	ability_cooldown = 2.3


func _start_assassin_dash(direction: Vector3) -> void:
	if direction.length_squared() <= 0.001:
		return
	request_line_hazard.emit(global_position, direction, 8.8, 1.35, 0.55, 0.26, 0.0, tint, "忍", 0.0)
	pending_action = "assassin_dash"
	pending_direction = direction
	windup_time = 0.55
	ability_cooldown = 4.1


func _start_cavalry_charge(direction: Vector3) -> void:
	if direction.length_squared() <= 0.001:
		return
	request_line_hazard.emit(global_position, direction, 16.5, 2.2, 0.9, 0.72, 0.0, tint, "骑", 0.0)
	pending_action = "cavalry_charge"
	pending_direction = direction
	windup_time = 0.9
	ability_cooldown = 6.6


func _start_elite_skill(direction: Vector3) -> void:
	match elite_skill_index % 4:
		0:
			request_hazard.emit(player.global_position, 4.3, 1.0, 1.25, contact_damage * 0.9 + 6.0, tint, "爆")
			ability_cooldown = 5.8
		1:
			pending_action = "elite_barrage"
			pending_direction = direction
			windup_time = 0.65
			ability_cooldown = 5.2
		2:
			pending_action = "elite_plum"
			pending_direction = direction
			windup_time = 0.48
			ability_cooldown = 5.0
		_:
			request_line_hazard.emit(global_position, direction, 18.0, 2.7, 1.05, 0.92, 0.0, tint, "魁", 0.0)
			pending_action = "elite_charge"
			pending_direction = direction
			windup_time = 1.05
			ability_cooldown = 7.4
	elite_skill_index += 1


func _start_boss_skill(direction: Vector3) -> void:
	match elite_skill_index % 5:
		0:
			request_hazard.emit(player.global_position, 5.4, 1.15, 1.35, contact_damage * 0.92 + 8.0, tint, "禁")
			ability_cooldown = 6.2
		1:
			pending_action = "boss_barrage"
			pending_direction = direction
			windup_time = 0.82
			ability_cooldown = 5.8
		2:
			pending_action = "boss_fan"
			pending_direction = direction
			windup_time = 0.62
			ability_cooldown = 5.2
		3:
			request_line_hazard.emit(global_position, direction, 21.0, 3.1, 1.08, 1.0, 0.0, tint, "卷", 0.0)
			pending_action = "boss_charge"
			pending_direction = direction
			windup_time = 1.12
			ability_cooldown = 7.6
		_:
			pending_action = "boss_cross"
			pending_direction = direction
			windup_time = 0.72
			ability_cooldown = 6.4
	elite_skill_index += 1


func _execute_pending_action() -> void:
	match pending_action:
		"archer_shot":
			_emit_enemy_projectile(pending_direction, 14.8, contact_damage * 0.82 + 1.5, "矢", tint.lightened(0.12), 2.4, 0.55)
		"assassin_dash":
			_start_dash(pending_direction, 0.32, 4.2, contact_damage + 3.0, 0.0)
		"cavalry_charge":
			_start_dash(pending_direction, 0.72, 5.1, contact_damage + 6.0, 1.0)
		"elite_barrage":
			_emit_projectile_row(pending_direction, 6, 0.82, 13.4, contact_damage * 0.76 + 2.0, "墨", tint.lightened(0.1), 2.7, 0.52)
		"elite_plum":
			elite_spin_angle += 0.42
			for index in range(5):
				var angle: float = elite_spin_angle + TAU * float(index) / 5.0
				var direction := Vector3(cos(angle), 0.0, sin(angle))
				_emit_enemy_projectile(direction, 11.8, contact_damage * 0.68 + 3.2, "梅", tint.lightened(0.16), 2.4, 0.58)
		"elite_charge":
			_start_dash(pending_direction, 0.9, 5.6, contact_damage + 8.0, 1.2)
		"boss_barrage":
			_emit_projectile_row(pending_direction, 8, 0.96, 15.2, contact_damage * 0.82 + 3.5, "墨", tint.lightened(0.14), 3.0, 0.6)
		"boss_fan":
			for index in range(7):
				var spread: float = -0.48 + float(index) * 0.16
				var fan_direction := pending_direction.rotated(Vector3.UP, spread)
				_emit_enemy_projectile(fan_direction, 13.4, contact_damage * 0.76 + 4.0, "卷", tint.lightened(0.2), 2.9, 0.62)
		"boss_charge":
			_start_dash(pending_direction, 1.0, 6.0, contact_damage + 10.0, 1.35)
		"boss_cross":
			_emit_projectile_row(pending_direction, 6, 1.0, 14.2, contact_damage * 0.72 + 3.0, "裂", tint.lightened(0.18), 2.8, 0.58)
			var cross_direction := Vector3(-pending_direction.z, 0.0, pending_direction.x)
			if cross_direction.length_squared() <= 0.001:
				cross_direction = Vector3.RIGHT
			_emit_projectile_row(cross_direction.normalized(), 6, 1.0, 14.2, contact_damage * 0.72 + 3.0, "裂", tint.lightened(0.18), 2.8, 0.58)

	pending_action = ""
	pending_direction = Vector3.ZERO


func _start_dash(direction: Vector3, duration: float, speed_multiplier: float, damage_value: float, stun_duration: float) -> void:
	if direction.length_squared() <= 0.001:
		return
	dash_direction = direction.normalized()
	dash_time = duration
	dash_speed_multiplier = speed_multiplier
	dash_damage = damage_value
	dash_stun_time = stun_duration
	dash_hit_ready = true


func _emit_enemy_projectile(direction: Vector3, speed: float, damage_value: float, projectile_glyph: String, projectile_tint: Color, life_time: float, radius: float, stun_duration: float = 0.0) -> void:
	if direction.length_squared() <= 0.001:
		return
	var origin := global_position + Vector3(0.0, hit_radius * 1.05, 0.0) + direction.normalized() * (hit_radius + 0.3)
	request_projectile.emit(origin, direction.normalized(), speed, damage_value, projectile_glyph, projectile_tint, life_time, radius, stun_duration)


func _emit_projectile_row(direction: Vector3, count: int, spacing: float, speed: float, damage_value: float, projectile_glyph: String, projectile_tint: Color, life_time: float, radius: float) -> void:
	if direction.length_squared() <= 0.001:
		return
	var perpendicular := Vector3(-direction.z, 0.0, direction.x)
	if perpendicular.length_squared() <= 0.001:
		perpendicular = Vector3.RIGHT
	perpendicular = perpendicular.normalized()

	for index in range(count):
		var row_offset: float = float(index) - float(count - 1) * 0.5
		var origin := global_position + Vector3(0.0, hit_radius * 1.08, 0.0) + perpendicular * row_offset * spacing
		request_projectile.emit(origin, direction.normalized(), speed, damage_value, projectile_glyph, projectile_tint, life_time, radius, 0.0)


func _face_direction(direction: Vector3, delta: float) -> void:
	if direction.length_squared() <= 0.001:
		return
	var target_yaw: float = atan2(-direction.x, -direction.z)
	rotation.y = lerp_angle(rotation.y, target_yaw, delta * 8.0)


func _build_visuals() -> void:
	body_material = _make_material(tint)
	accent_material = _make_material(tint.lightened(0.15))
	visual_root = Node3D.new()
	add_child(visual_root)

	if enemy_type == "cavalry":
		_build_cavalry_visuals()
	else:
		_build_humanoid_visuals()

	_build_glyph_badge()
	_build_health_bar()


func _build_humanoid_visuals() -> void:
	var head_material := _make_material(tint.lightened(0.06))
	var torso_size := Vector3(0.82, 1.02, 0.52)
	var pelvis_size := Vector3(0.68, 0.22, 0.44)
	var arm_size := Vector3(0.16, 0.72, 0.16)
	var leg_size := Vector3(0.2, 0.78, 0.22)

	if enemy_type == "tank":
		torso_size = Vector3(1.14, 1.18, 0.72)
		pelvis_size = Vector3(0.92, 0.28, 0.58)
		arm_size = Vector3(0.22, 0.84, 0.22)
		leg_size = Vector3(0.26, 0.84, 0.28)
	elif enemy_type == "elite":
		torso_size = Vector3(1.02, 1.24, 0.62)
		pelvis_size = Vector3(0.78, 0.24, 0.52)
		arm_size = Vector3(0.2, 0.8, 0.18)
		leg_size = Vector3(0.24, 0.86, 0.24)
	elif enemy_type == "boss":
		torso_size = Vector3(1.22, 1.42, 0.82)
		pelvis_size = Vector3(0.98, 0.28, 0.62)
		arm_size = Vector3(0.24, 0.92, 0.22)
		leg_size = Vector3(0.28, 0.94, 0.28)
	elif enemy_type == "ritualist":
		torso_size = Vector3(0.74, 1.14, 0.5)
		leg_size = Vector3(0.16, 0.72, 0.18)

	body_node = _add_box_part(torso_size, Vector3(0.0, 1.34, 0.0), body_material)
	_add_box_part(pelvis_size, Vector3(0.0, 0.78, 0.0), accent_material)
	left_arm_node = _add_box_part(arm_size, Vector3(-torso_size.x * 0.58, 1.32, 0.0), accent_material)
	right_arm_node = _add_box_part(arm_size, Vector3(torso_size.x * 0.58, 1.32, 0.0), accent_material)
	left_leg_node = _add_box_part(leg_size, Vector3(-0.18, 0.34, 0.0), body_material)
	right_leg_node = _add_box_part(leg_size, Vector3(0.18, 0.34, 0.0), body_material)

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.28
	if enemy_type == "elite":
		head_mesh.radius = 0.34
	elif enemy_type == "boss":
		head_mesh.radius = 0.42
	head_mesh.height = head_mesh.radius * 2.0
	head.mesh = head_mesh
	var head_height: float = 2.06
	if enemy_type == "elite":
		head_height = 2.18
	elif enemy_type == "boss":
		head_height = 2.42
	head.position = Vector3(0.0, head_height, 0.0)
	head.material_override = head_material
	visual_root.add_child(head)
	head_node = head

	match enemy_type:
		"swift":
			_add_box_part(Vector3(0.56, 0.1, 0.38), Vector3(0.0, 1.7, -0.18), accent_material)
		"tank":
			_add_box_part(Vector3(0.46, 0.26, 0.36), Vector3(-0.54, 1.82, 0.0), accent_material)
			_add_box_part(Vector3(0.46, 0.26, 0.36), Vector3(0.54, 1.82, 0.0), accent_material)
			_add_box_part(Vector3(0.76, 0.12, 0.24), Vector3(0.0, 1.92, -0.26), accent_material)
		"archer":
			var bow := _add_box_part(Vector3(0.08, 1.02, 0.08), Vector3(0.56, 1.24, -0.1), accent_material)
			bow.rotation_degrees.z = 18.0
			_add_box_part(Vector3(0.3, 0.44, 0.18), Vector3(-0.32, 1.44, 0.24), accent_material)
		"assassin":
			_add_box_part(Vector3(0.62, 0.18, 0.48), Vector3(0.0, 1.94, 0.0), accent_material)
			var blade_left := _add_box_part(Vector3(0.06, 0.08, 0.82), Vector3(-0.46, 1.0, -0.42), accent_material)
			blade_left.rotation_degrees.y = 12.0
			var blade_right := _add_box_part(Vector3(0.06, 0.08, 0.82), Vector3(0.46, 1.0, -0.42), accent_material)
			blade_right.rotation_degrees.y = -12.0
		"ritualist":
			var skirt := MeshInstance3D.new()
			var skirt_mesh := CylinderMesh.new()
			skirt_mesh.top_radius = 0.32
			skirt_mesh.bottom_radius = 0.58
			skirt_mesh.height = 0.96
			skirt.mesh = skirt_mesh
			skirt.position = Vector3(0.0, 0.82, 0.0)
			skirt.material_override = body_material
			visual_root.add_child(skirt)
			_add_box_part(Vector3(0.08, 1.18, 0.08), Vector3(0.42, 1.32, -0.28), accent_material)
			var ring := MeshInstance3D.new()
			var ring_mesh := CylinderMesh.new()
			ring_mesh.top_radius = 0.62
			ring_mesh.bottom_radius = 0.72
			ring_mesh.height = 0.06
			ring.mesh = ring_mesh
			ring.position = Vector3(0.0, 0.18, 0.0)
			ring.material_override = accent_material
			visual_root.add_child(ring)
		"elite":
			_add_box_part(Vector3(0.56, 1.04, 0.08), Vector3(0.0, 1.1, 0.34), accent_material)
			_add_box_part(Vector3(0.44, 0.24, 0.34), Vector3(-0.5, 1.82, 0.0), accent_material)
			_add_box_part(Vector3(0.44, 0.24, 0.34), Vector3(0.5, 1.82, 0.0), accent_material)
			for index in range(3):
				_add_box_part(Vector3(0.1, 0.34, 0.1), Vector3(-0.24 + float(index) * 0.24, 2.46, -0.12), accent_material)
		"boss":
			_add_box_part(Vector3(0.72, 1.2, 0.1), Vector3(0.0, 1.18, 0.44), accent_material)
			_add_box_part(Vector3(0.56, 0.24, 0.42), Vector3(-0.64, 1.98, 0.0), accent_material)
			_add_box_part(Vector3(0.56, 0.24, 0.42), Vector3(0.64, 1.98, 0.0), accent_material)
			_add_box_part(Vector3(1.12, 0.12, 0.26), Vector3(0.0, 2.06, -0.26), accent_material)
			for index in range(5):
				_add_box_part(Vector3(0.1, 0.42, 0.1), Vector3(-0.44 + float(index) * 0.22, 2.88, -0.1), accent_material)
			var cape := MeshInstance3D.new()
			var cape_mesh := BoxMesh.new()
			cape_mesh.size = Vector3(1.08, 1.24, 0.08)
			cape.mesh = cape_mesh
			cape.position = Vector3(0.0, 1.18, 0.54)
			cape.material_override = body_material
			visual_root.add_child(cape)


func _build_cavalry_visuals() -> void:
	body_node = _add_box_part(Vector3(1.68, 0.92, 2.38), Vector3(0.0, 0.9, 0.08), body_material)
	_add_box_part(Vector3(0.44, 0.92, 0.52), Vector3(0.0, 1.56, -0.88), accent_material)
	head_node = _add_box_part(Vector3(0.46, 0.36, 0.62), Vector3(0.0, 1.9, -1.34), body_material)
	left_leg_node = _add_box_part(Vector3(0.16, 1.02, 0.18), Vector3(-0.52, 0.3, -0.54), accent_material)
	right_leg_node = _add_box_part(Vector3(0.16, 1.02, 0.18), Vector3(0.52, 0.3, -0.54), accent_material)
	rear_left_leg_node = _add_box_part(Vector3(0.16, 1.02, 0.18), Vector3(-0.52, 0.3, 0.74), accent_material)
	rear_right_leg_node = _add_box_part(Vector3(0.16, 1.02, 0.18), Vector3(0.52, 0.3, 0.74), accent_material)

	_add_box_part(Vector3(0.66, 0.8, 0.46), Vector3(0.0, 1.72, -0.08), accent_material)
	_add_box_part(Vector3(0.42, 0.36, 0.34), Vector3(0.0, 2.26, -0.08), _make_material(tint.lightened(0.08)))
	_add_box_part(Vector3(0.08, 0.08, 1.34), Vector3(0.54, 1.78, -1.0), accent_material)


func _build_glyph_badge() -> void:
	var badge_height := _glyph_badge_height()
	var badge_root := Node3D.new()
	badge_root.position = Vector3(0.0, badge_height, 0.0)
	visual_root.add_child(badge_root)
	glyph_root = badge_root

	var badge_material := StandardMaterial3D.new()
	badge_material.albedo_color = Color(0.04, 0.06, 0.08, 0.86)
	badge_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	badge_material.cull_mode = BaseMaterial3D.CULL_DISABLED

	var ring_material := StandardMaterial3D.new()
	ring_material.albedo_color = Color(accent_material.albedo_color.r, accent_material.albedo_color.g, accent_material.albedo_color.b, 0.46)
	ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_material.cull_mode = BaseMaterial3D.CULL_DISABLED

	var disc := MeshInstance3D.new()
	var disc_mesh := CylinderMesh.new()
	disc_mesh.top_radius = 0.42
	if enemy_type == "elite":
		disc_mesh.top_radius = 0.5
	elif enemy_type == "boss":
		disc_mesh.top_radius = 0.6
	disc_mesh.bottom_radius = disc_mesh.top_radius
	disc_mesh.height = 0.08
	disc.mesh = disc_mesh
	disc.material_override = badge_material
	badge_root.add_child(disc)

	var ring := MeshInstance3D.new()
	var ring_mesh := CylinderMesh.new()
	ring_mesh.top_radius = disc_mesh.top_radius + 0.05
	ring_mesh.bottom_radius = ring_mesh.top_radius
	ring_mesh.height = 0.02
	ring.mesh = ring_mesh
	ring.position = Vector3(0.0, 0.05, 0.0)
	ring.material_override = ring_material
	badge_root.add_child(ring)
	glyph_ring_node = ring

	label_node = Label3D.new()
	label_node.text = glyph
	label_node.font = CJKFont.get_font()
	label_node.font_size = 42
	if enemy_type == "elite":
		label_node.font_size = 50
	elif enemy_type == "boss":
		label_node.font_size = 58
	label_node.position = Vector3(0.0, 0.04, 0.0)
	label_node.modulate = Color(0.98, 0.94, 0.84, 0.98)
	label_node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	badge_root.add_child(label_node)


func _add_box_part(size: Vector3, position: Vector3, material: Material) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = position
	mesh_instance.material_override = material
	visual_root.add_child(mesh_instance)
	return mesh_instance


func _update_visual_state() -> void:
	if hit_flash_time > 0.0:
		body_material.albedo_color = Color(1.0, 0.9, 0.74, 1.0)
	elif windup_time > 0.0:
		body_material.albedo_color = tint.lightened(0.2)
	else:
		body_material.albedo_color = tint

	if dash_time > 0.0:
		accent_material.albedo_color = tint.lightened(0.35)
	else:
		accent_material.albedo_color = tint.lightened(0.16)

	var bob_phase: float = drift_time * (3.2 + gait_amount * 1.8) + float(int(get_instance_id()) % 9) * 0.35
	if visual_root != null:
		visual_root.position.y = sin(bob_phase) * (0.04 + gait_amount * 0.04) + (0.06 if dash_time > 0.0 else 0.0)

	if glyph_root != null:
		var badge_height: float = 2.5
		if enemy_type == "cavalry":
			badge_height = 2.76
		elif enemy_type == "elite":
			badge_height = 2.72
		elif enemy_type == "boss":
			badge_height = 3.04
		glyph_root.position.y = badge_height + sin(drift_time * 1.8 + 0.6) * 0.05
	if glyph_ring_node != null:
		glyph_ring_node.rotation_degrees.y = wrapf(glyph_ring_node.rotation_degrees.y + 1.4 + gait_amount * 2.6, 0.0, 360.0)
	if label_node != null:
		label_node.modulate = Color(0.98, 0.94, 0.84, 0.92 + sin(drift_time * 2.0) * 0.05)

	var gait: float = sin(drift_time * 7.0) * 16.0 * gait_amount
	if enemy_type == "cavalry":
		if body_node != null:
			body_node.rotation_degrees.x = -3.0 - dash_time * 14.0 + sin(drift_time * 6.0) * 2.4 * gait_amount
			body_node.rotation_degrees.z = sin(drift_time * 3.2) * 2.2
		if head_node != null:
			head_node.rotation_degrees.x = 6.0 + sin(drift_time * 6.6 + 0.6) * 6.0
		if left_leg_node != null:
			left_leg_node.rotation_degrees.x = gait
		if right_leg_node != null:
			right_leg_node.rotation_degrees.x = -gait
		if rear_left_leg_node != null:
			rear_left_leg_node.rotation_degrees.x = -gait
		if rear_right_leg_node != null:
			rear_right_leg_node.rotation_degrees.x = gait
		return

	if body_node != null:
		body_node.scale = Vector3.ONE
		body_node.rotation_degrees.z = sin(drift_time * 3.2) * 3.2 * (0.3 + gait_amount)
		body_node.rotation_degrees.x = (-12.0 if dash_time > 0.0 else 0.0) + (-8.0 if windup_time > 0.0 and enemy_type == "archer" else 0.0)
	if head_node != null:
		head_node.rotation_degrees.z = -sin(drift_time * 3.2) * 1.8
	if left_leg_node != null:
		left_leg_node.rotation_degrees.x = gait
	if right_leg_node != null:
		right_leg_node.rotation_degrees.x = -gait
	if left_arm_node != null:
		left_arm_node.rotation_degrees.x = -gait * 0.65
		left_arm_node.rotation_degrees.z = -6.0
	if right_arm_node != null:
		right_arm_node.rotation_degrees.x = gait * 0.65
		right_arm_node.rotation_degrees.z = 6.0

	match enemy_type:
		"archer":
			if right_arm_node != null:
				right_arm_node.rotation_degrees.x = -28.0 - windup_time * 58.0
				right_arm_node.rotation_degrees.y = 12.0
			if left_arm_node != null:
				left_arm_node.rotation_degrees.x = 12.0 + windup_time * 28.0
		"assassin":
			if left_arm_node != null:
				left_arm_node.rotation_degrees.z = -18.0 - dash_time * 24.0
			if right_arm_node != null:
				right_arm_node.rotation_degrees.z = 18.0 + dash_time * 24.0
			if body_node != null:
				body_node.rotation_degrees.x = -10.0 if windup_time > 0.0 or dash_time > 0.0 else 0.0
		"ritualist":
			if left_arm_node != null:
				left_arm_node.rotation_degrees.x = -22.0 + sin(drift_time * 2.4) * 8.0
				left_arm_node.rotation_degrees.z = -18.0
			if right_arm_node != null:
				right_arm_node.rotation_degrees.x = -22.0 + sin(drift_time * 2.4 + 1.1) * 8.0
				right_arm_node.rotation_degrees.z = 18.0
		"elite":
			if body_node != null:
				body_node.scale = Vector3.ONE * (1.0 + sin(drift_time * 2.1) * 0.02)
			if left_arm_node != null:
				left_arm_node.rotation_degrees.z = -10.0 + sin(drift_time * 2.3) * 4.0
			if right_arm_node != null:
				right_arm_node.rotation_degrees.z = 10.0 - sin(drift_time * 2.3) * 4.0
		"boss":
			if body_node != null:
				body_node.scale = Vector3.ONE * (1.02 + sin(drift_time * 2.0) * 0.03)
				body_node.rotation_degrees.x = -6.0 if windup_time > 0.0 or dash_time > 0.0 else 0.0
			if left_arm_node != null:
				left_arm_node.rotation_degrees.z = -16.0 + sin(drift_time * 2.1) * 6.0
				left_arm_node.rotation_degrees.x = -12.0 + windup_time * 14.0
			if right_arm_node != null:
				right_arm_node.rotation_degrees.z = 16.0 - sin(drift_time * 2.1) * 6.0
				right_arm_node.rotation_degrees.x = 12.0 - windup_time * 12.0


func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	material.metallic = 0.05
	material.emission_enabled = true
	material.emission = Color(color.r * 0.12, color.g * 0.12, color.b * 0.12, 1.0)
	return material


func _build_health_bar() -> void:
	health_bar_width = 1.08
	if enemy_type == "tank" or enemy_type == "cavalry":
		health_bar_width = 1.24
	elif enemy_type == "elite":
		health_bar_width = 1.5
	elif enemy_type == "boss":
		health_bar_width = 1.96

	health_bar_root = Node3D.new()
	health_bar_root.position = Vector3(0.0, _health_bar_height(), 0.0)
	health_bar_root.rotation_degrees.x = -58.0
	visual_root.add_child(health_bar_root)

	health_bar_back_material = _make_bar_material(Color(0.04, 0.05, 0.07, 0.72))
	health_bar_fill_material = _make_bar_material(Color(0.32, 0.86, 0.42, 0.96))

	var back := MeshInstance3D.new()
	var back_mesh := BoxMesh.new()
	back_mesh.size = Vector3(health_bar_width + 0.12, 0.14, 0.04)
	back.mesh = back_mesh
	back.material_override = health_bar_back_material
	health_bar_root.add_child(back)

	health_bar_fill_node = MeshInstance3D.new()
	var fill_mesh := BoxMesh.new()
	fill_mesh.size = Vector3(health_bar_width, 0.09, 0.05)
	health_bar_fill_node.mesh = fill_mesh
	health_bar_fill_node.position = Vector3(0.0, 0.0, -0.01)
	health_bar_fill_node.material_override = health_bar_fill_material
	health_bar_root.add_child(health_bar_fill_node)


func _update_health_bar(delta: float) -> void:
	if health_bar_root == null or health_bar_fill_node == null or health_bar_fill_material == null or health_bar_back_material == null:
		return

	if delta <= 0.0:
		display_health = health
	else:
		display_health = move_toward(display_health, health, max(42.0, max_health * 3.4) * delta)

	var ratio: float = 0.0
	if max_health > 0.0:
		ratio = clamp(display_health / max_health, 0.0, 1.0)

	health_bar_root.position.y = _health_bar_height() + sin(drift_time * 1.8 + 0.35) * 0.03
	health_bar_root.rotation_degrees = Vector3(-58.0, -rotation_degrees.y, 0.0)
	health_bar_root.scale = Vector3.ONE * (1.0 + clamp(hit_flash_time / 0.14, 0.0, 1.0) * 0.18)

	health_bar_fill_node.visible = ratio > 0.001
	health_bar_fill_node.scale.x = max(ratio, 0.001)
	health_bar_fill_node.position.x = -health_bar_width * (1.0 - ratio) * 0.5

	var low_health: float = 1.0 - ratio
	var flash_mix: float = clamp(hit_flash_time / 0.14, 0.0, 1.0)
	var base_fill: Color = Color(0.28 + low_health * 0.54, 0.84 - low_health * 0.46, 0.34 - low_health * 0.16, 0.98)
	var fill_color: Color = base_fill.lerp(Color(1.0, 0.82, 0.54, 0.98), flash_mix * 0.68)
	health_bar_fill_material.albedo_color = fill_color
	health_bar_fill_material.emission = Color(fill_color.r * 0.28, fill_color.g * 0.28, fill_color.b * 0.28, 1.0)
	health_bar_back_material.albedo_color = Color(0.04, 0.05, 0.07, 0.7 if ratio < 0.999 else 0.54)


func _glyph_badge_height() -> float:
	var badge_height := 2.5
	if enemy_type == "cavalry":
		badge_height = 2.76
	elif enemy_type == "elite":
		badge_height = 2.72
	elif enemy_type == "boss":
		badge_height = 3.04
	return badge_height


func _health_bar_height() -> float:
	var offset := 0.5
	if enemy_type == "elite":
		offset = 0.56
	elif enemy_type == "boss":
		offset = 0.68
	return _glyph_badge_height() - offset


func _make_bar_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.emission_enabled = true
	material.emission = Color(color.r * 0.18, color.g * 0.18, color.b * 0.18, 1.0)
	return material
