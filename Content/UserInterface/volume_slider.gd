extends Control

# Use your audio to test volume manipulation

@onready var sprite: Sprite2D = get_node("Sprite2D") as Sprite2D

var master_bus = AudioServer.get_bus_index("Master")

const audio_off = preload("res://art/pieces/audioOff.png")
const audio_on = preload("res://art/pieces/audioOn.png")


func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus, value)
	
	if value == -30:
		AudioServer.set_bus_mute(master_bus, true)
		sprite.texture = audio_off
	else:
		AudioServer.set_bus_mute(master_bus, false)
		sprite.texture = audio_on
	
