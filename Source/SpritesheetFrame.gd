extends PanelContainer

var odd: Vector2

func set_frame_margin(margin: Vector2):
	$MarginContainer.add_theme_constant_override(&"margin_left", margin.x)
	$MarginContainer.add_theme_constant_override(&"margin_top", margin.y)
	
	margin += odd
	
	$MarginContainer.add_theme_constant_override(&"margin_right", margin.x)
	$MarginContainer.add_theme_constant_override(&"margin_bottom", margin.y)

func set_texture(texture: Texture2D):
	%TextureRect.texture = texture
	odd = Vector2(int(get_texture_size().x) % 2, int(get_texture_size().y) % 2)

func get_texture_size() -> Vector2:
	return %TextureRect.texture.get_size()

func get_texture() -> Texture2D:
	return %TextureRect.texture

func get_position2() -> Vector2:
	return position + %TextureRect.position

func get_texture_data() -> Image:
	return %TextureRect.texture.get_image()

func set_display_background(display: bool):
	get_theme_stylebox(&"panel").draw_center = display

func set_background_color(color: Color):
	get_theme_stylebox(&"panel").bg_color = color

func _get_drag_data(p: Vector2):
	var preview = TextureRect.new()
	preview.texture = %TextureRect.texture
	preview.ignore_texture_size = true
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.size = Vector2(64, 64)
	set_drag_preview(preview)
	return {type = "SpritesheetFrame", node = self}

func _can_drop_data(p: Vector2, data) -> bool:
	return data is Dictionary and data.get("type", "") == "SpritesheetFrame"

func _drop_data(p: Vector2, data) -> void:
	var index = get_index()
	if Input.is_key_pressed(KEY_SHIFT):
		get_parent().move_child(self, data.node.get_index())
	get_parent().move_child(data.node, index)
	owner.get_node(^"%Spritesheet").refresh_grid()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			owner.get_node(^"%StashDialog").stash_frame.call_deferred(self)
