extends AcceptDialog

var time: float
var fps: float

func _ready() -> void:
	set_process(false)
	visibility_changed.connect(func():
		if not visible:
			set_process(false))

func appear():
	%FrameValue.value = 0
	%FrameValue.max_value = %Grid.get_child_count() - 1
	%FrameValue.tick_count = %Grid.get_child_count()
	update_fps(%FPS.value)
	update_frame(0)
	time = 0
	popup_centered()

func update_frame(value: float) -> void:
	%FrameLabel.text = str(value)
	%PreviewTexture.texture = %Grid.get_child(value).get_texture()

func play() -> void:
	if not is_processing():
		%FrameValue.value = 0
	set_process(not is_processing())

func _process(delta: float) -> void:
	time += delta
	if time >= fps:
		time -= fps
		if %FrameValue.value < %FrameValue.max_value or %Loop.button_pressed:
			if %FrameValue.value == %FrameValue.max_value:
				%FrameValue.value = 0
			else:
				%FrameValue.value += 1
		else:
			set_process(false)

func update_fps(value: float) -> void:
	fps = 1.0 / value
