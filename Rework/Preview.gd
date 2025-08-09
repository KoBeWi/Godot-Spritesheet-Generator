extends Control

@onready var preview_frame: MarginContainer = %PreviewFrame
@onready var timeline: HSlider = %Timeline
@onready var timeline_frame: Label = %TimelineFrame
@onready var loop: CheckBox = %Loop
@onready var play_button: Button = %PlayButton

var frame_time: float = 1.0 / 12.0
var frame_progress: float

func _ready() -> void:
	Settings.subscribe(update_size)
	update_size.call_deferred()
	preview_frame.disable_input = true

func update_size():
	preview_frame.maximum_size = Settings.settings.preview_size

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			update_settings()
	elif what == NOTIFICATION_INTERNAL_PROCESS:
		frame_progress += get_process_delta_time()
		if frame_progress >= frame_time:
			frame_progress -= frame_time
			if timeline.value == timeline.max_value:
				if loop.button_pressed:
					timeline.value = 0
				else:
					set_process_internal(false)
					update_play_button()
			else:
				timeline.value += 1

func update_settings():
	timeline.max_value = owner.spritesheet.frames.size() - 1
	timeline.tick_count = timeline.max_value + 1
	update_frame()

func update_frame():
	preview_frame.frame = owner.spritesheet.frames[int(timeline.value)]
	preview_frame.update()
	timeline_frame.text = str(int(timeline.value))

func _play_pause() -> void:
	if not is_processing_internal() and timeline.value == timeline.max_value:
		timeline.value = 0
		frame_progress = 0
	
	set_process_internal(not is_processing_internal())
	update_play_button()

func _on_timeline_value_changed(value: float) -> void:
	update_frame()

func _on_fps_changed(value: float) -> void:
	frame_time = 1.0 / value

func update_play_button():
	const PLAY = preload("res://Rework/Play.svg")
	const PAUSE = preload("res://Rework/Pause.svg")
	play_button.icon = PAUSE if is_processing_internal() else PLAY
