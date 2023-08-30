extends ConfirmationDialog

func update_split_preview():
	%SplitPreview.queue_redraw()

func draw_split_preview() -> void:
	var preview: TextureRect = %SplitPreview
	var frame_count := Vector2(%SplitX.value, %SplitY.value)
	var frame_size := preview.size / frame_count
	
	for x in range(1, frame_count.x):
		for y in int(frame_count.y):
			preview.draw_line(frame_size * Vector2(x, y), frame_size * Vector2(x, y + 1), Color.WHITE)
			preview.draw_line(frame_size * Vector2(x, y) + Vector2.RIGHT, frame_size * Vector2(x, y + 1) + Vector2.RIGHT, Color.BLACK)
	
	for y in range(1, frame_count.y):
		for x in int(frame_count.x):
			preview.draw_line(frame_size * Vector2(x, y), frame_size * Vector2(x + 1, y), Color.WHITE)
			preview.draw_line(frame_size * Vector2(x, y) + Vector2.DOWN, frame_size * Vector2(x + 1, y) + Vector2.DOWN, Color.BLACK)

#func split_spritesheet() -> void:
	#file_list.clear()
	#image_list.clear()
#
	#var image: Image = images_to_process[0]
	#var sub_image_size := image.get_size() / Vector2i(%SplitX.value, %SplitY.value)
#
	#for y in %SplitY.value:
		#for x in %SplitX.value:
			#image_list.append(image.get_region(Rect2i(Vector2i(x, y) * sub_image_size, sub_image_size)))
#
	#images_to_process.clear()
	#load_images()
