extends HBoxContainer

enum { RESET, MIRROR_H = 2, MIRROR_V, CYCLE_RIGHT, CYCLE_LEFT, REVERSE, SHUFFLE }

@onready var sprite_sheet_grid: GridContainer = %SpriteSheetGrid

func _ready() -> void:
	for node in get_children():
		if node is Button:
			node.pressed.connect(make_transform.bind(node.get_index()))

func make_transform(id: int):
	var frames: Array[SpriteSheet.Frame] = owner.spritesheet.frames
	
	match id:
		RESET:
			frames.assign(owner.spritesheet.all_frames)
			for frame in frames:
				frame.modifiers.clear()
				frame.update_image()
		
		MIRROR_H:
			var columns := sprite_sheet_grid.columns
			var new_frames: Array[SpriteSheet.Frame]
			new_frames.resize(frames.size())
			
			for i in frames.size():
				var x := i % columns
				var y := i / columns
				x = columns - x
				new_frames[i] = frames[mini(y * columns + x, frames.size() -1)]
			
			# TODO: also flip
			frames.assign(new_frames)
		
		MIRROR_V:
			var columns := sprite_sheet_grid.columns
			var rows := frames.size() / sprite_sheet_grid.columns
			var new_frames: Array[SpriteSheet.Frame]
			new_frames.resize(frames.size())
			
			for i in frames.size():
				var x := i % columns
				var y := i / columns
				y = rows - y
				new_frames[i] = frames[mini(y * columns + x, frames.size() -1)]
			
			frames.assign(new_frames)
		
		CYCLE_RIGHT:
			var new_frames: Array[SpriteSheet.Frame]
			new_frames.resize(frames.size())
			
			for i in frames.size():
				new_frames[i] = frames[posmod(i - 1, frames.size())]
			
			frames.assign(new_frames)
		
		CYCLE_LEFT:
			var new_frames: Array[SpriteSheet.Frame]
			new_frames.resize(frames.size())
			
			for i in frames.size():
				new_frames[i] = frames[posmod(i + 1, frames.size())]
			
			frames.assign(new_frames)
		
		REVERSE:
			var new_frames: Array[SpriteSheet.Frame]
			var frames_size := frames.size()
			new_frames.resize(frames_size)
			
			for i in frames.size():
				new_frames[i] = frames[frames_size - i - 1]
			
			frames.assign(new_frames)
		
		SHUFFLE:
			frames.shuffle()
	
	sprite_sheet_grid.update_frame_list()
