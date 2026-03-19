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
var stun_time: float = 0.0
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
var head_material: StandardMaterial3D
var trim_material: StandardMaterial3D
var visual_root: Node3D
var torso_root: Node3D
var glyph_root: Node3D
var glyph_label: Label3D
var shoulder_left_mesh: MeshInstance3D
var shoulder_right_mesh: MeshInstance3D
var left_arm_mesh: MeshInstance3D
var right_arm_mesh: MeshInstance3D
var left_leg_mesh: MeshInstance3D
var right_leg_mesh: MeshInstance3D
var waist_mesh: MeshInstance3D
var cloak_mesh: MeshInstance3D
var motion_time: float = 0.0
var move_blend: float = 0.0


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
	if stun_time > 0.0:
		move_vector = Vector3.ZERO
	if move_vector.length_squared() > 1.0:
		move_vector = move_vector.normalized()
	if move_vector.length_squared() > 0.001:
		look_direction = move_vector.normalized()
		var target_yaw: float = atan2(-look_direction.x, -look_direction.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, delta * 10.0)
	move_blend = move_vector.length()
	motion_time += delta * (1.8 + move_blend * 6.0 + (0.9 if stun_time > 0.0 else 0.0))
	global_position += move_vector * move_speed * delta
	global_position.y = ground_height

	attack_cooldown = max(attack_cooldown - delta, 0.0)
	invulnerability_time = max(invulnerability_time - delta, 0.0)
	stealth_time = max(stealth_time - delta, 0.0)
	bush_lock_time = max(bush_lock_time - delta, 0.0)
	slash_anim_time = max(slash_anim_time - delta, 0.0)
	stun_time = max(stun_time - delta, 0.0)

	_handle_passives(delta)
	if stun_time <= 0.0:
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


func apply_stun(duration: float) -> void:
	if is_dead:
		return
	stun_time = max(stun_time, duration)
	_update_visual_state()


