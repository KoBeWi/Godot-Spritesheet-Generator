extends Control

enum Tab {SPRITESHEET, FRAME_LIST, LAYOUT, PREVIEW}

@onready var tabs: TabContainer = %Tabs
@onready var sprite_sheet_grid: GridContainer = %SpriteSheetGrid

var spritesheet: SpriteSheet

func _ready() -> void:
	for i in range(1, tabs.get_tab_count()):
		tabs.set_tab_disabled(i, true)

func _new_spritesheet() -> void:
	if spritesheet:
		pass # dialog warning
	else:
		spritesheet = SpriteSheet.new()
		
		tabs.set_tab_disabled(Tab.FRAME_LIST, false)
		tabs.current_tab = Tab.FRAME_LIST

func _paste_image_from_clipboard() -> void:
	if not DisplayServer.clipboard_has_image():
		return
	
	var frame := SpriteSheet.Frame.new()
	frame.image = DisplayServer.clipboard_get_image()
	frame.texture = ImageTexture.create_from_image(frame.image)
	spritesheet.frames.append(frame)
	
	sprite_sheet_grid.update_frame_list()
