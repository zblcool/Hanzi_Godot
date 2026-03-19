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
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	life_time += delta
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
	var core := MeshInstance3D.new()
	var core_mesh := SphereMesh.new()
	core_mesh.radius = 0.22
	core_mesh.height = 0.44
	core.mesh = core_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.emission_enabled = true
	material.emission = tint
	core.material_override = material
	add_child(core)

	var tail := MeshInstance3D.new()
	var tail_mesh := BoxMesh.new()
	tail_mesh.size = Vector3(0.08, 0.08, 0.46)
	tail.mesh = tail_mesh
	tail.position = Vector3(0.0, 0.0, 0.22)
	tail.material_override = material
	add_child(tail)

	var label := Label3D.new()
	label.text = glyph
	label.font = CJKFont.get_font()
	label.font_size = 20
	label.position = Vector3(0.0, 0.08, 0.0)
	label.modulate = Color(0.14, 0.08, 0.05, 0.94)
	add_child(label)
