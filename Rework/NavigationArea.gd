extends Control

@export var move_target: Control
@export var zoom_slider: Slider
@export var recenter_button: Button

var panning: bool

func _ready() -> void:
	recenter_button.pressed.connect(recenter)
	zoom_slider.value_changed.connect(update_zoom)

func recenter():
	move_target.position = size * 0.5 - move_target.size * 0.5
	zoom_slider.value = 1.0

func update_zoom(value: float):
	move_target.scale = Vector2.ONE * value

func _gui_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb:
		const zoom_delta = 0.05
		if mb.button_index == MOUSE_BUTTON_MIDDLE:
			panning = mb.pressed
		else:
			var zoom_value := int(mb.button_index == MOUSE_BUTTON_WHEEL_UP) - int(mb.button_index == MOUSE_BUTTON_WHEEL_DOWN)
			if zoom_value != 0 and not event.is_pressed():
				var prev_pos := move_target.get_local_mouse_position()
				zoom_slider.value += zoom_value * zoom_delta
				var pos_delta := (move_target.get_local_mouse_position() - prev_pos) * zoom_slider.value
				move_target.position += pos_delta
		
		return
	
	var mm := event as InputEventMouseMotion
	if mm:
		if panning:
			move_target.position += mm.relative
		
		return
