extends Node


@export_file("*.tscn") var game_scene: String = &""
var GameScene: PackedScene

@onready var menu_holder: MenuHolder = $MenuHolder


func _ready() -> void:
	menu_holder.open_menu(&"MainMenu")
	GameScene = load(game_scene)
	


func start_game() -> void:
	var scene: Node = GameScene.instantiate()
	$Game.add_child(scene)
	%Title.stop()
	await get_tree().create_timer(1).timeout
	%Theme.play()


func reset_game() -> void:
	_clean_game()
	start_game()


func reset_to_main_menu() -> void:
	_clean_game()
	menu_holder.open_menu(&"MainMenu")
	%Theme.stop()
	await get_tree().create_timer(1).timeout
	%Title.play()


func _clean_game() -> void:
	for c in $Game.get_children():
		c.queue_free()


func get_menu_holder() -> MenuHolder:
	return menu_holder
