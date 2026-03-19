extends Area2D

signal defeated(world_position: Vector2, xp_value: int, enemy_character: String)

const CJKFont := preload("res://scripts/cjk_font.gd")

@export var move_speed := 82.0
@export var max_health := 34.0
@export var touch_damage := 8.0
@export var experience_value := 1

var health := 0.0
var target
var character := "魇"

var contact_cooldown := 0.0
var hit_flash_time := 0.0
var draw_font: Font
var base_color := Color(0.62, 0.15, 0.13, 1.0)
var outline_color := Color(0.95, 0.78, 0.56, 0.9)


func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	draw_font = _build_font()

	if target == null:
		var players := get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			target = players[0]

	var hue := randf_range(0.0, 0.12)
	base_color = Color.from_hsv(hue, 0.78, 0.74)
	set_physics_process(true)
	queue_redraw()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return

	var offset: Vector2 = target.global_position - global_position
	if offset.length_squared() > 4.0:
		global_position += offset.normalized() * move_speed * delta

	contact_cooldown = max(contact_cooldown - delta, 0.0)
	hit_flash_time = max(hit_flash_time - delta, 0.0)

	if offset.length() < 30.0 and contact_cooldown <= 0.0:
		contact_cooldown = 0.75
		if target.has_method("receive_hit"):
			target.receive_hit(touch_damage)

	queue_redraw()


func take_damage(amount: float) -> void:
	health -= amount
	hit_flash_time = 0.12
	queue_redraw()

	if health <= 0.0:
		defeated.emit(global_position, experience_value, character)
		queue_free()


func _draw() -> void:
	var body_color := base_color
	if hit_flash_time > 0.0:
		body_color = Color(1.0, 0.9, 0.78, 1.0)

	draw_circle(Vector2.ZERO, 18.0, body_color)
	draw_arc(Vector2.ZERO, 22.0, -PI, PI, 32, outline_color, 2.0)

	var health_ratio := 0.0
	if max_health > 0.0:
		health_ratio = clamp(health / max_health, 0.0, 1.0)
	if health_ratio > 0.0:
		draw_arc(Vector2.ZERO, 26.0, -PI * 0.5, -PI * 0.5 + TAU * health_ratio, 24, Color(1.0, 0.84, 0.38, 0.9), 3.0)

	if draw_font != null:
		draw_string(draw_font, Vector2(-10.0, 8.0), character, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 21, Color(0.98, 0.95, 0.92))


func _build_font() -> Font:
	return CJKFont.get_font()
