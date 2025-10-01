## =============================================================================
## File: Peg.gd
## Purpose: Peg node: single-hit scoring with immediate collider disable and fade-out.
## Context: Godot 4.x (GDScript). Documented for quick onboarding (humans + LLMs).
## Notes:
##   - This header lists signals, exported tunables, and expected child nodes.
##   - Function banners summarize role, inputs, and side-effects.
##   - No logic changes here—only comments for clarity.
## Updated: 2025-10-01 22:22 UTC
## =============================================================================

## Summary
## Signals:
##   (none)
## Exported tunables:
##   - is_orange: bool = false
## Node/scene expectations (accessed with $Path or @onready vars):
##   - sprite: ColorRect at $ColorRect

extends StaticBody2D

@export var is_orange: bool = false
@onready var sprite: ColorRect = $ColorRect
var hit: bool = false

## ---------------------------------------------------------------------------
## _ready(-)
## Role: initialize node state, connect signals, create children as needed
## Inputs: -
## Side-effects: (state changes, signals, spawns, node edits)
## ---------------------------------------------------------------------------

func _ready() -> void:
	# Visual: orange are objectives, blue are normal
	sprite.color = (Color(1.0, 0.5, 0.1) if is_orange else Color(0.3, 0.6, 1.0))
	# Ensure collision layer/mask are set
	collision_layer = 1
	collision_mask = 1
	# Make sure this node is tagged (redundant but safe)
	if not is_in_group("peg"):
		add_to_group("peg")

## ---------------------------------------------------------------------------
## mark_hit(-)
## Role: (brief: describe purpose)
## Inputs: -
## Side-effects: (state changes, signals, spawns, node edits)
## ---------------------------------------------------------------------------

func mark_hit() -> void:
	if hit:
		return
	hit = true
	# Immediately disable all collisions so this peg can't be touched again
	for child in get_children():
		if child is CollisionShape2D:
			child.set_deferred("disabled", true)
	# Notify main once for scoring
	var main = get_tree().current_scene
	if main and main.has_method("on_peg_hit"):
		main.call("on_peg_hit", is_orange, self)
	# Small feedback & removal
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1,1,1,0.0), 0.15)
	tween.finished.connect(func(): queue_free())
