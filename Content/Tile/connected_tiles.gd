extends Area2D

var x
var y
var tile_width
var TILE_MARGIN

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_tile_scene_position(self,x,y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#self.position = get_global_mouse_position()

func set_tile_scene_position(tile, x, y):
	tile.position = Vector2(x * tile_width, y * tile_width) + Vector2(TILE_MARGIN, TILE_MARGIN)
	#tile.grid_pos = Vector2(x,y)
