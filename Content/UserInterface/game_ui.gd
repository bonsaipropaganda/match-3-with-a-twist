extends Control


@onready var main: Node = get_node("/root/Main")
@onready var menu_holder: MenuHolder = main.get_menu_holder()


func _on_pause_button_pressed() -> void:
	menu_holder.open_menu(&"Pause")


# func _on_retry_button_pressed() -> void:
# 	main.reset_game()


func set_moves_left(count: int) -> void:
	%MovesLeftLabel.text = "%2d" % [count]

func set_score(count: int) -> void:
	%ScoreLabel.text = "%2d" % [count]


func _on_grid_move_left_changed(value):
	set_moves_left(value)

func _on_grid_score_changed(value):
	set_score(value)
