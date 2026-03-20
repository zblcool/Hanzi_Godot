extends CanvasLayer

const CJKFont := preload("res://scripts/core/cjk_font.gd")
const JOYSTICK_SIZE := Vector2(224.0, 224.0)
const JOYSTICK_MARGIN := 28.0
const MOUSE_POINTER_ID := -2

signal movement_input_changed(input_vector: Vector2)
signal interact_requested
signal pause_requested

class VirtualJoystick:
	extends Control

	signal vector_changed(input_vector: Vector2)

	const BASE_RADIUS := 82.0
	const KNOB_RADIUS := 34.0
	const DEADZONE := 0.16

	var drag_pointer := -1
	var stick_vector: Vector2 = Vector2.ZERO

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_STOP
		queue_redraw()

	func _notification(what: int) -> void:
		if what == NOTIFICATION_RESIZED:
			queue_redraw()

	func reset_input() -> void:
		drag_pointer = -1
		if stick_vector != Vector2.ZERO:
			stick_vector = Vector2.ZERO
			vector_changed.emit(stick_vector)
		queue_redraw()

	func is_active() -> bool:
		return drag_pointer != -1

	func is_tracking_pointer(pointer_id: int) -> bool:
		return drag_pointer == pointer_id

	func begin_input(pointer_id: int, local_position: Vector2) -> void:
		drag_pointer = pointer_id
		_update_stick(local_position)

	func update_input(pointer_id: int, local_position: Vector2) -> void:
		if drag_pointer != pointer_id:
			return
		_update_stick(local_position)

	func end_input(pointer_id: int) -> void:
		if drag_pointer == pointer_id:
			reset_input()

	func _gui_input(event: InputEvent) -> void:
		var local_event := make_input_local(event)
		if local_event is InputEventScreenTouch:
			var touch := local_event as InputEventScreenTouch
			if touch.pressed:
				if drag_pointer == -1 and Rect2(Vector2.ZERO, size).has_point(touch.position):
					begin_input(touch.index, touch.position)
					accept_event()
			elif touch.index == drag_pointer:
				end_input(touch.index)
				accept_event()
			return

		if local_event is InputEventScreenDrag:
			var drag := local_event as InputEventScreenDrag
			if drag.index == drag_pointer:
				update_input(drag.index, drag.position)
				accept_event()
			return

		if local_event is InputEventMouseButton:
			var mouse_button := local_event as InputEventMouseButton
			if mouse_button.button_index != MOUSE_BUTTON_LEFT:
				return
			if mouse_button.pressed:
				if Rect2(Vector2.ZERO, size).has_point(mouse_button.position):
					begin_input(MOUSE_POINTER_ID, mouse_button.position)
					accept_event()
			elif drag_pointer == MOUSE_POINTER_ID:
				end_input(MOUSE_POINTER_ID)
				accept_event()
			return

		if local_event is InputEventMouseMotion and drag_pointer == MOUSE_POINTER_ID:
			var mouse_motion := local_event as InputEventMouseMotion
			update_input(MOUSE_POINTER_ID, mouse_motion.position)
			accept_event()

	func _update_stick(local_position: Vector2) -> void:
		var center := size * 0.5
		var delta := local_position - center
		var length := delta.length()
		if length <= 0.001:
			_set_stick_vector(Vector2.ZERO)
			return

		var strength: float = minf(length / BASE_RADIUS, 1.0)
		if strength <= DEADZONE:
			_set_stick_vector(Vector2.ZERO)
			return

		var scaled_strength: float = (strength - DEADZONE) / (1.0 - DEADZONE)
		_set_stick_vector(delta.normalized() * scaled_strength)

	func _set_stick_vector(new_vector: Vector2) -> void:
		new_vector = new_vector.limit_length(1.0)
		if stick_vector.is_equal_approx(new_vector):
			return
		stick_vector = new_vector
		vector_changed.emit(stick_vector)
		queue_redraw()

	func _draw() -> void:
		var center := size * 0.5
		draw_circle(center, BASE_RADIUS, Color(0.02, 0.04, 0.05, 0.34))
		draw_arc(center, BASE_RADIUS, 0.0, TAU, 48, Color(0.92, 0.7, 0.4, 0.42), 4.0)
		draw_circle(center, BASE_RADIUS * 0.4, Color(0.92, 0.7, 0.4, 0.08))

		var knob_center := center + stick_vector * BASE_RADIUS
		draw_circle(knob_center, KNOB_RADIUS, Color(0.95, 0.73, 0.42, 0.9))
		draw_arc(knob_center, KNOB_RADIUS, 0.0, TAU, 40, Color(1.0, 0.95, 0.86, 0.9), 3.0)

var ui_font: Font
var root: Control
var joystick: VirtualJoystick
var interact_button: Button
var pause_button: Button


func _ready() -> void:
	ui_font = CJKFont.get_font()
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_build_controls()
	_update_visibility()
	set_process_input(true)
	set_process_unhandled_input(true)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		visible = true
	if not visible or joystick == null or not joystick.is_active():
		return

	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if not touch.pressed and joystick.is_tracking_pointer(touch.index):
			_release_joystick(touch.index)
			get_viewport().set_input_as_handled()
		return

	if event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if joystick.is_tracking_pointer(drag.index):
			joystick.update_input(drag.index, _to_joystick_local(drag.position))
			get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index != MOUSE_BUTTON_LEFT:
			return
		if not mouse_button.pressed and joystick.is_tracking_pointer(MOUSE_POINTER_ID):
			_release_joystick(MOUSE_POINTER_ID)
			get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseMotion and joystick.is_tracking_pointer(MOUSE_POINTER_ID):
		var mouse_motion := event as InputEventMouseMotion
		joystick.update_input(MOUSE_POINTER_ID, _to_joystick_local(mouse_motion.position))
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or joystick == null or joystick.is_active():
		return

	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_try_start_joystick(touch.index, touch.position)
		return

	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_LEFT and mouse_button.pressed:
			_try_start_joystick(MOUSE_POINTER_ID, mouse_button.position)


