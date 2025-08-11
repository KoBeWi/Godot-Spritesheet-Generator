class_name Settings extends Control

@onready var default_name: LineEdit = %DefaultName
@onready var preview_width: SpinBox = %PreviewWidth
@onready var preview_height: SpinBox = %PreviewHeight
@onready var show_grid: CheckBox = %ShowGrid
@onready var grid_color_1: ColorPickerButton = %GridColor1
@onready var grid_color_2: ColorPickerButton = %GridColor2
@onready var show_outline: CheckBox = %ShowOutline
@onready var outline_color: ColorPickerButton = %OutlineColor
@onready var save_timer: Timer = %SaveTimer

static var node: Settings
static var settings: Dictionary[StringName, Variant]

signal settings_changed

func _init() -> void:
	node = self
	hide()
	
	var ss := FileAccess.get_file_as_string("user://settings")
	if ss.is_empty():
		apply_defaults()
	else:
		settings.assign(str_to_var(ss))

func _ready() -> void:
	default_name.text = settings.default_file_name
	preview_width.set_value_no_signal(settings.preview_size.x)
	preview_height.set_value_no_signal(settings.preview_size.y)
	show_grid.set_pressed_no_signal(settings.show_grid)
	grid_color_1.color = settings.grid_color1
	grid_color_2.color = settings.grid_color2
	show_outline.set_pressed_no_signal(settings.show_outline)
	outline_color.color = settings.outline_color

func queue_update_settings(...args):
	settings.default_file_name = default_name.text
	settings.preview_size.x = preview_width.value
	settings.preview_size.y = preview_height.value
	settings.show_grid = show_grid.button_pressed
	settings.grid_color1 = grid_color_1.color
	settings.grid_color2 = grid_color_2.color
	settings.show_outline = show_outline.button_pressed
	settings.outline_color = outline_color.color
	
	settings_changed.emit()
	save_timer.start()

func _on_save_timer_timeout() -> void:
	var f := FileAccess.open("user://settings", FileAccess.WRITE)
	f.store_string(var_to_str(settings))

func apply_defaults():
	settings.default_file_name = "Spritesheet-inator"
	settings.preview_size = Vector2i(256, 256)
	settings.show_grid = true
	settings.grid_color1 = Color.DARK_CYAN
	settings.grid_color2 = Color.DARK_CYAN.darkened(0.1)
	settings.show_outline = true
	settings.outline_color = Color(Color.CYAN, 0.2)
	
	if not &"last_folder" in settings:
		settings.last_folder = ""

func reset_settings() -> void:
	apply_defaults()
	_ready()
	queue_update_settings()

static func subscribe(callback: Callable):
	node.settings_changed.connect(callback)
