extends PopupPanel

func _ready() -> void:
	%BackgroundPicker.color = %Background.color

func show_settings():
	var button_pos: Vector2 = %SettingsButton.get_screen_position()
	position = button_pos + Vector2(0, %SettingsButton.size.y)
	popup()

func _on_background_picker_color_changed(color: Color) -> void:
	%Background.color = color
