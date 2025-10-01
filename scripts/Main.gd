extends Node2D

@onready var cannon: Node2D = $Cannon
@onready var bucket: Node2D = $Bucket
@onready var peg_container: Node2D = $Pegs
@onready var ui: CanvasLayer = $UI

const PEG_SCENE := null # we spawn pegs procedurally
const BALL_SCENE := null # we spawn balls procedurally

var score: int = 0
var balls_left: int = 10
var orange_remaining: int = 0
var ball_in_play: bool = false

# NEW: global gravity you can tweak from the UI
var current_gravity: float = 0.40     # lower gravity feel (default 0.4)
var bounce_factor_global: float = 0.75

func _ready() -> void:
	randomize()
	_spawn_level()
	ui.call("set_balls", balls_left)
	ui.call("set_score", score)
	ui.call("init_gravity_controls", current_gravity)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _spawn_level() -> void:
	for c in peg_container.get_children():
		c.queue_free()

	# Offset/hex-like grid of circular pegs (StaticBody2D)
	var cols := 12
	var rows := 8
	var spacing := Vector2(64, 48)
	var offset := Vector2(80, 120)
	var total := cols * rows
	var orange_count := int(round(total * 0.2))

	var idxs := []
	for i in total:
		idxs.append(i)
	idxs.shuffle()
	var orange_set := idxs.slice(0, orange_count)

	var idx := 0
	for y in rows:
		for x in cols:
			var peg := _make_peg()
			var pos := offset + Vector2(x * spacing.x + (y % 2) * (spacing.x * 0.5), y * spacing.y)
			peg.position = pos
			peg.rotation = randf() * TAU
			peg.set("is_orange", idx in orange_set)
			peg_container.add_child(peg)
			idx += 1

	orange_remaining = orange_count
	ui.call("set_orange", orange_remaining)

func _make_peg() -> Node2D:
	var peg := StaticBody2D.new()
	peg.name = "Peg"
	peg.set_script(load("res://scripts/Peg.gd"))
	peg.add_to_group("peg")
	# Visual
	var rect := ColorRect.new()
	rect.name = "ColorRect"
	rect.position = Vector2(-10, -10)
	rect.size = Vector2(20, 20)
	peg.add_child(rect)
	# Collision
	var col := CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape := CircleShape2D.new()
	shape.radius = 12
	col.shape = shape
	col.disabled = false
	peg.add_child(col)
	# Physics material (bouncy feel is handled via manual reflection now; this still helps)
	var pm := PhysicsMaterial.new()
	pm.bounce = 0.9
	pm.friction = 0.2
	peg.physics_material_override = pm
	# Layers/masks
	peg.collision_layer = 1
	peg.collision_mask = 1
	return peg

func request_shoot(global_origin: Vector2, dir_normalized: Vector2, speed: float) -> void:
	if ball_in_play or balls_left <= 0:
		return
	var ball := _make_ball()
	ball.global_position = global_origin
	get_tree().current_scene.add_child(ball)
	ball.apply_impulse(dir_normalized * speed * ball.mass)
	ball_in_play = true
	balls_left -= 1
	ui.call("set_balls", balls_left)
	ball.connect("ball_lost", Callable(self, "_on_ball_lost"))
	ball.connect("ball_caught", Callable(self, "_on_ball_caught"))

func _make_ball() -> RigidBody2D:
	var ball := RigidBody2D.new()
	ball.name = "Ball"
	ball.set_script(load("res://scripts/Ball.gd"))
	# Visual
	var shape := CollisionShape2D.new()
	shape.name = "CollisionShape2D"
	var circ := CircleShape2D.new(); circ.radius = 10
	shape.shape = circ
	ball.add_child(shape)
	var sprite := ColorRect.new()
	sprite.name = "Sprite"
	sprite.position = Vector2(-10, -10)
	sprite.size = Vector2(20, 20)
	ball.add_child(sprite)
	# Physics feel
	var pm := PhysicsMaterial.new()
	pm.bounce = 0.85
	pm.friction = 0.2
	ball.physics_material_override = pm
	# IMPORTANT: apply current gravity & bounce factor
	ball.gravity_scale = current_gravity
	ball.set("bounce_factor", bounce_factor_global)
	# Layers/masks
	ball.collision_layer = 1
	ball.collision_mask = 1
	return ball

func _on_ball_lost() -> void:
	ball_in_play = false
	if balls_left <= 0 and orange_remaining > 0:
		ui.call("show_message", "Out of balls! Press R to restart.")

func _on_ball_caught() -> void:
	balls_left += 1
	ui.call("set_balls", balls_left)

func on_peg_hit(is_orange: bool, _peg_node: Node) -> void:
	score += (100 if is_orange else 10)
	ui.call("set_score", score)
	if is_orange:
		orange_remaining -= 1
		ui.call("set_orange", orange_remaining)
		if orange_remaining <= 0:
			ui.call("show_message", "YOU WIN! Score: %d\nPress R to play again." % score)

# === UI hooks for gravity ===
func set_gravity_scale(new_value: float) -> void:
	current_gravity = clamp(new_value, 0.05, 2.0)
	ui.call("show_gravity", current_gravity)
	# Update live ball if one is in play
	if ball_in_play:
		for b in get_tree().get_nodes_in_group("ball"):
			if b.has_method("set_gravity_scale_custom"):
				b.set_gravity_scale_custom(current_gravity)

func adjust_gravity(delta: float) -> void:
	set_gravity_scale(current_gravity + delta)
