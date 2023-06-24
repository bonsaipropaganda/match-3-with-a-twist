extends Node

@export var main_menu_scene: PackedScene

func go_to_main_menu():
	get_tree().change_scene_to_packed(main_menu_scene)

func open_settings():
	%AudioSettings.show()
