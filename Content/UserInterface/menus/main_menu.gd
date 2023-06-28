extends Control


@onready var main: Node = get_node("/root/Main")
@onready var menu_holder: MenuHolder = main.get_menu_holder()


func _on_settings_button_pressed() -> void:
	menu_holder.open_menu(&"Settings")


func _on_start_button_pressed() -> void:
	menu_holder.close_menu()
	main.start_game()


func _on_exit_button_pressed() -> void:
	# won't work on iOS
	get_tree().quit()
