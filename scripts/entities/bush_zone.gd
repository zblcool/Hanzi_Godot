extends Node3D

const CJKFont := preload("res://scripts/core/cjk_font.gd")

signal activated(message: String)

var player = null
var radius: float = 2.1
var cooldown_time: float = 6.2
var cooldown_remaining: float = 0.0
var material: StandardMaterial3D
var ring_material: StandardMaterial3D
var label_node: Label3D
var bush_root: Node3D
var sway_time: float = 0.0


func configure(player_ref, bush_radius: float = 2.1) -> void:
	player = player_ref
	radius = bush_radius


func _ready() -> void:
	_build_visuals()
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	sway_time += delta
	cooldown_remaining = max(cooldown_remaining - delta, 0.0)
	if material != null:
		var ready_ratio: float = 1.0
		if cooldown_time > 0.0:
			ready_ratio = 1.0 - cooldown_remaining / cooldown_time
		material.albedo_color = Color(0.18 + ready_ratio * 0.2, 0.34 + ready_ratio * 0.28, 0.22 + ready_ratio * 0.18, 0.94)
		material.emission_energy_multiplier = 0.18 + ready_ratio * 0.2
	if ring_material != null:
		var ring_alpha: float = 0.22
		if cooldown_time > 0.0:
			ring_alpha = 0.12 + (1.0 - cooldown_remaining / cooldown_time) * 0.18
		ring_material.albedo_color = Color(0.42, 0.82, 0.58, ring_alpha)
	if label_node != null:
		label_node.position.y = 1.82 + sin(sway_time * 2.0) * 0.04
	if bush_root != null:
		bush_root.rotation_degrees.y = sin(sway_time * 1.4) * 5.0

	if not is_instance_valid(player):
		return

	if cooldown_remaining > 0.0:
		return

	if player.has_method("can_hide_in_bush") and not player.can_hide_in_bush():
		return

	var flat_player: Vector3 = player.global_position
	flat_player.y = 0.0
	var flat_self: Vector3 = global_position
	flat_self.y = 0.0
	var distance: float = flat_player.distance_to(flat_self)
	if distance <= radius:
		player.enter_bush()
		cooldown_remaining = cooldown_time
		activated.emit("草丛遮住了身形，字灵会短暂丢失目标。")


func _build_visuals() -> void:
	bush_root = Node3D.new()
	add_child(bush_root)

	material = StandardMaterial3D.new()
	material.albedo_color = Color(0.26, 0.56, 0.34, 0.94)
	material.roughness = 1.0
	material.emission_enabled = true
	material.emission = Color(0.18, 0.42, 0.24, 1.0)
	material.emission_energy_multiplier = 0.18

	var ring := MeshInstance3D.new()
	var ring_mesh := CylinderMesh.new()
	ring_mesh.top_radius = radius * 0.92
	ring_mesh.bottom_radius = radius * 0.92
	ring_mesh.height = 0.04
	ring.mesh = ring_mesh
	ring.position = Vector3(0.0, 0.04, 0.0)
	ring_material = StandardMaterial3D.new()
	ring_material.albedo_color = Color(0.42, 0.82, 0.58, 0.22)
	ring_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	ring_material.emission_enabled = true
	ring_material.emission = Color(0.34, 0.68, 0.42, 1.0)
	ring.material_override = ring_material
	add_child(ring)

	for index in range(5):
		var clump := MeshInstance3D.new()
		var clump_mesh := SphereMesh.new()
		clump_mesh.radius = 0.85
		clump_mesh.height = 1.3
		clump.mesh = clump_mesh
		clump.position = Vector3(
			cos(float(index) * 1.26) * 0.9,
			0.7,
			sin(float(index) * 1.26) * 0.9
		)
		clump.material_override = material
		bush_root.add_child(clump)

	label_node = Label3D.new()
	label_node.text = "隐"
	label_node.font = CJKFont.get_font()
	label_node.font_size = 24
	label_node.position = Vector3(0.0, 1.82, 0.0)
	label_node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label_node.modulate = Color(0.92, 1.0, 0.92, 0.92)
	add_child(label_node)
