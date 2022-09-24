@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_tool_menu_item("Open Spritesheet Generator", run_generator)
	get_editor_interface().get_command_palette().add_command("Open Spritesheet Generator", "addons/open_spritesheet_generator", run_generator)

func _exit_tree() -> void:
	remove_tool_menu_item("Open Spritesheet Generator")
	get_editor_interface().get_command_palette().remove_command("addons/open_spritesheet_generator")

func run_generator():
	get_editor_interface().play_custom_scene("res://addons/SpritesheetGenerator/SpritesheetGenerator.tscn")
