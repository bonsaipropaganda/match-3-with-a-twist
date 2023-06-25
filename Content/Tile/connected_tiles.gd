extends Area2D
class_name ConnectedTiles

var tile_type
var clicked: bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	#pass
	if clicked == true:
		self.position = get_global_mouse_position()

# TODO: we need to check and see if this scene has been clicked
# if clicked need to have pos follow the mouse around

func _on_tile_clicked():
	print("connection succesful!")
	clicked = true
