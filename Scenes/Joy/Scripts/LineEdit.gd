extends LineEdit

func _gui_input(p_event):
	if Global.get_use_joy():
		if p_event.is_action_pressed("OK"):
			_open_virtual_keyboard()

func _open_virtual_keyboard():
	Virtual_Keyboard.closed.connect(_on_Virtual_Keyboard_closed)
	Virtual_Keyboard.input_proceeded.connect(_on_Virtual_Keyboard_input_proceeded)
	
	var curr_text = get_text()
	Virtual_Keyboard.open(curr_text.to_upper())

func _on_Virtual_Keyboard_closed():
	Virtual_Keyboard.closed.disconnect(_on_Virtual_Keyboard_closed)
	Virtual_Keyboard.input_proceeded.disconnect(_on_Virtual_Keyboard_input_proceeded)
	
	grab_focus()

func _on_Virtual_Keyboard_input_proceeded(p_input):
	var new_text = p_input.capitalize()
	set_text(new_text)
	text_changed.emit(new_text)
