## =============================================================================
## File: Bucket.gd
## Purpose: Moving bucket at bottom: grants extra ball when it catches one.
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
##   - width: float = 140.0
##   - speed: float = 220.0
## Node/scene expectations (accessed with $Path or @onready vars):
##   - area: Area2D at $Area2D

extends Node2D

@export var width: float = 140.0
@export var speed: float = 220.0
@onready var area: Area2D = $Area2D

var dir := 1

## ---------------------------------------------------------------------------
## _ready(-)
## Role: initialize node state, connect signals, create children as needed
## Inputs: -
## Side-effects: (state changes, signals, spawns, node edits)
## ---------------------------------------------------------------------------

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)

## ---------------------------------------------------------------------------
## _process(delta: float)
## Role: per-frame updates (input/aim/labels, non-physics)
## Inputs: delta: float
## Side-effects: (state changes, signals, spawns, node edits)
## ---------------------------------------------------------------------------

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

## ---------------------------------------------------------------------------
## _on_body_entered(body: Node)
## Role: (brief: describe purpose)
## Inputs: body: Node
## Side-effects: (state changes, signals, spawns, node edits)
## ---------------------------------------------------------------------------

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("ball"):
		if body.has_method("_on_caught"):
			body.call_deferred("_on_caught")
