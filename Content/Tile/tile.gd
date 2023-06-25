extends Area2D

const SPRITE_WIDTH = 128.0 # Currently set to width of placeholder image

var sprite2D : Sprite2D

var tile_type: TileType
var group_id: int
var tile_width: int
var grid_pos: Vector2 # Set by grid

enum TileStats{
	CAN_SWAP,
	CAN_FALL, #Caused A Whole Rework Of The Unswap Mechanic To Happen
	BREAK_ON_MATCH,
	BREAK_ON_ADJACENT_MATCH, #Not Implemented Yet
	BREAK_ON_PRESSURE
}

enum TileType {
	RED,
	BLUE,
	GREEN,
	YELLOW,
	GREY,
	#GHOST,
}

const tile_stats = [
	[TileStats.CAN_SWAP,TileStats.CAN_FALL,TileStats.BREAK_ON_MATCH],
	[TileStats.CAN_SWAP,TileStats.CAN_FALL,TileStats.BREAK_ON_MATCH],
	[TileStats.CAN_SWAP,TileStats.CAN_FALL,TileStats.BREAK_ON_MATCH],
	[TileStats.CAN_SWAP,TileStats.CAN_FALL,TileStats.BREAK_ON_MATCH],
	[TileStats.CAN_SWAP,TileStats.BREAK_ON_ADJACENT_MATCH],                           
	#[TileStats.CAN_SWAP,TileStats.BREAK_ON_PRESSURE],
	]

# Indexed by TileType
# Replace these with the actual images
const tile_images = [
	preload("res://art/pieces/unselected_red.png"),
	preload("res://art/pieces/unselected_blue.png"),
	preload("res://art/pieces/unselected_green.png"),
	preload("res://art/pieces/unselected_yellow.png"),
	preload("res://art/pieces/unselected_grey.png"),
	preload("res://art/pieces/unselected_ghost.png"),
]

func initialise(_tile_width : float, margin_width):
	tile_width = _tile_width - margin_width * 2
	scale *= tile_width / SPRITE_WIDTH
	$CollisionShape2D.position = Vector2.ONE * tile_width
	$CollisionShape2D.shape.size = Vector2.ONE * tile_width * 2
	
	
	tile_type = randi() % TileType.size()
	sprite2D = $Sprite2D
	sprite2D.texture = tile_images[tile_type]

var clicked = false
func _on_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("click"):
		clicked = true
	if Input.is_action_just_released("click"):
		clicked = false

func _process(delta):
	if clicked:
		var mouse_pos = get_viewport().get_mouse_position()
		var my_pos = $CollisionShape2D.global_position
		if abs(mouse_pos.x - my_pos.x) > tile_width/2:
			Globals.emit_signal("swap_tile", grid_pos, Vector2(sign(mouse_pos.x - my_pos.x), 0))
			clicked = false
		if abs(mouse_pos.y - my_pos.y) > tile_width/2:
			Globals.emit_signal("swap_tile", grid_pos, Vector2(0, sign(mouse_pos.y - my_pos.y)))
			clicked = false
