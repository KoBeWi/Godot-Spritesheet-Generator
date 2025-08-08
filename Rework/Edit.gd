extends PanelContainer

@onready var sprite_sheet_grid: GridContainer = %SpriteSheetGrid
@onready var edit_warning: VBoxContainer = %EditWarning

@onready var offset_x: SpinBox = %OffsetX
@onready var offset_y: SpinBox = %OffsetY
@onready var buttons: Array[Button] = [%EditFlipX, %EditFlipY, %EditTranspose]
@onready var mod_parent: VBoxContainer = %ModParent
@onready var mod_list: Control = %ModList

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
	
	if enabled:
		var ref := selected_frames[0]
		var frame_size: Vector2i = owner.spritesheet.frame_size
		offset_x.max_value = frame_size.x - ref.image.get_width()
		offset_y.max_value = frame_size.y - ref.image.get_height()
	
	mod_parent.visible = selected_frames.size() == 1 and not selected_frames[0].modifiers.is_empty()
	if not mod_parent.visible:
		return
	
	for node in mod_list.get_children():
		node.free()
	
	for moder in selected_frames[0].modifiers:
		var instance := preload("uid://42kwe3m2hgqd").instantiate()
		instance.frame = selected_frames[0]
		instance.modifier = moder
		mod_list.add_child(instance)

func _flip_x() -> void:
	var flipper := SpriteSheet.FlipX.new()
	for frame in selected_frames:
		frame.add_modifier(flipper)
	
	if selected_frames.size() == 1:
		update_frames()

func _flip_y() -> void:
	var flipper := SpriteSheet.FlipY.new()
	for frame in selected_frames:
		frame.add_modifier(flipper)
	
	if selected_frames.size() == 1:
		update_frames()

func _transpose() -> void:
	for frame in selected_frames:
		var rotater := SpriteSheet.Rotate.new()
		frame.add_modifier(rotater)
	
	# TODO: fix frame size?
	
	if selected_frames.size() == 1:
		update_frames()

func _modulate() -> void:
	for frame in selected_frames:
		var modulater := SpriteSheet.Modulate.new()
		frame.add_modifier(modulater)
	
	if selected_frames.size() == 1:
		update_frames()

func offset_x_changed(value: float) -> void:
	for frame in selected_frames:
		frame.offset.x = value
		frame.changed.emit()

func offset_y_changed(value: float) -> void:
	for frame in selected_frames:
		frame.offset.y = value
		frame.changed.emit()
