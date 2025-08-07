extends Control

@onready var name_label: Label = %NameLabel

var modifier: SpriteSheet.FrameModifier

func set_modifier(m: SpriteSheet.FrameModifier):
	modifier = m

func _ready() -> void:
	name_label.text = modifier.name
