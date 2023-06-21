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

var grid: Array
var group_counts: Dictionary
var done_updating := false
var doingSwap:bool = false
var prevoiusSwaps:Array = []

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
	
	var to_free = []
	if settled:
		to_free = get_to_free()
		for i in to_free: # [tile_type, x, y]
			var x = i[1]
			var y = i[2]
			if grid[y][x] != null:
				grid[y][x].queue_free()
				grid[y][x] = null
	
	if to_free.size() == 0:
		done_updating = true
		for x in grid_width:
			if (add_tile(x, 0)):
				done_updating = false
	else:
		settled = false
	
	# Unswaps all the tiles swaped when the length of previous swaps that havent made a match = 3 if enabled
	if len(prevoiusSwaps) == 3 and true:
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
	tile.grid_pos = Vector2(x,y)

func add_tile(x, y) -> bool:
	if (x < 0 || x >= grid_width || y < 0 || y >= grid_height):
		assert(false) # Do not try to add tiles out of bounds
	if (grid[y][x] != null):
		return false # Do not try to spawn tiles on top of each other
	
	var new_tile = tile_scene.instantiate()
	grid[y][x] = new_tile
	set_tile_scene_position(new_tile, x, y)
	new_tile.initialise(tile_width, TILE_MARGIN)
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
	else:
		return grid[y][x] != null && grid[y+1][x] == null

func get_to_free():
	var to_free := []
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
						to_free.append_array(to_check)
					to_check.clear()
					to_check.append([grid[y][x].tile_type, x, y])
				elif grid[y][x].tile_type == to_check.back()[0]:
					to_check.append([grid[y][x].tile_type, x, y])
					if y == grid_height-1 && to_check.size() >= 3:
						to_check.append([grid[y][x].tile_type, x, y])
						to_free.append_array(to_check)
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
						to_free.append_array(to_check)
					to_check.clear()
					to_check.append([grid[y][x].tile_type, x, y])
				elif grid[y][x].tile_type == to_check.back()[0]:
					to_check.append([grid[y][x].tile_type, x, y])
					if x == grid_width-1 && to_check.size() >= 3:
						to_check.append([grid[y][x].tile_type, x, y])
						to_free.append_array(to_check)
			else:
				to_check.clear()
	return to_free

func on_swap_tile(from_pos, direction):
	if done_updating and !doingSwap:

		var to_pos = from_pos + direction
		
		if (to_pos.x < 0 || to_pos.x >= grid_width || to_pos.y < 0 || to_pos.y >= grid_height):
			return
		if (grid[from_pos.y][from_pos.x].tile_type == grid[to_pos.y][to_pos.x].tile_type):
			return
		
		doingSwap = true
		
		var tmp = grid[from_pos.y][from_pos.x]
		grid[from_pos.y][from_pos.x] = grid[to_pos.y][to_pos.x]
		grid[to_pos.y][to_pos.x] = tmp
		
		set_tile_scene_position(grid[from_pos.y][from_pos.x], from_pos.x, from_pos.y)
		set_tile_scene_position(grid[to_pos.y][to_pos.x], to_pos.x, to_pos.y)
		
		prevoiusSwaps.append([from_pos,to_pos])
		if get_to_free() != []:
			prevoiusSwaps = []
		
		# Reverts changes if no matches were made if allowed
		if get_to_free() == [] and false:
			await get_tree().create_timer(0.25).timeout
			
			tmp = grid[from_pos.y][from_pos.x]
			grid[from_pos.y][from_pos.x] = grid[to_pos.y][to_pos.x]
			grid[to_pos.y][to_pos.x] = tmp
		
			set_tile_scene_position(grid[from_pos.y][from_pos.x], from_pos.x, from_pos.y)
			set_tile_scene_position(grid[to_pos.y][to_pos.x], to_pos.x, to_pos.y)
		
		doingSwap = false
		done_updating = false

func on_unswap_tiles():
	if done_updating and !doingSwap:
		doingSwap = true
		var to_pos:Vector2
		var from_pos:Vector2
		var tmp = grid[from_pos.y][from_pos.x]
		
		
		prevoiusSwaps.reverse()
		for swap in prevoiusSwaps:
			await get_tree().create_timer(0.3).timeout
			
			to_pos = swap[0]
			from_pos = swap[1]
			tmp = grid[from_pos.y][from_pos.x]
			grid[from_pos.y][from_pos.x] = grid[to_pos.y][to_pos.x]
			grid[to_pos.y][to_pos.x] = tmp
		
			set_tile_scene_position(grid[from_pos.y][from_pos.x], from_pos.x, from_pos.y)
			set_tile_scene_position(grid[to_pos.y][to_pos.x], to_pos.x, to_pos.y)
		
		prevoiusSwaps = []
		doingSwap = false
		done_updating = false


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
