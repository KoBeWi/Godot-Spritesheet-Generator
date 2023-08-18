extends CanvasLayer

var pan_origin: Vector2
var pan_start: Vector2

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
			cc.scale -= Vector2.ONE * 0.05
			if cc.scale.x <= 0:
				cc.scale = Vector2.ONE * 0.05
			
			cc.position -= (lm - cc.get_local_mouse_position()) * cc.scale
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var lm = cc.get_local_mouse_position()
			cc.scale += Vector2.ONE * 0.05
			cc.position -= (lm - cc.get_local_mouse_position()) * cc.scale
	
	if event is InputEventMouseMotion:
		if pan_origin != Vector2():
			%Spritesheet.position = pan_start + (get_mouse_position() - pan_origin)

func get_mouse_position() -> Vector2:
	return owner.get_local_mouse_position()

func refresh_background():
	%Background.custom_minimum_size = %Grid.get_minimum_size()
