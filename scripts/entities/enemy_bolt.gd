extends Node3D

const CJKFont := preload("res://scripts/core/cjk_font.gd")

signal impact(world_position: Vector3, tint: Color, label: String)

var player = null
var direction: Vector3 = Vector3(0.0, 0.0, -1.0)
var speed: float = 14.0
var damage: float = 8.0
var glyph: String = "矢"
var tint: Color = Color(0.94, 0.52, 0.3, 1.0)
var max_life_time: float = 2.4
var hit_radius: float = 0.55
var stun_time: float = 0.0

var life_time: float = 0.0
var visual_root: Node3D
var core_material: StandardMaterial3D
var accent_material: StandardMaterial3D
var halo_material: StandardMaterial3D
var glyph_label: Label3D
var halo_node: MeshInstance3D


func configure(player_ref, origin: Vector3, move_direction: Vector3, speed_value: float, damage_value: float, glyph_value: String, tint_value: Color, lifetime: float, radius_value: float, stun_duration: float = 0.0) -> void:
	player = player_ref
	position = origin
	direction = move_direction.normalized()
	speed = speed_value
	damage = damage_value
	glyph = glyph_value
	tint = tint_value
	max_life_time = lifetime
	hit_radius = radius_value
	stun_time = stun_duration


func _ready() -> void:
	_build_visuals()
	_align_to_direction()
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	life_time += delta
	if visual_root != null:
		visual_root.rotation_degrees.z += delta * 240.0
		visual_root.scale = Vector3.ONE * (1.0 + sin(life_time * 15.0) * 0.06)
	if halo_node != null:
		halo_node.rotation_degrees.y += delta * 140.0
	if glyph_label != null:
		glyph_label.position.y = 0.12 + sin(life_time * 12.0) * 0.025
	if life_time >= max_life_time:
		queue_free()
		return

	if not is_instance_valid(player):
		return

	var distance: float = global_position.distance_to(player.global_position + Vector3(0.0, 0.8, 0.0))
	if distance > hit_radius + 0.75:
		return

	if player.has_method("receive_damage"):
		player.receive_damage(damage)
	if stun_time > 0.0 and player.has_method("apply_stun"):
		player.apply_stun(stun_time)
	impact.emit(global_position, tint, glyph)
	queue_free()


func _build_visuals() -> void:
	visual_root = Node3D.new()
	add_child(visual_root)

	core_material = StandardMaterial3D.new()
	core_material.albedo_color = tint.lightened(0.1)
	core_material.emission_enabled = true
	core_material.emission = tint
	core_material.roughness = 0.36

	accent_material = StandardMaterial3D.new()
	accent_material.albedo_color = Color(0.18, 0.04, 0.04, 1.0)
	accent_material.emission_enabled = true
	accent_material.emission = tint.darkened(0.18)
	accent_material.roughness = 0.44

	halo_material = StandardMaterial3D.new()
	halo_material.albedo_color = Color(tint.r, tint.g, tint.b, 0.22)
	halo_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	halo_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	halo_material.emission_enabled = true
	halo_material.emission = tint

	var core := MeshInstance3D.new()
	var core_mesh := SphereMesh.new()
	core_mesh.radius = 0.18
	core_mesh.height = 0.36
	core.mesh = core_mesh
	core.material_override = core_material
	visual_root.add_child(core)

	var shell := MeshInstance3D.new()
	var shell_mesh := BoxMesh.new()
	shell_mesh.size = Vector3(0.28, 0.28, 0.28)
	shell.mesh = shell_mesh
	shell.rotation_degrees = Vector3(38.0, 0.0, 38.0)
	shell.material_override = accent_material
	visual_root.add_child(shell)

	var tail := MeshInstance3D.new()
	var tail_mesh := BoxMesh.new()
	tail_mesh.size = Vector3(0.08, 0.08, 0.64)
	tail.mesh = tail_mesh
	tail.position = Vector3(0.0, 0.0, 0.34)
	tail.material_override = core_material
	visual_root.add_child(tail)

	var barb_left := MeshInstance3D.new()
	var barb_left_mesh := BoxMesh.new()
	barb_left_mesh.size = Vector3(0.16, 0.04, 0.16)
	barb_left.mesh = barb_left_mesh
	barb_left.position = Vector3(-0.08, 0.0, -0.08)
	barb_left.rotation_degrees.y = 28.0
	barb_left.material_override = accent_material
	visual_root.add_child(barb_left)

	var barb_right := MeshInstance3D.new()
	var barb_right_mesh := BoxMesh.new()
	barb_right_mesh.size = Vector3(0.16, 0.04, 0.16)
	barb_right.mesh = barb_right_mesh
	barb_right.position = Vector3(0.08, 0.0, -0.08)
	barb_right.rotation_degrees.y = -28.0
	barb_right.material_override = accent_material
	visual_root.add_child(barb_right)

	halo_node = MeshInstance3D.new()
	var halo_mesh := CylinderMesh.new()
	halo_mesh.top_radius = 0.28
	halo_mesh.bottom_radius = 0.28
	halo_mesh.height = 0.02
	halo_node.mesh = halo_mesh
	halo_node.rotation_degrees.x = 90.0
	halo_node.material_override = halo_material
	visual_root.add_child(halo_node)

	glyph_label = Label3D.new()
	glyph_label.text = glyph
	glyph_label.font = CJKFont.get_font()
	glyph_label.font_size = 18
	glyph_label.position = Vector3(0.0, 0.12, 0.0)
	glyph_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	glyph_label.modulate = Color(0.18, 0.08, 0.06, 0.94)
	visual_root.add_child(glyph_label)


func _align_to_direction() -> void:
	if direction.length_squared() <= 0.001:
		return
	look_at(global_position + direction, Vector3.UP)
