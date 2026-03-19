extends Node3D

const CJKFont := preload("res://scripts/core/cjk_font.gd")

signal health_changed(current: float, maximum: float)
signal defeated
signal fire_projectile(origin: Vector3, direction: Vector3, damage: float, speed: float, glyph: String, tint: Color)
signal request_wave(origin: Vector3, radius: float, damage: float, tint: Color, label: String)
signal request_slash(origin: Vector3, forward: Vector3, radius: float, damage: float, arc_dot: float, tint: Color, label: String)

var hero_id: String = "scholar"
var hero_name: String = "书生"
var hero_title: String = "墨诀远射"
var role: String = "ranged"

var body_color: Color = Color(0.9, 0.88, 0.82, 1.0)
var accent_color: Color = Color(0.9, 0.54, 0.32, 1.0)

var ground_height: float = 0.62
var move_speed: float = 6.0
var base_max_health: float = 100.0
var max_health: float = 100.0
var health: float = 100.0
var attack_range: float = 12.0
var collect_radius: float = 4.0
var base_projectile_speed: float = 20.0
var projectile_speed: float = 20.0

var base_attack_interval: float = 0.58
var base_attack_damage: float = 15.0
var current_attack_interval: float = 0.58
var current_attack_damage: float = 15.0

var extra_projectiles: int = 0
var slash_radius_bonus: float = 0.0
var blade_level: int = 0
var heal_level: int = 0
var wave_level: int = 0
var skill_levels: Dictionary = {}
var word_skill_levels: Dictionary = {}
var max_health_bonus: float = 0.0
var damage_reduction_ratio: float = 0.0

var attack_cooldown: float = 0.0
var invulnerability_time: float = 0.0
var heal_timer: float = 0.0
var wave_timer: float = 0.0
var stealth_time: float = 0.0
var bush_lock_time: float = 0.0
var slash_anim_time: float = 0.0
var is_dead: bool = false

var look_direction: Vector3 = Vector3(0.0, 0.0, -1.0)

var body_mesh: MeshInstance3D
var head_mesh: MeshInstance3D
var weapon_root: Node3D
var weapon_mesh: MeshInstance3D
var accent_mesh: MeshInstance3D
var body_material: StandardMaterial3D
var accent_material: StandardMaterial3D
var weapon_material: StandardMaterial3D


func configure(hero_data: Dictionary) -> void:
	hero_id = String(hero_data["id"])
	hero_name = String(hero_data["name"])
	hero_title = String(hero_data["title"])
	role = String(hero_data["role"])
	body_color = hero_data["body"]
	accent_color = hero_data["accent"]
	move_speed = float(hero_data["move_speed"])
	base_max_health = float(hero_data["max_health"])
	max_health = base_max_health
	health = max_health
	attack_range = float(hero_data["attack_range"])
	base_projectile_speed = float(hero_data["projectile_speed"])
	projectile_speed = base_projectile_speed
	collect_radius = float(hero_data["collect_radius"])
	base_attack_interval = float(hero_data["attack_interval"])
	base_attack_damage = float(hero_data["attack_damage"])
	current_attack_interval = base_attack_interval
	current_attack_damage = base_attack_damage


func _ready() -> void:
	add_to_group("player")
	_build_visuals()
	_apply_skill_levels()
	health_changed.emit(health, max_health)
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_vector := Vector3(input_vector.x, 0.0, input_vector.y)
	if move_vector.length_squared() > 1.0:
		move_vector = move_vector.normalized()
	if move_vector.length_squared() > 0.001:
		look_direction = move_vector.normalized()
		var target_yaw: float = atan2(-look_direction.x, -look_direction.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, delta * 10.0)
	global_position += move_vector * move_speed * delta
	global_position.y = ground_height

	attack_cooldown = max(attack_cooldown - delta, 0.0)
	invulnerability_time = max(invulnerability_time - delta, 0.0)
	stealth_time = max(stealth_time - delta, 0.0)
	bush_lock_time = max(bush_lock_time - delta, 0.0)
	slash_anim_time = max(slash_anim_time - delta, 0.0)

	_handle_passives(delta)
	_try_attack()
	_update_visual_state()


func set_skill_level(recipe_id: String, level: int) -> void:
	skill_levels[recipe_id] = level
	_apply_skill_levels()


func set_word_skill_level(word_id: String, level: int) -> void:
	word_skill_levels[word_id] = level
	_apply_skill_levels()


