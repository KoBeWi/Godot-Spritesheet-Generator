extends Control

const FORMATS = ["bmp", "dds", "exr", "hdr", "jpg", "jpeg", "png", "tga", "svg", "svgz", "webp"]

@onready var repack: PanelContainer = %Repack
@onready var frame_container: HBoxContainer = %FrameContainer

var filter_cache: PackedStringArray
var spritesheet: SpriteSheet:
	get:
		return owner.spritesheet

func _ready() -> void:
	get_window().files_dropped.connect(_on_files_dropped)
	
	filter_cache = FORMATS.map(func(format: String) -> String: return "*.%s" % format)
	var filter_string := ", ".join(filter_cache) + ";Image File"
	filter_cache = [filter_string]
	
	owner.ready.connect(update_all_frames)

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
		owner.assign_path(selected_paths[0].get_base_dir().path_join(Settings.settings.default_file_name + ".png"))
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
	image.convert(Image.FORMAT_RGBA8)
	
	var frame := SpriteSheet.Frame.new()
	frame.source_image = image
	frame.initialize()
	spritesheet.add_frame(frame)
	
	ensure_size(frame.image.get_size())
	
	owner.queue_update_frames()
	return frame

func create_frame_from_path(path: String) -> SpriteSheet.Frame:
	if not path.get_extension() in FORMATS:
		return
	
	var frame := SpriteSheet.Frame.new()
	frame.file_path = path
	frame.initialize()
	spritesheet.add_frame(frame)
	
	ensure_size(frame.image.get_size())
	
	owner.queue_update_frames()
	return frame

func add_directory(directory: String):
	for file in DirAccess.get_files_at(directory):
		create_frame_from_path(directory.path_join(file))
	
	for frame in spritesheet.frames:
		ensure_size(frame.image.get_size())
	
	owner.assign_path(directory.path_join(Settings.settings.default_file_name + ".png"))

func save_last_folder(folder: String):
	Settings.settings.last_folder = folder
	Settings.node.save_timer.start()

func ensure_size(s: Vector2i):
	spritesheet.frame_size = spritesheet.frame_size.max(s)

func update_all_frames():
	for frame in frame_container.get_children():
		frame.free()
	
	if spritesheet.all_frames.is_empty():
		var label := Label.new()
		label.text = "None"
		frame_container.add_child(label)
		return
	
	frame_container.add_child(VSeparator.new())
	for frame in spritesheet.all_frames:
		if frame.image.get_size() == Vector2i(1, 1):
			continue
		
		var trect := TextureRect.new()
		trect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		trect.mouse_filter = Control.MOUSE_FILTER_STOP
		trect.texture = frame.texture
		frame_container.add_child(trect)
		
		trect.gui_input.connect(add_deleted_frame.bind(frame))
		
		frame_container.add_child(VSeparator.new())

func add_deleted_frame(event: InputEvent, frame: SpriteSheet.Frame):
	var mb := event as InputEventMouseButton
	if mb and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		spritesheet.frames.append(frame)
		owner.queue_update_frames() # TODO: This will reload the frame_container, which is not ideal.
