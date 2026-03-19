extends Node3D

const CJKFont := preload("res://scripts/core/cjk_font.gd")

var player = null
var length: float = 12.0
var width: float = 1.8
var warning_time: float = 0.8
var active_time: float = 0.4
var damage: float = 0.0
var stun_time: float = 0.0
var tint: Color = Color(0.92, 0.3, 0.28, 1.0)
var label: String = "线"

var elapsed: float = 0.0
var tick_timer: float = 0.0
var warning_material: StandardMaterial3D
var active_material: StandardMaterial3D
var active_mesh: MeshInstance3D
var label_node: Label3D


func configure(player_ref, origin: Vector3, forward: Vector3, hazard_length: float, hazard_width: float, warning: float, active_duration: float, damage_value: float, tint_value: Color, label_value: String, stun_duration: float = 0.0) -> void:
	player = player_ref
	length = hazard_length
	width = hazard_width
	warning_time = warning
	active_time = active_duration
	damage = damage_value
	tint = tint_value
	label = label_value
	stun_time = stun_duration

	var direction := forward.normalized()
	if direction.length_squared() <= 0.001:
		direction = Vector3(0.0, 0.0, -1.0)
	global_position = Vector3(origin.x, 0.03, origin.z) + direction * (length * 0.5)
	look_at(global_position + direction, Vector3.UP)


func _ready() -> void:
	_build_visuals()
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	elapsed += delta
	if elapsed < warning_time:
		var pulse: float = 0.96 + sin(elapsed * 9.0) * 0.06
		scale = Vector3.ONE * pulse
		return

	scale = Vector3.ONE
	active_mesh.visible = true
	warning_material.albedo_color = Color(tint.r, tint.g, tint.b, 0.18)
	active_material.albedo_color = Color(tint.r, tint.g, tint.b, 0.5)

	if elapsed >= warning_time + active_time:
		queue_free()
		return

	if damage <= 0.0 and stun_time <= 0.0:
		return

	tick_timer -= delta
	if tick_timer > 0.0:
		return
	tick_timer = 0.18

	if not is_instance_valid(player):
		return

	var local_point: Vector3 = to_local(player.global_position)
	if abs(local_point.x) > width * 0.5 or abs(local_point.z) > length * 0.5:
		return

	if damage > 0.0 and player.has_method("receive_damage"):
		player.receive_damage(damage)
	if stun_time > 0.0 and player.has_method("apply_stun"):
		player.apply_stun(stun_time)


func _build_visuals() -> void:
	warning_material = StandardMaterial3D.new()
	warning_material.albedo_color = Color(tint.r, tint.g, tint.b, 0.3)
	warning_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	warning_material.cull_mode = BaseMaterial3D.CULL_DISABLED

	active_material = StandardMaterial3D.new()
	active_material.albedo_color = Color(tint.r, tint.g, tint.b, 0.0)
	active_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	active_material.cull_mode = BaseMaterial3D.CULL_DISABLED

	var warning_box := MeshInstance3D.new()
	var warning_mesh := BoxMesh.new()
	warning_mesh.size = Vector3(width, 0.05, length)
	warning_box.mesh = warning_mesh
	warning_box.material_override = warning_material
	add_child(warning_box)

	active_mesh = MeshInstance3D.new()
	var active_shape := BoxMesh.new()
	active_shape.size = Vector3(width * 0.72, 0.08, length)
	active_mesh.mesh = active_shape
	active_mesh.position = Vector3(0.0, 0.02, 0.0)
	active_mesh.material_override = active_material
	active_mesh.visible = false
	add_child(active_mesh)

	label_node = Label3D.new()
	label_node.text = label
	label_node.font = CJKFont.get_font()
	label_node.font_size = 30
	label_node.position = Vector3(0.0, 0.12, 0.0)
	label_node.modulate = Color(1.0, 0.92, 0.9, 0.94)
	add_child(label_node)
