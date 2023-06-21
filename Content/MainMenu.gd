extends Control

@export var startScene : PackedScene
@export var settingsScene : PackedScene

func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_packed(settingsScene)

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(startScene)

func _on_exit_button_pressed() -> void:
	pass # Replace with function body.
