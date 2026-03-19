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


func configure(origin: Vector3, move_direction: Vector3, damage_value: float, speed_value: float, glyph_value: String, tint_value: Color) -> void:
	position = origin
	direction = move_direction.normalized()
	damage = damage_value
	speed = speed_value
	glyph = glyph_value
	tint = tint_value


func _ready() -> void:
	_build_visuals()
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	life_time += delta
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
	var core := MeshInstance3D.new()
	var core_mesh := SphereMesh.new()
	core_mesh.radius = 0.26
	core_mesh.height = 0.52
	core.mesh = core_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.emission_enabled = true
	material.emission = tint
	core.material_override = material
	add_child(core)

	var label := Label3D.new()
	label.text = glyph
	label.font = CJKFont.get_font()
	label.font_size = 24
	label.position = Vector3(0.0, 0.12, 0.0)
	label.modulate = Color(0.12, 0.09, 0.07, 0.95)
	add_child(label)
