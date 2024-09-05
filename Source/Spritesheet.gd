extends CenterContainer

var margin: Vector2i

func hmargin_changed(value: float) -> void:
	margin.x = value
	refresh_margin()

func vmargin_changed(value: float) -> void:
	margin.y = value
	refresh_margin()

func refresh_margin():
	get_tree().call_group(&"frame", &"set_frame_margin", margin)

func add_frame(texture: Texture2D):
	var frame := preload("res://Source/SpritesheetFrame.tscn").instantiate()
	frame.set_texture(texture)
	frame.set_display_background(%DisplayGrid.button_pressed)
	frame.set_frame_margin(margin)
	%Grid.add_child(frame)
	frame.owner = owner

func refresh_grid():
	var coord: Vector2i
	var dark = false
	var columns: int = %Grid.columns
	
	for rect in %Grid.get_children():
		rect.set_background_color(Color(0, 0, 0, 0.2 if dark else 0.1))
		rect.update_index()
		dark = not dark
		coord.x += 1
		
		if coord.x == columns:
			coord.x = 0
			coord.y += 1
			dark = coord.y % 2 == 1

func toggle_grid(show: bool) -> void:
	get_tree().call_group(&"frame", &"set_display_background", show)

func toggle_auto(button_pressed: bool) -> void:
	%Columns.editable = not button_pressed
	update_columns()
	refresh_grid()

func columns_changed(value: float) -> void:
	%Grid.columns = value

func update_columns():
	if %Auto.button_pressed:
		var image_count: int = %Grid.get_child_count()
		var best: int
		var best_score = -9999999
		
		for i in range(1, image_count + 1):
			var cols = i
			var rows = ceili(image_count / float(i))
			
			var score = image_count - cols * rows - maxi(cols, rows) - rows
			if score > best_score:
				best = i
				best_score = score
		
		%Grid.columns = best
	else:
		%Grid.columns = %Columns.value
	
	refresh_grid()

func clear():
	for frame in %Grid.get_children():
		frame.free()
