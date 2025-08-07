extends Control

class CropData:
	var min_x := 9999999
	var min_y := 9999999
	var max_x := -9999999
	var max_y := -9999999
	
	func add_point(x: int, y: int):
		min_x = mini(min_x, x)
		min_y = mini(min_y, y)
		max_x = maxi(max_x, x)
		max_y = maxi(max_y, y)
	
	func get_rect() -> Rect2i:
		return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)

@onready var threshold: SpinBox = %Threshold
@onready var sprite_sheet_grid: GridContainer = %SpriteSheetGrid

func crop_images() -> void:
	var max_size := Vector2i()
	for frame: SpriteSheet.Frame in owner.spritesheet.frames:
		var crop := get_crop_data(frame.image, threshold.value, null)
		var cropper := SpriteSheet.Crop.new()
		cropper.rect = crop.get_rect()
		frame.modifiers.append(cropper)
		frame.update_image()
		max_size = max_size.max(frame.image.get_size())
	
	owner.spritesheet.frame_size = max_size
	sprite_sheet_grid.update_frame_list()

func smart_crop_images():
	var crop_data := CropData.new()
	for frame: SpriteSheet.Frame in owner.spritesheet.frames:
		get_crop_data(frame.image, threshold.value, crop_data)
	
	var rect := crop_data.get_rect()
	for frame: SpriteSheet.Frame in owner.spritesheet.frames:
		var cropper := SpriteSheet.Crop.new()
		cropper.rect = rect
		frame.modifiers.append(cropper)
		frame.update_image()
	
	owner.spritesheet.frame_size = rect.size
	sprite_sheet_grid.update_frame_list()

func crop_frame(frame: SpriteSheet.Frame, crop_data: CropData):
	var cut := threshold.value
	var image := frame.source_image
	for x in image.get_width():
		for y in image.get_height():
			if image.get_pixel(x, y).a >= cut:
				crop_data.add_point(x, y)

static func get_crop_data(image: Image, alpha_threshold: float, base_crop: CropData) -> CropData:
	var crop_data := base_crop if base_crop else CropData.new()
	for x in image.get_width():
		for y in image.get_height():
			if image.get_pixel(x, y).a >= alpha_threshold:
				crop_data.add_point(x, y)
	
	return crop_data
