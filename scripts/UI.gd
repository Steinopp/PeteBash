extends CanvasLayer

@onready var lbl_score: Label = $Margin/VBox/HBox/Score
@onready var lbl_balls: Label = $Margin/VBox/HBox/Balls
@onready var lbl_orange: Label = $Margin/VBox/HBox/Orange
@onready var msg: Label = $Margin/VBox/Message

func set_score(v: int) -> void:
    lbl_score.text = "Score: %d" % v

func set_balls(v: int) -> void:
    lbl_balls.text = "Balls: %d" % v

func set_orange(v: int) -> void:
    lbl_orange.text = "Orange: %d" % v

func show_message(t: String) -> void:
    msg.text = t
