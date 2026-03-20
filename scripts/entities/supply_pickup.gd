extends Node3D

const CJKFont := preload("res://scripts/core/cjk_font.gd")

signal collected(world_position: Vector3, supply_id: String, amount: float, tint: Color, label: String)

const SUPPLY_DATA := {
	"paper": {
		"glyph": "纸",
		"title": "残纸",
		"color": Color(0.96, 0.82, 0.58, 1.0),
		"glow": Color(1.0, 0.92, 0.76, 1.0),
		"amount": 3.0
	},
	"ink": {
		"glyph": "墨",
		"title": "墨团",
		"color": Color(0.42, 0.86, 0.92, 1.0),
		"glow": Color(0.18, 0.26, 0.34, 1.0),
		"amount": 16.0
	},
	"seal": {
		"glyph": "印",
		"title": "战印",
		"color": Color(0.94, 0.44, 0.34, 1.0),
		"glow": Color(1.0, 0.76, 0.62, 1.0),
		"amount": 1.0
	}
}

var player = null
var supply_id: String = "paper"
var amount: float = 3.0
var label: String = "纸"
var tint: Color = Color(0.96, 0.82, 0.58, 1.0)
var glow: Color = Color(1.0, 0.92, 0.76, 1.0)

var hover_time: float = 0.0
var drift_velocity: Vector3 = Vector3.ZERO
var visual_root: Node3D
var orbit_root: Node3D
var halo_node: MeshInstance3D
var core_node: MeshInstance3D
var label_node: Label3D
var detail_nodes: Array[Node3D] = []


func configure(player_ref, new_supply_id: String, amount_override: float = -1.0) -> void:
	player = player_ref
	supply_id = new_supply_id if SUPPLY_DATA.has(new_supply_id) else "paper"
	var data: Dictionary = SUPPLY_DATA[supply_id]
	amount = float(data["amount"]) if amount_override < 0.0 else amount_override
	label = String(data["glyph"])
	tint = Color(data["color"])
	glow = Color(data["glow"])


func _ready() -> void:
	_build_visuals()
	drift_velocity = Vector3(randf_range(-0.8, 0.8), 0.0, randf_range(-0.8, 0.8))
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	hover_time += delta
	position.y = 0.45 + sin(hover_time * 2.8 + float(int(get_instance_id()) % 9)) * 0.14
	if visual_root != null:
		visual_root.rotation_degrees.y += delta * (42.0 if supply_id == "paper" else 54.0)
		visual_root.scale = Vector3.ONE * (1.0 + sin(hover_time * 5.6) * 0.05)
	if orbit_root != null:
		orbit_root.rotation_degrees.y -= delta * (78.0 if supply_id == "seal" else 58.0)
	if halo_node != null:
		halo_node.scale = Vector3.ONE * (1.0 + sin(hover_time * 4.2 + 0.5) * 0.08)
	if core_node != null:
		core_node.rotation_degrees.y += delta * 36.0
	if label_node != null:
		label_node.position.y = 0.1 + sin(hover_time * 4.8 + 0.3) * 0.03

	for index in range(detail_nodes.size()):
		var node: Node3D = detail_nodes[index]
		node.position.y = sin(hover_time * 3.2 + float(index) * 0.7) * 0.04
		node.rotation_degrees.y += delta * (42.0 + float(index) * 8.0)

	if not is_instance_valid(player):
		return

	var target: Vector3 = player.global_position + Vector3(0.0, 0.6, 0.0)
	var distance: float = global_position.distance_to(target)
	var attraction_radius: float = 4.6
	if player.has_method("get_collect_radius"):
		attraction_radius = player.get_collect_radius() + 1.1
	if distance < attraction_radius:
		var direction: Vector3 = (target - global_position).normalized()
		global_position += direction * (4.8 + max(0.0, attraction_radius - distance) * 4.8) * delta
	else:
		global_position += drift_velocity * delta
		drift_velocity = drift_velocity.move_toward(Vector3.ZERO, 1.1 * delta)

	if distance < 0.95:
		collected.emit(global_position, supply_id, amount, tint, label)
		queue_free()


func _build_visuals() -> void:
	visual_root = Node3D.new()
	add_child(visual_root)

	orbit_root = Node3D.new()
	visual_root.add_child(orbit_root)

	halo_node = MeshInstance3D.new()
	var halo_mesh := CylinderMesh.new()
	halo_mesh.top_radius = 0.48 if supply_id == "seal" else 0.42
	halo_mesh.bottom_radius = halo_mesh.top_radius
	halo_mesh.height = 0.02
	halo_node.mesh = halo_mesh
	halo_node.rotation_degrees.x = 90.0
	halo_node.material_override = _make_halo_material(tint, glow)
	visual_root.add_child(halo_node)

	match supply_id:
		"ink":
			_build_ink_visuals()
		"seal":
			_build_seal_visuals()
		_:
			_build_paper_visuals()

	label_node = Label3D.new()
	label_node.text = label
	label_node.font = CJKFont.get_font()
	label_node.font_size = 24
	label_node.position = Vector3(0.0, 0.1, 0.0)
	label_node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label_node.modulate = Color(1.0, 0.95, 0.86, 0.96)
	visual_root.add_child(label_node)


