class_name SpriteSheet

class Frame:
	var file_path: String
	var source_image: Image # TODO
	var image: Image
	var texture: Texture
	
	func initialize():
		image = source_image.duplicate()
		texture = ImageTexture.create_from_image(image)

var frames: Array[Frame]
var unused_frames: Array[Frame]
var file_path: String
