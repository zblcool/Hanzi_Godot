extends Area2D

signal request_word_bolt(origin: Vector2, direction: Vector2, character: String, damage: float, speed: float)
signal health_changed(current: float, maximum: float)
signal defeated

const CJKFont := preload("res://scripts/cjk_font.gd")
const BOLT_GLYPHS := ["字", "文", "言", "诗", "书", "墨", "印", "诀"]

@export var move_speed := 260.0
@export var max_health := 100.0
@export var attack_interval := 0.72
@export var attack_damage := 20.0
@export var attack_speed := 620.0

var health := 0.0
var attack_cooldown := 0.0
var invulnerability_time := 0.0
var projectiles_per_shot := 1
var glyph_index := 0
var is_defeated := false

var draw_font: Font


func _ready() -> void:
	add_to_group("player")
	health = max_health
	draw_font = _build_font()
	health_changed.emit(health, max_health)
	set_physics_process(true)
	queue_redraw()


func _physics_process(delta: float) -> void:
	if is_defeated:
		return

	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_direction.length_squared() > 1.0:
		input_direction = input_direction.normalized()
	global_position += input_direction * move_speed * delta

	attack_cooldown -= delta
	invulnerability_time = max(invulnerability_time - delta, 0.0)

	if attack_cooldown <= 0.0:
		_fire_at_closest_enemy()

	queue_redraw()


func apply_upgrade(index: int) -> String:
	match index % 4:
		0:
			attack_damage += 6.0
			return "「笔锋」: 字诀伤害 +6"
		1:
			attack_interval = max(0.22, attack_interval - 0.08)
			return "「疾书」: 攻速提升"
		2:
			move_speed += 30.0
			return "「步法」: 移速提升"
		_:
			projectiles_per_shot += 1
			return "「成词」: 每次多发射一个字诀"


func heal(amount: float) -> void:
	health = min(max_health, health + amount)
	health_changed.emit(health, max_health)


func receive_hit(amount: float) -> void:
	if is_defeated or invulnerability_time > 0.0:
		return

	health = max(0.0, health - amount)
	invulnerability_time = 0.45
	health_changed.emit(health, max_health)
	queue_redraw()

	if health <= 0.0:
		is_defeated = true
		defeated.emit()


func _fire_at_closest_enemy() -> void:
	var enemy_nodes := get_tree().get_nodes_in_group("enemies")
	var closest_enemy: Node2D
	var closest_distance := INF

	for enemy in enemy_nodes:
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		var distance := global_position.distance_squared_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy

	if closest_enemy == null:
		return

	attack_cooldown = attack_interval

	var forward: Vector2 = (closest_enemy.global_position - global_position).normalized()
	var spread_step := 0.22
	for index in range(projectiles_per_shot):
		var offset: float = float(index) - float(projectiles_per_shot - 1) * 0.5
		var direction: Vector2 = forward.rotated(offset * spread_step)
		var glyph: String = BOLT_GLYPHS[glyph_index % BOLT_GLYPHS.size()]
		glyph_index += 1
		request_word_bolt.emit(global_position + direction * 24.0, direction, glyph, attack_damage, attack_speed)


func _draw() -> void:
	var body_color := Color(0.96, 0.92, 0.84)
	if invulnerability_time > 0.0:
		body_color = Color(1.0, 0.78, 0.62)

	draw_circle(Vector2.ZERO, 18.0, body_color)
	draw_arc(Vector2.ZERO, 23.0, -PI * 0.85, PI * 0.85, 40, Color(0.78, 0.24, 0.15, 0.95), 3.2)
	draw_circle(Vector2.ZERO, 4.5, Color(0.14, 0.12, 0.11, 0.95))
	if draw_font != null:
		draw_string(draw_font, Vector2(-10.0, 8.0), "文", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 22, Color(0.08, 0.07, 0.07))


func _build_font() -> Font:
	return CJKFont.get_font()
