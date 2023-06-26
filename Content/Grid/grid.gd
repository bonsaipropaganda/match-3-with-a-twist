@tool
extends Node2D

const GRID_COLOR = Color("fce1cf")
const LINE_WIDTH = 2.0
const TILE_MARGIN = 3.0

const TIMESTEP = 0.2

@export var grid_width = 6
@export var grid_height = 6
@export var tile_width = 70

@onready var tile_scene := preload("res://Content/Tile/tile.tscn")
@onready var connected_scene := preload("res://Content/Tile/connected_tiles.tscn")
@export var connected_tile_scene: PackedScene

var grid: Array
var group_counts: Dictionary
var done_updating := false
var is_swapping:bool = false
var previous_swaps:Array = []

func _ready():
	if !Engine.is_editor_hint():
		$Timer.wait_time = TIMESTEP
		Globals.connect("swap_tile", on_swap_tile)
		grid = init_grid(grid_width, grid_height)
		
		for y in grid_height:
			for x in grid_width:
				add_tile(x,y)
	queue_redraw()

func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()
	else:
		if !done_updating && $Timer.is_stopped():
			pass
			$Timer.start()

func _on_timer_timeout():
	update_grid()

func update_grid():
	var settled = true
	for y in range(grid_height-2, -1, -1):
		for x in range(0, grid_width):
			if can_fall(x, y):
				move_tile(x, y, x, y+1)
				settled = false
				done_updating = false
	
	var matched_tiles = []
	if settled:
		matched_tiles = get_matched_tiles()
		for i in matched_tiles: # [tile_type, x, y]
			var x = i[1]
			var y = i[2]
			if grid[y][x] != null:
				grid[y][x].queue_free()
				grid[y][x] = null
	
	if matched_tiles.size() == 0:
		if settled:
			done_updating = true
		for x in grid_width:
			if (add_tile(x, 0)):
				done_updating = false
	else:
		settled = false
	
	# Unswaps all the tiles swapped when the length of previous swaps that havent made a match = 3 if enabled
	if len(previous_swaps) == 3 and true:
		on_unswap_tiles()

func init_grid(width, height):
	var g = []
	for i in height:
		g.append([])
		for j in width:
			g[i].append(null)
	return g

func _draw():
	# Vertical lines
	for x in grid_width + 1:
		draw_line(Vector2(x * tile_width, 0), Vector2(x * tile_width, grid_height * tile_width), GRID_COLOR, 2.0)
	# Horizontal lines
	for y in grid_height + 1:
		draw_line(Vector2(0, y * tile_width), Vector2(grid_width * tile_width, y * tile_width), GRID_COLOR, 2.0)

func set_tile_scene_position(tile, x, y):
	tile.position = Vector2(x * tile_width, y * tile_width) + Vector2(TILE_MARGIN, TILE_MARGIN)
	if tile.get("grid_pos") != null:
		tile.grid_pos = Vector2(x,y)

func add_tile(x, y, type=null) -> bool:
	if (x < 0 || x >= grid_width || y < 0 || y >= grid_height):
		assert(false) # Do not try to add tiles out of bounds
	if (grid[y][x] != null):
		return false # Do not try to spawn tiles on top of each other
	
	var new_tile = tile_scene.instantiate()
	grid[y][x] = new_tile
	set_tile_scene_position(new_tile, x, y)
	new_tile.initialise(tile_width, TILE_MARGIN, type)
	add_child(new_tile)
	return true

# Move tile to empty space
func move_tile(x1, y1, x2, y2):
	if grid[y1][x1] != null && grid[y2][x2] == null:
		set_tile_scene_position(grid[y1][x1], x2, y2)
		grid[y2][x2] = grid[y1][x1]
		grid[y1][x1] = null

func can_fall(x, y):
	if y == grid_height - 1:
		return false
	if grid[y][x] is ConnectedTiles:
		return false # TODO make way for connected to fall
	else:
		return grid[y][x] != null && grid[y+1][x] == null && (Tile.TileStats.CAN_FALL in Tile.tile_stats[grid[y][x].tile_type])

