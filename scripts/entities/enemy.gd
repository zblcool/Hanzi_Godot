extends Node3D

const CJKFont := preload("res://scripts/core/cjk_font.gd")

signal defeated(world_position: Vector3, enemy_type: String)
signal request_hazard(target_position: Vector3, radius: float, warning_time: float, active_time: float, damage: float, tint: Color, label: String)

var enemy_type: String = "basic"
var enemy_name: String = "魇卒"
var glyph: String = "魇"
var player = null

var ground_height: float = 0.56
var move_speed: float = 3.6
var max_health: float = 24.0
var health: float = 24.0
var contact_damage: float = 8.0
var preferred_min_distance: float = 8.0
var preferred_max_distance: float = 12.0
var hit_radius: float = 1.0
var tint: Color = Color(0.74, 0.24, 0.2, 1.0)

var attack_cooldown: float = 0.0
var ability_cooldown: float = 0.0
var dash_time: float = 0.0
var hit_flash_time: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO
var is_dead: bool = false

var body_material: StandardMaterial3D
var accent_material: StandardMaterial3D
var label_node: Label3D


func configure(kind: String, difficulty: float, player_ref) -> void:
	enemy_type = kind
	player = player_ref

	match enemy_type:
		"swift":
			enemy_name = "忍"
			glyph = "忍"
			move_speed = 5.7 + difficulty * 0.4
			max_health = 16.0 + difficulty * 6.0
			contact_damage = 7.0 + difficulty * 1.2
			hit_radius = 0.82
			tint = Color(0.88, 0.42, 0.34, 1.0)
		"tank":
			enemy_name = "墨甲"
			glyph = "甲"
			move_speed = 2.8 + difficulty * 0.18
			max_health = 38.0 + difficulty * 12.0
			contact_damage = 12.0 + difficulty * 1.8
			hit_radius = 1.28
			tint = Color(0.45, 0.51, 0.62, 1.0)
		"ritualist":
			enemy_name = "阵师"
			glyph = "阵"
			move_speed = 3.2 + difficulty * 0.2
			max_health = 22.0 + difficulty * 8.0
			contact_damage = 6.0 + difficulty * 1.2
			hit_radius = 0.96
			preferred_min_distance = 8.6
			preferred_max_distance = 12.8
			tint = Color(0.57, 0.37, 0.86, 1.0)
		_:
			enemy_name = "魇卒"
			glyph = "魇"
			move_speed = 3.8 + difficulty * 0.22
			max_health = 24.0 + difficulty * 8.0
			contact_damage = 8.0 + difficulty * 1.35
			hit_radius = 1.02
			tint = Color(0.72, 0.22, 0.18, 1.0)

	health = max_health


func _ready() -> void:
	add_to_group("enemy")
	_build_visuals()
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	if is_dead or not is_instance_valid(player):
		return

	attack_cooldown = max(attack_cooldown - delta, 0.0)
	ability_cooldown = max(ability_cooldown - delta, 0.0)
	dash_time = max(dash_time - delta, 0.0)
	hit_flash_time = max(hit_flash_time - delta, 0.0)

	var motion: Vector3 = Vector3.ZERO
	var player_hidden: bool = false
	if player.has_method("is_hidden_in_bush"):
		player_hidden = player.is_hidden_in_bush()

	if not player_hidden:
		var offset: Vector3 = player.global_position - global_position
		offset.y = 0.0
		var distance: float = offset.length()
		var direction: Vector3 = Vector3.ZERO
		if distance > 0.001:
			direction = offset.normalized()

		match enemy_type:
			"swift":
				if dash_time > 0.0:
					motion = dash_direction * (move_speed * 2.4)
				else:
					motion = direction * move_speed
					if ability_cooldown <= 0.0 and distance < 8.0:
						dash_time = 0.24
						dash_direction = direction
						ability_cooldown = 3.4
			"tank":
				motion = direction * move_speed
			"ritualist":
				if distance < preferred_min_distance:
					motion = -direction * move_speed
				elif distance > preferred_max_distance:
					motion = direction * move_speed
				if ability_cooldown <= 0.0 and distance < 15.0:
					request_hazard.emit(player.global_position, 2.8, 1.05, 2.4, contact_damage * 0.9 + 4.0, tint, "阵")
					ability_cooldown = 4.8
			_:
				motion = direction * move_speed

		if distance < hit_radius + 1.0 and attack_cooldown <= 0.0:
			if player.has_method("receive_damage"):
				player.receive_damage(contact_damage)
			attack_cooldown = 1.0

	global_position += motion * delta
	global_position.y = ground_height

	if motion.length_squared() > 0.01:
		var target_yaw: float = atan2(-motion.x, -motion.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, delta * 8.0)

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


func _build_visuals() -> void:
	body_material = _make_material(tint)
	accent_material = _make_material(tint.lightened(0.15))

	var body := MeshInstance3D.new()
	if enemy_type == "tank":
		var tank_shape := BoxMesh.new()
		tank_shape.size = Vector3(1.8, 1.3, 1.8)
		body.mesh = tank_shape
	else:
		var shape := SphereMesh.new()
		shape.radius = hit_radius
		shape.height = hit_radius * 2.0
		body.mesh = shape
	body.position = Vector3(0.0, hit_radius, 0.0)
	body.material_override = body_material
	add_child(body)

	var crest := MeshInstance3D.new()
	var crest_shape := BoxMesh.new()
	crest_shape.size = Vector3(hit_radius * 0.9, 0.14, hit_radius * 0.42)
	crest.mesh = crest_shape
	crest.position = Vector3(0.0, hit_radius * 1.45, 0.0)
	crest.material_override = accent_material
	add_child(crest)

	label_node = Label3D.new()
	label_node.text = glyph
	label_node.font = CJKFont.get_font()
	label_node.font_size = 40 if enemy_type != "tank" else 46
	label_node.position = Vector3(0.0, hit_radius * 1.4, 0.0)
	label_node.modulate = Color(1.0, 0.95, 0.89, 0.98)
	add_child(label_node)


func _update_visual_state() -> void:
	if hit_flash_time > 0.0:
		body_material.albedo_color = Color(1.0, 0.9, 0.74, 1.0)
	else:
		body_material.albedo_color = tint
	accent_material.albedo_color = tint.lightened(0.16)


func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.84
	return material
