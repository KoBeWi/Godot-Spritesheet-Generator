extends MarginContainer

const SCENE = preload("uid://c6ce0mrlnw0ui")

@onready var texture: TextureRect = %Texture
@onready var margins: MarginContainer = $Margins
@onready var background: ColorRect = $Background
@onready var selection: Panel = $Selection

var frame: SpriteSheet.Frame
var disable_input: bool

func _ready() -> void:
	update()

func update():
	if frame:
		texture.texture = frame.texture
	else:
		texture.texture = null

func update_margins(horizontal: int, vertical: int):
	margins.add_theme_constant_override(&"margin_left", horizontal + frame.offset.x)
	margins.add_theme_constant_override(&"margin_right", horizontal)
	margins.add_theme_constant_override(&"margin_top", vertical + frame.offset.y)
	margins.add_theme_constant_override(&"margin_bottom", vertical)

func _gui_input(event: InputEvent) -> void:
	if disable_input:
		return
	
	var mb := event as InputEventMouseButton
	if mb:
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			selection.visible = not selection.visible
			if not mb.shift_pressed:
				for node in get_parent().get_children():
					if node != self:
						node.selection.visible = false

func is_selected() -> bool:
	return selection.visible
