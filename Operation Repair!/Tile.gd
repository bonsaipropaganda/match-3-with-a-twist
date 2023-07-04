extends Area2D
class_name Tile

const SPRITE_SCALE = 128.0

var tileType: TileType
var groupId: int
var tileScale: int
var gridPos: Vector2
var parentNode:Grid

var clicked:bool = false

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
enum TileStats{
	CAN_SWAP,
	CAN_FALL,
	BREAK_ON_MATCH,
	BREAK_ON_ADJACENT_MATCH,
	BREAK_ON_PRESSURE
	}

const tileImages = [
	preload("res://art/pieces/unselected_pink.png"),
	preload("res://art/pieces/unselected_orange.png"),
	preload("res://art/pieces/unselected_red.png"),
	preload("res://art/pieces/unselected_blue.png"),
	preload("res://art/pieces/unselected_green.png"),
	preload("res://art/pieces/unselected_yellow.png"),
	preload("res://art/pieces/unselected_grey.png"),
	preload("res://art/pieces/unselected_ghost.png"),
]
const tileStats = [
	[TileStats.CAN_SWAP,TileStats.CAN_FALL,TileStats.BREAK_ON_MATCH],
	[TileStats.CAN_SWAP,TileStats.CAN_FALL,TileStats.BREAK_ON_MATCH],
	[TileStats.CAN_SWAP,TileStats.CAN_FALL,TileStats.BREAK_ON_MATCH],
	[TileStats.CAN_SWAP,TileStats.CAN_FALL,TileStats.BREAK_ON_MATCH],
	[TileStats.CAN_SWAP,TileStats.CAN_FALL,TileStats.BREAK_ON_MATCH],
	[TileStats.CAN_SWAP,TileStats.CAN_FALL,TileStats.BREAK_ON_MATCH],
	[TileStats.CAN_SWAP,TileStats.BREAK_ON_ADJACENT_MATCH,],                           
	#[TileStats.CAN_SWAP,TileStats.BREAK_ON_PRESSURE],
	]


func initialise_tile(_parentNode:Grid = parentNode,_tileType = randi() % TileType.size()):
	parentNode = _parentNode
	tileScale = parentNode.tileScale - parentNode.TILE_MARGIN * 2
	scale *= tileScale / SPRITE_SCALE
	$CollisionShape2D.position = Vector2.ONE * parentNode.tileScale
	$CollisionShape2D.shape.size = Vector2.ONE * parentNode.tileScale * 2
	
	tileType = _tileType
	z_index += 1
	$Sprite2D.texture = tileImages[tileType]

func has_stat(stat:TileStats)->bool:
	if stat in tileStats[tileType]:
		return true
	else:
		return false

func set_grid_position(_gridPos:Vector2):
	position = _gridPos * parentNode.tileScale + Vector2(parentNode.TILE_MARGIN, parentNode.TILE_MARGIN)
	gridPos = _gridPos
	parentNode.doneUpdating = false

func get_tile_at(_gridPos:Vector2)->Tile:
	if len(parentNode.tiles) == 0:
		return null
	for tile in parentNode.tiles:
		if tile.gridPos == _gridPos:
			return tile
	return null

func _on_input_event(_viewport, event: InputEvent, _shape_idx):
	if event.is_action_pressed("click"):
		clicked = true

func _on_tile_drag():
	if clicked:
		var mouse_pos = get_viewport().get_mouse_position()
		var my_pos = $CollisionShape2D.global_position
		if abs(mouse_pos.x - my_pos.x) > tileScale/2 and can_swap(gridPos + Vector2(sign(mouse_pos.x - my_pos.x), 0)):
			if can_swap(gridPos + Vector2(sign(mouse_pos.x - my_pos.x), 0)):
				swap_to_position(gridPos + Vector2(sign(mouse_pos.x - my_pos.x), 0))
		if abs(mouse_pos.y - my_pos.y) > tileScale/2 and can_swap(gridPos + Vector2(0, sign(mouse_pos.y - my_pos.y))):
			if can_swap(gridPos + Vector2(0, sign(mouse_pos.y - my_pos.y))):
				swap_to_position(gridPos + Vector2(0, sign(mouse_pos.y - my_pos.y)))
	if not Input.is_action_pressed("click"):
		clicked = false

func can_swap(_gridPos:Vector2):
	if not parentNode.doneUpdating:
		return false
	
	if not has_stat(TileStats.CAN_SWAP):
		return false
	
	if get_tile_at(_gridPos) != null: if not get_tile_at(_gridPos).has_stat(TileStats.CAN_SWAP):
		return false
	
	return parentNode.valid_grid_pos(_gridPos)

func swap_to_position(_gridPos:Vector2):
	
	parentNode.move_left -= 1
	
	if get_tile_at(_gridPos) == null:
		set_grid_position(_gridPos)
	else:
		get_tile_at(_gridPos).set_grid_position(gridPos)
		set_grid_position(_gridPos)

func can_fall():
	if not has_stat(TileStats.CAN_FALL):
		return false
	elif gridPos.y + 1 == parentNode.gridHeight:
		return false
	elif get_tile_at(gridPos+Vector2.DOWN) != null:
		return false
	
	return parentNode.valid_grid_pos(gridPos+Vector2.DOWN)

func fall():
	clicked = false
	set_grid_position(gridPos+Vector2.DOWN)

func _process(delta):
	_on_tile_drag()
