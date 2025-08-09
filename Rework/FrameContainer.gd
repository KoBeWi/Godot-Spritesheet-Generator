extends MarginContainer

const SCENE = preload("uid://c6ce0mrlnw0ui")

@onready var grid := get_parent() as GridContainer
@onready var texture: Control = %Texture
@onready var margins: MarginContainer = $Margins
@onready var background: ColorRect = $Background
@onready var selection: Panel = $Selection

var spritesheet: SpriteSheet
var frame: SpriteSheet.Frame:
	set(f):
		if frame == f:
			return
		
		if frame:
			frame.changed.disconnect(update)
		
		frame = f
		frame.changed.connect(update)

var disable_input: bool
var maximum_size := Vector2.INF:
	set(ms):
		if maximum_size == ms:
			return
		maximum_size = ms
		update()
var draw_scale := 1.0

signal selection_changed

func _ready() -> void:
	Settings.subscribe(texture.queue_redraw)

func update():
	update_margins()
	if spritesheet.frame_size.x <= maximum_size.x and spritesheet.frame_size.y <= maximum_size.y:
		draw_scale = 1.0
		texture.custom_minimum_size = spritesheet.frame_size
	elif spritesheet.frame_size.x > spritesheet.frame_size.y:
		draw_scale = maximum_size.x / spritesheet.frame_size.x
		texture.custom_minimum_size = Vector2(maximum_size.x, spritesheet.frame_size.y * draw_scale)
	else:
		draw_scale = maximum_size.y / spritesheet.frame_size.y
		texture.custom_minimum_size = Vector2(spritesheet.frame_size.x * draw_scale, maximum_size.y)
	
	texture.queue_redraw()

func update_margins():
	margins.begin_bulk_theme_override()
	margins.add_theme_constant_override(&"margin_left", spritesheet.margins.x)
	margins.add_theme_constant_override(&"margin_right", spritesheet.margins.x)
	margins.add_theme_constant_override(&"margin_top", spritesheet.margins.y)
	margins.add_theme_constant_override(&"margin_bottom", spritesheet.margins.y)
	margins.end_bulk_theme_override()

func _gui_input(event: InputEvent) -> void:
	if disable_input:
		return
	
	var mb := event as InputEventMouseButton
	if mb:
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			var disabled: bool
			if not mb.shift_pressed:
				for node in grid.get_children():
					if node != self:
						disabled = disabled or node.selection.visible
						node.selection.visible = false
			
			if not disabled or not selection.visible:
				selection.visible = not selection.visible
				selection_changed.emit()
		return

func is_selected() -> bool:
	return selection.visible

func _on_texture_draw() -> void:
	if not frame.texture:
		return
	
	var rect := Rect2(frame.offset, frame.texture.get_size() * draw_scale)
	if not disable_input and Settings.settings.show_outline:
		texture.draw_rect(rect, Settings.settings.outline_color, false)
	texture.draw_texture_rect(frame.texture, rect, false)
