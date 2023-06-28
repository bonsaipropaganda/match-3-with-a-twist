extends Control


@onready var main: Node = get_node("/root/Main")
@onready var menu_holder: MenuHolder = main.get_menu_holder()


func _on_pause_button_pressed() -> void:
	menu_holder.open_menu(&"Pause")


# func _on_retry_button_pressed() -> void:
# 	main.reset_game()


func set_moves_left(count: int) -> void:
	%MovesLeftLabel.text = "%2d" % [count]
