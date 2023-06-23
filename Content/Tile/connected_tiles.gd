extends Area2D

var x
var y
var tile_width
var TILE_MARGIN

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass
	#self.position = get_global_mouse_position()

func set_tile_scene_position(tile, x, y):
	tile.position = Vector2(x * tile_width, y * tile_width) + Vector2(TILE_MARGIN, TILE_MARGIN)
	tile.grid_pos = Vector2(x,y)