func apply_blade_upgrade(amount: int = 1) -> void:
	blade_level += amount
	_apply_skill_levels()
	if weapon_mesh != null:
		var scale_x: float = 0.55 + float(blade_level) * (0.18 if role == "melee" else 0.08)
		var scale_z: float = 1.9 + float(blade_level) * (0.34 if role == "melee" else 0.18)
		weapon_mesh.scale = Vector3(scale_x, 1.0, scale_z)


func get_collect_radius() -> float:
	return collect_radius


func can_hide_in_bush() -> bool:
	return bush_lock_time <= 0.0 and stealth_time <= 0.0 and not is_dead


func enter_bush() -> void:
	stealth_time = 2.5
	bush_lock_time = 3.6
	_update_visual_state()


func is_hidden_in_bush() -> bool:
	return stealth_time > 0.0


func receive_damage(amount: float) -> void:
	if is_dead or invulnerability_time > 0.0:
		return
	var adjusted_damage: float = amount * max(0.12, 1.0 - damage_reduction_ratio)
	health = max(0.0, health - adjusted_damage)
	invulnerability_time = 0.42
	health_changed.emit(health, max_health)
	_update_visual_state()
	if health <= 0.0:
		is_dead = true
		defeated.emit()


func heal(amount: float) -> void:
	if is_dead:
		return
	health = min(max_health, health + amount)
	health_changed.emit(health, max_health)


func _handle_passives(delta: float) -> void:
	if heal_level > 0:
		heal_timer -= delta
		if heal_timer <= 0.0:
			heal(1.5 + float(heal_level) * 1.2)
			heal_timer = max(5.4 - float(heal_level) * 0.45, 2.4)

	if wave_level > 0:
		wave_timer -= delta
		if wave_timer <= 0.0:
			var wave_radius: float = 4.8 + float(wave_level) * 0.55
			var wave_damage: float = 12.0 + float(wave_level) * 4.5 + float(blade_level)
			request_wave.emit(global_position, wave_radius, wave_damage, Session.RECIPES["hai"]["color"], "海")
			wave_timer = max(6.8 - float(wave_level) * 0.55, 2.8)


func _try_attack() -> void:
	if attack_cooldown > 0.0:
		return

	var closest_enemy = _find_closest_enemy()
	if closest_enemy == null:
		return

	var target_position: Vector3 = closest_enemy.global_position
	target_position.y = ground_height
	var distance: float = global_position.distance_to(target_position)

	if role == "melee":
		var melee_range: float = attack_range + slash_radius_bonus + float(blade_level) * 0.16
		if distance > melee_range:
			return
		attack_cooldown = current_attack_interval
		slash_anim_time = 0.18
		request_slash.emit(global_position, look_direction, melee_range, current_attack_damage, 0.3, accent_color, "斩")
		return

	if distance > attack_range:
		return

	attack_cooldown = current_attack_interval
	var projectile_count: int = 1 + extra_projectiles
	for index in range(projectile_count):
		var offset: float = float(index) - float(projectile_count - 1) * 0.5
		var direction := (target_position - global_position).normalized()
		direction = direction.rotated(Vector3.UP, offset * 0.1)
		fire_projectile.emit(global_position + Vector3(0.0, 1.0, 0.0) + direction * 1.2, direction, current_attack_damage, projectile_speed, "墨", accent_color)


