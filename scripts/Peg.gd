extends Node2D

@export var is_orange: bool = false
@onready var area: Area2D = $Area2D
@onready var sprite: ColorRect = $ColorRect
var hit: bool = false

func _ready() -> void:
	sprite.color = (Color(1.0, 0.5, 0.1) if is_orange else Color(0.3, 0.6, 1.0))
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if hit:
		return
	if body.is_in_group("ball"):
		hit = true
		var main = get_tree().current_scene
		main.call("on_peg_hit", is_orange, self)
		var tween := create_tween()
		tween.tween_property(sprite, "modulate", Color(1,1,1,0.0), 0.15)
		tween.finished.connect(func(): queue_free())
