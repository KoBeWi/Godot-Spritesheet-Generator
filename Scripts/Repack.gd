extends Control

@onready var repack_preview: TextureRect = %RepackPreview
@onready var repack_columns: SpinBox = %RepackColumns
@onready var repack_rows: SpinBox = %RepackRows
@onready var repack_width: SpinBox = %RepackWidth
@onready var repack_height: SpinBox = %RepackHeight
@onready var repack_spacing_x: SpinBox = %RepackSpacingX
@onready var repack_spacing_y: SpinBox = %RepackSpacingY
@onready var repack_offset_x: SpinBox = %RepackOffsetX
@onready var repack_offset_y: SpinBox = %RepackOffsetY

var image: Image
var base_path: String

func _init() -> void:
	hide()

func _ready() -> void:
	Settings.subscribe(repack_preview.queue_redraw)

func repack_file(path: String):
	base_path = path
	image = Image.load_from_file(path)
	if not image:
		# TODO: Error
		return
	
	image.convert(Image.FORMAT_RGBA8)
	repack_preview.texture = ImageTexture.create_from_image(image)
	show()

func get_frame_size() -> Vector2i:
	if repack_width.value > 0 and repack_height.value > 0:
		return Vector2i(repack_width.value, repack_height.value)
	else:
		return image.get_size() / Vector2i(repack_columns.value, repack_rows.value)

func auto_size() -> void:
	repack_width.set_value_no_signal(image.get_width() / repack_columns.value)
	repack_height.set_value_no_signal(image.get_height() / repack_rows.value)

func _confirm() -> void:
	var frame_size := get_frame_size()
	var grid_step := frame_size + Vector2i(repack_spacing_x.value, repack_spacing_y.value)
	
	var offset := Vector2i(repack_offset_x.value, repack_offset_y.value)
	for y in repack_rows.value:
		for x in repack_columns.value:
			var frame := image.get_region(Rect2i(offset + Vector2i(x, y) * grid_step, frame_size))
			owner.import_frames.create_frame_from_image(frame)
	
	owner.assign_path(base_path.get_base_dir().path_join(Settings.settings.default_file_name + ".png"))
	image = null
	hide()

func _cancel() -> void:
	image = null
	hide()

func _draw_grid() -> void:
	var frame_size := get_frame_size()
	var spacing := Vector2i(repack_spacing_x.value, repack_spacing_y.value)
	var grid_step := frame_size + spacing
	var full_size := grid_step * Vector2i(repack_columns.value, repack_rows.value) - spacing
	var offset := Vector2i(repack_offset_x.value, repack_offset_y.value)
	
	var grid_color: Color = Settings.settings.cut_mode_grid
	var fade_color: Color = Settings.settings.cut_mode_fade
	for x in range(1, int(repack_columns.value)):
		if repack_spacing_x.value > 0:
			repack_preview.draw_rect(Rect2(offset + Vector2i(x * grid_step.x - spacing.x, 0), Vector2(spacing.x, full_size.y)), fade_color)
			repack_preview.draw_line(offset + Vector2i(x * grid_step.x - spacing.x, 0), offset + Vector2i(x * grid_step.x - spacing.x, full_size.y), grid_color)
		
		repack_preview.draw_line(offset + Vector2i(x * grid_step.x, 0), offset + Vector2i(x * grid_step.x, full_size.y), grid_color)
	
	for y in range(1, int(repack_rows.value)):
		if repack_spacing_y.value > 0:
			repack_preview.draw_rect(Rect2(offset + Vector2i(0, y * grid_step.y - spacing.y), Vector2(full_size.x, spacing.y)), fade_color)
			repack_preview.draw_line(offset + Vector2i(0, y * grid_step.y - spacing.y), offset + Vector2i(full_size.x, y * grid_step.y - spacing.y), grid_color)
		
		repack_preview.draw_line(offset + Vector2i(0, y * grid_step.y), offset + Vector2i(full_size.x, y * grid_step.y), grid_color)
	
	var need_outline: bool
	if full_size.x < repack_preview.size.x:
		repack_preview.draw_rect(Rect2(offset + Vector2i(full_size.x, 0), Vector2(repack_preview.size.x - full_size.x, full_size.y)), fade_color)
		need_outline = true
	
	if full_size.y < repack_preview.size.y:
		repack_preview.draw_rect(Rect2(offset + Vector2i(0, full_size.y), Vector2(repack_preview.size.x, repack_preview.size.y - full_size.y)), fade_color)
		need_outline = true
	
	if need_outline:
		repack_preview.draw_rect(Rect2(offset, full_size), grid_color, false)
