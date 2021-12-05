tool
extends EditorPlugin

func _enter_tree() -> void:
	add_tool_menu_item("Open Spritesheet Generator", self, "run_generator")

func _exit_tree() -> void:
	remove_tool_menu_item("Open Spritesheet Generator")

func run_generator(whatever):
	get_editor_interface().play_custom_scene("res://addons/SpritesheetGenerator/SpritesheetGenerator.tscn")
