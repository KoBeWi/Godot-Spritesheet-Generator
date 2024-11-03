extends MarginContainer

const SCENE = preload("uid://c6ce0mrlnw0ui")

@onready var texture_rect: TextureRect = $TextureRect

var frame: SpriteSheet.Frame

func _ready() -> void:
	texture_rect.texture = frame.texture
