extends Node2D

@export var connected_tile_scene: PackedScene

# variables to be passed to the new connected tiles scene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_grid_match_created(match_type,x,y) -> void:
	var new_connection = connected_tile_scene.instantiate()
	
	# variables to be passed into the new connection from the grid
	new_connection.x = x
	new_connection.y = y
	new_connection.tile_width = $Grid.tile_width
	new_connection.TILE_MARGIN = $Grid.TILE_MARGIN
	
	add_child(new_connection)
