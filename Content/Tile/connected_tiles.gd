extends Area2D
class_name ConnectedTiles

var tile_type
var clicked: bool = false
var tile_width: int

func _process(delta: float) -> void:
	drag_pieces()

# TODO: we need to check and see if this scene has been clicked
# if clicked need to have pos follow the mouse around

func _on_tile_clicked():
	#if clicked == false:
	clicked = true
	#else: clicked = false

func drag_pieces():
	if clicked == true:
		var mouse_pos = get_global_mouse_position()
		var target_pos = (mouse_pos - self.position).normalized()
		self.global_position = $mouse_pos.position
