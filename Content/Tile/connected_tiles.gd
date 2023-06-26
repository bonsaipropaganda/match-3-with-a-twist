extends Area2D
class_name ConnectedTiles

var tile_type
var clicked =  false
var tile_width: int

func _process(delta: float) -> void:
	if clicked:
		global_position = lerp(global_position,get_global_mouse_position(), 25 * delta)

func _on_tile_clicked():
	clicked = true

func _input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		print("clicked = ", clicked)
		clicked = false
		print("clicked = ", clicked)
