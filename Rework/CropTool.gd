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
	for frame: SpriteSheet.Frame in owner.spritesheet.frames:
		var crop_data := CropData.new()
		crop_frame(frame, crop_data)
		
		var rect := crop_data.get_rect()
		var new_image := Image.create(rect.size.x, rect.size.y, false, frame.source_image.get_format())
		new_image.blit_rect(frame.source_image, rect, Vector2())
		frame.texture = ImageTexture.create_from_image(new_image)
	
	sprite_sheet_grid.update_frame_list()

func smart_crop_images():
	var crop_data := CropData.new()
	
	for frame: SpriteSheet.Frame in owner.spritesheet.frames:
		crop_frame(frame, crop_data)
	
	var rect := crop_data.get_rect()
	for frame: SpriteSheet.Frame in owner.spritesheet.frames:
		var new_image := Image.create(rect.size.x, rect.size.y, false, frame.source_image.get_format())
		new_image.blit_rect(frame.source_image, rect, Vector2())
		frame.texture = ImageTexture.create_from_image(new_image)
	
	sprite_sheet_grid.update_frame_list()

func crop_frame(frame: SpriteSheet.Frame, crop_data: CropData):
	var cut := threshold.value
	var image := frame.source_image
	for x in image.get_width():
		for y in image.get_height():
			if image.get_pixel(x, y).a >= cut:
				crop_data.add_point(x, y)
