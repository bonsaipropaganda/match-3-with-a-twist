extends Control

@onready var main: Node = get_node("/root/Main")
@onready var menu_holder: MenuHolder = main.get_menu_holder()


func _ready() -> void:
	get_tree().paused = true


func _exit_tree() -> void:
	get_tree().paused = false
	request_ready()


func _on_resume_button_pressed() -> void:
	menu_holder.close_menu()


func _on_settings_button_pressed() -> void:
	menu_holder.open_menu(&"Settings")


func _on_main_menu_button_pressed() -> void:
	menu_holder.close_menu()
	main.reset_to_main_menu()
