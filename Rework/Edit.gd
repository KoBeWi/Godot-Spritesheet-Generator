extends PanelContainer

@onready var sprite_sheet_grid: GridContainer = %SpriteSheetGrid
@onready var edit_warning: VBoxContainer = %EditWarning

@onready var offset_x: SpinBox = %OffsetX
@onready var offset_y: SpinBox = %OffsetY
@onready var buttons: Array[Button] = [%EditFlipX, %EditFlipY, %EditTranspose]
@onready var mod_list: Tree = %ModList

var selected_frames: Array[SpriteSheet.Frame]

func _init() -> void:
	hide()

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		update_frames()

func update_frames():
	if not is_visible_in_tree():
		return
	
	selected_frames.assign(sprite_sheet_grid.get_children().filter(func(node) -> bool: return node.is_selected()).map(func(node) -> SpriteSheet.Frame: return node.frame))
	
	var enabled := not selected_frames.is_empty()
	edit_warning.visible = not enabled
	offset_x.editable = enabled
	offset_y.editable = enabled
	for button in buttons:
		button.disabled = not enabled

func _flip_x() -> void:
	var flipper := SpriteSheet.FlipX.new()
	for frame in selected_frames:
		frame.modifiers.append(flipper)
		frame.update_image()

func _flip_y() -> void:
	var flipper := SpriteSheet.FlipY.new()
	for frame in selected_frames:
		frame.modifiers.append(flipper)
		frame.update_image()

func _transpose() -> void:
	var rotater := SpriteSheet.Rotate.new()
	for frame in selected_frames:
		frame.modifiers.append(rotater)
		frame.update_image()
	
	sprite_sheet_grid.update_grid()

func offset_x_changed(value: float) -> void:
	for frame in selected_frames:
		frame.offset.x = value
		frame.changed.emit()

func offset_y_changed(value: float) -> void:
	for frame in selected_frames:
		frame.offset.y = value
		frame.changed.emit()
