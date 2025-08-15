extends PanelContainer

@onready var sprite_sheet_grid: GridContainer = %SpriteSheetGrid
@onready var edit_warning: VBoxContainer = %EditWarning

@onready var offset_x: SpinBox = %OffsetX
@onready var offset_y: SpinBox = %OffsetY
@onready var buttons: Array[Button] = [%CenterImage, %EditFlipX, %EditFlipY, %EditTranspose, %EditModulate, %EditRemoveColor]
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
		offset_x.set_value_no_signal(ref.offset.x)
		offset_y.max_value = frame_size.y - ref.image.get_height()
		offset_y.set_value_no_signal(ref.offset.y)
	
	update_modifiers()

func update_modifiers():
	if selected_frames.is_empty():
		mod_parent.hide()
		return
	
	for node in mod_list.get_children():
		node.free()
	
	var common_mods: Array[SpriteSheet.FrameModifier]
	for moder in selected_frames[0].modifiers:
		if selected_frames.all(func(sf: SpriteSheet.Frame) -> bool: return moder in sf.modifiers):
			common_mods.append(moder)
	
	if common_mods.is_empty():
		mod_parent.hide()
		return
	else:
		mod_parent.show()
	
	for moder in common_mods:
		var instance := preload("uid://42kwe3m2hgqd").instantiate()
		instance.frames = selected_frames
		instance.modifier = moder
		instance.deleted.connect(update_modifier_visibility)
		mod_list.add_child(instance)

func update_modifier_visibility():
	var common_mods: Array[SpriteSheet.FrameModifier]
	if not selected_frames.is_empty():
		for moder in selected_frames[0].modifiers:
			if selected_frames.all(func(sf: SpriteSheet.Frame) -> bool: return moder in sf.modifiers):
				common_mods.append(moder)
	
	mod_parent.visible = not common_mods.is_empty()

func _flip_x() -> void:
	var flipper := SpriteSheet.FlipX.new()
	for frame in selected_frames:
		frame.add_modifier(flipper)
	
	update_modifiers()

func _flip_y() -> void:
	var flipper := SpriteSheet.FlipY.new()
	for frame in selected_frames:
		frame.add_modifier(flipper)
	
	update_modifiers()

func _transpose() -> void:
	var rotater := SpriteSheet.Rotate.new()
	for frame in selected_frames:
		frame.add_modifier(rotater)
	
	# TODO: fix frame size?
	
	update_modifiers()

func _modulate() -> void:
	var modulater := SpriteSheet.Modulate.new()
	for frame in selected_frames:
		frame.add_modifier(modulater)
	
	update_modifiers()

func _remove_color() -> void:
	var remover := SpriteSheet.RemoveColor.new()
	for frame in selected_frames:
		frame.add_modifier(remover)
	
	update_modifiers()

func offset_x_changed(value: float) -> void:
	for frame in selected_frames:
		frame.offset.x = value
		frame.changed.emit()

func offset_y_changed(value: float) -> void:
	for frame in selected_frames:
		frame.offset.y = value
		frame.changed.emit()

func center_image() -> void:
	var sz: Vector2i = owner.spritesheet.frame_size
	for frame in selected_frames:
		var ims := frame.image.get_size()
		if ims.x < sz.x:
			offset_x.set_value_no_signal((sz.x - ims.x) / 2)
			frame.offset.x = (sz.x - ims.x) / 2
		else:
			offset_x.set_value_no_signal(0)
			frame.offset.x = 0
		
		if ims.y < sz.y:
			offset_y.set_value_no_signal((sz.y - ims.y) / 2)
			frame.offset.y = (sz.y - ims.y) / 2
		else:
			offset_y.set_value_no_signal(0)
			frame.offset.y = 0
		frame.changed.emit()
