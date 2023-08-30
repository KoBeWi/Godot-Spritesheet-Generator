extends AcceptDialog

func stash_frame(frame: Node):
	var image: Image = frame.get_texture_data()
	var texture := ImageTexture.create_from_image(image)
	
	var button := TextureButton.new()
	button.texture_normal = texture
	button.custom_minimum_size = Vector2(128, 128)
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.ignore_texture_size = true
	button.pressed.connect(unstash_frame.bind(button), CONNECT_DEFERRED)
	%StashImages.add_child(button)
	
	var ref := ReferenceRect.new()
	button.add_child(ref)
	ref.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ref.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ref.editor_only = false
	
	frame.free()
	%Spritesheet.update_columns()
	update_stash()

func unstash_frame(tb: TextureButton):
	%Spritesheet.add_frame(tb.texture_normal)
	%Spritesheet.update_columns()
	tb.free()
	update_stash()
	
	if %Stash.disabled:
		hide()

func update_stash():
	%Stash.disabled = %StashImages.get_child_count() == 0
