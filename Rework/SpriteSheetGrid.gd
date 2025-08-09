extends GridContainer

const FrameContainer = preload("res://Rework/FrameContainer.gd")

@onready var edit: PanelContainer = %Edit
@onready var column_count: SpinBox = %ColumnCount
@onready var auto_columns: CheckBox = %AutoColumns
@onready var horizontal_margin: SpinBox = %HorizontalMargin
@onready var vertical_margin: SpinBox = %VerticalMargin

var had_selection: bool

func _ready() -> void:
	Settings.subscribe(update_grid)

func update_frame_list():
	var missing_frames: Array[SpriteSheet.Frame] = owner.spritesheet.frames.duplicate()
	column_count.max_value = missing_frames.size()
	
	for container: FrameContainer in get_children():
		var idx := missing_frames.find(container.frame)
		if idx == -1:
			container.free()
		else:
			missing_frames.remove_at(idx)
	
	for frame in missing_frames:
		var new_container := FrameContainer.SCENE.instantiate()
		new_container.spritesheet = owner.spritesheet
		add_child(new_container)
		new_container.selection_changed.connect(edit.update_frames)
	
	var frames: Array[SpriteSheet.Frame] = owner.spritesheet.frames
	for i in frames.size():
		get_child(i).frame = frames[i]
		get_child(i).update()
	
	update_margins()
	update_columns()

func update_columns():
	if not auto_columns.button_pressed:
		columns = column_count.value
		update_grid()
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
	update_grid()

func update_grid():
	for container: FrameContainer in get_children():
		var x: int = container.get_index() % columns
		var y: int = container.get_index() / columns
		var alt: bool = Settings.settings.show_grid and (x % 2 == 0) != (y % 2 == 0)
		container.background.color = Settings.settings.grid_color2 if alt else Settings.settings.grid_color1
	
	var container := get_parent_control()
	var center := container.get_rect().get_center()
	container.reset_size()
	container.position += center - container.get_rect().get_center()

func on_columns_changed(value: float) -> void:
	update_columns()

func on_auto_toggled(toggled_on: bool) -> void:
	column_count.editable = not toggled_on
	update_columns()

func update_margins() -> void:
	owner.spritesheet.margins = Vector2i(horizontal_margin.value, vertical_margin.value)
	for container: FrameContainer in get_children():
		container.update_margins()

func get_rows() -> int:
	return ceili(get_child_count() / float(columns))

func _select_all() -> void:
	var all_selected := get_children().all(func(container: FrameContainer) -> bool: return container.is_selected())
	for container: FrameContainer in get_children():
		container.selection.visible = not all_selected
	edit.update_frames()

func _unhandled_key_input(event: InputEvent) -> void:
	var k := event as InputEventKey
	if k:
		if k.pressed and k.keycode == KEY_DELETE:
			var was_deleted: bool
			var spritesheet: SpriteSheet = owner.spritesheet
			for container: FrameContainer in get_children():
				if container.is_selected():
					spritesheet.frames.erase(container.frame)
					was_deleted = true
			
			if was_deleted:
				update_frame_list()

func update_settings() -> void:
	update_grid()
