extends Control

@export var startScene : PackedScene

func _on_settings_button_pressed() -> void:
	SceneManager.open_settings()

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(startScene)

func _on_exit_button_pressed() -> void:
	get_tree().quit() # won't work on iOS
