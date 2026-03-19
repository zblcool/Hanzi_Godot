extends Area2D

const CJKFont := preload("res://scripts/cjk_font.gd")

@export var speed := 620.0
@export var damage := 20.0
@export var max_range := 560.0

var direction := Vector2.RIGHT
var character := "字"

var distance_travelled := 0.0
var has_hit := false
var draw_font: Font


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	draw_font = _build_font()
	set_physics_process(true)
	queue_redraw()


func _physics_process(delta: float) -> void:
	if has_hit:
		return

	var motion := direction * speed * delta
	global_position += motion
	distance_travelled += motion.length()
	queue_redraw()

	if distance_travelled >= max_range:
		queue_free()


func _on_area_entered(area) -> void:
	if has_hit:
		return

	if area.has_method("take_damage"):
		has_hit = true
		area.take_damage(damage)
		queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 10.0, Color(1.0, 0.9, 0.56, 0.96))
	draw_arc(Vector2.ZERO, 13.0, -PI, PI, 24, Color(0.9, 0.38, 0.16, 0.9), 2.0)
	if draw_font != null:
		draw_string(draw_font, Vector2(-8.0, 6.0), character, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 18, Color(0.15, 0.09, 0.06))


func _build_font() -> Font:
	return CJKFont.get_font()
