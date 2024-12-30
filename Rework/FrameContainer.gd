extends MarginContainer

const SCENE = preload("uid://c6ce0mrlnw0ui")

@onready var texture: TextureRect = %Texture

var frame: SpriteSheet.Frame

func _ready() -> void:
	texture.texture = frame.texture
