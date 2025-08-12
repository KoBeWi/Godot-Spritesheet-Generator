extends Control

enum Tab {SPRITESHEET, FRAME_LIST, CUSTOMIZATION}

@onready var tabs: TabContainer = %Tabs
@onready var sprite_sheet_grid: GridContainer = %SpriteSheetGrid
@onready var preview: PanelContainer = %Preview
@onready var preview_button: Button = %PreviewButton

@onready var frame_width: SpinBox = %FrameWidth
@onready var frame_height: SpinBox = %FrameHeight
@onready var size_label: Label = %SizeLabel
@onready var size_format := size_label.text

@onready var confirm_new: ConfirmationDialog = $ConfirmNew
@onready var save_path: LineEdit = %SavePath
@onready var save_button: Button = %SaveButton
@onready var save_pick_dialog: FileDialog = %SavePickDialog
@onready var error_dialog: AcceptDialog = %ErrorDialog

var update_pending: bool

var spritesheet: SpriteSheet

func _ready() -> void:
	%InsertFrames.hide()
	
	for i in range(1, tabs.get_tab_count()):
		tabs.set_tab_disabled(i, true)
	
	_new_spritesheet()
	update_save_button()

func _new_spritesheet() -> void:
	if spritesheet:
		confirm_new.popup_centered()
	else:
		spritesheet = SpriteSheet.new()
		spritesheet.changed.connect(update_size)
		
		tabs.set_tab_disabled(Tab.FRAME_LIST, false)
		tabs.current_tab = Tab.FRAME_LIST
		preview.preview_frame.spritesheet = spritesheet
	
	update_size()

func _discard_spritesheet() -> void:
	spritesheet = null
	_new_spritesheet()
	queue_update_frames()

func queue_update_frames():
	if update_pending:
		return
	update_pending = true
	
	var no_frames := spritesheet.all_frames.is_empty()
	tabs.set_tab_disabled(Tab.CUSTOMIZATION, no_frames)
	
	var updater := func():
		sprite_sheet_grid.update_frame_list()
		update_size()
		update_pending = false
	
	update_save_button()
	updater.call_deferred()

func assign_path(path: String):
	if save_path.text.is_empty():
		save_path.text = path
		update_save_button()

func save_spritesheet() -> void:
	var frame_size: Vector2i = spritesheet.frame_size + spritesheet.margins * 2
	var saving_image := Image.create(frame_size.x * sprite_sheet_grid.columns, frame_size.y * sprite_sheet_grid.get_rows(), false, Image.FORMAT_RGBA8)
	
	var idx: int
	for frame in spritesheet.frames:
		saving_image.blit_rect(frame.image, Rect2i(Vector2(), frame_size), Vector2i(idx % sprite_sheet_grid.columns, idx / sprite_sheet_grid.columns) * frame_size + Vector2i(spritesheet.margins + frame.offset))
		idx += 1
	
	var err := saving_image.save_png(save_path.text)
	if err != OK:
		match err:
			ERR_FILE_CANT_OPEN:
				error_dialog.dialog_text = "Could not save spritesheet: Can't open file."
			_:
				error_dialog.dialog_text = "Could not save spritesheet: Error %d." % err
		error_dialog.popup_centered()

func update_size():
	frame_width.set_value_no_signal(spritesheet.frame_size.x)
	frame_height.set_value_no_signal(spritesheet.frame_size.y)
	
	var frame_size: Vector2i = spritesheet.frame_size + spritesheet.margins * 2
	frame_size.x *= sprite_sheet_grid.columns
	frame_size.y *= sprite_sheet_grid.get_rows()
	if spritesheet.frames.is_empty():
		frame_size = Vector2i()
	
	size_label.text = size_format % [frame_size.x, frame_size.y]

func _pick_save_file() -> void:
	save_pick_dialog.current_path = save_path.text
	save_pick_dialog.popup_centered()

func _on_file_picked(path: String) -> void:
	if path.get_extension().is_empty():
		save_path.text = path + ".png"
	else:
		save_path.text = path
	update_save_button()

func update_save_button() -> void:
	var path := save_path.text
	if path.is_empty():
		save_button.tooltip_text = "Path is empty."
	elif not path.is_absolute_path():
		save_button.tooltip_text = "Path must be absolute."
	elif path.get_extension() != "png":
		save_button.tooltip_text = "Must be a PNG file."
	elif spritesheet.frames.is_empty():
		save_button.tooltip_text = "SpriteSheet is empty."
	else:
		save_button.tooltip_text = ""
	
	save_button.disabled = not save_button.tooltip_text.is_empty()

func set_frame_width(value: float) -> void:
	if spritesheet.frame_size.x == value:
		return
	spritesheet.frame_size.x = value
	queue_update_frames()

func set_frame_height(value: float) -> void:
	if spritesheet.frame_size.y == value:
		return
	spritesheet.frame_size.y = value
	queue_update_frames()

func update_preview_button():
	var no_frames := spritesheet.frames.is_empty()
	preview_button.disabled = no_frames
	if no_frames:
		preview_button.button_pressed = false
