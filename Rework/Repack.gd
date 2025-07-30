extends Control

@onready var repack_preview: TextureRect = %RepackPreview
@onready var repack_columns: SpinBox = %RepackColumns
@onready var repack_rows: SpinBox = %RepackRows

var image: Image
var base_path: String

func _init() -> void:
	hide()

func repack_file(path: String):
	base_path = path
	image = Image.load_from_file(path)
	if not image:
		return
	
	repack_preview.texture = ImageTexture.create_from_image(image)
	show()

func _confirm() -> void:
	var grid_step := image.get_size() / Vector2i(repack_columns.value, repack_rows.value)
	for y in repack_rows.value:
		for x in repack_columns.value:
			var frame := image.get_region(Rect2i(Vector2i(x, y) * grid_step, grid_step))
			owner.create_frame_from_image(frame)
	
	owner.assign_path(base_path.get_base_dir().path_join(owner.default_filename))
	image = null
	hide()

func _cancel() -> void:
	image = null
	hide()

func _draw_grid() -> void:
	var grid_step := image.get_size() / Vector2i(repack_columns.value, repack_rows.value)
	for x in range(1, int(repack_columns.value)):
		repack_preview.draw_line(Vector2(x * grid_step.x, 0), Vector2(x * grid_step.x, repack_preview.size.y), Color.WHITE)
	
	for y in range(1, int(repack_rows.value)):
		repack_preview.draw_line(Vector2(0, y * grid_step.y), Vector2(repack_preview.size.x, y * grid_step.y), Color.WHITE)
