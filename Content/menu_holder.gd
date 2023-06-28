class_name MenuHolder
extends Node


"""
The list of all menus this MenuHolder has.
Keys should be StringName and values should be a String with the path to menus.
"""
@export var menus: Dictionary = {}

var current_menu_stack: Array[StringName] = []
var cached_menus: Dictionary = {} # Idk if a cache is needed

"""
Opens a menu above what's already loaded.
To replace the current menu, use change_to_menu`.
"""
func open_menu(menu: StringName) -> void:
	if !is_loaded(menu):
		load_menu(menu)
	current_menu_stack.push_back(menu)
	add_child(cached_menus[menu])


"""
Replaces the current menu with `menu`.
"""
func change_to_menu(menu: StringName) -> void:
	close_menu()
	open_menu(menu)


"""
Close the last opened menu.
"""
func close_menu() -> void:
	if get_child_count() < 1:
		push_error("There are no menus to close")
		return
	current_menu_stack.pop_back()
	var last: Node = get_child(get_child_count()-1)
	remove_child(last) # Don't queue free because menu is cached


"""
Loads a menu and caches it (sync, TODO: maybe use threaded load ?).
"""
func load_menu(menu: StringName) -> void:
	if not menu in menus:
		push_error("Menu %s does not exist" % [menu as String])
		return
	if menu in  cached_menus:
		push_warning("Menu %s has already been loaded" % [menu as String])
		return
	
	cached_menus[menu] = ResourceLoader.load(menus[menu], "PackedScene").instantiate()


func is_loaded(menu: StringName) -> bool:
	return menu in cached_menus


func has_opened_menu() -> bool:
	return len(current_menu_stack) > 0


func get_last_opened_menu() -> StringName:
	if not has_opened_menu():
		return &""
	return current_menu_stack[len(current_menu_stack)-1]
