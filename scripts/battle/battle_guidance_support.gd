extends RefCounted


func active_nodes_for_meta(root: Node, meta_key: String, meta_value: Variant) -> Array[Node3D]:
	var matches: Array[Node3D] = []
	for node in root.get_children():
		if not is_instance_valid(node) or node.is_queued_for_deletion():
			continue
		if node.get_meta(meta_key, null) != meta_value:
			continue
		if node is Node3D:
			matches.append(node as Node3D)
	return matches


func active_pickups_for_meta(pickups_root: Node, meta_key: String, meta_value: Variant) -> Array[Node3D]:
	return active_nodes_for_meta(pickups_root, meta_key, meta_value)


func nearest_pickup_target(candidates: Array[Node3D], reference_position: Vector3) -> Node3D:
	var nearest: Node3D = null
	var nearest_distance: float = INF
	for candidate in candidates:
		var distance: float = reference_position.distance_squared_to(candidate.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = candidate
	return nearest


func meta_target(
	player_position: Vector3,
	root: Node,
	meta_key: String,
	meta_value: Variant,
	label: String,
	accent: Color,
	height_offset: float = 1.5
) -> Dictionary:
	var target: Node3D = nearest_pickup_target(
		active_nodes_for_meta(root, meta_key, meta_value),
		player_position
	)
	if target == null:
		return {}
	return {
		"world_position": target.global_position + Vector3(0.0, height_offset, 0.0),
		"text": label,
		"accent": accent
	}


func objective_target(
	player_position: Vector3,
	pickups_root: Node,
	room_objective_id: String,
	label: String,
	accent: Color
) -> Dictionary:
	return meta_target(
		player_position,
		pickups_root,
		"room_objective_id",
		room_objective_id,
		label,
		accent,
		1.5
	)


func beacon_target(player_position: Vector3, pickups_root: Node, label: String, accent: Color) -> Dictionary:
	return meta_target(
		player_position,
		pickups_root,
		"chamber_break_beacon",
		true,
		label,
		accent,
		1.65
	)


func screen_indicator_payload(
	camera: Camera3D,
	viewport_rect: Rect2,
	world_position: Vector3,
	margin: Vector2,
	on_screen_offset: Vector2
) -> Dictionary:
	var screen_position: Vector2 = camera.unproject_position(world_position)
	var viewport_size: Vector2 = viewport_rect.size
	var center: Vector2 = viewport_size * 0.5
	var camera_local_target: Vector3 = camera.global_transform.affine_inverse() * world_position
	var is_behind_camera: bool = camera_local_target.z > 0.0

	if not is_behind_camera and Rect2(margin, viewport_size - margin * 2.0).has_point(screen_position):
		return {
			"screen_position": screen_position + on_screen_offset,
			"arrow_rotation": 0.0,
			"on_screen": true
		}

	var direction: Vector2 = screen_position - center
	if is_behind_camera:
		direction = center - screen_position
	if direction.length_squared() <= 0.001:
		direction = Vector2.UP
	direction = direction.normalized()
	var half_extents: Vector2 = viewport_size * 0.5 - margin
	var scale_x: float = INF if absf(direction.x) <= 0.001 else half_extents.x / absf(direction.x)
	var scale_y: float = INF if absf(direction.y) <= 0.001 else half_extents.y / absf(direction.y)
	var edge_distance: float = minf(scale_x, scale_y)
	return {
		"screen_position": center + direction * edge_distance,
		"arrow_rotation": direction.angle() + PI * 0.5,
		"on_screen": false
	}
