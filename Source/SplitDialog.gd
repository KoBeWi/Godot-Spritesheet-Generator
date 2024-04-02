extends ConfirmationDialog

@onready var split_preview: Control = %SplitPreview

var image: Image
var texture: Texture2D
var ratio: float

func start_split(file: String):
	image = Image.load_from_file(file)
	texture = ImageTexture.create_from_image(image)
	
	var image_size := image.get_size()
	var max_axis := image_size.max_axis_index()
	ratio = minf(800.0 / image_size[max_axis], 1.0)
	split_preview.custom_minimum_size = (image_size * ratio).floor()
	
	popup_centered()

func update_split_preview():
	split_preview.queue_redraw()

func draw_split_preview() -> void:
	split_preview.draw_texture_rect(texture, Rect2(Vector2(), split_preview.size), false)
	
	var frame_count := Vector2i(%SplitX.value, %SplitY.value)
	var frame_size := Vector2i(split_preview.size) / frame_count
	
	for x in range(1, frame_count.x):
		for y in int(frame_count.y):
			split_preview.draw_dashed_line(frame_size * Vector2i(x, y), frame_size * Vector2i(x, y + 1), Color.WHITE)
			split_preview.draw_dashed_line(frame_size * Vector2i(x, y) + Vector2i.RIGHT, frame_size * Vector2i(x, y + 1) + Vector2i.RIGHT, Color.BLACK)
	
	for y in range(1, frame_count.y):
		for x in int(frame_count.x):
			split_preview.draw_dashed_line(frame_size * Vector2i(x, y), frame_size * Vector2i(x + 1, y), Color.WHITE)
			split_preview.draw_dashed_line(frame_size * Vector2i(x, y) + Vector2i.DOWN, frame_size * Vector2i(x + 1, y) + Vector2i.DOWN, Color.BLACK)

func split_spritesheet() -> void:
	%ProcessDialog.split_image(image, Vector2i(%SplitX.value, %SplitY.value))
	
	await %ProcessDialog.finished
	
	owner.reload_textures.call_deferred()
