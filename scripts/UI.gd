## =============================================================================
## File: UI.gd
## Purpose: Heads-up display: labels for score/balls/orange, messages, gravity controls.
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
##   (none)
## Node/scene expectations (accessed with $Path or @onready vars):
##   - lbl_score: Label at $Margin/VBox/HBox/Score
##   - lbl_balls: Label at $Margin/VBox/HBox/Balls
##   - lbl_orange: Label at $Margin/VBox/HBox/Orange
##   - msg: Label at $Margin/VBox/Message

extends CanvasLayer

@onready var lbl_score: Label = $Margin/VBox/HBox/Score
@onready var lbl_balls: Label = $Margin/VBox/HBox/Balls
@onready var lbl_orange: Label = $Margin/VBox/HBox/Orange
@onready var msg: Label = $Margin/VBox/Message

var gravity_label: Label

## ---------------------------------------------------------------------------
## set_score(v: int)
## Role: (brief: describe purpose)
## Inputs: v: int
## Side-effects: (state changes, signals, spawns, node edits)
## ---------------------------------------------------------------------------

func set_score(v: int) -> void:
	lbl_score.text = "Score: %d" % v

## ---------------------------------------------------------------------------
## set_balls(v: int)
## Role: (brief: describe purpose)
## Inputs: v: int
## Side-effects: (state changes, signals, spawns, node edits)
## ---------------------------------------------------------------------------

func set_balls(v: int) -> void:
	lbl_balls.text = "Balls: %d" % v

## ---------------------------------------------------------------------------
## set_orange(v: int)
## Role: (brief: describe purpose)
## Inputs: v: int
## Side-effects: (state changes, signals, spawns, node edits)
## ---------------------------------------------------------------------------

func set_orange(v: int) -> void:
	lbl_orange.text = "Orange: %d" % v

## ---------------------------------------------------------------------------
## show_message(t: String)
## Role: (brief: describe purpose)
## Inputs: t: String
## Side-effects: (state changes, signals, spawns, node edits)
## ---------------------------------------------------------------------------

func show_message(t: String) -> void:
	msg.text = t

# --- Gravity controls (programmatically add buttons so you don't edit scenes) ---

## ---------------------------------------------------------------------------
## init_gravity_controls(current_gravity: float)
## Role: (brief: describe purpose)
## Inputs: current_gravity: float
## Side-effects: (state changes, signals, spawns, node edits)
## ---------------------------------------------------------------------------
func init_gravity_controls(current_gravity: float) -> void:
	var vbox: VBoxContainer = $Margin/VBox
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	vbox.add_child(row)

	var btn_minus := Button.new()
	btn_minus.text = "Gravity -"
	row.add_child(btn_minus)

	gravity_label = Label.new()
	row.add_child(gravity_label)

	var btn_plus := Button.new()
	btn_plus.text = "Gravity +"
	row.add_child(btn_plus)

	btn_minus.pressed.connect(func():
		var main = get_tree().current_scene
		if main and main.has_method("adjust_gravity"):
			main.call("adjust_gravity", -0.05)
	)

	btn_plus.pressed.connect(func():
		var main = get_tree().current_scene
		if main and main.has_method("adjust_gravity"):
			main.call("adjust_gravity", +0.05)
	)

	show_gravity(current_gravity)

## ---------------------------------------------------------------------------
## show_gravity(v: float)
## Role: (brief: describe purpose)
## Inputs: v: float
## Side-effects: (state changes, signals, spawns, node edits)
## ---------------------------------------------------------------------------

func show_gravity(v: float) -> void:
	if gravity_label:
		gravity_label.text = "Gravity: %.2f" % v
