extends Control

const SPRITE_WIDTH = 128.0 # Currently set to width of placeholder image

var tile_type: TileType

enum TileType {
	RED,
	BLUE,
	GREEN,
	YELLOW,
}

# Indexed by TileType
# Replace these with the actual images
const tile_images = [
	preload("res://icon.svg"),
	preload("res://icon.svg"),
	preload("res://icon.svg"),
	preload("res://icon.svg"),
]

# These are to distinguish tiles before we have sprites
# Delete this after we add sprites
const tile_colors = [
	Color("ef2655"),
	Color("2655ef"),
	Color("55ef26"),
	Color("efe526"),
]

func initialise(tile_width : float, margin_width):
	tile_width -= margin_width * 2
	scale *= tile_width / SPRITE_WIDTH
	
	randomize()
	tile_type = randi() % TileType.size()
	$Sprite2D.texture = tile_images[tile_type]
	$Sprite2D.modulate = tile_colors[tile_type]
