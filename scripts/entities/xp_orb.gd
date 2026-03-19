extends Area2D

signal collected(value: int)

const CJKFont := preload("res://scripts/cjk_font.gd")

@export var value := 1

var player: Area2D
var character := "字"

var drift_velocity := Vector2.ZERO
var draw_font: Font
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	draw_font = _build_font()
	drift_velocity = Vector2(rng.randf_range(-18.0, 18.0), rng.randf_range(-22.0, -6.0))
	area_entered.connect(_on_area_entered)
	set_physics_process(true)
	queue_redraw()


func _physics_process(delta: float) -> void:
	if is_instance_valid(player):
		var offset: Vector2 = player.global_position - global_position
		var distance: float = offset.length()
		if distance <= 180.0:
			var pull_speed: float = 180.0 + max(0.0, 180.0 - distance) * 4.0
			if distance > 1.0:
				global_position += offset.normalized() * pull_speed * delta
		else:
			global_position += drift_velocity * delta
			drift_velocity = drift_velocity.move_toward(Vector2.ZERO, 24.0 * delta)
	else:
		global_position += drift_velocity * delta
		drift_velocity = drift_velocity.move_toward(Vector2.ZERO, 24.0 * delta)

	queue_redraw()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		collected.emit(value)
		queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 10.0, Color(0.48, 0.86, 1.0, 0.95))
	draw_arc(Vector2.ZERO, 13.0, -PI, PI, 20, Color(1.0, 1.0, 1.0, 0.82), 2.0)
	if draw_font != null:
		draw_string(draw_font, Vector2(-8.0, 6.0), character, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, Color(0.04, 0.18, 0.24))


func _build_font() -> Font:
	return CJKFont.get_font()
