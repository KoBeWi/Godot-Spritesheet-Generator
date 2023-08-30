extends Control

const SUPPORTED_FORMATS: PackedStringArray = ["bmp", "dds", "exr", "hdr", "jpg", "jpeg", "png", "tga", "svg", "svgz", "webp"]

var file_list: Array[String]
var image_list: Array[Image]
var texture_list: Array[Texture2D]

var images_to_process: Array
var images_to_texturize: Array
var first_time := true
var image_count: int
var output_path: String

signal images_processed

func _enter_tree() -> void:
	$ProcessDialog.hide()
	$SplitDialog.hide()
	$StashDialog.hide()
	$PreviewDialog.hide()

func _ready():
	$Welcome.text = $Welcome.text % ", ".join(SUPPORTED_FORMATS)
	
	get_viewport().files_dropped.connect(process_files)
	set_process(false)

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
	$ProcessDialog.create_textures_from_image_list()
	await $ProcessDialog.finished
	
	for texture in texture_list:
		%Spritesheet.add_frame(texture)
	
	$Welcome.hide()
	%Spritesheet.update_columns()
	$SpritesheetView.show()

func save_png() -> void:
	var image_size: Vector2 = %Grid.get_child(0).get_minimum_size()
	
	var image := Image.create(image_size.x * %Grid.columns, image_size.y * (ceil(%Grid.get_child_count() / float(%Grid.columns))), false, Image.FORMAT_RGBA8)
	
	for rect in %Grid.get_children():
		image.blit_rect(rect.get_texture_data(), Rect2(Vector2(), image_size), rect.get_position2())
	
	image.save_png(output_path.path_join(%CustomName.text) + ".png")

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




#func load_images_from_file_list():
	#texture_list.clear()
	#image_list.clear()
#
	#for image in %Grid.get_children():
		#image.free()
#
	#for image in %StashImages.get_children():
		#image.free()
	#update_stash()
#
	#var size_map: Dictionary
#
	#if not file_list.is_empty():
		#image_list = file_list.map(func(file: String):
			#var image := Image.load_from_file(file)
			#if image:
				#image.set_meta(&"path", file)
			#return image)
#
	#for image in image_list:
		#if not image:
			#continue
#
		#if not image.get_size() in size_map:
			#size_map[image.get_size()] = []
		#size_map[image.get_size()].append(image)
#
	#var output_name: String
	#var most_common_size: Vector2i
	#var most_common_count: int
#
	#for size in size_map:
		#if size_map[size].size() > most_common_count:
			#most_common_size = size
			#most_common_count = size_map[size].size()
#
	#for image in size_map[most_common_size]:
		#if output_path.is_empty():
			#var path: String = image.get_meta(&"path", "")
			#output_path = path.get_base_dir()
			#output_name = path.get_base_dir().get_file()
#
		#images_to_process.append(image)
	#size_map.clear()
#
	#if not output_name.is_empty():# and %CustomName.text.is_empty():
		#%CustomName.text = output_name
	#update_save_button() ## źle
#
	#if images_to_process.size() < file_list.size():
		#show_error("Rejected %s image(s) due to size mismatch." % (file_list.size() - images_to_process.size()))
#
	#if images_to_process.size() == 1:
		#if file_list.size() > 1:
			#images_to_process.clear()
			#show_error("Only one dropped image was valid.")
		#else:
			#%CustomName.text = file_list[0].get_file().get_basename()
			#%SplitPreview.texture = ImageTexture.create_from_image(images_to_process[0])
			#$SplitDialog.reset_size()
			#$SplitDialog.popup_centered()
#
		#return
#
	#$Status.show()
	#%Spritesheet.hide()
#
	#image_count = images_to_process.size()
	#%Columns.max_value = image_count
#
	#threshold = %Threshold.value
	#min_x = 9999999
	#min_y = 9999999
	#max_x = -9999999
	#max_y = -9999999
#
	#set_process(true)
#
	#await images_processed
#
	#for texture in texture_list:
		#add_frame(texture)
#
	#toggle_auto(auto)
	#refresh_margin()
#
	#$Status.hide()
	#%Spritesheet.show()
