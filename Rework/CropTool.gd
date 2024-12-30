extends Button

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

@onready var threshold: SpinBox = %Threshold

var crop_data: CropData

func _pressed() -> void:
	crop_images()

func crop_images():
	var cut := threshold.value
	crop_data = CropData.new()
	
	for frame: SpriteSheet.Frame in owner.spritesheet:
		var image := frame.source_image
		for x in image.get_width():
			for y in image.get_height():
				if image.get_pixel(x, y).a >= cut:
					crop_data.add_point(x, y)
