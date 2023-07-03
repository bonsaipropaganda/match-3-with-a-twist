@tool
extends Node2D


signal move_left_changed(value: int)
signal score_changed(value: int)
signal game_over()


const GRID_COLOR := Color("fce1cf")
const LINE_WIDTH: float = 2.0
const TILE_MARGIN: float = 3.0

const TIMESTEP = 0.2

@export_group("Grid Variables")
@export var grid_width = 6
@export var grid_height = 6
@export_color_no_alpha var background_color := Color.BLACK

@export_group("Tile Variables")
@export var tile_width: float = 70
## Tile falling speed in tiles/second
@export var falling_speed: float = 10.0
## Tile swapping speed in tiles/second
@export var swapping_speed: float = 12.0

@onready var tile_scene := preload("res://Content/Tile/tile.tscn")

var grid: Array
var group_counts: Dictionary
var currently_moving_tiles: int = 0
var done_updating := false
var doing_swap: bool = false
var prevoius_swaps: Array = []


# Move count stuff
var move_left: int = 10:
	set(value):
		move_left = value
		move_left_changed.emit(value)
		if value < 0: # if you hit LESS than zero then game over
			# TODO: game over should be at the end of the grid update (when nothing moves anymore)
			game_over.emit()

# score stuff
var score: int = 0:
	set(value):
		score = value
		score_changed.emit(value)


func _ready():
	queue_redraw()
	
	if Engine.is_editor_hint():
		return
	
	$Timer.wait_time = TIMESTEP
	Globals.connect("swap_tile", on_swap_tile)
	grid = init_grid(grid_width, grid_height)
	
	for y in grid_height:
		for x in grid_width:
			add_tile(x,y)
	
	# Update move left after ready
	move_left_changed.emit(move_left)
	
	position.x = 640 - (tile_width * grid_width)/2
	position.y = 360 - (tile_width * grid_height)/2
	
func _process(_delta):
	if Engine.is_editor_hint():
		queue_redraw()
	else:
		if !done_updating && $Timer.is_stopped():
			$Timer.start()


func _on_timer_timeout():
	update_grid()


func update_grid():
	# Gravity
	for x in range(0, grid_width):
		var ground_level: int = grid_height - 1
		for y in range(grid_height - 1, -1, -1):
			if not is_instance_valid(grid[y][x]): continue
			
			if Tile.TileStats.CAN_FALL in Tile.tile_stats[grid[y][x].tile_type]:
				if ground_level != y: # If the tile is not on ground, make it fall
					move_tile(x, y, x, ground_level, true, falling_speed)
					done_updating = false
				# Raise ground level
				ground_level -= 1
			else:
				# Update the ground to be above this tile
				ground_level = y - 1
	
	
	# Handle matches
	var matches = []
	if is_board_settled():
		matches = get_matches()
		
		# Remove tiles from the board
		for i in matches: # [tile_type, x, y]
			var x = i[1]
			var y = i[2]
			if grid[y][x] != null:
				grid[y][x].queue_free()
				grid[y][x] = null
		
		# Reward the player for matches
		if matches != []:
			prevoius_swaps = []
		
		add_moves(matches.size())
		add_score(matches.size())
		play_sfx(matches.size())
	
	if matches.size() == 0:
		if is_board_settled():
			done_updating = true
			
		# Add tiles to the game
		for x in grid_width:
			# Get the amount of tiles to be added
			var new_tile_count: int = 0
			for y in grid_height:
				if is_instance_valid(grid[y][x]): break
				
				new_tile_count += 1
				done_updating = false
			
			for i in new_tile_count:
				var y: int = new_tile_count - 1 - i
				add_tile(x, y)
				
				# Animate tile entering the screen
				var tile: Tile = grid[y][x]
				tile.grid_pos = Vector2(x, -i-1) # Well... that's a bit hacky... but it works !
				tile.position = get_tile_scene_position(x, -i-1)
				animate_tile_scene_position(tile, x, y, falling_speed)
	
	# Unswaps all the tiles swaped when the length of previous swaps that havent made a match = 3 if enabled
	if len(prevoius_swaps) == 3:
		on_unswap_tiles()


func init_grid(width, height):
	var g = []
	for i in height:
		g.append([])
		for j in width:
			g[i].append(null)
	return g


func _draw():
	# Background, tiles on it are not clipped
	draw_rect(Rect2(Vector2.ZERO, tile_width * Vector2(grid_width, grid_height)), background_color)
	# Vertical lines
	for x in grid_width + 1:
		draw_line(Vector2(x * tile_width, 0), Vector2(x * tile_width, grid_height * tile_width), GRID_COLOR, 2.0)
	# Horizontal lines
	for y in grid_height + 1:
		draw_line(Vector2(0, y * tile_width), Vector2(grid_width * tile_width, y * tile_width), GRID_COLOR, 2.0)


func set_tile_scene_position(tile: Tile, x: int, y: int):
	tile.position = get_tile_scene_position(x, y)
	tile.grid_pos = Vector2(x,y)


func animate_tile_scene_position(tile: Tile, x: int, y: int, speed: float) -> void:
	# Move tile
	var final_grid_pos := Vector2i(x, y)
	var final_scene_pos: Vector2 = get_tile_scene_position(x, y)
	var distance: float = (final_grid_pos - Vector2i(tile.grid_pos)).length()
	tile.grid_pos = Vector2(x, y)
	var duration: float = distance / speed
	tile.animated_move_to(final_scene_pos, duration)
	
	# Keep count of moving tiles
	currently_moving_tiles += 1
	tile.done_moving.connect(func(): currently_moving_tiles -= 1, CONNECT_ONE_SHOT)


