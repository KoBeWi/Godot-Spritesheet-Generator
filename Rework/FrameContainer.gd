extends MarginContainer

const SCENE = preload("uid://c6ce0mrlnw0ui")

@onready var texture: TextureRect = %Texture
@onready var margins: MarginContainer = $Margins
@onready var background: ColorRect = $Background

var frame: SpriteSheet.Frame

func _ready() -> void:
	if frame:
		texture.texture = frame.texture

func update_margins(horizontal: int, vertical: int):
	margins.add_theme_constant_override(&"margin_left", horizontal + frame.offset.x)
	margins.add_theme_constant_override(&"margin_right", horizontal)
	margins.add_theme_constant_override(&"margin_top", vertical + frame.offset.y)
	margins.add_theme_constant_override(&"margin_bottom", vertical)
