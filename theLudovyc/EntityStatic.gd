extends Sprite2D
class_name EntityStatic

var width := 0

var height := 0

func update_offset():
	if texture == null:
		return
	if centered:
		centered = false
	var final_height = height
	if final_height % 2 == 0:
		final_height -= 1
	offset = Vector2(0, -texture.get_height()) + Vector2(-width * 32, final_height * 16)