func reset_input() -> void:
	if joystick != null:
		joystick.reset_input()
		joystick.visible = false


func _build_controls() -> void:
	joystick = VirtualJoystick.new()
	joystick.set_anchors_preset(Control.PRESET_TOP_LEFT)
	joystick.position = Vector2(JOYSTICK_MARGIN, JOYSTICK_MARGIN)
	joystick.size = JOYSTICK_SIZE
	joystick.custom_minimum_size = JOYSTICK_SIZE
	joystick.visible = false
	joystick.vector_changed.connect(_on_joystick_vector_changed)
	root.add_child(joystick)

	interact_button = Button.new()
	interact_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	interact_button.offset_left = -212.0
	interact_button.offset_top = -104.0
	interact_button.offset_right = -28.0
	interact_button.offset_bottom = -28.0
	interact_button.custom_minimum_size = Vector2(184.0, 76.0)
	interact_button.text = "交互 / 磨词"
	interact_button.add_theme_font_override("font", ui_font)
	interact_button.add_theme_font_size_override("font_size", 20)
	interact_button.add_theme_color_override("font_color", Color(0.96, 0.9, 0.8, 0.98))
	var normal_style := _make_panel_style(Color(0.04, 0.06, 0.08, 0.84), Color(0.28, 0.34, 0.4, 0.7), 28)
	var hover_style := _make_panel_style(Color(0.08, 0.11, 0.14, 0.9), Color(0.92, 0.69, 0.38, 0.82), 28)
	var pressed_style := _make_panel_style(Color(0.1, 0.12, 0.16, 0.94), Color(0.94, 0.7, 0.4, 0.9), 28)
	interact_button.add_theme_stylebox_override("normal", normal_style)
	interact_button.add_theme_stylebox_override("hover", hover_style)
	interact_button.add_theme_stylebox_override("pressed", pressed_style)
	interact_button.add_theme_stylebox_override("focus", hover_style)
	interact_button.pressed.connect(_on_interact_pressed)
	root.add_child(interact_button)

	pause_button = Button.new()
	pause_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	pause_button.offset_left = -140.0
	pause_button.offset_top = 28.0
	pause_button.offset_right = -28.0
	pause_button.offset_bottom = 92.0
	pause_button.custom_minimum_size = Vector2(112.0, 64.0)
	pause_button.text = "暂停"
	pause_button.add_theme_font_override("font", ui_font)
	pause_button.add_theme_font_size_override("font_size", 20)
	pause_button.add_theme_color_override("font_color", Color(0.96, 0.9, 0.8, 0.98))
	pause_button.add_theme_stylebox_override("normal", normal_style)
	pause_button.add_theme_stylebox_override("hover", hover_style)
	pause_button.add_theme_stylebox_override("pressed", pressed_style)
	pause_button.add_theme_stylebox_override("focus", hover_style)
	pause_button.pressed.connect(_on_pause_pressed)
	root.add_child(pause_button)


func _update_visibility() -> void:
	visible = (
		OS.has_feature("web") or
		DisplayServer.is_touchscreen_available() or
		OS.has_feature("mobile") or
		OS.has_feature("android") or
		OS.has_feature("ios") or
		OS.has_feature("web_android") or
		OS.has_feature("web_ios")
	)


func _try_start_joystick(pointer_id: int, screen_position: Vector2) -> void:
	if _is_over_interact_button(screen_position):
		return
	_place_joystick(screen_position)
	joystick.visible = true
	joystick.begin_input(pointer_id, _to_joystick_local(screen_position))
	get_viewport().set_input_as_handled()


func _release_joystick(pointer_id: int) -> void:
	joystick.end_input(pointer_id)
	joystick.visible = false


func _place_joystick(screen_position: Vector2) -> void:
	var desired_position := screen_position - JOYSTICK_SIZE * 0.5
	var viewport_size := get_viewport().get_visible_rect().size
	var max_position := viewport_size - JOYSTICK_SIZE - Vector2(JOYSTICK_MARGIN, JOYSTICK_MARGIN)
	joystick.position = Vector2(
		clamp(desired_position.x, JOYSTICK_MARGIN, max(JOYSTICK_MARGIN, max_position.x)),
		clamp(desired_position.y, JOYSTICK_MARGIN, max(JOYSTICK_MARGIN, max_position.y))
	)


func _to_joystick_local(screen_position: Vector2) -> Vector2:
	return screen_position - joystick.position


func _is_over_interact_button(screen_position: Vector2) -> bool:
	return (
		interact_button != null and interact_button.get_global_rect().has_point(screen_position)
	) or (
		pause_button != null and pause_button.get_global_rect().has_point(screen_position)
	)


func _on_joystick_vector_changed(input_vector: Vector2) -> void:
	movement_input_changed.emit(input_vector)


func _on_interact_pressed() -> void:
	interact_requested.emit()


func _on_pause_pressed() -> void:
	pause_requested.emit()


func _make_panel_style(fill_color: Color, border_color: Color, corner_radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = border_color
	style.corner_radius_top_left = corner_radius
	style.corner_radius_top_right = corner_radius
	style.corner_radius_bottom_right = corner_radius
	style.corner_radius_bottom_left = corner_radius
	return style
