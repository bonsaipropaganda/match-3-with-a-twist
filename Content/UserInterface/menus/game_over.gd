extends Control


@onready var main: Node = get_node("/root/Main")
@onready var menu_holder: MenuHolder = main.get_menu_holder()


func _on_retry_button_pressed() -> void:
	menu_holder.close_menu()
	main.reset_game()


func _on_main_menu_button_pressed() -> void:
	menu_holder.close_menu()
	main.reset_to_main_menu()
