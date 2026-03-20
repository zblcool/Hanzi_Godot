extends CanvasLayer

const CJKFont := preload("res://scripts/core/cjk_font.gd")

signal movement_input_changed(input_vector: Vector2)
signal interact_requested

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

	func _gui_input(event: InputEvent) -> void:
		var local_event := make_input_local(event)
		if local_event is InputEventScreenTouch:
			var touch := local_event as InputEventScreenTouch
			if touch.pressed:
				if drag_pointer == -1 and Rect2(Vector2.ZERO, size).has_point(touch.position):
					drag_pointer = touch.index
					_update_stick(touch.position)
					accept_event()
			elif touch.index == drag_pointer:
				reset_input()
				accept_event()
			return

		if local_event is InputEventScreenDrag:
			var drag := local_event as InputEventScreenDrag
			if drag.index == drag_pointer:
				_update_stick(drag.position)
				accept_event()
			return

		if local_event is InputEventMouseButton:
			var mouse_button := local_event as InputEventMouseButton
			if mouse_button.button_index != MOUSE_BUTTON_LEFT:
				return
			if mouse_button.pressed:
				if Rect2(Vector2.ZERO, size).has_point(mouse_button.position):
					drag_pointer = -2
					_update_stick(mouse_button.position)
					accept_event()
			elif drag_pointer == -2:
				reset_input()
				accept_event()
			return

		if local_event is InputEventMouseMotion and drag_pointer == -2:
			var mouse_motion := local_event as InputEventMouseMotion
			_update_stick(mouse_motion.position)
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


func _ready() -> void:
	ui_font = CJKFont.get_font()
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_build_controls()
	_update_visibility()
	set_process_input(true)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		visible = true


func reset_input() -> void:
	if joystick != null:
		joystick.reset_input()


func _build_controls() -> void:
	joystick = VirtualJoystick.new()
	joystick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	joystick.offset_left = 28.0
	joystick.offset_top = -248.0
	joystick.offset_right = 252.0
	joystick.offset_bottom = -24.0
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


func _on_joystick_vector_changed(input_vector: Vector2) -> void:
	movement_input_changed.emit(input_vector)


func _on_interact_pressed() -> void:
	interact_requested.emit()


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
