extends AcceptDialog

enum { MODE_LOAD_IMAGES, MODE_CROP_IMAGES, MODE_CREATE_TEXTURES, MODE_SPLIT_SPRITESHEET, MODE_SAVE }

@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar


var file_list: Array[String]
var image_list: Array[Image]
var texture_list: Array[Texture2D]

var work_mode: int

var current_index: int

var min_x: int
var min_y: int
var max_x: int
var max_y: int

signal finished

func _ready() -> void:
	get_ok_button().hide()
	set_process(false)
	
	file_list = owner.file_list
	image_list = owner.image_list
	texture_list = owner.texture_list

func load_images_from_file_list():
	image_list.clear()
	image_list.resize(file_list.size())
	
	progress_bar.max_value = file_list.size()
	start_work(MODE_LOAD_IMAGES)

func create_textures_from_image_list():
	texture_list.clear()
	texture_list.resize(image_list.size())
	
	min_x = 9999999
	min_y = 9999999
	max_x = -9999999
	max_y = -9999999
	
	progress_bar.max_value = image_list.size()
	start_work(MODE_CROP_IMAGES)

func start_work(work_type: int):
	work_mode = work_type
	current_index = 0
	progress_bar.value = 0
	set_process(true)
	status_label.text = ""
	reset_size()
	popup_centered()

func _process(delta: float) -> void:
	while delta > 0:
		var time := Time.get_ticks_msec()
		process()
		delta -= (Time.get_ticks_msec() - time) * 0.001
		
		if current_index == -1:
			set_process(false)
			finished.emit()
			hide()
			return

func process():
	match work_mode:
		MODE_LOAD_IMAGES:
			var path := file_list[current_index]
			
			status_label.text = "Loading images (%d/%d)\n%s" % [current_index + 1, file_list.size(), path.get_file()]
			image_list[current_index] = Image.load_from_file(path)
			
			current_index += 1
			progress_bar.value += 1
			
			if current_index == file_list.size():
				current_index = -1
		
		MODE_CROP_IMAGES:
			var image := image_list[current_index]
			
			status_label.text = "Preprocessing images (%d/%d)" % [current_index + 1, image_list.size()]
			
			var threshold: float = %Threshold.value
			for x in image.get_width():
				for y in image.get_height():
					if image.get_pixel(x, y).a >= threshold:
						min_x = mini(min_x, x)
						min_y = mini(min_y, y)
						max_x = maxi(max_x, x)
						max_y = maxi(max_y, y)
			
			current_index += 1
			progress_bar.value += 1
			
			if current_index == image_list.size():
				start_work(MODE_CREATE_TEXTURES)
		
		MODE_CREATE_TEXTURES:
			var image := image_list[current_index]
			
			status_label.text = "Creating textures (%d/%d)" % [current_index + 1, image_list.size()]
			
			var rect := Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
			
			var true_image := Image.create(rect.size.x, rect.size.y, false, image.get_format())
			true_image.blit_rect(image, rect, Vector2())
			texture_list[current_index] = ImageTexture.create_from_image(true_image)
			
			current_index += 1
			progress_bar.value += 1
			
			if current_index == image_list.size():
				current_index = -1

func show_error(error: String):
	owner.show_error(error)
