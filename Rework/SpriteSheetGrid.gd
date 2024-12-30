extends GridContainer

const FrameContainer = preload("res://Rework/FrameContainer.gd")

@onready var column_count: SpinBox = %ColumnCount
@onready var auto_columns: CheckBox = %AutoColumns
@onready var horizontal_margin: SpinBox = %HorizontalMargin
@onready var vertical_margin: SpinBox = %VerticalMargin

func update_frame_list():
	var missing_frames: Array[SpriteSheet.Frame] = owner.spritesheet.frames.duplicate()
	column_count.max_value = missing_frames.size()
	
	for container: FrameContainer in get_children():
		var idx := missing_frames.find(container.frame)
		if idx == -1:
			container.queue_free()
		else:
			missing_frames.remove_at(idx)
			container.texture.texture = container.frame.texture
	
	for frame in missing_frames:
		var new_container := FrameContainer.SCENE.instantiate()
		new_container.frame = frame
		add_child(new_container)
	
	update_columns()

func update_columns():
	if not auto_columns.button_pressed:
		columns = column_count.value
		return
	
	var frame_count: int = column_count.max_value
	var best_value: int
	var best_score := -9999999
	
	for i in range(1, frame_count + 1):
		var cols := i
		var rows := ceili(frame_count / float(i))
		
		var score := frame_count - cols * rows - maxi(cols, rows) - rows
		if score > best_score:
			best_value = i
			best_score = score
	
	columns = best_value

func on_columns_changed(value: float) -> void:
	update_columns()

func on_auto_toggled(toggled_on: bool) -> void:
	column_count.editable = not toggled_on
	update_columns()

func margin_changed(value: float) -> void:
	for container: FrameContainer in get_children():
		container.update_margins(horizontal_margin.value, vertical_margin.value)
