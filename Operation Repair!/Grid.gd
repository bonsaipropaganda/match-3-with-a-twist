@tool
extends Node2D
class_name Grid

signal move_left_changed(value: int)
signal score_changed(value: int)
signal game_over()

const GRID_COLOR = Color("fce1cf")
const LINE_WIDTH = 2.0
const TILE_MARGIN = 3.0

const TIMESTEP = 0.2
var doneUpdating:bool = false

@export var gridWidth = 6
@export var gridHeight = 6
@export var tileScale = 70

@onready var tile_scene := preload("res://Content/Tile/tile.tscn")

var move_left: int = 10:
	set(value):
		move_left = value
		move_left_changed.emit(value)
		if value <= 0:
			# TODO: game over should be at the end of the grid update (when nothing moves anymore)
			game_over.emit()

# score stuff
var score: int = 0:
	set(value):
		score = value
		score_changed.emit(value)

var tiles:Array[Tile] = []

var done_updating := false

func _ready():
	if !Engine.is_editor_hint():
		$Timer.wait_time = TIMESTEP
	for y in gridHeight-1:
		for x in gridWidth:
			add_tile(Vector2(x,y))
	
	move_left_changed.emit(move_left)
	
	await get_tree().create_timer(.5).timeout
	update_grid()
	print(get_matched_tiles())

func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()
	else:
		if !done_updating && $Timer.is_stopped():
			$Timer.start()

func _on_timer_timeout():
	update_grid()

func update_grid():
	doneUpdating = true
	tiles_fall()
	if not doneUpdating: return
	spawn_new_tiles()
	if not doneUpdating: return
	break_matched_tiles()

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
				doneUpdating = false

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

func get_agacent_tiles(_tiles:Array):
	var agacentTiles:Array[Tile]
	var isAgacent = true
	for tile in tiles:
		for _tile in _tiles:
			if _tile.gridPos == tile.gridPos and _tile.gridPos.distance_to(tile.gridPos) != 1:
				isAgacent = false
			if isAgacent and tile.has_stat(Tile.TileStats.BREAK_ON_ADJACENT_MATCH):
				agacentTiles.append(tile)
	return agacentTiles

func break_matched_tiles():
	var _tiles = get_matched_tiles()
	for tile in _tiles:
		if not tile.has_stat(Tile.TileStats.BREAK_ON_MATCH):
			_tiles.erase(tile)
	var agacentTiles = get_agacent_tiles(_tiles)
	
	for tile in agacentTiles:
		if not tile.has_stat(Tile.TileStats.BREAK_ON_ADJACENT_MATCH):
			agacentTiles.erase(tile)
	
	_tiles.append_array(agacentTiles)
	
	if not _tiles.is_empty():
		doneUpdating = false
	
	for tile in _tiles:
		tiles.erase(tile)
		tile.queue_free()

func spawn_new_tiles():
	for x in gridWidth:
		if get_tile_at(Vector2(x,0)) == null:
			add_tile(Vector2(x,0))
			doneUpdating = false