func is_stunned() -> bool:
	return stun_time > 0.0


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
	weapon_material = _make_material(accent_color.lightened(0.14))
	head_material = _make_material(body_color.lightened(0.08))
	trim_material = _make_material(Color(0.96, 0.9, 0.8, 1.0))

	visual_root = Node3D.new()
	add_child(visual_root)

	torso_root = Node3D.new()
	visual_root.add_child(torso_root)

	var torso_size := Vector3(0.72, 1.04, 0.46)
	var waist_size := Vector3(0.62, 0.18, 0.4)
	var arm_size := Vector3(0.14, 0.72, 0.16)
	var leg_size := Vector3(0.18, 0.86, 0.2)
	var head_radius: float = 0.28

	if role == "melee":
		torso_size = Vector3(0.82, 1.02, 0.52)
		waist_size = Vector3(0.68, 0.2, 0.42)
		arm_size = Vector3(0.16, 0.78, 0.18)
		leg_size = Vector3(0.2, 0.9, 0.22)
		head_radius = 0.29

	body_mesh = _add_box_part(torso_root, torso_size, Vector3(0.0, 1.3, 0.0), body_material)
	waist_mesh = _add_box_part(torso_root, waist_size, Vector3(0.0, 0.76, 0.0), accent_material)
	accent_mesh = _add_box_part(torso_root, Vector3(torso_size.x * 0.74, 0.14, 0.38), Vector3(0.0, 1.1, 0.16), trim_material)

	shoulder_left_mesh = _add_box_part(torso_root, Vector3(0.22, 0.16, 0.24), Vector3(-torso_size.x * 0.54, 1.72, 0.0), accent_material)
	shoulder_right_mesh = _add_box_part(torso_root, Vector3(0.22, 0.16, 0.24), Vector3(torso_size.x * 0.54, 1.72, 0.0), accent_material)
	left_arm_mesh = _add_box_part(torso_root, arm_size, Vector3(-torso_size.x * 0.58, 1.22, 0.0), accent_material)
	right_arm_mesh = _add_box_part(torso_root, arm_size, Vector3(torso_size.x * 0.58, 1.22, 0.0), accent_material)
	left_leg_mesh = _add_box_part(torso_root, leg_size, Vector3(-0.18, 0.34, 0.0), body_material)
	right_leg_mesh = _add_box_part(torso_root, leg_size, Vector3(0.18, 0.34, 0.0), body_material)

	head_mesh = MeshInstance3D.new()
	var head_shape := SphereMesh.new()
	head_shape.radius = head_radius
	head_shape.height = head_radius * 2.0
	head_mesh.mesh = head_shape
	head_mesh.position = Vector3(0.0, 2.0, 0.02)
	head_mesh.material_override = head_material
	torso_root.add_child(head_mesh)

	if role == "ranged":
		var robe := MeshInstance3D.new()
		var robe_mesh := CylinderMesh.new()
		robe_mesh.top_radius = 0.28
		robe_mesh.bottom_radius = 0.56
		robe_mesh.height = 1.08
		robe.mesh = robe_mesh
		robe.position = Vector3(0.0, 0.78, 0.0)
		robe.material_override = body_material
		visual_root.add_child(robe)
		cloak_mesh = robe
		_add_box_part(torso_root, Vector3(0.18, 0.52, 0.1), Vector3(0.0, 1.3, -0.28), accent_material)
		_add_box_part(torso_root, Vector3(0.12, 0.66, 0.12), Vector3(-0.28, 1.04, 0.16), trim_material)
		_add_box_part(torso_root, Vector3(0.12, 0.66, 0.12), Vector3(0.28, 1.04, 0.16), trim_material)
	else:
		cloak_mesh = _add_box_part(torso_root, Vector3(0.2, 1.0, 0.08), Vector3(0.0, 1.14, 0.34), accent_material)
		_add_box_part(torso_root, Vector3(0.24, 0.86, 0.14), Vector3(-0.5, 1.18, 0.0), trim_material)
		_add_box_part(torso_root, Vector3(0.24, 0.86, 0.14), Vector3(0.5, 1.18, 0.0), trim_material)
		_add_box_part(torso_root, Vector3(0.4, 0.16, 0.28), Vector3(0.0, 1.76, -0.18), accent_material)

	weapon_root = Node3D.new()
	weapon_root.position = Vector3(0.12, 0.06, -0.12)
	right_arm_mesh.add_child(weapon_root)

	weapon_mesh = MeshInstance3D.new()
	weapon_root.add_child(weapon_mesh)
	if role == "melee":
		var sword_mesh := BoxMesh.new()
		sword_mesh.size = Vector3(0.12, 0.12, 1.86)
		weapon_mesh.mesh = sword_mesh
		weapon_mesh.position = Vector3(0.0, -0.14, -0.94)
		weapon_mesh.material_override = weapon_material
		var guard := MeshInstance3D.new()
		var guard_mesh := BoxMesh.new()
		guard_mesh.size = Vector3(0.38, 0.08, 0.08)
		guard.mesh = guard_mesh
		guard.position = Vector3(0.0, -0.12, -0.12)
		guard.material_override = trim_material
		weapon_root.add_child(guard)
	else:
		var brush_mesh := BoxMesh.new()
		brush_mesh.size = Vector3(0.1, 0.1, 1.18)
		weapon_mesh.mesh = brush_mesh
		weapon_mesh.position = Vector3(0.0, -0.08, -0.6)
		weapon_mesh.material_override = trim_material
		var brush_tip := MeshInstance3D.new()
		var brush_tip_mesh := BoxMesh.new()
		brush_tip_mesh.size = Vector3(0.16, 0.16, 0.24)
		brush_tip.mesh = brush_tip_mesh
		brush_tip.position = Vector3(0.0, -0.1, -1.1)
		brush_tip.material_override = weapon_material
		weapon_root.add_child(brush_tip)

	_build_glyph_badge("文" if role == "ranged" else "侠")


