extends Area2D


signal done_moving()


const SPRITE_WIDTH = 128.0 # Currently set to width of placeholder image

var sprite2D : Sprite2D

var tile_type: TileType
var group_id: int
var tile_width: int
var grid_pos: Vector2 # Set by grid

# Tile moving animation stuff
var move_tween: Tween
var final_move_position: Vector2


enum TileStats{
	CAN_SWAP,
	CAN_FALL, #Caused A Whole Rework Of The Unswap Mechanic To Happen
	BREAK_ON_MATCH,
	BREAK_ON_ADJACENT_MATCH, #Not Implemented Yet
	BREAK_ON_PRESSURE
}

enum TileType {
	PINK,
	ORANGE,
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
	[TileStats.CAN_SWAP,TileStats.CAN_FALL,TileStats.BREAK_ON_MATCH],
	[TileStats.CAN_SWAP,TileStats.CAN_FALL,TileStats.BREAK_ON_MATCH],
	[TileStats.CAN_SWAP,TileStats.BREAK_ON_ADJACENT_MATCH,TileStats.BREAK_ON_MATCH],                           
	#[TileStats.CAN_SWAP,TileStats.BREAK_ON_PRESSURE],
	]

# Indexed by TileType
# Replace these with the actual images
const tile_images = [
	preload("res://art/pieces/unselected_pink.png"),
	preload("res://art/pieces/unselected_orange.png"),
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
	
	
	tile_type = randi() % TileType.size() as TileType
	sprite2D = $Sprite2D
	sprite2D.texture = tile_images[tile_type]


var clicked = false
func _on_input_event(_viewport, event: InputEvent, _shape_idx):
	if event.is_action_pressed("click"):
		clicked = true
	if event.is_action_released("click"):
		clicked = false


func _process(_delta):
	if clicked:
		var mouse_pos = get_viewport().get_mouse_position()
		var my_pos = $CollisionShape2D.global_position
		if abs(mouse_pos.x - my_pos.x) > tile_width / 2:
			Globals.emit_signal("swap_tile", grid_pos, Vector2(sign(mouse_pos.x - my_pos.x), 0))
			clicked = false
		if abs(mouse_pos.y - my_pos.y) > tile_width / 2:
			Globals.emit_signal("swap_tile", grid_pos, Vector2(0, sign(mouse_pos.y - my_pos.y)))
			clicked = false


func animated_move_to(target_pos: Vector2, duration: float) -> void:
	if move_tween:
		if move_tween.is_running():
			move_tween.stop()
			position = final_move_position
			done_moving.emit() # Send the done moving signal for cancellation
		move_tween.kill()
	
	move_tween = create_tween()
	move_tween.tween_property(self, ^"position", target_pos, duration)
	move_tween.tween_callback(func(): done_moving.emit())
	final_move_position = target_pos
