extends Node3D

const CJKFont := preload("res://scripts/core/cjk_font.gd")

var pulse_time: float = 0.0
var glow_material: StandardMaterial3D
var label_node: Label3D


func _ready() -> void:
	add_to_group("inkstone")
	_build_visuals()
	set_process(true)


func _process(delta: float) -> void:
	pulse_time += delta
	if glow_material != null:
		glow_material.emission_energy_multiplier = 0.85 + sin(pulse_time * 2.2) * 0.18
	if label_node != null:
		label_node.position.y = 1.45 + sin(pulse_time * 1.8) * 0.05


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

	label_node = Label3D.new()
	label_node.text = "砚"
	label_node.font = CJKFont.get_font()
	label_node.font_size = 38
	label_node.position = Vector3(0.0, 1.45, 0.0)
	label_node.modulate = Color(0.88, 0.93, 1.0, 0.98)
	add_child(label_node)
