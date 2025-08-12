extends Control

const FORMATS = ["bmp", "dds", "exr", "hdr", "jpg", "jpeg", "png", "tga", "svg", "svgz", "webp"]

@onready var repack: PanelContainer = %Repack

var filter_cache: PackedStringArray
var spritesheet: SpriteSheet:
	get:
		return owner.spritesheet

func _ready() -> void:
	get_window().files_dropped.connect(_on_files_dropped)
	
	filter_cache = FORMATS.map(func(format: String) -> String: return "*.%s" % format)
	var filter_string := ", ".join(filter_cache) + ";Image File"
	filter_cache = [filter_string]

func _on_files_dropped(files: PackedStringArray):
	for file in files:
		if DirAccess.dir_exists_absolute(file):
			add_directory(file)
		else:
			create_frame_from_path(file)
			owner.assign_path(file.get_base_dir().path_join(Settings.settings.default_file_name + ".png"))

func _add_files() -> void:
	var callback := func(status: bool, selected_paths: PackedStringArray, selected_filter_index: int):
		if not status:
			return
		
		save_last_folder(selected_paths[0].get_base_dir())
		for path in selected_paths:
			create_frame_from_path(path)
	
	DisplayServer.file_dialog_show("Select Images", Settings.settings.last_folder, "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILES, filter_cache, callback)

func _add_directory() -> void:
	var callback := func(status: bool, selected_paths: PackedStringArray, selected_filter_index: int):
		if not status:
			return
		
		save_last_folder(selected_paths[0])
		add_directory(selected_paths[0])
	
	DisplayServer.file_dialog_show("Select Directory", Settings.settings.last_folder, "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_DIR, [], callback)

func _repack_spritesheet() -> void:
	var callback := func(status: bool, selected_paths: PackedStringArray, selected_filter_index: int):
		if not status:
			return
		
		save_last_folder(selected_paths[0].get_base_dir())
		repack.repack_file(selected_paths[0])
	
	DisplayServer.file_dialog_show("Select Image", Settings.settings.last_folder, "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, filter_cache, callback)

func _paste_image_from_clipboard() -> void:
	if not DisplayServer.clipboard_has_image():
		return
	
	create_frame_from_image(DisplayServer.clipboard_get_image())

func _add_empty_frame() -> void:
	var image := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	create_frame_from_image(image)

func create_frame_from_image(image: Image):
	var frame := SpriteSheet.Frame.new()
	frame.source_image = image
	frame.initialize()
	spritesheet.add_frame(frame)
	
	if spritesheet.frame_size == Vector2i():
		spritesheet.frame_size = frame.image.get_size()
	
	owner.queue_update_frames()
	return frame

func create_frame_from_path(path: String):
	if not path.get_extension() in FORMATS:
		return
	
	var frame := SpriteSheet.Frame.new()
	frame.file_path = path
	frame.initialize()
	spritesheet.add_frame(frame)
	
	#if spritesheet.frame_size == Vector2i(): # źle
		#spritesheet.frame_size = frame.image.get_size()
	
	owner.queue_update_frames()
	return frame

func add_directory(directory: String):
	for file in DirAccess.get_files_at(directory):
		create_frame_from_path(directory.path_join(file))
	
	if spritesheet.frame_size == Vector2i():
		for frame in spritesheet.frames:
			spritesheet.frame_size = spritesheet.frame_size.max(frame.image.get_size())
	
	owner.assign_path(directory.path_join(Settings.settings.default_file_name + ".png"))

func save_last_folder(folder: String):
	Settings.settings.last_folder = folder
	Settings.node.save_timer.start()
