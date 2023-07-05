@tool
extends Node


@export var button_down_stream: AudioStream
@export var button_up_stream: AudioStream
@export var pressed_stream: AudioStream

var main: Node


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	main = get_node("/root/Main")
	
	var parent: BaseButton = get_parent()
	parent.button_down.connect(_try_play_stream.bind(button_down_stream))
	parent.pressed.connect(_try_play_stream.bind(pressed_stream))
	parent.button_up.connect(_try_play_stream.bind(button_up_stream))


func _try_play_stream(stream: AudioStream) -> void:
	if not stream:
		return
	main.play_global_sfx(stream)


func _get_configuration_warnings() -> PackedStringArray:
	var warns := PackedStringArray()
	var parent: Node = get_parent()
	if not parent is BaseButton:
		warns.push_back("Buttion Sfx Node should be parented to a button")
	return warns
