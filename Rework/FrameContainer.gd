extends MarginContainer

const SCENE = preload("uid://c6ce0mrlnw0ui")

@onready var grid := get_parent() as GridContainer
@onready var texture: TextureRect = %Texture
@onready var margins: MarginContainer = $Margins
@onready var background: ColorRect = $Background
@onready var selection: Panel = $Selection

var frame: SpriteSheet.Frame
var disable_input: bool

signal selection_changed

func _ready() -> void:
	update()

func update():
	if frame:
		texture.texture = frame.texture
	else:
		texture.texture = null

func update_margins(horizontal: int, vertical: int):
	margins.begin_bulk_theme_override()
	margins.add_theme_constant_override(&"margin_left", horizontal + frame.offset.x)
	margins.add_theme_constant_override(&"margin_right", horizontal)
	margins.add_theme_constant_override(&"margin_top", vertical + frame.offset.y)
	margins.add_theme_constant_override(&"margin_bottom", vertical)
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
