extends Node2D


@onready var menu_holder: MenuHolder = get_node("/root/Main").get_menu_holder()


func _on_game_over() -> void:
	menu_holder.open_menu(&"GameOver")
