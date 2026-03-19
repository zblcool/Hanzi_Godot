extends Node3D

signal activated(message: String)

var player = null
var radius: float = 2.1
var cooldown_time: float = 6.2
var cooldown_remaining: float = 0.0
var material: StandardMaterial3D


func configure(player_ref, bush_radius: float = 2.1) -> void:
	player = player_ref
	radius = bush_radius


func _ready() -> void:
	_build_visuals()
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	cooldown_remaining = max(cooldown_remaining - delta, 0.0)
	if material != null:
		var ready_ratio: float = 1.0
		if cooldown_time > 0.0:
			ready_ratio = 1.0 - cooldown_remaining / cooldown_time
		material.albedo_color = Color(0.18 + ready_ratio * 0.2, 0.34 + ready_ratio * 0.28, 0.22 + ready_ratio * 0.18, 0.94)

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
	var bush_root := Node3D.new()
	add_child(bush_root)

	material = StandardMaterial3D.new()
	material.albedo_color = Color(0.26, 0.56, 0.34, 0.94)
	material.roughness = 1.0

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