# Return array of [tile_id, x, y]
func get_matched_tiles():
	var matched_tiles := []
	var to_check := []
	
	# Vertical check
	for x in grid_width:
		to_check.clear()
		for y in grid_height:
			if grid[y][x]:
				if to_check.is_empty():
					to_check.append([grid[y][x].tile_type, x, y])
				elif grid[y][x].tile_type != to_check.back()[0]:
					if to_check.size() >= 3:
						matched_tiles.append_array(to_check)
					to_check.clear()
					to_check.append([grid[y][x].tile_type, x, y])
				elif grid[y][x].tile_type == to_check.back()[0]:
					to_check.append([grid[y][x].tile_type, x, y])
					if y == grid_height-1 && to_check.size() >= 3:
						to_check.append([grid[y][x].tile_type, x, y])
						matched_tiles.append_array(to_check)
			else:
				to_check.clear()
	# Horizontal check
	for y in grid_height:
		to_check.clear()
		for x in grid_width:
			if grid[y][x]:
				if to_check.is_empty():
					to_check.append([grid[y][x].tile_type, x, y])
				elif grid[y][x].tile_type != to_check.back()[0]:
					if to_check.size() >= 3:
						matched_tiles.append_array(to_check)
					to_check.clear()
					to_check.append([grid[y][x].tile_type, x, y])
				elif grid[y][x].tile_type == to_check.back()[0]:
					to_check.append([grid[y][x].tile_type, x, y])
					if x == grid_width-1 && to_check.size() >= 3:
						to_check.append([grid[y][x].tile_type, x, y])
						matched_tiles.append_array(to_check)
			else:
				to_check.clear()
		
				# Stops Tile from breaking if that tile doesnt have the BREAK_ON_MATCH Stat
		for tile in matched_tiles:
			if Tile.TileStats.BREAK_ON_MATCH not in Tile.tile_stats[tile[0]]:
				matched_tiles.erase(tile)
	
	# Makes Tile break if that tile has the BREAK_ON_AGACENT_MATCH Stat and is agacent to a match that was made
	for row in grid:
		for tile in row:
			if tile != null:
				if Tile.TileStats.BREAK_ON_ADJACENT_MATCH in Tile.tile_stats[tile.tile_type]:
					for free in matched_tiles:
						if tile.grid_pos.distance_to(Vector2(free[1],free[2])) == 1:
							to_check.append([tile.tile_type, tile.grid_pos.x, tile.grid_pos.y])
		
	return matched_tiles

const HAS_TILE = 1
const HAS_CONNECTED = 2
const HAS_BOTH = HAS_TILE | HAS_CONNECTED

func generate_connected_tiles():
	var to_connect = get_matched_tiles()
	var grouped_tiles = {}
	var group_info = {}
	
	for i in to_connect:
		var tile_type = i[0]
		var x = i[1]
		var y = i[2]
		# tracks whether the tile is a part of a connected tile or just a single tile
		var tile_info = HAS_TILE if (grid[y][x] is Tile) else HAS_CONNECTED
		
		if grouped_tiles.get(tile_type):
			group_info[tile_type] |= tile_info
			grouped_tiles[tile_type].append(grid[y][x])
		else:
			group_info[tile_type] = tile_info
			grouped_tiles[tile_type] = [grid[y][x]]
	
	for type in grouped_tiles.keys():
		if group_info[type] == HAS_BOTH:
			continue
		var connected = connected_scene.instantiate()
		connected.modulate = Color("243784") # for debug
		add_child(connected)
		connected.tile_width = tile_width
		for tile in grouped_tiles[type]:
			tile.reparent(connected)
			# connects the tiles' tile_scene_clicked signal to the connected tile scene
			for y in grid_height:
				for x in grid_width:
					var tile_scene = grid[y][x]
					# first check if tile is null and if the connection is already there
					if tile_scene != null and !tile_scene.tile_scene_clicked.is_connected(connected._on_tile_clicked):
						tile_scene.tile_scene_clicked.connect(connected._on_tile_clicked)
			
			#var gp = tile.grid_pos # this is commented out temporarily so that it doesn't crash - bonsai im working on the tile scene making it so that it can be moved when it is reparented
			#grid[gp.y][gp.x] = connected

