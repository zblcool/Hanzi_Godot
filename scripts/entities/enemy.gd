extends Area2D

signal defeated(world_position: Vector2, xp_value: int, enemy_character: String, was_elite: bool)

const CJKFont := preload("res://scripts/cjk_font.gd")

@export var move_speed := 82.0
@export var max_health := 34.0
@export var touch_damage := 8.0
@export var experience_value := 1

var health := 0.0
var target
var character := "魇"
var role_name := ""
var is_elite := false

var contact_cooldown := 0.0
var hit_flash_time := 0.0
var slow_time := 0.0
var slow_strength := 0.0
var knockback_velocity := Vector2.ZERO
var draw_font: Font
var base_color := Color(0.62, 0.15, 0.13, 1.0)
var outline_color := Color(0.95, 0.78, 0.56, 0.9)


func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	draw_font = _build_font()

	if target == null:
		var players = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			target = players[0]

	if base_color == Color(0.62, 0.15, 0.13, 1.0):
		var hue = randf_range(0.0, 0.12)
		base_color = Color.from_hsv(hue, 0.78, 0.74)
	set_physics_process(true)
	queue_redraw()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return

	var offset: Vector2 = target.global_position - global_position
	if offset.length_squared() > 4.0:
		var effective_speed: float = move_speed * (1.0 - clamp(slow_strength, 0.0, 0.75))
		global_position += offset.normalized() * effective_speed * delta

	global_position += knockback_velocity * delta
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 600.0 * delta)

	contact_cooldown = max(contact_cooldown - delta, 0.0)
	hit_flash_time = max(hit_flash_time - delta, 0.0)
	slow_time = max(slow_time - delta, 0.0)
	if slow_time <= 0.0:
		slow_strength = 0.0

	if offset.length() < 30.0 and contact_cooldown <= 0.0:
		contact_cooldown = 0.75
		if target.has_method("receive_hit"):
			target.receive_hit(touch_damage)

	queue_redraw()


func take_damage(amount: float, show_flash: bool = true) -> void:
	health -= amount
	if show_flash:
		hit_flash_time = 0.12
	queue_redraw()

	if health <= 0.0:
		defeated.emit(global_position, experience_value, character, is_elite)
		queue_free()


func apply_slow(amount: float, duration: float) -> void:
	slow_strength = max(slow_strength, amount)
	slow_time = max(slow_time, duration)
	queue_redraw()


func apply_knockback(impulse: Vector2) -> void:
	knockback_velocity += impulse


func _draw() -> void:
	var radius = 18.0
	if is_elite:
		radius = 24.0

	var body_color = base_color
	if slow_strength > 0.0:
		body_color = body_color.lerp(Color(0.42, 0.74, 0.92, 1.0), clamp(slow_strength * 0.7, 0.0, 0.65))
	if hit_flash_time > 0.0:
		body_color = Color(1.0, 0.9, 0.78, 1.0)

	draw_circle(Vector2.ZERO, radius, body_color)
	draw_arc(Vector2.ZERO, radius + 4.0, -PI, PI, 40, outline_color, 2.4)
	if is_elite:
		draw_arc(Vector2.ZERO, radius + 8.0, -PI, PI, 40, Color(1.0, 0.65, 0.24, 0.95), 2.6)

	var health_ratio = 0.0
	if max_health > 0.0:
		health_ratio = clamp(health / max_health, 0.0, 1.0)
	if health_ratio > 0.0:
		draw_arc(Vector2.ZERO, radius + 8.0, -PI * 0.5, -PI * 0.5 + TAU * health_ratio, 26, Color(1.0, 0.84, 0.38, 0.9), 3.0)

	if draw_font != null:
		var font_size = 21
		var glyph_offset = Vector2(-10.0, 8.0)
		if is_elite:
			font_size = 26
			glyph_offset = Vector2(-13.0, 10.0)
		draw_string(draw_font, glyph_offset, character, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, Color(0.98, 0.95, 0.92))
		if is_elite and not role_name.is_empty():
			draw_string(draw_font, Vector2(-22.0, -30.0), role_name, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 15, Color(1.0, 0.85, 0.63, 0.95))


func _build_font() -> Font:
	return CJKFont.get_font()
