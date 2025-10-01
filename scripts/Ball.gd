extends RigidBody2D

signal ball_lost
signal ball_caught

func _ready() -> void:
	add_to_group("ball")
	contact_monitor = true
	max_contacts_reported = 10

func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	var v = linear_velocity
	var max_speed := 1400.0
	if v.length() > max_speed:
		linear_velocity = v.normalized() * max_speed

func _process(_delta: float) -> void:
	var viewport = get_viewport_rect()
	if global_position.y > viewport.size.y + 100:
		emit_signal("ball_lost")
		queue_free()

func _on_caught() -> void:
	emit_signal("ball_caught")
	queue_free()
