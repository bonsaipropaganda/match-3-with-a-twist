@tool
extends Node2D

const GRID_COLOR = Color("fce1cf")
const LINE_WIDTH = 2.0
const TILE_MARGIN = 3.0

@export var grid_width = 5
@export var grid_height = 5
@export var tile_width = 70
var grid: Array

@onready var tile_scene := preload("res://Content/Tile/tile.tscn")

func _ready():
	if !Engine.is_editor_hint():
		grid = init_grid(grid_width, grid_height)
		add_tile(0,0)
		add_tile(0,1)
		add_tile(0,3)
		add_tile(4,2)
		add_tile(2,0)
	queue_redraw()

func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()
	else:
		if Input.is_action_just_pressed("ui_accept"):
			update_grid()

func _draw():
	# Vertical lines
	for x in grid_width + 1:
		draw_line(Vector2(x * tile_width, 0), Vector2(x * tile_width, grid_height * tile_width), GRID_COLOR, 2.0)
	# Horizontal lines
	for y in grid_height + 1:
		draw_line(Vector2(0, y * tile_width), Vector2(grid_width * tile_width, y * tile_width), GRID_COLOR, 2.0)

func init_grid(width, height, fill_with=null):
	var g = []
	for i in height:
		g.append([])
		for j in width:
			g[i].append(fill_with)
	return g

func set_tile_position(tile, x, y):
	tile.position = Vector2(x * tile_width, y * tile_width) + Vector2(TILE_MARGIN, TILE_MARGIN)

func add_tile(x, y):
	if (x < 0 || x >= grid_width || y < 0 || y >= grid_height):
		assert(false) # Do not try to add tiles out of bounds
	if (grid[y][x] != null):
		assert(false) # Do not try to spawn tiles on top of each other
	
	var new_tile = tile_scene.instantiate()
	grid[y][x] = new_tile
	set_tile_position(new_tile, x, y)
	new_tile.initialise(tile_width, TILE_MARGIN)
	add_child(new_tile)

func move_tile(x1, y1, x2, y2):
	if grid[y1][x1] != null && grid[y2][x2] == null:
		set_tile_position(grid[y1][x1], x2, y2)
		grid[y2][x2] = grid[y1][x1]
		grid[y1][x1] = null

func update_grid():
	for y in range(grid_height-2, -1, -1):
		for x in range(0, grid_width):
			# Fall if space below is empty
			if grid[y][x] != null && grid[y+1][x] == null:
				move_tile(x, y, x, y+1)
