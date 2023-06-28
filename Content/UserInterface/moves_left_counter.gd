extends Node2D

var moves_left: int = 10
signal game_over

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# update moves left label
	$MovesLeftLabel.text = "Moves left: " + str(moves_left)
	
	# game over
	if moves_left == 0:
		game_over.emit()

func _on_grid_tiles_swap() -> void:
	moves_left -= 1

func _on_moves_recieved(move_amount):
	moves_left += move_amount
