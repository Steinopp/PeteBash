extends CanvasLayer

@onready var lbl_score: Label = $Margin/VBox/HBox/Score
@onready var lbl_balls: Label = $Margin/VBox/HBox/Balls
@onready var lbl_orange: Label = $Margin/VBox/HBox/Orange
@onready var msg: Label = $Margin/VBox/Message

var gravity_label: Label

func set_score(v: int) -> void:
	lbl_score.text = "Score: %d" % v

func set_balls(v: int) -> void:
	lbl_balls.text = "Balls: %d" % v

func set_orange(v: int) -> void:
	lbl_orange.text = "Orange: %d" % v

func show_message(t: String) -> void:
	msg.text = t

# --- Gravity controls (programmatically add buttons so you don't edit scenes) ---
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

func show_gravity(v: float) -> void:
	if gravity_label:
		gravity_label.text = "Gravity: %.2f" % v
