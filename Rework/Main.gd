extends Control

enum Tab {SPRITESHEET, FRAME_LIST, CUSTOMIZATION}

const FORMATS = ["bmp", "dds", "exr", "hdr", "jpg", "jpeg", "png", "tga", "svg", "svgz", "webp"]

@onready var tabs: TabContainer = %Tabs
@onready var repack: PanelContainer = $Repack
@onready var sprite_sheet_grid: GridContainer = %SpriteSheetGrid
@onready var preview: PanelContainer = %Preview
@onready var preview_button: Button = %PreviewButton

@onready var frame_width: SpinBox = %FrameWidth
@onready var frame_height: SpinBox = %FrameHeight
@onready var size_label: Label = %SizeLabel
@onready var size_format := size_label.text

@onready var confirm_new: ConfirmationDialog = $ConfirmNew
@onready var save_path: LineEdit = %SavePath
@onready var save_button: Button = %SaveButton
@onready var save_pick_dialog: FileDialog = %SavePickDialog

var default_filename = "Spritesheet-inator.png"

var filter_cache: PackedStringArray
var update_pending: bool

var spritesheet: SpriteSheet

func _ready() -> void:
	for i in range(1, tabs.get_tab_count()):
		tabs.set_tab_disabled(i, true)
	get_window().files_dropped.connect(_on_files_dropped)
	
	filter_cache = FORMATS.map(func(format: String) -> String: return "*.%s" % format)
	var filter_string := ", ".join(filter_cache) + ";Image Files"
	filter_cache = [filter_string]
	
	_new_spritesheet()
	update_save_button()

func add_directory(directory: String):
	for file in DirAccess.get_files_at(directory):
		create_frame_from_path(directory.path_join(file))
	
	assign_path(directory.path_join(default_filename))

func _new_spritesheet() -> void:
	if spritesheet:
		confirm_new.popup_centered()
	else:
		spritesheet = SpriteSheet.new()
		
		tabs.set_tab_disabled(Tab.FRAME_LIST, false)
		tabs.current_tab = Tab.FRAME_LIST
		preview.preview_frame.spritesheet = spritesheet
	
	update_size()
	spritesheet.changed.connect(update_size)

func _discard_spritesheet() -> void:
	spritesheet = null
	_new_spritesheet()
	queue_update_frames()

func _add_files() -> void:
	var callback := func(status: bool, selected_paths: PackedStringArray, selected_filter_index: int):
		if not status:
			return
		
		for path in selected_paths:
			create_frame_from_path(path)
	
	DisplayServer.file_dialog_show("Select Images", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILES, filter_cache, callback)

func _add_directory() -> void:
	var callback := func(status: bool, selected_paths: PackedStringArray, selected_filter_index: int):
		if not status:
			return
		
		add_directory(selected_paths[0])
	
	DisplayServer.file_dialog_show("Select Directory", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_DIR, [], callback)

func _repack_spritesheet() -> void:
	var callback := func(status: bool, selected_paths: PackedStringArray, selected_filter_index: int):
		if not status:
			return
		
		repack.repack_file(selected_paths[0])
	
	DisplayServer.file_dialog_show("Select Image", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, filter_cache, callback)

func _paste_image_from_clipboard() -> void:
	if not DisplayServer.clipboard_has_image():
		return
	
	create_frame_from_image(DisplayServer.clipboard_get_image())

func queue_update_frames():
	if update_pending:
		return
	update_pending = true
	
	var no_frames := spritesheet.frames.size() + spritesheet.unused_frames.size() == 0
	tabs.set_tab_disabled(Tab.CUSTOMIZATION, no_frames)
	preview_button.disabled = no_frames
	if no_frames:
		preview_button.button_pressed = false
	
	var updater := func():
		sprite_sheet_grid.update_frame_list()
		update_size()
		update_pending = false
	
	update_save_button()
	updater.call_deferred()

func create_frame_from_image(image: Image):
	var frame := SpriteSheet.Frame.new()
	frame.source_image = image
	frame.initialize()
	spritesheet.frames.append(frame)
	
	if spritesheet.frame_size == Vector2i():
		spritesheet.frame_size = frame.image.get_size()
	
	queue_update_frames()
	return frame

func create_frame_from_path(path: String):
	if not path.get_extension() in FORMATS:
		return
	
	var frame := SpriteSheet.Frame.new()
	frame.file_path = path
	frame.initialize()
	spritesheet.frames.append(frame)
	
	if spritesheet.frame_size == Vector2i():
		spritesheet.frame_size = frame.image.get_size()
	
	queue_update_frames()
	return frame

func assign_path(path: String):
	if save_path.text.is_empty():
		save_path.text = path
		update_save_button()

func save_spritesheet() -> void:
	var frame_size: Vector2i = spritesheet.frame_size + spritesheet.margins * 2
	var saving_image := Image.create(frame_size.x * sprite_sheet_grid.columns, frame_size.y * sprite_sheet_grid.get_rows(), false, Image.FORMAT_RGBA8)
	
	var idx: int
	for frame in spritesheet.frames:
		saving_image.blit_rect(frame.image, Rect2i(Vector2(), frame_size), Vector2i(idx % sprite_sheet_grid.columns, idx / sprite_sheet_grid.columns) * frame_size + Vector2i(spritesheet.margins + frame.offset))
		idx += 1
	
	saving_image.save_png(save_path.text)

func update_size():
	frame_width.set_value_no_signal(spritesheet.frame_size.x)
	frame_height.set_value_no_signal(spritesheet.frame_size.y)
	
	var frame_size: Vector2i = spritesheet.frame_size + spritesheet.margins * 2
	frame_size.x *= sprite_sheet_grid.columns
	frame_size.y *= sprite_sheet_grid.get_rows()
	size_label.text = size_format % [frame_size.x, frame_size.y]

func _pick_save_file() -> void:
	save_pick_dialog.current_path = save_path.text
	save_pick_dialog.popup_centered()

func _on_file_picked(path: String) -> void:
	if path.get_extension().is_empty():
		save_path.text = path + ".png"
	else:
		save_path.text = path
	update_save_button()

func update_save_button() -> void:
	var path := save_path.text
	if path.is_empty():
		save_button.tooltip_text = "Path is empty."
	elif not path.is_absolute_path():
		save_button.tooltip_text = "Path must be absolute."
	elif path.get_extension() != "png":
		save_button.tooltip_text = "Must be a PNG file."
	elif spritesheet.frames.is_empty():
		save_button.tooltip_text = "SpriteSheet is empty."
	else:
		save_button.tooltip_text = ""
	
	save_button.disabled = not save_button.tooltip_text.is_empty()

func _on_files_dropped(files: PackedStringArray):
	for file in files:
		if DirAccess.dir_exists_absolute(file):
			add_directory(file)
		else:
			create_frame_from_path(file)
			assign_path(file.get_base_dir().path_join(default_filename))
