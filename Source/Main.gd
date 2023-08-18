extends Control

const SUPPORTED_FORMATS: PackedStringArray = ["bmp", "dds", "exr", "hdr", "jpg", "jpeg", "png", "tga", "svg", "svgz", "webp"]

var file_list: Array
var image_list: Array
var texture_list: Array

var images_to_process: Array
var images_to_texturize: Array
var first_time := true
var image_count: int
var output_path: String

var auto := true
var margin := Vector2.ONE

signal images_processed

func _enter_tree() -> void:
	$SplitDialog.hide()
	$StashDialog.hide()
	$PreviewDialog.hide()

func _ready():
	$Status.text = $Status.text % ", ".join(SUPPORTED_FORMATS)
	
	get_viewport().files_dropped.connect(load_files)
	set_process(false)

func load_files(files: PackedStringArray):
	file_list.clear()
	image_list.clear()
	images_to_process.clear()
	
	%CustomName.text = ""
	%Reload.disabled = false
	%SavePNG.disabled = false
	
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
	
	load_images()

func load_images():
	texture_list.clear()
	
	for image in %Grid.get_children():
		image.free()
	
	for image in %StashImages.get_children():
		image.free()
	update_stash()
	
	var size_map: Dictionary
	
	if not file_list.is_empty():
		image_list = file_list.map(func(file: String):
			var image := Image.load_from_file(file)
			if image:
				image.set_meta(&"path", file)
			return image)
	
	for image in image_list:
		if not image:
			continue
		
		if not image.get_size() in size_map:
			size_map[image.get_size()] = []
		size_map[image.get_size()].append(image)
	
	var output_name: String
	var most_common_size: Vector2i
	var most_common_count: int
	
	for size in size_map:
		if size_map[size].size() > most_common_count:
			most_common_size = size
			most_common_count = size_map[size].size()
	
	for image in size_map[most_common_size]:
		if output_path.is_empty():
			var path: String = image.get_meta(&"path", "")
			output_path = path.get_base_dir()
			output_name = path.get_base_dir().get_file()
		
		images_to_process.append(image)
	size_map.clear()
	
	if not output_name.is_empty() and %CustomName.text.is_empty():
		%CustomName.text = output_name
	update_save_button()
	
	if images_to_process.size() < file_list.size():
		show_error("Rejected %s image(s) due to size mismatch." % (file_list.size() - images_to_process.size()))
	
	if images_to_process.size() == 1:
		if file_list.size() > 1:
			images_to_process.clear()
			show_error("Only one dropped image was valid.")
		else:
			%CustomName.text = file_list[0].get_file().get_basename()
			%SplitPreview.texture = ImageTexture.create_from_image(images_to_process[0])
			$SplitDialog.reset_size()
			$SplitDialog.popup_centered()
		
		return
	
	$Status.show()
	%Spritesheet.hide()
	
	image_count = images_to_process.size()
	%Columns.max_value = image_count
	
	threshold = %Threshold.value
	min_x = 9999999
	min_y = 9999999
	max_x = -9999999
	max_y = -9999999
	
	set_process(true)
	
	await images_processed
	
	for texture in texture_list:
		add_frame(texture)
	
	toggle_auto(auto)
	refresh_margin()
	
	$Status.hide()
	%Spritesheet.show()

var threshold: float
var min_x: int
var min_y: int
var max_x: int
var max_y: int

func _process(delta: float) -> void:
	if not images_to_process.is_empty():
		var image: Image = images_to_process.pop_front()
		$Status.text = str("Preprocessing image ", image_count - images_to_process.size(), "/", image_count)
		
		for x in image.get_width():
			for y in image.get_height():
				if image.get_pixel(x, y).a >= threshold:
					min_x = mini(min_x, x)
					min_y = mini(min_y, y)
					max_x = maxi(max_x, x)
					max_y = maxi(max_y, y)
		
		images_to_texturize.append(image)
	elif not images_to_texturize.is_empty():
		var rect := Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
		var image: Image = images_to_texturize.pop_front()
		$Status.text = str("Creating texture ", image_count - images_to_texturize.size(), "/", image_count)
		
		var true_image := Image.create(rect.size.x, rect.size.y, false, image.get_format())
		true_image.blit_rect(image, rect, Vector2())
		
		var texture := ImageTexture.create_from_image(true_image)
		texture_list.append(texture)
		
		if images_to_texturize.is_empty():
			set_process(false)
			images_processed.emit()
			if first_time:
				recenter()
				first_time = false

