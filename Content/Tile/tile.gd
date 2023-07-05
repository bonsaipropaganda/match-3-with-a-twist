extends Area2D


signal done_moving()


const SPRITE_WIDTH = 108.0*1.5 # Currently set to width of placeholder image

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
#const tile_images = [
#	preload("res://art/pieces/unselected_pink.png"),
#	preload("res://art/pieces/unselected_orange.png"),
#	preload("res://art/pieces/unselected_red.png"),
#	preload("res://art/pieces/unselected_blue.png"),
#	preload("res://art/pieces/unselected_green.png"),
#	preload("res://art/pieces/unselected_yellow.png"),
#	preload("res://art/pieces/unselected_grey.png"),
#	preload("res://art/pieces/unselected_ghost.png"),
#]

const tile_images = [
	preload("res://art/pieces/outline/tilePink.png"),
	preload("res://art/pieces/outline/tileOrange.png"),
	preload("res://art/pieces/outline/tileRed.png"),
	preload("res://art/pieces/outline/tileBlue.png"),
	preload("res://art/pieces/outline/tileGreen.png"),
	preload("res://art/pieces/outline/tileYellow.png"),
	preload("res://art/pieces/outline/tileBlack.png"),
	preload("res://art/pieces/outline/tileGrey.png")
]


func initialise(_tile_width : float, margin_width):
	tile_width = _tile_width - margin_width * 2
	scale *= tile_width / SPRITE_WIDTH
	$CollisionShape2D.position = Vector2.ONE * tile_width
	$CollisionShape2D.shape.size = Vector2.ONE * tile_width * 2
	
	
	tile_type = randi() % TileType.size() as TileType
	if tile_type == 6: # decreases chances of getting grey tile type
		tile_type = randi() % TileType.size() as TileType
	sprite2D = $SpriteHolder/Sprite2D
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
	var direction = (target_pos-position).normalized()
	scale_tween(Vector2(0.8,0.8)-abs(Vector2.ONE-direction)*0.3, Vector2.ONE, 0.5)
	
	if move_tween:
		if move_tween.is_running():
			move_tween.stop()
			position = final_move_position
			done_moving.emit() # Send the done moving signal for cancellation
		move_tween.kill()
	
	move_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	move_tween.tween_property(self, ^"position", target_pos, duration)
	move_tween.tween_callback(func(): done_moving.emit())
	final_move_position = target_pos
	await get_tree().create_timer(duration).timeout
	
#	var r = randi_range(0,1); if r==0:r=-1
#	DampedOscillator.animate($SpriteHolder/Sprite2D, "scale", randf_range(225,275), randf_range(6,7),randf_range(8,11), randf_range(0.20,0.3)*r)
	DampedOscillator.animate($SpriteHolder/Sprite2D, "scale", randf_range(225,275), randf_range(6,7),randf_range(8,11), randf_range(0.20,0.3))

func destroy() -> void:
	$DeathParticle.texture = $SpriteHolder/Sprite2D.texture
	$DeathParticle/AnimationPlayer.play("Anim")
	$DeathParticle.emitting=true
	$SpriteHolder.hide()
	await get_tree().create_timer(5).timeout
	queue_free()

var last_tween
func scale_tween(start_var, final_var, duration) -> void:
	$SpriteHolder.scale = start_var
	if last_tween: last_tween.stop()
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	last_tween = tween
	tween.tween_property($SpriteHolder, "scale", final_var, duration)

func _on_mouse_entered() -> void:
	scale_tween($SpriteHolder.scale, Vector2(1.1,1.1), 0.2)

func _on_mouse_exited() -> void:
	scale_tween($SpriteHolder.scale, Vector2(1,1), 0.2)