func _find_closest_enemy():
	var nearest_enemy = null
	var nearest_distance := INF
	for node in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		var distance: float = global_position.distance_squared_to(node.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = node
	return nearest_enemy


func _apply_skill_levels() -> void:
	var ming_level: int = int(skill_levels.get("ming", 0))
	var xiu_level: int = int(skill_levels.get("xiu", 0))
	var hai_level: int = int(skill_levels.get("hai", 0))
	var ming_word_level: int = int(word_skill_levels.get("ming_guang", 0))
	var xiu_word_level: int = int(word_skill_levels.get("xiu_yang", 0))
	var hai_word_level: int = int(word_skill_levels.get("hai_xiao", 0))

	heal_level = xiu_level + xiu_word_level
	wave_level = hai_level + hai_word_level * 2

	max_health_bonus = float(xiu_word_level) * 18.0
	damage_reduction_ratio = float(xiu_word_level) * 0.12
	max_health = base_max_health + max_health_bonus
	health = min(health, max_health)
	projectile_speed = base_projectile_speed + float(blade_level) * 0.8 + float(ming_word_level) * 1.0

	current_attack_damage = base_attack_damage + float(ming_level) * 2.4 + float(wave_level) * 1.2 + float(ming_word_level) * 4.0
	current_attack_interval = max(0.28, base_attack_interval - float(ming_level) * 0.03 - float(ming_word_level) * 0.04)

	if role == "ranged":
		extra_projectiles = ming_level + ming_word_level + int(blade_level / 3)
		slash_radius_bonus = 0.0
	else:
		extra_projectiles = 0
		slash_radius_bonus = float(ming_level) * 0.35 + float(ming_word_level) * 0.5
		current_attack_damage += float(blade_level) * 2.6 + float(ming_word_level) * 2.0
		current_attack_interval = max(0.34, current_attack_interval - float(blade_level) * 0.015)

	if heal_timer <= 0.0:
		heal_timer = max(5.4 - float(heal_level) * 0.45 - float(xiu_word_level) * 0.22, 1.9)
	if wave_timer <= 0.0:
		wave_timer = max(6.8 - float(wave_level) * 0.55 - float(hai_word_level) * 0.45, 2.1)

	health_changed.emit(health, max_health)


func _build_visuals() -> void:
	body_material = _make_material(body_color)
	accent_material = _make_material(accent_color)
	weapon_material = _make_material(accent_color.lightened(0.1))

	body_mesh = MeshInstance3D.new()
	var body_shape := CylinderMesh.new()
	body_shape.top_radius = 0.42
	body_shape.bottom_radius = 0.48
	body_shape.height = 1.0
	body_mesh.mesh = body_shape
	body_mesh.position = Vector3(0.0, 0.55, 0.0)
	body_mesh.material_override = body_material
	add_child(body_mesh)

	head_mesh = MeshInstance3D.new()
	var head_shape := SphereMesh.new()
	head_shape.radius = 0.28
	head_shape.height = 0.56
	head_mesh.mesh = head_shape
	head_mesh.position = Vector3(0.0, 1.26, 0.0)
	head_mesh.material_override = _make_material(body_color.lightened(0.06))
	add_child(head_mesh)

	accent_mesh = MeshInstance3D.new()
	var accent_shape := BoxMesh.new()
	accent_shape.size = Vector3(0.66, 0.12, 0.42)
	accent_mesh.mesh = accent_shape
	accent_mesh.position = Vector3(0.0, 0.9, 0.0)
	accent_mesh.material_override = accent_material
	add_child(accent_mesh)

	weapon_root = Node3D.new()
	weapon_root.position = Vector3(0.45, 0.9, -0.1)
	add_child(weapon_root)

	weapon_mesh = MeshInstance3D.new()
	weapon_root.add_child(weapon_mesh)
	if role == "melee":
		var sword_mesh := BoxMesh.new()
		sword_mesh.size = Vector3(0.12, 0.12, 1.9)
		weapon_mesh.mesh = sword_mesh
		weapon_mesh.position = Vector3(0.0, 0.0, -0.95)
		weapon_mesh.material_override = weapon_material
	else:
		var brush_mesh := BoxMesh.new()
		brush_mesh.size = Vector3(0.14, 0.14, 1.25)
		weapon_mesh.mesh = brush_mesh
		weapon_mesh.position = Vector3(0.0, 0.0, -0.63)
		weapon_mesh.material_override = weapon_material

	var label := Label3D.new()
	label.text = "文" if role == "ranged" else "侠"
	label.font = CJKFont.get_font()
	label.font_size = 44
	label.position = Vector3(0.0, 1.78, 0.0)
	label.modulate = Color(1.0, 0.92, 0.74, 0.96)
	add_child(label)


func _update_visual_state() -> void:
	var current_body: Color = body_color
	var current_accent: Color = accent_color
	if invulnerability_time > 0.0:
		current_body = Color(1.0, 0.82, 0.74, 1.0)
	if stealth_time > 0.0:
		current_body = Color(0.44, 0.6, 0.52, 1.0)
		current_accent = Color(0.6, 0.84, 0.7, 1.0)

	body_material.albedo_color = current_body
	accent_material.albedo_color = current_accent
	weapon_material.albedo_color = current_accent.lightened(0.06)

	if role == "melee":
		if slash_anim_time > 0.0:
			var phase: float = 1.0 - slash_anim_time / 0.18
			weapon_root.rotation_degrees.y = lerp(110.0, -68.0, phase)
		else:
			weapon_root.rotation_degrees.y = 28.0
	else:
		weapon_root.rotation_degrees.y = -20.0 + sin(Time.get_ticks_msec() / 220.0) * 4.0


func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	return material
