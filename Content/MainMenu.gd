extends Control

@export var startScene : PackedScene
@export var settingsScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_game_pressed():
	get_tree().change_scene_to_packed(startScene)


func _on_settings_pressed():
	get_tree().change_scene_to_packed(settingsScene)
