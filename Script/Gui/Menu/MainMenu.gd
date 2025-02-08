extends MainMenu

@onready var panel_menu = %PanelMenu

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_anything_pressed():
		# Set the animation mark to the very end, so all final values are still set.
		var animation_player := $AnimationPlayer as AnimationPlayer
		animation_player.seek(animation_player.current_animation_length)

		set_process(false)
		
		
func _open_sub_menu(menu : Control):
	panel_menu.visible = true
	
	sub_menu = menu
	sub_menu.show()

func _close_sub_menu():
	if sub_menu == null:
		return
	
	panel_menu.visible = false
	
	sub_menu.hide()
	sub_menu = null
