extends Node2D

@export var muzzle_speed: float = 1100.0
@onready var barrel: Node2D = $Barrel
@onready var muzzle: Marker2D = $Barrel/Muzzle
@onready var main: Node = get_tree().current_scene

var can_shoot: bool = true

func _process(_delta: float) -> void:
	var mouse_pos: Vector2 = get_global_mouse_position()
	var aim_dir: Vector2 = (mouse_pos - global_position)
	rotation = aim_dir.angle()

	var is_down: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if is_down and can_shoot:
		var dir_n: Vector2 = aim_dir.normalized()
		print("SHOOT click @ ", muzzle.global_position, " dir=", dir_n)
		main.call("request_shoot", muzzle.global_position, dir_n, muzzle_speed)
		can_shoot = false
	elif not is_down and not can_shoot:
		can_shoot = true