func toggle_grid(show: bool) -> void:
	get_tree().call_group(&"frame", &"set_display_background", show)

func toggle_auto(button_pressed: bool) -> void:
	%Columns.editable = not button_pressed
	auto = button_pressed
	
	if button_pressed:
		var best: int
		var best_score = -9999999
		
		for i in range(1, image_count + 1):
			var cols = i
			var rows = ceili(image_count / float(i))
			
			var score = image_count - cols * rows - maxi(cols, rows) - rows
			if score > best_score:
				best = i
				best_score = score
		
		%Grid.columns = best
	else:
		%Grid.columns = %Columns.value
	refresh_grid()

func hmargin_changed(value: float) -> void:
	margin.x = value
	refresh_margin()

func vmargin_changed(value: float) -> void:
	margin.y = value
	refresh_margin()

func refresh_margin():
	get_tree().call_group(&"frame", &"set_frame_margin", margin)

func columns_changed(value: float) -> void:
	%Grid.columns = value
	refresh_grid()

func refresh_grid():
	var coord: Vector2
	var dark = false
	
	for rect in %Grid.get_children():
		rect.set_background_color(Color(0, 0, 0, 0.2 if dark else 0.1))
		dark = not dark
		coord.x += 1
		
		if coord.x == %Grid.columns:
			coord.x = 0
			coord.y += 1
			dark = int(coord.y) % 2 == 1

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

func recenter() -> void:
	%Spritesheet.position = get_viewport().size / 2 - Vector2i(%Spritesheet.size) / 2
	%Spritesheet.scale = Vector2.ONE

func update_split_preview():
	%SplitPreview.queue_redraw()

func draw_split_preview() -> void:
	var preview: TextureRect = %SplitPreview
	var frame_count := Vector2(%SplitX.value, %SplitY.value)
	var frame_size := preview.size / frame_count
	
	for x in range(1, frame_count.x):
		for y in int(frame_count.y):
			preview.draw_line(frame_size * Vector2(x, y), frame_size * Vector2(x, y + 1), Color.WHITE)
			preview.draw_line(frame_size * Vector2(x, y) + Vector2.RIGHT, frame_size * Vector2(x, y + 1) + Vector2.RIGHT, Color.BLACK)
	
	for y in range(1, frame_count.y):
		for x in int(frame_count.x):
			preview.draw_line(frame_size * Vector2(x, y), frame_size * Vector2(x + 1, y), Color.WHITE)
			preview.draw_line(frame_size * Vector2(x, y) + Vector2.DOWN, frame_size * Vector2(x + 1, y) + Vector2.DOWN, Color.BLACK)

func split_spritesheet() -> void:
	file_list.clear()
	image_list.clear()
	
	var image: Image = images_to_process[0]
	var sub_image_size := image.get_size() / Vector2i(%SplitX.value, %SplitY.value)
	
	for y in %SplitY.value:
		for x in %SplitX.value:
			image_list.append(image.get_region(Rect2i(Vector2i(x, y) * sub_image_size, sub_image_size)))
	
	images_to_process.clear()
	load_images()

func remove_frame(frame):
	var image: Image = frame.get_texture_data()
	var texture := ImageTexture.create_from_image(image)
	
	var button := TextureButton.new()
	button.texture_normal = texture
	button.custom_minimum_size = Vector2(128, 128)
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.ignore_texture_size = true
	button.pressed.connect(re_add_image.bind(button), CONNECT_DEFERRED)
	%StashImages.add_child(button)
	
	var ref := ReferenceRect.new()
	button.add_child(ref)
	ref.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ref.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ref.editor_only = false
	
	frame.free()
	refresh_grid()
	update_stash()

func update_stash():
	%Stash.disabled = %StashImages.get_child_count() == 0

func re_add_image(tb: TextureButton):
	add_frame(tb.texture_normal)
	tb.free()
	refresh_grid()
	update_stash()
	
	if %Stash.disabled:
		$StashDialog.hide()

func add_frame(texture: Texture2D):
	var rect := preload("res://Source/SpritesheetFrame.tscn").instantiate()
	rect.set_texture(texture)
	rect.set_display_background(%DisplayGrid.button_pressed)
	rect.set_frame_margin(margin)
	%Grid.add_child(rect)

func update_save_button() -> void:
	%SavePNG.disabled = %CustomName.text.is_empty()
