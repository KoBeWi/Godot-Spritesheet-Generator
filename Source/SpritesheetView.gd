extends CanvasLayer

var pan_origin: Vector2
var pan_start: Vector2
var mouse_zooming: bool

func _ready() -> void:
	%Grid.minimum_size_changed.connect(refresh_background)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var cc: Control = %Spritesheet
		
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				pan_origin = get_mouse_position()
				pan_start = cc.position
			else:
				pan_origin = Vector2()
		
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var lm = cc.get_local_mouse_position()
			mouse_zooming = true
			%ZoomSlider.value -= 0.05
			mouse_zooming = false
			cc.position -= (lm - cc.get_local_mouse_position()) * cc.scale
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var lm = cc.get_local_mouse_position()
			%ZoomSlider.value += 0.05
			mouse_zooming = true
			cc.position -= (lm - cc.get_local_mouse_position()) * cc.scale
			mouse_zooming = false
	
	if event is InputEventMouseMotion:
		if pan_origin != Vector2():
			%Spritesheet.position = pan_start + (get_mouse_position() - pan_origin)

func get_mouse_position() -> Vector2:
	return owner.get_local_mouse_position()

func refresh_background():
	%Background.custom_minimum_size = %Grid.get_minimum_size()

func recenter() -> void: ## TODO: widok całości? dopasowanie zoomo do rozmiaru?
	%Spritesheet.position = get_viewport().size / 2 - Vector2i(%Spritesheet.size) / 2
	%Spritesheet.scale = Vector2.ONE

func set_zoom(value: float) -> void:
	var cc: Control = %Spritesheet
	var center_position: Vector2
	
	if not mouse_zooming:
		center_position = cc.position + cc.size * 0.5 * cc.scale
	
	cc.scale = Vector2.ONE * value
	%ZoomLabel.text = "%0.2fx" % value
	
	if not mouse_zooming:
		cc.position = center_position - cc.size * 0.5 * cc.scale