func _build_paper_visuals() -> void:
	var core_material := _make_solid_material(Color(0.98, 0.95, 0.86, 1.0), glow)
	var trim_material := _make_solid_material(tint.lightened(0.08), tint.lightened(0.12))

	core_node = MeshInstance3D.new()
	var sheet_mesh := BoxMesh.new()
	sheet_mesh.size = Vector3(0.42, 0.06, 0.54)
	core_node.mesh = sheet_mesh
	core_node.rotation_degrees = Vector3(16.0, 18.0, -8.0)
	core_node.material_override = core_material
	visual_root.add_child(core_node)

	for index in range(3):
		var strip := MeshInstance3D.new()
		var strip_mesh := BoxMesh.new()
		strip_mesh.size = Vector3(0.18, 0.04, 0.28)
		strip.mesh = strip_mesh
		var angle: float = TAU * float(index) / 3.0
		strip.position = Vector3(cos(angle) * 0.24, 0.02, sin(angle) * 0.24)
		strip.rotation_degrees = Vector3(24.0, rad_to_deg(angle) + 36.0, 16.0)
		strip.material_override = trim_material
		orbit_root.add_child(strip)
		detail_nodes.append(strip)


func _build_ink_visuals() -> void:
	var core_material := _make_solid_material(Color(0.12, 0.15, 0.2, 1.0), tint)
	var mote_material := _make_solid_material(tint.lightened(0.1), glow)

	core_node = MeshInstance3D.new()
	var orb_mesh := SphereMesh.new()
	orb_mesh.radius = 0.22
	orb_mesh.height = 0.44
	core_node.mesh = orb_mesh
	core_node.material_override = core_material
	visual_root.add_child(core_node)

	for index in range(4):
		var mote := MeshInstance3D.new()
		var mote_mesh := SphereMesh.new()
		mote_mesh.radius = 0.08
		mote_mesh.height = 0.16
		mote.mesh = mote_mesh
		var angle: float = TAU * float(index) / 4.0
		mote.position = Vector3(cos(angle) * 0.25, 0.02, sin(angle) * 0.25)
		mote.material_override = mote_material
		orbit_root.add_child(mote)
		detail_nodes.append(mote)


func _build_seal_visuals() -> void:
	var core_material := _make_solid_material(tint, glow)
	var cap_material := _make_solid_material(glow, Color(1.0, 0.95, 0.86, 1.0))

	core_node = MeshInstance3D.new()
	var seal_mesh := BoxMesh.new()
	seal_mesh.size = Vector3(0.34, 0.34, 0.34)
	core_node.mesh = seal_mesh
	core_node.rotation_degrees = Vector3(0.0, 22.0, 0.0)
	core_node.material_override = core_material
	visual_root.add_child(core_node)

	var seal_cap := MeshInstance3D.new()
	var cap_mesh := CylinderMesh.new()
	cap_mesh.top_radius = 0.12
	cap_mesh.bottom_radius = 0.16
	cap_mesh.height = 0.24
	seal_cap.mesh = cap_mesh
	seal_cap.position = Vector3(0.0, 0.22, 0.0)
	seal_cap.material_override = cap_material
	visual_root.add_child(seal_cap)

	for index in range(4):
		var shard := MeshInstance3D.new()
		var shard_mesh := BoxMesh.new()
		shard_mesh.size = Vector3(0.12, 0.04, 0.18)
		shard.mesh = shard_mesh
		var angle: float = TAU * float(index) / 4.0
		shard.position = Vector3(cos(angle) * 0.28, 0.02, sin(angle) * 0.28)
		shard.rotation_degrees = Vector3(24.0, rad_to_deg(angle), 0.0)
		shard.material_override = cap_material
		orbit_root.add_child(shard)
		detail_nodes.append(shard)


func _make_solid_material(base_color: Color, emission_color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = base_color
	material.roughness = 0.34
	material.metallic = 0.08
	material.emission_enabled = true
	material.emission = emission_color
	return material


func _make_halo_material(base_color: Color, emission_color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(base_color.r, base_color.g, base_color.b, 0.28)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.roughness = 0.22
	material.emission_enabled = true
	material.emission = emission_color
	return material
