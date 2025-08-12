class_name SpriteSheet

var frame_size: Vector2i:
	set(fs):
		if frame_size != fs:
			frame_size = fs
			changed.emit()

var margins := Vector2i.ONE
var frames: Array[Frame]
var all_frames: Array[Frame]

signal changed

func add_frame(frame: Frame):
	frames.append(frame)
	all_frames.append(frame)

class Frame:
	var file_path: String
	var source_image: Image
	var image: Image
	var texture: ImageTexture
	var offset: Vector2i
	var modifiers: Array[FrameModifier]
	
	signal changed
	
	func initialize():
		if not source_image and file_path:
			source_image = Image.load_from_file(file_path)
			if not source_image:
				source_image = Image.create(1, 1, false, Image.FORMAT_RGBA8) # TODO placeholder
		
		image = source_image.duplicate()
		texture = ImageTexture.create_from_image(image)
	
	func add_modifier(modifier: FrameModifier):
		for modo in modifiers:
			if modo.name == modifier.name:
				modifiers.erase(modo)
				break
		
		modifiers.append(modifier)
		update_image()
	
	func update_image():
		image.copy_from(source_image)
		
		for modifier in modifiers:
			modifier._apply(image)
		
		texture.set_image(image)
		changed.emit()

class FrameModifier:
	var name: String
	
	func _apply(image: Image):
		pass
	
	func _get_options() -> Array:
		return []

class FlipX extends FrameModifier:
	func _init() -> void:
		name = "Flip X"
	
	func _apply(image: Image):
		image.flip_x()

class FlipY extends FrameModifier:
	func _init() -> void:
		name = "Flip Y"
	
	func _apply(image: Image):
		image.flip_y()

class Rotate extends FrameModifier:
	var rotation: int
	
	func _init() -> void:
		name = "Rotate"
	
	func _apply(image: Image):
		match rotation:
			0:
				image.rotate_90(CLOCKWISE)
			1:
				image.rotate_180()
			2:
				image.rotate_90(COUNTERCLOCKWISE)
	
	func _get_options() -> Array:
		var combo := OptionButton.new()
		combo.add_item("90")
		combo.add_item("180")
		combo.add_item("270")
		return ["Rotation", combo, &"selected", &"rotation"]

class Modulate extends FrameModifier:
	var color := Color.WHITE
	
	func _init() -> void:
		name = "Modulate"
	
	func _apply(image: Image):
		image.convert(Image.FORMAT_RGBA8)
		var data := image.get_data()
		
		for i in data.size() / 4:
			if data[i * 4 + 3] == 0:
				continue
			
			data[i * 4] *= color.r
			data[i * 4 + 1] *= color.g
			data[i * 4 + 2] *= color.b
		
		image.set_data(image.get_width(), image.get_height(), false, image.get_format(), data)
	
	func _get_options() -> Array:
		var colorer := ColorPickerButton.new()
		colorer.edit_alpha = false
		colorer.custom_minimum_size.x = 24
		return ["Color", colorer, &"color", &"color"]

class RemoveColor extends FrameModifier:
	var color := Color.MAGENTA
	
	func _init() -> void:
		name = "Remove Color"
	
	func _apply(image: Image):
		image.convert(Image.FORMAT_RGBA8)
		var data := image.get_data()
		
		var test_r: int = color.r * 255
		var test_g: int = color.g * 255
		var test_b: int = color.b * 255
		
		for i in data.size() / 4:
			if data[i * 4] == test_r and data[i * 4 + 1] == test_g and data[i * 4 + 2] == test_b:
				data[i * 4 + 3] = 0
		
		image.set_data(image.get_width(), image.get_height(), false, image.get_format(), data)
	
	func _get_options() -> Array:
		var colorer := ColorPickerButton.new()
		colorer.edit_alpha = false
		colorer.custom_minimum_size.x = 24
		return ["Color", colorer, &"color", &"color"]

class Crop extends FrameModifier:
	var rect: Rect2i
	
	func _init() -> void:
		name = "Crop"
	
	func _apply(image: Image):
		var new_image := Image.create(rect.size.x, rect.size.y, false, image.get_format())
		new_image.blit_rect(image, rect, Vector2())
		image.set_data(new_image.get_width(), new_image.get_height(), false, new_image.get_format(), new_image.get_data())
