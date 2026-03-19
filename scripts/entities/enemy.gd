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
var label_node: Label3D
var body_node: MeshInstance3D


func configure(kind: String, difficulty: float, player_ref) -> void:
	enemy_type = kind
	player = player_ref
	difficulty_scale = difficulty
	strafe_sign = -1.0 if int(get_instance_id()) % 2 == 0 else 1.0
	_apply_type_stats()
	health = max_health


func _ready() -> void:
	add_to_group("enemy")
	_build_visuals()
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

	_update_visual_state()


func take_damage(amount: float) -> void:
	if is_dead:
		return
	health -= amount
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


func _handle_contact_attack(distance: float) -> void:
	if attack_cooldown > 0.0:
		return
	if enemy_type == "archer" or enemy_type == "ritualist":
		return
	if distance > hit_radius + 1.0:
		return
	if player.has_method("receive_damage"):
		player.receive_damage(contact_damage)
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

	body_node = MeshInstance3D.new()
	body_node.mesh = _build_body_mesh()
	body_node.position = Vector3(0.0, hit_radius, 0.0)
	body_node.material_override = body_material
	add_child(body_node)

	var crest := MeshInstance3D.new()
	var crest_shape := BoxMesh.new()
	crest_shape.size = Vector3(hit_radius * 0.9, 0.14, hit_radius * 0.42)
	crest.mesh = crest_shape
	crest.position = Vector3(0.0, hit_radius * 1.48, 0.0)
	crest.material_override = accent_material
	add_child(crest)

	match enemy_type:
		"archer":
			var bow := MeshInstance3D.new()
			var bow_mesh := BoxMesh.new()
			bow_mesh.size = Vector3(0.08, 0.96, 0.08)
			bow.mesh = bow_mesh
			bow.position = Vector3(0.52, hit_radius * 1.02, -0.18)
			bow.rotation_degrees.z = 18.0
			bow.material_override = accent_material
			add_child(bow)
		"assassin":
			var blade := MeshInstance3D.new()
			var blade_mesh := BoxMesh.new()
			blade_mesh.size = Vector3(0.08, 0.08, 0.92)
			blade.mesh = blade_mesh
			blade.position = Vector3(0.42, hit_radius * 0.95, -0.56)
			blade.material_override = accent_material
			add_child(blade)
		"cavalry":
			var rider := MeshInstance3D.new()
			var rider_mesh := BoxMesh.new()
			rider_mesh.size = Vector3(0.7, 0.74, 0.54)
			rider.mesh = rider_mesh
			rider.position = Vector3(0.0, hit_radius * 1.5, -0.1)
			rider.material_override = accent_material
			add_child(rider)
		"ritualist":
			var ring := MeshInstance3D.new()
			var ring_mesh := CylinderMesh.new()
			ring_mesh.top_radius = hit_radius * 0.74
			ring_mesh.bottom_radius = hit_radius * 0.9
			ring_mesh.height = 0.08
			ring.mesh = ring_mesh
			ring.position = Vector3(0.0, 0.22, 0.0)
			ring.material_override = accent_material
			add_child(ring)
		"elite":
			for index in range(3):
				var spike := MeshInstance3D.new()
				var spike_mesh := BoxMesh.new()
				spike_mesh.size = Vector3(0.12, 0.48, 0.12)
				spike.mesh = spike_mesh
				spike.position = Vector3(-0.32 + float(index) * 0.32, hit_radius * 1.9, -0.16)
				spike.material_override = accent_material
				add_child(spike)

	label_node = Label3D.new()
	label_node.text = glyph
	label_node.font = CJKFont.get_font()
	label_node.font_size = 48 if enemy_type == "elite" else (44 if enemy_type == "cavalry" or enemy_type == "tank" else 40)
	label_node.position = Vector3(0.0, hit_radius * 1.45, 0.0)
	label_node.modulate = Color(1.0, 0.95, 0.89, 0.98)
	add_child(label_node)


func _build_body_mesh() -> PrimitiveMesh:
	match enemy_type:
		"tank":
			var mesh := BoxMesh.new()
			mesh.size = Vector3(1.8, 1.3, 1.8)
			return mesh
		"archer":
			var mesh := CylinderMesh.new()
			mesh.top_radius = 0.38
			mesh.bottom_radius = 0.44
			mesh.height = 1.6
			return mesh
		"assassin":
			var mesh := SphereMesh.new()
			mesh.radius = hit_radius
			mesh.height = hit_radius * 2.2
			return mesh
		"cavalry":
			var mesh := BoxMesh.new()
			mesh.size = Vector3(1.8, 1.15, 2.5)
			return mesh
		"ritualist":
			var mesh := SphereMesh.new()
			mesh.radius = hit_radius
			mesh.height = hit_radius * 2.0
			return mesh
		"elite":
			var mesh := CylinderMesh.new()
			mesh.top_radius = 0.76
			mesh.bottom_radius = 1.0
			mesh.height = 2.25
			return mesh
		_:
			var mesh := SphereMesh.new()
			mesh.radius = hit_radius
			mesh.height = hit_radius * 2.0
			return mesh


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


func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.84
	return material