func _update_visual_state() -> void:
	var current_body: Color = body_color
	var current_accent: Color = accent_color
	var current_trim: Color = Color(0.96, 0.9, 0.8, 1.0)
	if invulnerability_time > 0.0:
		current_body = Color(1.0, 0.82, 0.74, 1.0)
	if stun_time > 0.0:
		current_body = Color(0.72, 0.76, 0.94, 1.0)
		current_accent = Color(0.48, 0.58, 0.9, 1.0)
		current_trim = Color(0.78, 0.84, 1.0, 1.0)
	if stealth_time > 0.0:
		current_body = Color(0.44, 0.6, 0.52, 1.0)
		current_accent = Color(0.6, 0.84, 0.7, 1.0)
		current_trim = Color(0.82, 0.96, 0.88, 1.0)

	body_material.albedo_color = current_body
	accent_material.albedo_color = current_accent
	weapon_material.albedo_color = current_accent.lightened(0.06)
	head_material.albedo_color = current_body.lightened(0.08)
	trim_material.albedo_color = current_trim

	var bob: float = sin(motion_time * 0.9) * (0.04 + move_blend * 0.03)
	if slash_anim_time > 0.0:
		bob += 0.03
	if visual_root != null:
		visual_root.position.y = bob
	if glyph_root != null:
		glyph_root.position.y = 2.58 + sin(motion_time * 1.2 + 0.6) * 0.05
		glyph_root.rotation_degrees.y = wrapf(glyph_root.rotation_degrees.y + (0.4 + move_blend * 1.6), 0.0, 360.0)

	var gait: float = sin(motion_time * 1.8) * 18.0 * move_blend
	var sway: float = sin(motion_time * 0.9) * 4.5 * (0.3 + move_blend)
	torso_root.rotation_degrees.z = sway * 0.35
	left_leg_mesh.rotation_degrees.x = gait
	right_leg_mesh.rotation_degrees.x = -gait
	left_arm_mesh.rotation_degrees.x = -gait * 0.6
	right_arm_mesh.rotation_degrees.x = gait * 0.45
	left_arm_mesh.rotation_degrees.z = -6.0 - sway * 0.6
	right_arm_mesh.rotation_degrees.z = 6.0 + sway * 0.6
	head_mesh.rotation_degrees.z = -sway * 0.18

	if role == "melee":
		if slash_anim_time > 0.0:
			var phase: float = 1.0 - slash_anim_time / 0.18
			right_arm_mesh.rotation_degrees.x = lerp(44.0, -124.0, phase)
			right_arm_mesh.rotation_degrees.y = lerp(18.0, -74.0, phase)
			weapon_root.rotation_degrees.x = lerp(-18.0, -54.0, phase)
			weapon_root.rotation_degrees.y = lerp(72.0, -42.0, phase)
			weapon_root.rotation_degrees.z = lerp(18.0, -22.0, phase)
		else:
			right_arm_mesh.rotation_degrees.x = -18.0 + gait * 0.3
			right_arm_mesh.rotation_degrees.y = 8.0
			weapon_root.rotation_degrees.x = -18.0
			weapon_root.rotation_degrees.y = 32.0
			weapon_root.rotation_degrees.z = 12.0
	else:
		right_arm_mesh.rotation_degrees.x = -28.0 - move_blend * 8.0 + sin(motion_time * 1.5 + 0.4) * 4.0
		right_arm_mesh.rotation_degrees.y = 10.0 + sin(motion_time * 0.9) * 4.0
		weapon_root.rotation_degrees.x = -12.0 + sin(motion_time * 1.8) * 4.0
		weapon_root.rotation_degrees.y = 18.0 + sin(motion_time * 1.1) * 6.0
		weapon_root.rotation_degrees.z = 8.0

	if cloak_mesh != null:
		cloak_mesh.rotation_degrees.x = 3.0 + sin(motion_time * 1.4 + 0.8) * (3.0 + move_blend * 3.0)
	if accent_mesh != null:
		accent_mesh.rotation_degrees.x = sin(motion_time * 1.2 + 0.2) * 2.4
	if waist_mesh != null:
		waist_mesh.rotation_degrees.y = sin(motion_time * 0.8) * 3.2
	if glyph_label != null:
		glyph_label.modulate = current_trim.lightened(0.02)


func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.8
	material.metallic = 0.06
	material.emission_enabled = true
	material.emission = Color(color.r * 0.16, color.g * 0.16, color.b * 0.16, 1.0)
	return material


func _build_glyph_badge(symbol: String) -> void:
	glyph_root = Node3D.new()
	glyph_root.position = Vector3(0.0, 2.58, 0.0)
	visual_root.add_child(glyph_root)

	var badge_material := StandardMaterial3D.new()
	badge_material.albedo_color = Color(0.03, 0.05, 0.08, 0.86)
	badge_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	badge_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	badge_material.emission_enabled = true
	badge_material.emission = Color(0.04, 0.06, 0.1, 1.0)

	var ring_material := StandardMaterial3D.new()
	ring_material.albedo_color = Color(accent_color.r, accent_color.g, accent_color.b, 0.42)
	ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	ring_material.emission_enabled = true
	ring_material.emission = accent_color.lightened(0.08)

	var disc := MeshInstance3D.new()
	var disc_mesh := CylinderMesh.new()
	disc_mesh.top_radius = 0.34
	disc_mesh.bottom_radius = 0.34
	disc_mesh.height = 0.06
	disc.mesh = disc_mesh
	disc.material_override = badge_material
	glyph_root.add_child(disc)

	var ring := MeshInstance3D.new()
	var ring_mesh := CylinderMesh.new()
	ring_mesh.top_radius = 0.4
	ring_mesh.bottom_radius = 0.4
	ring_mesh.height = 0.02
	ring.mesh = ring_mesh
	ring.position = Vector3(0.0, 0.04, 0.0)
	ring.material_override = ring_material
	glyph_root.add_child(ring)

	glyph_label = Label3D.new()
	glyph_label.text = symbol
	glyph_label.font = CJKFont.get_font()
	glyph_label.font_size = 36
	glyph_label.position = Vector3(0.0, 0.03, 0.0)
	glyph_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	glyph_label.modulate = Color(1.0, 0.95, 0.84, 0.98)
	glyph_root.add_child(glyph_label)


func _add_box_part(parent: Node3D, size: Vector3, box_position: Vector3, material: Material) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = box_position
	mesh_instance.material_override = material
	parent.add_child(mesh_instance)
	return mesh_instance
