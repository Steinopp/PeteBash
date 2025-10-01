## =============================================================================
## File: Ball.gd
## Purpose: Ball physics + reliable peg hit detection (sensor Area2D) + ricochet behavior.
## Context: Godot 4.x (GDScript). Documented for quick onboarding (humans + LLMs).
## Notes:
##   - This header lists signals, exported tunables, and expected child nodes.
##   - Function banners summarize role, inputs, and side-effects.
##   - No logic changes here—only comments for clarity.
## Updated: 2025-10-01 22:22 UTC
## =============================================================================

## Summary
## Signals:
##   - ball_lost
##   - ball_caught
## Exported tunables:
##   - bounce_factor: float = 0.75
##   - min_incident_cos: float = 0.20     # ~78° or shallower = “glancing”
##   - min_bounce_speed: float = 120.0
##   - direct_bounce_speed_scale: float = 0.60
##   - max_speed: float = 1400.0
## Node/scene expectations (accessed with $Path or @onready vars):
##   (no explicit @onready or $Path usages found)

extends RigidBody2D

signal ball_lost
signal ball_caught

# --- Tunables ---
# Scales speed after a "normal" (non-glancing) bounce.
@export var bounce_factor: float = 0.75
# If the incidence angle is too shallow (cosine below this), do a direct push-away instead of a weak bounce.
@export var min_incident_cos: float = 0.20     # ~78° or shallower = “glancing”
# Minimum speed the ball should have after an interaction (prevents getting stuck).
@export var min_bounce_speed: float = 120.0
# Outgoing speed scale used for direct push-away on glancing hits.
@export var direct_bounce_speed_scale: float = 0.60
# Max speed clamp to avoid tunneling / unstable physics.
@export var max_speed: float = 1400.0

## ---------------------------------------------------------------------------
## _ready(-)
## Role: initialize node state, connect signals, create children as needed
## Inputs: -
## Side-effects: (state changes, signals, spawns, node edits)
## ---------------------------------------------------------------------------

func _ready() -> void:
	add_to_group("ball")
	contact_monitor = true
	max_contacts_reported = 10

	# Continuous Collision Detection (enum in Godot 4)
	continuous_cd = RigidBody2D.CCDMode.CCD_MODE_CAST_RAY

	# Layers/masks (match pegs)
	collision_layer = 1
	collision_mask = 1

	# --- Sensor hitbox to reliably detect peg contacts ---
	var hitbox := Area2D.new()
	hitbox.name = "Hitbox"
	hitbox.collision_layer = 1
	hitbox.collision_mask = 1
	hitbox.monitoring = true
	hitbox.monitorable = true

	var hshape := CollisionShape2D.new()
	var hcircle := CircleShape2D.new()
	hcircle.radius = 14.0  # slightly larger than the ball's physics radius (~10)
	hshape.shape = hcircle
	hitbox.add_child(hshape)
	add_child(hitbox)

	# Godot 4: pass a Callable to connect()
	hitbox.body_entered.connect(Callable(self, "_on_hitbox_body_entered"))

## ---------------------------------------------------------------------------
## _integrate_forces(state: PhysicsDirectBodyState2D)
## Role: low-level physics callback to clamp velocity or inspect contacts
## Inputs: state: PhysicsDirectBodyState2D
## Side-effects: (state changes, signals, spawns, node edits)
## ---------------------------------------------------------------------------

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Clamp max speed to keep behavior stable
	var v: Vector2 = linear_velocity
	if v.length() > max_speed:
		linear_velocity = v.normalized() * max_speed

## ---------------------------------------------------------------------------
## _process(_delta: float)
## Role: per-frame updates (input/aim/labels, non-physics)
## Inputs: _delta: float
## Side-effects: (state changes, signals, spawns, node edits)
## ---------------------------------------------------------------------------

func _process(_delta: float) -> void:
	# If we fall off-screen, end the ball
	var viewport := get_viewport_rect()
	if global_position.y > viewport.size.y + 100.0:
		emit_signal("ball_lost")
		queue_free()

## ---------------------------------------------------------------------------
## _on_caught(-)
## Role: (brief: describe purpose)
## Inputs: -
## Side-effects: (state changes, signals, spawns, node edits)
## ---------------------------------------------------------------------------

func _on_caught() -> void:
	emit_signal("ball_caught")
	queue_free()

## ---------------------------------------------------------------------------
## _on_hitbox_body_entered(body: Node)
## Role: sensor overlap with peg; score + bounce response
## Inputs: body: Node
## Side-effects: (state changes, signals, spawns, node edits)
## ---------------------------------------------------------------------------

func _on_hitbox_body_entered(body: Node) -> void:
	# Only care about pegs (StaticBody2D in group "peg")
	if body == null or not body.is_in_group("peg"):
		return

	# Ask the peg to score & disappear (one-shot)
	if body.has_method("mark_hit"):
		body.call_deferred("mark_hit")

	# --- Compute a robust reflection / push-away ---
	# Properly typed normal (Vector2). Cast to Node2D to read its position.
	var peg_pos: Vector2 = (body as Node2D).global_position
	var from_peg: Vector2 = global_position - peg_pos

	# Guard against zero-length vector (rare but possible if centers coincide this frame).
	var normal: Vector2
	if from_peg.length() > 0.0001:
		normal = from_peg.normalized()
	else:
		var vin_norm: Vector2 = linear_velocity
		normal = (-vin_norm.normalized()) if vin_norm.length() > 0.0001 else Vector2.UP

	# Incoming velocity and incidence cosine (how "head-on" we hit).
	var v_in: Vector2 = linear_velocity
	var v_in_len: float = v_in.length()
	var inc_dir: Vector2 = (-v_in / v_in_len) if v_in_len > 0.0 else -normal
	var incidence_cos: float = max(0.0, inc_dir.dot(normal))

	if incidence_cos < min_incident_cos:
		# Too glancing: shoot the ball directly out along the normal at a solid speed.
		var speed: float = max(min_bounce_speed, v_in_len * direct_bounce_speed_scale)
		linear_velocity = normal * speed
	else:
		# “Normal” bounce: reflect across the normal with some energy loss.
		var v_out: Vector2 = v_in.bounce(normal) * bounce_factor
		if v_out.length() < min_bounce_speed:
			v_out = (v_out.normalized() * min_bounce_speed) if v_out.length() > 0.0 else (normal * min_bounce_speed)
		linear_velocity = v_out

# Allow Main/UI to tweak gravity on the live ball

## ---------------------------------------------------------------------------
## set_gravity_scale_custom(value: float)
## Role: (brief: describe purpose)
## Inputs: value: float
## Side-effects: (state changes, signals, spawns, node edits)
## ---------------------------------------------------------------------------
func set_gravity_scale_custom(value: float) -> void:
	gravity_scale = value
