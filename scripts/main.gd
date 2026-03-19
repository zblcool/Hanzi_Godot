extends Node2D

const PLAYER_SCENE := preload("res://scenes/entities/player.tscn")
const ENEMY_SCENE := preload("res://scenes/entities/enemy.tscn")
const WORD_BOLT_SCENE := preload("res://scenes/entities/word_bolt.tscn")
const XP_ORB_SCENE := preload("res://scenes/entities/xp_orb.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")

const ENEMY_GLYPHS := ["魇", "咒", "魅", "祟", "骨", "煞", "夜", "影", "妖", "梦"]
const ORB_GLYPHS := ["字", "文", "墨", "灵"]

@onready var enemies_root: Node2D = $Enemies
@onready var projectiles_root: Node2D = $Projectiles
@onready var pickups_root: Node2D = $Pickups

var player
var hud
var rng := RandomNumberGenerator.new()

var elapsed_time := 0.0
var spawn_timer := 0.0
var spawn_interval := 1.25
var kills := 0
var level := 1
var experience := 0
var experience_target := 6
var upgrade_index := 0
var game_over := false


func _ready() -> void:
	rng.randomize()
	_setup_input_map()
	_spawn_player()
	_spawn_hud()
	_sync_hud()
	hud.show_message("字海求生：移动躲避，自动发射字诀。", 3.0)
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	if game_over:
		if Input.is_action_just_pressed("restart"):
			get_tree().reload_current_scene()
		queue_redraw()
		return

	elapsed_time += delta
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		_spawn_enemy()
		spawn_interval = max(0.32, 1.25 - elapsed_time * 0.02)
		spawn_timer = spawn_interval

	hud.set_runtime(elapsed_time, kills)
	queue_redraw()


func _draw() -> void:
	if player == null:
		return

	var viewport_rect: Rect2 = get_viewport_rect()
	var half_size: Vector2 = viewport_rect.size * 0.75
	var center: Vector2 = player.global_position
	var draw_rect_area := Rect2(center - half_size, half_size * 2.0)
	draw_rect(draw_rect_area, Color(0.06, 0.06, 0.08), true)

	var cell := 64.0
	var major_every := 4
	var start_x: float = floor(draw_rect_area.position.x / cell) * cell
	var end_x: float = draw_rect_area.end.x
	var start_y: float = floor(draw_rect_area.position.y / cell) * cell
	var end_y: float = draw_rect_area.end.y

	var minor_color := Color(0.13, 0.13, 0.17, 0.55)
	var major_color := Color(0.36, 0.25, 0.14, 0.75)

	var x: float = start_x
	while x <= end_x:
		var line_color := minor_color
		if int(round(x / cell)) % major_every == 0:
			line_color = major_color
		draw_line(Vector2(x, start_y), Vector2(x, end_y), line_color, 1.2)
		x += cell

	var y: float = start_y
	while y <= end_y:
		var line_color := minor_color
		if int(round(y / cell)) % major_every == 0:
			line_color = major_color
		draw_line(Vector2(start_x, y), Vector2(end_x, y), line_color, 1.2)
		y += cell

	draw_circle(Vector2.ZERO, 14.0, Color(0.77, 0.31, 0.17, 0.95))
	draw_circle(Vector2.ZERO, 6.0, Color(1.0, 0.86, 0.62, 0.95))


func _spawn_player() -> void:
	player = PLAYER_SCENE.instantiate()
	player.global_position = Vector2.ZERO
	add_child(player)
	player.request_word_bolt.connect(_spawn_word_bolt)
	player.health_changed.connect(Callable(self, "_on_player_health_changed"))
	player.defeated.connect(_on_player_defeated)


func _spawn_hud() -> void:
	hud = HUD_SCENE.instantiate()
	add_child(hud)
	hud.set_tip("WASD / 方向键移动，系统会自动瞄准最近的字灵。")


func _spawn_enemy() -> void:
	if player == null:
		return

	var enemy = ENEMY_SCENE.instantiate()
	var angle := rng.randf_range(0.0, TAU)
	var distance := rng.randf_range(560.0, 760.0)
	enemy.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * distance
	enemy.character = ENEMY_GLYPHS[rng.randi_range(0, ENEMY_GLYPHS.size() - 1)]
	enemy.target = player
	enemy.max_health = 28.0 + elapsed_time * 1.55
	enemy.move_speed = 76.0 + min(110.0, elapsed_time * 1.45)
	enemy.touch_damage = 8.0 + elapsed_time * 0.18
	enemy.experience_value = 1 + int(elapsed_time / 45.0)
	enemy.scale = Vector2.ONE * rng.randf_range(0.92, 1.28)
	enemy.defeated.connect(_on_enemy_defeated)
	enemies_root.add_child(enemy)


func _spawn_word_bolt(origin: Vector2, direction: Vector2, character: String, damage: float, speed: float) -> void:
	var word_bolt = WORD_BOLT_SCENE.instantiate()
	word_bolt.global_position = origin
	word_bolt.direction = direction
	word_bolt.character = character
	word_bolt.damage = damage
	word_bolt.speed = speed
	projectiles_root.add_child(word_bolt)


func _on_enemy_defeated(world_position: Vector2, xp_value: int, enemy_character: String) -> void:
	kills += 1

	var orb = XP_ORB_SCENE.instantiate()
	orb.global_position = world_position
	orb.player = player
	orb.value = xp_value
	orb.character = ORB_GLYPHS[rng.randi_range(0, ORB_GLYPHS.size() - 1)]
	orb.collected.connect(_on_orb_collected)
	pickups_root.add_child(orb)

	if kills % 18 == 0:
		hud.show_message("字潮加剧：敌群更密了。", 2.2)


func _on_orb_collected(value: int) -> void:
	experience += value
	while experience >= experience_target:
		experience -= experience_target
		level += 1
		experience_target = int(round(experience_target * 1.35)) + 3
		var upgrade_text: String = player.apply_upgrade(upgrade_index)
		upgrade_index += 1
		player.heal(10.0)
		hud.show_message("领悟 %s" % upgrade_text, 2.8)

	_sync_hud()


func _on_player_health_changed(current: float, maximum: float) -> void:
	hud.set_health(current, maximum)


func _on_player_defeated() -> void:
	game_over = true
	hud.set_game_over(true)


func _sync_hud() -> void:
	if player != null:
		hud.set_health(player.health, player.max_health)
	hud.set_progress(experience, experience_target, level)
	hud.set_runtime(elapsed_time, kills)


func _setup_input_map() -> void:
	_ensure_action("move_up", [KEY_W, KEY_UP])
	_ensure_action("move_down", [KEY_S, KEY_DOWN])
	_ensure_action("move_left", [KEY_A, KEY_LEFT])
	_ensure_action("move_right", [KEY_D, KEY_RIGHT])
	_ensure_action("restart", [KEY_R])


func _ensure_action(action_name: StringName, keycodes: Array[int]) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	if InputMap.action_get_events(action_name).is_empty():
		for keycode in keycodes:
			var event := InputEventKey.new()
			event.physical_keycode = keycode
			InputMap.action_add_event(action_name, event)
