@tool
extends Node2D
class_name Grid


const GRID_COLOR = Color("fce1cf")
const LINE_WIDTH = 2.0
const TILE_MARGIN = 3.0

const TIMESTEP = 0.2
var doneUpdating:bool = false

@export var gridWidth = 6
@export var gridHeight = 6
@export var tileScale = 70

@onready var tile_scene := preload("res://Content/Tile/tile.tscn")

var tiles:Array[Tile] = []

var done_updating := false

func _ready():
	if !Engine.is_editor_hint():
		$Timer.wait_time = TIMESTEP
	for y in gridHeight:
		for x in gridWidth:
			add_tile(Vector2(x,y))
	
	await get_tree().create_timer(.5).timeout
	update_grid()

func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()

func update_grid():
	if not doneUpdating:
		tiles_fall()

func _draw():
	# Vertical lines
	for x in gridWidth + 1:
		draw_line(Vector2(x * tileScale, 0), Vector2(x * tileScale, gridHeight * tileScale), GRID_COLOR, 2.0)
	# Horizontal lines
	for y in gridHeight + 1:
		draw_line(Vector2(0, y * tileScale), Vector2(gridWidth * tileScale, y * tileScale), GRID_COLOR, 2.0)

func add_tile(_gridPos:Vector2):
	if (_gridPos.x < 0 || _gridPos.x >= gridWidth || _gridPos.y < 0 || _gridPos.y >= gridHeight):
		return # Do not try to add tiles out of bounds
	if (get_tile_at(_gridPos) != null):
		return # Do not try to spawn tiles on top of each other
	
	var new_tile:Tile = tile_scene.instantiate()
	tiles.append(new_tile)
	
	new_tile.initialise_tile(self)
	
	add_child(new_tile)
	
	new_tile.set_grid_position(_gridPos)
	
	

func get_tile_at(_gridPos:Vector2)->Tile:
	if len(tiles) == 0:
		return null
	for tile in tiles:
		if tile.gridPos == _gridPos:
			return tile
	return null

func tiles_fall():
	var tileFell = false
	for tile in tiles:
			if tile.can_fall():
				tile.fall()
				tileFell = true
	
	if tileFell:
		tiles_fall()

func valid_grid_pos(_gridPos:Vector2):
	if 0 <= _gridPos.x and _gridPos.x < gridWidth and 0 <= _gridPos.y and _gridPos.y < gridHeight:
		return true
	else:
		return false

func get_matched_tiles():
	var matchedTiles := []
	var tilesToCheck := []
	
	for x in gridWidth:
		tilesToCheck.clear()
		for y in gridHeight:
			var testTile = get_tile_at(Vector2(x,y))
			if testTile != null and tilesToCheck.is_empty():
				tilesToCheck.append(testTile)
			elif testTile != null and testTile.tileType != tilesToCheck.back().tileType:
				if tilesToCheck.size() >= 3:
					matchedTiles.append_array(tilesToCheck)
				tilesToCheck.clear()
				tilesToCheck.append(testTile)
			elif testTile != null and testTile.tileType == tilesToCheck.back().tileType:
					tilesToCheck.append(testTile)
					if y == gridHeight -1 && tilesToCheck.size() >= 3:
						matchedTiles.append_array(tilesToCheck)
			elif testTile == null:
				tilesToCheck.clear()

	for y in gridWidth:
		tilesToCheck.clear()
		for x in gridHeight:
			var testTile = get_tile_at(Vector2(x,y))
			if testTile != null and tilesToCheck.is_empty():
				tilesToCheck.append(testTile)
			elif testTile != null and testTile.tileType != tilesToCheck.back().tileType:
				if tilesToCheck.size() >= 3:
					matchedTiles.append_array(tilesToCheck)
				tilesToCheck.clear()
				tilesToCheck.append(testTile)
			elif testTile != null and testTile.tileType == tilesToCheck.back().tileType:
					tilesToCheck.append(testTile)
					if x == gridWidth -1 && tilesToCheck.size() >= 3:
						matchedTiles.append_array(tilesToCheck)
			elif testTile == null:
				tilesToCheck.clear()

	return matchedTiles

