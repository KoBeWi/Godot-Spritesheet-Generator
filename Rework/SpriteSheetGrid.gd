extends GridContainer

const FrameContainer = preload("res://Rework/FrameContainer.gd")

func update_frame_list():
	var missing_frames: Array[SpriteSheet.Frame] = owner.spritesheet.frames
	
	# coś tu nie działa jak się wkleja wielokrotnie
	for container: FrameContainer in get_children():
		var idx := missing_frames.find(container.frame)
		if idx == -1:
			container.queue_free()
		else:
			missing_frames.remove_at(idx)
	
	for frame in missing_frames:
		var new_container := FrameContainer.SCENE.instantiate()
		new_container.frame = frame
		add_child(new_container)
