extends Control

var node_controls: Dictionary = {}
var link_definitions: Array[Dictionary] = []
var active_node_id := ""
var active_lane := ""
var accent := Color(0.66, 0.68, 0.94, 1.0)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_route_data(node_controls_value: Dictionary, link_definitions_value: Array[Dictionary], active_node_id_value: String, active_lane_value: String, accent_value: Color) -> void:
	node_controls = node_controls_value.duplicate(false)
	link_definitions.clear()
	for link_definition in link_definitions_value:
		if link_definition is Dictionary:
			link_definitions.append((link_definition as Dictionary).duplicate(true))
	active_node_id = active_node_id_value
	active_lane = active_lane_value
	accent = accent_value
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	if node_controls.is_empty() or link_definitions.is_empty():
		return

	var layer_origin := get_global_rect().position
	for link_definition in link_definitions:
		var from_control := node_controls.get(String(link_definition.get("from_id", "")), null) as Control
		var to_control := node_controls.get(String(link_definition.get("to_id", "")), null) as Control
		if not is_instance_valid(from_control) or not is_instance_valid(to_control):
			continue

		var start_rect := from_control.get_global_rect()
		var end_rect := to_control.get_global_rect()
		var start := start_rect.position + start_rect.size * 0.5 - layer_origin
		var end := end_rect.position + end_rect.size * 0.5 - layer_origin
		var tone: Color = link_definition.get("tone", accent)
		var highlighted := String(link_definition.get("from_id", "")) == active_node_id or String(link_definition.get("to_id", "")) == active_node_id
		if not highlighted and not active_lane.is_empty():
			highlighted = String(link_definition.get("from_lane", "")) == active_lane or String(link_definition.get("to_lane", "")) == active_lane

		var state := String(link_definition.get("state", "option"))
		var progress_state := String(link_definition.get("progress_state", "locked"))
		var stroke_color := Color(tone.r, tone.g, tone.b, 0.12)
		var stroke_width := 1.8
		if progress_state == "completed":
			stroke_color.a = 0.44
			stroke_width = 3.0
		elif progress_state == "available":
			stroke_color.a = 0.3
			stroke_width = 2.4
		if state == "path" or state == "boss":
			stroke_color.a = maxf(stroke_color.a, 0.26)
			stroke_width = maxf(stroke_width, 3.0)
		if highlighted:
			stroke_color.a = minf(0.72, stroke_color.a + 0.28)
			stroke_width += 1.6

		var shadow_color := Color(0.02, 0.03, 0.04, stroke_color.a * 0.45)
		var curve := _build_curve_points(start, end)
		draw_polyline(curve, shadow_color, stroke_width + 2.0, true)
		draw_polyline(curve, stroke_color, stroke_width, true)

		if highlighted:
			draw_circle(start, stroke_width + 1.0, Color(tone.r, tone.g, tone.b, 0.18))
			draw_circle(end, stroke_width + 1.0, Color(tone.r, tone.g, tone.b, 0.18))


func _build_curve_points(start: Vector2, end: Vector2) -> PackedVector2Array:
	var vertical_span := absf(end.y - start.y)
	var horizontal_span := absf(end.x - start.x)
	var control_push := clampf(vertical_span * 0.42, 28.0, 94.0)
	var side_sway := clampf(horizontal_span * 0.16, 12.0, 52.0) * signf(end.x - start.x)
	var control_a := start + Vector2(side_sway, control_push)
	var control_b := end - Vector2(side_sway, control_push)
	var points := PackedVector2Array()
	for index in range(17):
		var t := float(index) / 16.0
		points.append(_sample_cubic(start, control_a, control_b, end, t))
	return points


func _sample_cubic(start: Vector2, control_a: Vector2, control_b: Vector2, end: Vector2, t: float) -> Vector2:
	var inverse := 1.0 - t
	return (
		start * pow(inverse, 3)
		+ control_a * (3.0 * pow(inverse, 2) * t)
		+ control_b * (3.0 * inverse * t * t)
		+ end * pow(t, 3)
	)
