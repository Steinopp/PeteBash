extends Node2D

@export var width: float = 140.0
@export var speed: float = 220.0
@onready var area: Area2D = $Area2D

var dir := 1

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position.x += dir * speed * delta
	var viewport = get_viewport_rect()
	var half = width * 0.5
	if position.x < half + 20:
		position.x = half + 20
		dir = 1
	elif position.x > viewport.size.x - half - 20:
		position.x = viewport.size.x - half - 20
		dir = -1

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("ball"):
		if body.has_method("_on_caught"):
			body.call_deferred("_on_caught")
