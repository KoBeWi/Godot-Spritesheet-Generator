class_name SpriteSheet

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
	
	func update_image():
		image.copy_from(source_image)
		
		for modifier in modifiers:
			modifier._apply(image)
		
		texture.set_image(image)

class FrameModifier:
	var name: String
	
	func _apply(image: Image):
		pass

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
	func _init() -> void:
		name = "Rotate"
	
	func _apply(image: Image):
		image.rotate_90(CLOCKWISE)

var frames: Array[Frame]
var unused_frames: Array[Frame]
var file_path: String # używane?
