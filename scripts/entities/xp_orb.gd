extends Node3D

const CJKFont := preload("res://scripts/core/cjk_font.gd")

signal collected(value: int)

var player = null
var value: int = 1

var hover_time: float = 0.0
var drift_velocity: Vector3 = Vector3.ZERO


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
	var orb := MeshInstance3D.new()
	var orb_mesh := SphereMesh.new()
	orb_mesh.radius = 0.28
	orb_mesh.height = 0.56
	orb.mesh = orb_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.48, 0.88, 1.0, 1.0)
	material.emission_enabled = true
	material.emission = Color(0.28, 0.72, 0.96, 1.0)
	orb.material_override = material
	add_child(orb)

	var label := Label3D.new()
	label.text = "灵"
	label.font = CJKFont.get_font()
	label.font_size = 26
	label.position = Vector3(0.0, 0.08, 0.0)
	label.modulate = Color(0.08, 0.14, 0.18, 0.95)
	add_child(label)
