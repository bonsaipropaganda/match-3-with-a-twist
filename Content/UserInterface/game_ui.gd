extends Control

signal resume
signal pause

func _ready() -> void:
	if owner and owner.has_signal("game_over"):
		owner.game_over.connect(on_game_over)

func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	%PauseMenu.show()
	pause.emit()

func on_game_over() -> void:
	%GameOverUI.show()

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	%PauseMenu.hide()
	resume.emit()

func _on_settings_button_pressed() -> void:
	SceneManager.open_settings()

func _on_main_menu_button_pressed() -> void:
	SceneManager.go_to_main_menu()

func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()
