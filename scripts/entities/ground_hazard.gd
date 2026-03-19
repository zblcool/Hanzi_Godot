extends Node3D

const CJKFont := preload("res://scripts/core/cjk_font.gd")

var player = null
var radius: float = 2.8
var warning_time: float = 1.0
var active_time: float = 2.4
var damage: float = 8.0
var tint: Color = Color(0.62, 0.26, 0.88, 1.0)
var label: String = "阵"

var elapsed: float = 0.0
var tick_timer: float = 0.0
var telegraph_material: StandardMaterial3D
var active_material: StandardMaterial3D
var active_mesh: MeshInstance3D
var label_node: Label3D
var ring_mesh: MeshInstance3D
var glow_mesh: MeshInstance3D
var shard_root: Node3D


func configure(player_ref, origin: Vector3, hazard_radius: float, warning: float, active_duration: float, damage_value: float, tint_value: Color, label_value: String) -> void:
	player = player_ref
	position = Vector3(origin.x, 0.03, origin.z)
	radius = hazard_radius
	warning_time = warning
	active_time = active_duration
	damage = damage_value
	tint = tint_value
	label = label_value


func _ready() -> void:
	_build_visuals()
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	elapsed += delta
	if ring_mesh != null:
		ring_mesh.rotation_degrees.y += delta * 64.0
	if shard_root != null:
		shard_root.rotation_degrees.y -= delta * 48.0
	if label_node != null:
		label_node.position.y = 0.12 + sin(elapsed * 4.4) * 0.03
	if glow_mesh != null:
		glow_mesh.scale = Vector3.ONE * (0.94 + sin(elapsed * 6.4) * 0.08)
	if elapsed < warning_time:
		var pulse: float = 0.94 + sin(elapsed * 8.0) * 0.08
		scale = Vector3.ONE * pulse
		return

	scale = Vector3.ONE
	if active_mesh != null:
		active_mesh.visible = true
	if telegraph_material != null:
		telegraph_material.albedo_color = Color(tint.r, tint.g, tint.b, 0.22)
	if active_material != null:
		active_material.albedo_color = Color(tint.r, tint.g, tint.b, 0.6)

	if elapsed >= warning_time + active_time:
		queue_free()
		return

	tick_timer -= delta
	if tick_timer > 0.0:
		return
	tick_timer = 0.55

	if not is_instance_valid(player):
		return

	var player_position: Vector3 = player.global_position
	player_position.y = 0.0
	var hazard_position: Vector3 = global_position
	hazard_position.y = 0.0
	if player_position.distance_to(hazard_position) <= radius:
		if player.has_method("receive_damage"):
			player.receive_damage(damage)


func _build_visuals() -> void:
	telegraph_material = StandardMaterial3D.new()
	telegraph_material.albedo_color = Color(tint.r, tint.g, tint.b, 0.34)
	telegraph_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	telegraph_material.cull_mode = BaseMaterial3D.CULL_DISABLED

	active_material = StandardMaterial3D.new()
	active_material.albedo_color = Color(tint.r, tint.g, tint.b, 0.0)
	active_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	active_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	active_material.emission_enabled = true
	active_material.emission = tint.lightened(0.08)

	var warning_disc := MeshInstance3D.new()
	var warning_mesh := CylinderMesh.new()
	warning_mesh.top_radius = radius
	warning_mesh.bottom_radius = radius
	warning_mesh.height = 0.06
	warning_disc.mesh = warning_mesh
	warning_disc.material_override = telegraph_material
	add_child(warning_disc)

	ring_mesh = MeshInstance3D.new()
	var ring_shape := CylinderMesh.new()
	ring_shape.top_radius = radius * 0.9
	ring_shape.bottom_radius = radius * 0.9
	ring_shape.height = 0.025
	ring_mesh.mesh = ring_shape
	ring_mesh.position = Vector3(0.0, 0.02, 0.0)
	ring_mesh.material_override = active_material
	add_child(ring_mesh)

	active_mesh = MeshInstance3D.new()
	var active_shape := CylinderMesh.new()
	active_shape.top_radius = radius * 0.78
	active_shape.bottom_radius = radius * 0.78
	active_shape.height = 0.08
	active_mesh.mesh = active_shape
	active_mesh.material_override = active_material
	active_mesh.position = Vector3(0.0, 0.02, 0.0)
	active_mesh.visible = false
	add_child(active_mesh)

	glow_mesh = MeshInstance3D.new()
	var glow_shape := CylinderMesh.new()
	glow_shape.top_radius = radius * 1.06
	glow_shape.bottom_radius = radius * 1.06
	glow_shape.height = 0.02
	glow_mesh.mesh = glow_shape
	glow_mesh.position = Vector3(0.0, 0.01, 0.0)
	glow_mesh.material_override = telegraph_material
	add_child(glow_mesh)

	shard_root = Node3D.new()
	add_child(shard_root)
	for index in range(4):
		var shard := MeshInstance3D.new()
		var shard_mesh := BoxMesh.new()
		shard_mesh.size = Vector3(0.18, 0.03, 0.42)
		shard.mesh = shard_mesh
		var angle: float = TAU * float(index) / 4.0
		shard.position = Vector3(cos(angle) * radius * 0.56, 0.03, sin(angle) * radius * 0.56)
		shard.rotation_degrees.y = rad_to_deg(angle)
		shard.material_override = active_material
		shard_root.add_child(shard)

	label_node = Label3D.new()
	label_node.text = label
	label_node.font = CJKFont.get_font()
	label_node.font_size = 34
	label_node.position = Vector3(0.0, 0.12, 0.0)
	label_node.modulate = Color(1.0, 0.92, 0.98, 0.96)
	label_node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label_node)
