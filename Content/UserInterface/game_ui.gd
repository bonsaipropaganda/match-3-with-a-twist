extends Control


@onready var main: Node = get_node("/root/Main")
@onready var menu_holder: MenuHolder = main.get_menu_holder()


func _on_pause_button_pressed() -> void:
	menu_holder.open_menu(&"Pause")


# func _on_retry_button_pressed() -> void:
# 	main.reset_game()


func set_moves_left(count: int) -> void:
	$MarginContainer/Control/MovesLeft/AnimationPlayer.stop()
	if int(%MovesLeftLabel.text) > count:
		$MarginContainer/Control/MovesLeft/AnimationPlayer.play("newmove")
	else:
		$MarginContainer/Control/MovesLeft/AnimationPlayer.play_backwards("newmove")
	
	%MovesLeftLabel.text = "%2d" % [count]

func set_score(count: int) -> void:
	%ScoreLabel.text = "%2d" % [count]
	$MarginContainer/Control/Score/AnimationPlayer.stop()
	$MarginContainer/Control/Score/AnimationPlayer.play("newscore")
