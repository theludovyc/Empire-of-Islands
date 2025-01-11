extends RichTextLabel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = get_global_mouse_position() - Vector2(size.x / 2, size.y * 1.5)
	pass


func _on_visibility_changed():
	# to avoid teleport effect
	if visible:
		position = get_global_mouse_position() - Vector2(size.x / 2, size.y * 1.5)

	set_process(visible)
