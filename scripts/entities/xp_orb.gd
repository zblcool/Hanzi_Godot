extends Node3D

const CJKFont := preload("res://scripts/core/cjk_font.gd")

signal collected(value: int)

var player = null
var value: int = 1

var hover_time: float = 0.0
var drift_velocity: Vector3 = Vector3.ZERO
var visual_root: Node3D
var shard_root: Node3D
var halo_node: MeshInstance3D
var glyph_label: Label3D


func configure(player_ref, xp_value: int) -> void:
	player = player_ref
	value = xp_value


func _ready() -> void:
	_build_visuals()
	drift_velocity = Vector3(randf_range(-0.9, 0.9), 0.0, randf_range(-0.9, 0.9))
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	hover_time += delta
	position.y = 0.45 + sin(hover_time * 3.2) * 0.16
	if visual_root != null:
		visual_root.rotation_degrees.y += delta * 58.0
		visual_root.scale = Vector3.ONE * (1.0 + sin(hover_time * 7.4) * 0.06)
	if shard_root != null:
		shard_root.rotation_degrees.y -= delta * 84.0
	if halo_node != null:
		halo_node.rotation_degrees.y += delta * 34.0
	if glyph_label != null:
		glyph_label.position.y = 0.12 + sin(hover_time * 5.8) * 0.03

	if not is_instance_valid(player):
		return

	var target: Vector3 = player.global_position + Vector3(0.0, 0.55, 0.0)
	var distance: float = global_position.distance_to(target)
	var attraction_radius: float = 5.0
	if player.has_method("get_collect_radius"):
		attraction_radius = player.get_collect_radius() + 1.8
	if distance < attraction_radius:
		var direction: Vector3 = (target - global_position).normalized()
		global_position += direction * (5.4 + max(0.0, attraction_radius - distance) * 3.5) * delta
	else:
		global_position += drift_velocity * delta
		drift_velocity = drift_velocity.move_toward(Vector3.ZERO, 1.4 * delta)

	if distance < 1.0:
		collected.emit(value)
		queue_free()


func _build_visuals() -> void:
	visual_root = Node3D.new()
	add_child(visual_root)

	var core_material := StandardMaterial3D.new()
	core_material.albedo_color = Color(0.84, 0.98, 1.0, 1.0)
	core_material.emission_enabled = true
	core_material.emission = Color(0.46, 0.9, 1.0, 1.0)
	core_material.roughness = 0.24

	var shard_material := StandardMaterial3D.new()
	shard_material.albedo_color = Color(0.72, 0.98, 1.0, 1.0)
	shard_material.emission_enabled = true
	shard_material.emission = Color(0.34, 0.78, 0.98, 1.0)
	shard_material.roughness = 0.36

	var halo_material := StandardMaterial3D.new()
	halo_material.albedo_color = Color(0.54, 0.92, 1.0, 0.24)
	halo_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	halo_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	halo_material.emission_enabled = true
	halo_material.emission = Color(0.3, 0.76, 0.98, 1.0)

	var orb := MeshInstance3D.new()
	var orb_mesh := SphereMesh.new()
	orb_mesh.radius = 0.18
	orb_mesh.height = 0.36
	orb.mesh = orb_mesh
	orb.material_override = core_material
	visual_root.add_child(orb)

	shard_root = Node3D.new()
	visual_root.add_child(shard_root)
	for index in range(4):
		var shard := MeshInstance3D.new()
		var shard_mesh := BoxMesh.new()
		shard_mesh.size = Vector3(0.16, 0.05, 0.22)
		shard.mesh = shard_mesh
		var angle: float = TAU * float(index) / 4.0
		shard.position = Vector3(cos(angle) * 0.22, 0.0, sin(angle) * 0.22)
		shard.rotation_degrees = Vector3(20.0, rad_to_deg(angle), 34.0)
		shard.material_override = shard_material
		shard_root.add_child(shard)

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
	glyph_label.text = "灵"
	glyph_label.font = CJKFont.get_font()
	glyph_label.font_size = 24
	glyph_label.position = Vector3(0.0, 0.12, 0.0)
	glyph_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	glyph_label.modulate = Color(0.08, 0.14, 0.18, 0.95)
	visual_root.add_child(glyph_label)
