extends Node2D

signal game_over

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO: remove this and replace with game over logic
	await get_tree().create_timer(2.0, false).timeout
	game_over.emit()
