extends Node3D

const CJKFont := preload("res://scripts/core/cjk_font.gd")

signal impact(world_position: Vector3, tint: Color, label: String)

var direction: Vector3 = Vector3(0.0, 0.0, -1.0)
var speed: float = 20.0
var damage: float = 15.0
var glyph: String = "墨"
var tint: Color = Color(0.92, 0.67, 0.34, 1.0)

var life_time: float = 0.0
var max_life_time: float = 2.0
var hit_radius: float = 0.75
var visual_root: Node3D
var core_material: StandardMaterial3D
var shell_material: StandardMaterial3D
var halo_material: StandardMaterial3D
var tail_material: StandardMaterial3D
var glyph_label: Label3D
var halo_node: MeshInstance3D


func configure(origin: Vector3, move_direction: Vector3, damage_value: float, speed_value: float, glyph_value: String, tint_value: Color) -> void:
	position = origin
	direction = move_direction.normalized()
	damage = damage_value
	speed = speed_value
	glyph = glyph_value
	tint = tint_value


func _ready() -> void:
	_build_visuals()
	_align_to_direction()
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	life_time += delta
	if visual_root != null:
		visual_root.rotation_degrees.z += delta * 320.0
		visual_root.scale = Vector3.ONE * (1.0 + sin(life_time * 18.0) * 0.08)
	if halo_node != null:
		halo_node.rotation_degrees.y += delta * 180.0
	if glyph_label != null:
		glyph_label.position.y = 0.16 + sin(life_time * 16.0) * 0.03
	if life_time >= max_life_time:
		queue_free()
		return

	for node in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		var distance: float = global_position.distance_to(node.global_position)
		var radius: float = 1.0
		if node.has_method("get_hit_radius"):
			radius = node.get_hit_radius()
		if distance <= hit_radius + radius:
			if node.has_method("take_damage"):
				node.take_damage(damage)
			impact.emit(global_position, tint, glyph)
			queue_free()
			return


func _build_visuals() -> void:
	visual_root = Node3D.new()
	add_child(visual_root)

	core_material = StandardMaterial3D.new()
	core_material.albedo_color = Color(0.98, 0.97, 0.92, 1.0)
	core_material.emission_enabled = true
	core_material.emission = tint.lightened(0.32)
	core_material.roughness = 0.28

	shell_material = StandardMaterial3D.new()
	shell_material.albedo_color = tint.lightened(0.12)
	shell_material.emission_enabled = true
	shell_material.emission = tint
	shell_material.roughness = 0.34

	tail_material = StandardMaterial3D.new()
	tail_material.albedo_color = Color(0.92, 0.86, 0.74, 1.0)
	tail_material.emission_enabled = true
	tail_material.emission = tint.lightened(0.18)
	tail_material.roughness = 0.44

	halo_material = StandardMaterial3D.new()
	halo_material.albedo_color = Color(tint.r, tint.g, tint.b, 0.26)
	halo_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	halo_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	halo_material.emission_enabled = true
	halo_material.emission = tint.lightened(0.12)

	var core := MeshInstance3D.new()
	var core_mesh := SphereMesh.new()
	core_mesh.radius = 0.2
	core_mesh.height = 0.4
	core.mesh = core_mesh
	core.material_override = core_material
	visual_root.add_child(core)

	var shell := MeshInstance3D.new()
	var shell_mesh := BoxMesh.new()
	shell_mesh.size = Vector3(0.34, 0.34, 0.34)
	shell.mesh = shell_mesh
	shell.rotation_degrees = Vector3(45.0, 0.0, 45.0)
	shell.material_override = shell_material
	visual_root.add_child(shell)

	var tail_a := MeshInstance3D.new()
	var tail_a_mesh := BoxMesh.new()
	tail_a_mesh.size = Vector3(0.08, 0.08, 0.62)
	tail_a.mesh = tail_a_mesh
	tail_a.position = Vector3(0.0, 0.0, 0.3)
	tail_a.material_override = tail_material
	visual_root.add_child(tail_a)

	var tail_b := MeshInstance3D.new()
	var tail_b_mesh := BoxMesh.new()
	tail_b_mesh.size = Vector3(0.06, 0.24, 0.32)
	tail_b.mesh = tail_b_mesh
	tail_b.position = Vector3(0.0, 0.0, 0.54)
	tail_b.material_override = shell_material
	visual_root.add_child(tail_b)

	halo_node = MeshInstance3D.new()
	var halo_mesh := CylinderMesh.new()
	halo_mesh.top_radius = 0.34
	halo_mesh.bottom_radius = 0.34
	halo_mesh.height = 0.02
	halo_node.mesh = halo_mesh
	halo_node.rotation_degrees.x = 90.0
	halo_node.material_override = halo_material
	visual_root.add_child(halo_node)

	glyph_label = Label3D.new()
	glyph_label.text = glyph
	glyph_label.font = CJKFont.get_font()
	glyph_label.font_size = 22
	glyph_label.position = Vector3(0.0, 0.16, -0.02)
	glyph_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	glyph_label.modulate = Color(0.18, 0.12, 0.08, 0.96)
	visual_root.add_child(glyph_label)


func _align_to_direction() -> void:
	if direction.length_squared() <= 0.001:
		return
	look_at(global_position + direction, Vector3.UP)
