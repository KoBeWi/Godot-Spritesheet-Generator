extends Control

const SUPPORTED_FORMATS: PackedStringArray = ["bmp", "dds", "exr", "hdr", "jpg", "jpeg", "png", "tga", "svg", "svgz", "webp"]

var file_list: Array[String]
var image_list: Array[Image]
var texture_list: Array[Texture2D]

var images_to_process: Array
var images_to_texturize: Array
var image_count: int
var output_path: String

signal images_processed

func _enter_tree() -> void:
	$ProcessDialog.hide()
	$SplitDialog.hide()
	$StashDialog.hide()
	$PreviewDialog.hide()

func _ready():
	set_spritesheet_visible(false)
	
	$Welcome.text = $Welcome.text % ", ".join(SUPPORTED_FORMATS)
	%Load.get_popup().index_pressed.connect(load_dialog_option)
	
	get_viewport().files_dropped.connect(process_files)
	set_process(false)

func set_spritesheet_visible(vis: bool):
	$Welcome.visible = not vis
	$SpritesheetView.visible = vis
	$Controls.visible = vis
	
	%Reload.disabled = not vis
	%Close.disabled = not vis
	%PreviewButton.disabled = not vis

func process_files(files: PackedStringArray):
	%CustomName.text = ""
	%Reload.disabled = true
	%SavePNG.disabled = true
	
	file_list.clear()
	
	if files.size() == 1 and not FileAccess.file_exists(files[0]):
		var dir := DirAccess.open(files[0])
		if not dir:
			show_error("Can't open directory.")
			return
		
		output_path = files[0]
		%CustomName.text = output_path.get_file()
		
		for file in dir.get_files():
			if file.get_extension() in SUPPORTED_FORMATS:
				file_list.append(str(dir.get_current_dir().path_join(file)))
	else:
		var wrong_count: int
		for file in files:
			if file.get_extension() in SUPPORTED_FORMATS:
				file_list.append(file)
			else:
				wrong_count += 1
		
		if wrong_count > 0:
			show_error("Skipped %s file(s) with unsupported extension." % wrong_count)
	
	if file_list.is_empty():
		show_error("No valid files or directories to process.")
		return
	
	if file_list.size() == 1:
		$SplitDialog.start_split(file_list[0])
		return
	
	$ProcessDialog.load_images_from_file_list()
	await $ProcessDialog.finished
	
	var size_map: Dictionary

	for image in image_list:
		if not image:
			continue
		
		if not image.get_size() in size_map:
			size_map[image.get_size()] = []
		size_map[image.get_size()].append(image)
	
	if size_map.is_empty():
		show_error("Failed to load any image.")
		return
	
	var most_common_size: Vector2i
	var most_common_count: int
	
	for size in size_map:
		if size_map[size].size() > most_common_count:
			most_common_size = size
			most_common_count = size_map[size].size()
	
	image_list.assign(size_map[most_common_size])
	
	if image_list.size() < file_list.size():
		show_error("Rejected %d image(s) due to size mismatch or invalid data." % (file_list.size() - image_list.size()))
	
	if image_list.size() == 1:
		show_error("Single image left, aborting.")
		return
	
	reload_textures.call_deferred()

func reload_textures():
	%Reload.disabled = true
	%SavePNG.disabled = true
	
	$ProcessDialog.create_textures_from_image_list()
	await $ProcessDialog.finished
	
	%Spritesheet.clear()
	for texture in texture_list:
		%Spritesheet.add_frame(texture)
	
	%Spritesheet.update_columns()
	set_spritesheet_visible(true)
	
	%Reload.disabled = false
	%SavePNG.disabled = false ## TODO: jakiś check czy wszystko w porządku
	%Close.disabled = false
	$SpritesheetView.recenter()

func save_png() -> void:
	$ProcessDialog.save_spritesheet()

func show_error(text: String):
	if not %Error.visible:
		%Error.show()
	else:
		%Error.text += "\n"
	%Error.text += text
	%Timer.start()

func error_hidden() -> void:
	%Error.text = ""

func update_save_button() -> void:
	%SavePNG.disabled = %CustomName.text.is_empty()

func load_dialog_option(option: int) -> void:
	var files_selected = func(status: bool, selected_paths: PackedStringArray, selected_filter_index: int):
		if status:
			process_files(selected_paths)
	
	var format_filters: Array[String] # TODO cachować to
	format_filters.assign(Array(SUPPORTED_FORMATS).map(func(format: String) -> String: return "*.%s" % format))
	DisplayServer.file_dialog_show("Select Images", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILES if option == 0 else DisplayServer.FILE_DIALOG_MODE_OPEN_DIR, [], files_selected)

func close_spritesheet() -> void:
	file_list.clear()
	image_list.clear()
	texture_list.clear()
	
	set_spritesheet_visible(false)

func columns_changed(value: float) -> void:
	%Spritesheet.update_columns()