func on_swap_tile(from_pos, direction):
	if done_updating and !is_swapping:
		# sets new position based on where it came from place the direction of the swap
		var to_pos = from_pos + direction
		# this makes sure the tile can't be moved outside of the grid
		var slideInstead = false
		
		if (to_pos.x < 0 || to_pos.x >= grid_width || to_pos.y < 0 || to_pos.y >= grid_height):
			return
		
		# checks if where it's swapping with is the same type of tile (I think)
		if (grid[from_pos.y][from_pos.x].tile_type == grid[to_pos.y][to_pos.x].tile_type):
			return
#		if grid[from_pos.y][from_pos.x].tile_type == Globals.TileType.GHOST or grid[to_pos.y][to_pos.x].tile_type == Globals.TileType.GHOST:
#			return

		if grid[to_pos.y][to_pos.x] != null:
			if (grid[from_pos.y][from_pos.x].tile_type == grid[to_pos.y][to_pos.x].tile_type):
				return
			if Tile.TileStats.CAN_SWAP not in Tile.tile_stats[grid[from_pos.y][from_pos.x].tile_type] or Tile.TileStats.CAN_SWAP not in Tile.tile_stats[grid[to_pos.y][to_pos.x].tile_type]:
				return
		else:
			slideInstead = true
			if Tile.TileStats.CAN_SWAP not in Tile.tile_stats[grid[from_pos.y][from_pos.x].tile_type]:
				return
		
		is_swapping = true
		
		# keeps track of the previous swaps that have been made
		previous_swaps.append(grid)
		
		# updates where the tiles are at
		set_tile_scene_position(grid[from_pos.y][from_pos.x], from_pos.x, from_pos.y)
		set_tile_scene_position(grid[to_pos.y][to_pos.x], to_pos.x, to_pos.y)
		
		generate_connected_tiles()

		
#		# Removes a Temporary Tile
#		if grid[from_pos.y][from_pos.x].tile_type == Globals.TileType.GHOST:
#			grid[from_pos.y][from_pos.x].queue_free()
#			grid[from_pos.y][from_pos.x] = null
		
		if get_matched_tiles() != []:
			previous_swaps = []
		
		# Reverts changes if no matches were made if allowed
		if get_matched_tiles() == [] and false:
			await get_tree().create_timer(0.25).timeout
		
		if !slideInstead:
			var tmp = grid[from_pos.y][from_pos.x]
			grid[from_pos.y][from_pos.x] = grid[to_pos.y][to_pos.x]
			grid[to_pos.y][to_pos.x] = tmp
		
			set_tile_scene_position(grid[from_pos.y][from_pos.x], from_pos.x, from_pos.y)
			set_tile_scene_position(grid[to_pos.y][to_pos.x], to_pos.x, to_pos.y)
		else:
			move_tile(from_pos.x, from_pos.y, to_pos.x, to_pos.y)
		
		
		
		if get_matched_tiles() != []:
			previous_swaps = []
		
		
		is_swapping = false

func on_unswap_tiles():
	if done_updating and !is_swapping:
		is_swapping = true
		var to_pos:Vector2
		var from_pos:Vector2
		var tmp = grid[from_pos.y][from_pos.x]
		
		
		# Still Needs Reimplemented
		previous_swaps.reverse()
		for swap in previous_swaps:
			await get_tree().create_timer(0.05).timeout
		
		previous_swaps = []
		is_swapping = false


#func update_tile_group(x, y, group_id, tile_type):
#	if (x < 0 || x >= grid_width || y < 0 || y >= grid_height || grid[y][x] == null):
#		return
#	if (can_fall(x,y) || grid[y][x].group_id != NO_GROUP || grid[y][x].tile_type != tile_type):
#		return
#
#	grid[y][x].group_id = group_id
#	if group_counts.get(group_id):
#		group_counts[group_id] += 1
#	else:
#		group_counts[group_id] = 1
#
#	update_tile_group(x-1, y, group_id, tile_type)
#	update_tile_group(x+1, y, group_id, tile_type)
#	update_tile_group(x, y-1, group_id, tile_type)
#	update_tile_group(x, y+1, group_id, tile_type)
