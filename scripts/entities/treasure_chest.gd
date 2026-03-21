extends Node3D

const CJKFont := preload("res://scripts/core/cjk_font.gd")

signal opened(world_position: Vector3, drops: Dictionary)

var player = null
var drops: Dictionary = {}
var open_radius: float = 1.85
var is_open: bool = false

var pulse_time: float = 0.0
var body_root: Node3D
var lid_hinge: Node3D
var glow_material: StandardMaterial3D
var ring_material: StandardMaterial3D
var label_node: Label3D
var hint_label: Label3D


func configure(player_ref, new_drops: Dictionary, radius: float = 1.85) -> void:
	player = player_ref
	drops = new_drops.duplicate(true)
	open_radius = radius


func _ready() -> void:
	add_to_group("map_chest")
	_build_visuals()
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	pulse_time += delta

	if glow_material != null:
		var glow_energy: float = 0.28 if is_open else 0.72 + sin(pulse_time * 2.2) * 0.12
		glow_material.emission_energy_multiplier = glow_energy
	if ring_material != null:
		var ring_alpha: float = 0.08 if is_open else 0.18 + sin(pulse_time * 1.8) * 0.04
		ring_material.albedo_color = Color(0.96, 0.78, 0.44, ring_alpha)
		ring_material.emission_energy_multiplier = 0.2 if is_open else 0.5 + sin(pulse_time * 1.6) * 0.08
	if label_node != null:
		label_node.position.y = 1.38 + sin(pulse_time * 1.9) * 0.05
	if hint_label != null:
		hint_label.position.y = 1.82 + sin(pulse_time * 2.1 + 0.45) * 0.04
	if body_root != null and not is_open:
		body_root.rotation_degrees.y = sin(pulse_time * 1.2) * 2.0

	if is_open or not is_instance_valid(player):
		return

	var flat_player: Vector3 = player.global_position
	flat_player.y = 0.0
	var flat_self: Vector3 = global_position
	flat_self.y = 0.0
	if flat_player.distance_to(flat_self) <= open_radius:
		_open_chest()


func _open_chest() -> void:
	is_open = true
	if label_node != null:
		label_node.text = "开"
	if hint_label != null:
		hint_label.text = "已开"

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(lid_hinge, "rotation_degrees:x", -104.0, 0.28)
	tween.tween_property(body_root, "position:y", 0.1, 0.12).from(0.0)
	tween.chain().tween_property(body_root, "position:y", 0.0, 0.16)

	opened.emit(global_position + Vector3(0.0, 0.55, 0.0), drops.duplicate(true))


func _build_visuals() -> void:
	body_root = Node3D.new()
	add_child(body_root)

	var base_material := StandardMaterial3D.new()
	base_material.albedo_color = Color(0.34, 0.22, 0.14, 1.0)
	base_material.roughness = 0.9

	glow_material = StandardMaterial3D.new()
	glow_material.albedo_color = Color(0.86, 0.62, 0.26, 1.0)
	glow_material.roughness = 0.36
	glow_material.metallic = 0.18
	glow_material.emission_enabled = true
	glow_material.emission = Color(1.0, 0.84, 0.52, 1.0)
	glow_material.emission_energy_multiplier = 0.72

	var ring := MeshInstance3D.new()
	var ring_mesh := CylinderMesh.new()
	ring_mesh.top_radius = 1.05
	ring_mesh.bottom_radius = 1.05
	ring_mesh.height = 0.03
	ring.mesh = ring_mesh
	ring.position = Vector3(0.0, 0.03, 0.0)
	ring_material = StandardMaterial3D.new()
	ring_material.albedo_color = Color(0.96, 0.78, 0.44, 0.18)
	ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	ring_material.emission_enabled = true
	ring_material.emission = Color(1.0, 0.82, 0.48, 1.0)
	ring_material.emission_energy_multiplier = 0.5
	ring.material_override = ring_material
	add_child(ring)

	var base := MeshInstance3D.new()
	var base_mesh := BoxMesh.new()
	base_mesh.size = Vector3(1.34, 0.8, 0.96)
	base.mesh = base_mesh
	base.position = Vector3(0.0, 0.4, 0.0)
	base.material_override = base_material
	body_root.add_child(base)

	for side in [-0.48, 0.48]:
		var band := MeshInstance3D.new()
		var band_mesh := BoxMesh.new()
		band_mesh.size = Vector3(0.14, 0.88, 1.02)
		band.mesh = band_mesh
		band.position = Vector3(side, 0.44, 0.0)
		band.material_override = glow_material
		body_root.add_child(band)

	lid_hinge = Node3D.new()
	lid_hinge.position = Vector3(0.0, 0.78, -0.44)
	body_root.add_child(lid_hinge)

	var lid := MeshInstance3D.new()
	var lid_mesh := BoxMesh.new()
	lid_mesh.size = Vector3(1.42, 0.24, 1.0)
	lid.mesh = lid_mesh
	lid.position = Vector3(0.0, 0.0, 0.5)
	lid.material_override = base_material
	lid_hinge.add_child(lid)

	var latch := MeshInstance3D.new()
	var latch_mesh := BoxMesh.new()
	latch_mesh.size = Vector3(0.18, 0.26, 0.08)
	latch.mesh = latch_mesh
	latch.position = Vector3(0.0, -0.2, 0.96)
	latch.material_override = glow_material
	lid_hinge.add_child(latch)

	label_node = Label3D.new()
	label_node.text = "箱"
	label_node.font = CJKFont.get_font()
	label_node.font_size = 32
	label_node.position = Vector3(0.0, 1.38, 0.0)
	label_node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label_node.modulate = Color(1.0, 0.95, 0.86, 0.98)
	add_child(label_node)

	hint_label = Label3D.new()
	hint_label.text = "宝箱"
	hint_label.font = CJKFont.get_font()
	hint_label.font_size = 18
	hint_label.position = Vector3(0.0, 1.82, 0.0)
	hint_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	hint_label.modulate = Color(0.98, 0.9, 0.8, 0.9)
	add_child(hint_label)