func add_tile(x, y) -> bool:
	if x < 0 || x >= grid_width || y < 0 || y >= grid_height:
		return false # Do not try to add tiles out of bounds
	if grid[y][x] != null:
		return false # Do not try to spawn tiles on top of each other
	
	var new_tile = tile_scene.instantiate()
	grid[y][x] = new_tile
	set_tile_scene_position(new_tile, x, y)
	new_tile.initialise(tile_width, TILE_MARGIN)
	add_child(new_tile)
	return true


# Move tile to empty space
func move_tile(x1, y1, x2, y2, animated := false, tile_speed: float = 1.0):
	if grid[y1][x1] != null && grid[y2][x2] == null:
		if not animated:
			set_tile_scene_position(grid[y1][x1], x2, y2)
		else:
			animate_tile_scene_position(grid[y1][x1], x2, y2, tile_speed)
		grid[y2][x2] = grid[y1][x1]
		grid[y1][x1] = null


func can_fall(x, y):
	if y == grid_height - 1:
		return false
	else:
		return grid[y][x] != null && grid[y+1][x] == null


func get_matches():
	var matches := []
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
						matches.append_array(to_check)
					to_check.clear()
					to_check.append([grid[y][x].tile_type, x, y])
				elif grid[y][x].tile_type == to_check.back()[0]:
					to_check.append([grid[y][x].tile_type, x, y])
					if y == grid_height-1 && to_check.size() >= 3:
						to_check.append([grid[y][x].tile_type, x, y])
						matches.append_array(to_check)
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
						matches.append_array(to_check)
					to_check.clear()
					to_check.append([grid[y][x].tile_type, x, y])
				elif grid[y][x].tile_type == to_check.back()[0]:
					to_check.append([grid[y][x].tile_type, x, y])
					if x == grid_width-1 && to_check.size() >= 3:
						to_check.append([grid[y][x].tile_type, x, y])
						matches.append_array(to_check)
			else:
				# if the tile is null this runs
				if !to_check.is_empty():
					if to_check.size() >= 3:
						matches.append_array(to_check)
				to_check.clear()
		
		# Stops Tile from breaking if that tile doesnt have the BREAK_ON_MATCH Stat
		for tile in matches:
			if Tile.TileStats.BREAK_ON_MATCH not in Tile.tile_stats[tile[0]]:
				matches.erase(tile)
	
	# Makes Tile break if that tile has the BREAK_ON_AGACENT_MATCH Stat and is agacent to a match that was made
	for row in grid:
		for tile in row:
			if tile != null:
				if Tile.TileStats.BREAK_ON_ADJACENT_MATCH in Tile.tile_stats[tile.tile_type]:
					for free in matches:
						if tile.grid_pos.distance_to(Vector2(free[1],free[2])) == 1:
							matches.append([tile.tile_type, tile.grid_pos.x, tile.grid_pos.y])
#	matches += to_check
	return matches


func on_swap_tile(from_pos, direction):
	if done_updating and !doing_swap:
		var to_pos = from_pos + direction
		var slideInstead = false
		
		if (to_pos.x < 0 || to_pos.x >= grid_width || to_pos.y < 0 || to_pos.y >= grid_height):
			return
		
		# Spawns a Temporary Tile
		if grid[to_pos.y][to_pos.x] != null:
			if (grid[from_pos.y][from_pos.x].tile_type == grid[to_pos.y][to_pos.x].tile_type):
				return
			if Tile.TileStats.CAN_SWAP not in Tile.tile_stats[grid[from_pos.y][from_pos.x].tile_type] or Tile.TileStats.CAN_SWAP not in Tile.tile_stats[grid[to_pos.y][to_pos.x].tile_type]:
				return
		else:
			slideInstead = true
			# Don't allow for moving a tile up
			if to_pos.y - from_pos.y == -1:
				return
			# Don't allow to slide an unswappable tile
			if Tile.TileStats.CAN_SWAP not in Tile.tile_stats[grid[from_pos.y][from_pos.x].tile_type]:
				return
		
		doing_swap = true
		
		prevoius_swaps.append(grid)
		move_left -= 1 # Decrease move counter
		
		
		if !slideInstead:
			var tmp = grid[from_pos.y][from_pos.x]
			grid[from_pos.y][from_pos.x] = grid[to_pos.y][to_pos.x]
			grid[to_pos.y][to_pos.x] = tmp
		
			animate_tile_scene_position(grid[from_pos.y][from_pos.x], from_pos.x, from_pos.y, swapping_speed)
			animate_tile_scene_position(grid[to_pos.y][to_pos.x], to_pos.x, to_pos.y, swapping_speed)
		else:
			move_tile(from_pos.x, from_pos.y, to_pos.x, to_pos.y, true, swapping_speed)
		
		doing_swap = false
		done_updating = false


func on_unswap_tiles():
	if done_updating and !doing_swap:
		doing_swap = true
		
		# Still Needs Reimplemented
		prevoius_swaps.reverse()
		for swap in prevoius_swaps:
			await get_tree().create_timer(0.05).timeout
			pass
		
		prevoius_swaps = []
		doing_swap = false
		done_updating = false


# basically add more moves depending on the match size
func add_moves(tiles_matched):
	if tiles_matched >= 6:
		move_left += 4


func add_score(tiles_matched):
	if tiles_matched == 3:
		score += 40
	elif tiles_matched == 4:
		score += 60
	elif tiles_matched == 5:
		score += 80
	elif tiles_matched >= 6:
		score += 0

func play_sfx(tiles_matched):
	if tiles_matched >= 3:
		%Match.play()

func get_tile_scene_position(x: int, y: int) -> Vector2:
	return Vector2(x * tile_width, y * tile_width) + Vector2(TILE_MARGIN, TILE_MARGIN)


func is_board_settled() -> bool:
	return currently_moving_tiles == 0

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
