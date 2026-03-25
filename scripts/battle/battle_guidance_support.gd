extends RefCounted


func active_pickups_for_meta(pickups_root: Node, meta_key: String, meta_value: Variant) -> Array[Node3D]:
	var matches: Array[Node3D] = []
	for pickup in pickups_root.get_children():
		if not is_instance_valid(pickup) or pickup.is_queued_for_deletion():
			continue
		if pickup.get_meta(meta_key, null) != meta_value:
			continue
		if pickup is Node3D:
			matches.append(pickup as Node3D)
	return matches


func nearest_pickup_target(candidates: Array[Node3D], reference_position: Vector3) -> Node3D:
	var nearest: Node3D = null
	var nearest_distance: float = INF
	for candidate in candidates:
		var distance: float = reference_position.distance_squared_to(candidate.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = candidate
	return nearest


func objective_target(
	player_position: Vector3,
	pickups_root: Node,
	room_objective_id: String,
	label: String,
	accent: Color
) -> Dictionary:
	var objective_pickup: Node3D = nearest_pickup_target(
		active_pickups_for_meta(pickups_root, "room_objective_id", room_objective_id),
		player_position
	)
	if objective_pickup == null:
		return {}
	return {
		"world_position": objective_pickup.global_position + Vector3(0.0, 1.5, 0.0),
		"text": label,
		"accent": accent
	}


func beacon_target(player_position: Vector3, pickups_root: Node, label: String, accent: Color) -> Dictionary:
	var beacon_pickup: Node3D = nearest_pickup_target(
		active_pickups_for_meta(pickups_root, "chamber_break_beacon", true),
		player_position
	)
	if beacon_pickup == null:
		return {}
	return {
		"world_position": beacon_pickup.global_position + Vector3(0.0, 1.65, 0.0),
		"text": label,
		"accent": accent
	}


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
