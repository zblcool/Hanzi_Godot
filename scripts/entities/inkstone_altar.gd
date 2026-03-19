extends Node3D

const CJKFont := preload("res://scripts/core/cjk_font.gd")

var pulse_time: float = 0.0
var glow_material: StandardMaterial3D
var ring_material: StandardMaterial3D
var label_node: Label3D
var hint_label: Label3D
var orbit_root: Node3D


func _ready() -> void:
	add_to_group("inkstone")
	_build_visuals()
	set_process(true)


func _process(delta: float) -> void:
	pulse_time += delta
	if glow_material != null:
		glow_material.emission_energy_multiplier = 0.85 + sin(pulse_time * 2.2) * 0.18
	if ring_material != null:
		ring_material.emission_energy_multiplier = 0.66 + sin(pulse_time * 1.8) * 0.16
	if label_node != null:
		label_node.position.y = 1.45 + sin(pulse_time * 1.8) * 0.05
	if hint_label != null:
		hint_label.position.y = 1.9 + sin(pulse_time * 2.1 + 0.6) * 0.04
	if orbit_root != null:
		orbit_root.rotation_degrees.y += delta * 24.0


func _build_visuals() -> void:
	var base := MeshInstance3D.new()
	var base_mesh := BoxMesh.new()
	base_mesh.size = Vector3(1.8, 0.34, 1.3)
	base.mesh = base_mesh
	base.position = Vector3(0.0, 0.18, 0.0)
	var base_material := StandardMaterial3D.new()
	base_material.albedo_color = Color(0.18, 0.18, 0.2, 1.0)
	base_material.roughness = 0.95
	base.material_override = base_material
	add_child(base)

	var halo := MeshInstance3D.new()
	var halo_mesh := CylinderMesh.new()
	halo_mesh.top_radius = 1.18
	halo_mesh.bottom_radius = 1.18
	halo_mesh.height = 0.03
	halo.mesh = halo_mesh
	halo.position = Vector3(0.0, 0.05, 0.0)
	ring_material = StandardMaterial3D.new()
	ring_material.albedo_color = Color(0.26, 0.54, 0.88, 0.16)
	ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	ring_material.emission_enabled = true
	ring_material.emission = Color(0.34, 0.62, 0.94, 1.0)
	ring_material.emission_energy_multiplier = 0.66
	halo.material_override = ring_material
	add_child(halo)

	var plate := MeshInstance3D.new()
	var plate_mesh := CylinderMesh.new()
	plate_mesh.top_radius = 0.48
	plate_mesh.bottom_radius = 0.54
	plate_mesh.height = 0.12
	plate.mesh = plate_mesh
	plate.position = Vector3(0.0, 0.36, 0.0)
	glow_material = StandardMaterial3D.new()
	glow_material.albedo_color = Color(0.09, 0.1, 0.12, 1.0)
	glow_material.emission_enabled = true
	glow_material.emission = Color(0.33, 0.57, 0.88, 1.0)
	glow_material.emission_energy_multiplier = 0.85
	plate.material_override = glow_material
	add_child(plate)

	var slab := MeshInstance3D.new()
	var slab_mesh := BoxMesh.new()
	slab_mesh.size = Vector3(0.96, 0.16, 0.58)
	slab.mesh = slab_mesh
	slab.position = Vector3(0.0, 0.46, 0.0)
	var slab_material := StandardMaterial3D.new()
	slab_material.albedo_color = Color(0.12, 0.12, 0.14, 1.0)
	slab_material.roughness = 0.98
	slab.material_override = slab_material
	add_child(slab)

	orbit_root = Node3D.new()
	add_child(orbit_root)
	for index in range(4):
		var shard := MeshInstance3D.new()
		var shard_mesh := BoxMesh.new()
		shard_mesh.size = Vector3(0.22, 0.06, 0.46)
		shard.mesh = shard_mesh
		var angle: float = TAU * float(index) / 4.0
		shard.position = Vector3(cos(angle) * 0.86, 0.22, sin(angle) * 0.86)
		shard.rotation_degrees.y = rad_to_deg(angle)
		shard.material_override = glow_material
		orbit_root.add_child(shard)

	label_node = Label3D.new()
	label_node.text = "砚"
	label_node.font = CJKFont.get_font()
	label_node.font_size = 38
	label_node.position = Vector3(0.0, 1.45, 0.0)
	label_node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label_node.modulate = Color(0.88, 0.93, 1.0, 0.98)
	add_child(label_node)

	hint_label = Label3D.new()
	hint_label.text = "磨词"
	hint_label.font = CJKFont.get_font()
	hint_label.font_size = 20
	hint_label.position = Vector3(0.0, 1.9, 0.0)
	hint_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	hint_label.modulate = Color(0.98, 0.92, 0.82, 0.9)
	add_child(hint_label)
