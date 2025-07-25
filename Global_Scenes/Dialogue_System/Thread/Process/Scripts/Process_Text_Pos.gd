extends "res://Global_Scenes/Dialogue_System/Thread/Process/Scripts/Process_Base.gd"

@onready var _a_Text_Box = get_node("Text_Box")
@onready var _a_Name = get_node("Text_Box/Name")
@onready var _a_Name_Text = get_node("Text_Box/Name/Margin/Text")
@onready var _a_Rect = get_node("Text_Box/VBox/Dialogue/Rect")
@onready var _a_Mini_Bust = get_node("Text_Box/VBox/Dialogue/Margin/HBox/Mini_Bust")
@onready var _a_Text = get_node("Text_Box/VBox/Dialogue/Margin/HBox/Margin/Text")
@onready var _a_Proceed_Dot = get_node("Text_Box/VBox/Dialogue/Proceed_Dot")
@onready var _a_Arrow = get_node("Text_Box/VBox/Arrow")
@onready var _a_Anims = get_node("Text_Box/Anims")

func _ready():
	super()
	_a_Anims.animation_finished.connect(_on_anim_finished)
	
	_load_data_general(_a_args["Data"][_a_type]["General"])
	await get_tree().process_frame
	_load_data_pos(_a_args["Data"][_a_type]["Pos"])
	_load_data_sprites(_a_args["Data"][_a_type]["Sprites"])
	
	if _a_fade_in:
		_a_Anims.play("Fade_In")
	else:
		_a_Anims.play("Faded_In")
	
	if _a_process_type == "Sub" || _a_process_type == "Manual":
		set_process_unhandled_input(false)
	
	_a_Proceed_Dot.hide()

func _input(p_event):
	if p_event.is_action_pressed("Proceed_Dialogue"):
		if _a_text_finished:
			if _a_fade_out:
				_a_Anims.play("Fade_Out")
			else:
				completed.emit()
				queue_free()
		else:
			var text_length = _a_Text.get_total_character_count()
			_a_Text.set_visible_characters(text_length)
			
			_a_text_finished = true
			_a_Proceed_Dot.show()
			_a_Character_Timer.stop()

func _load_data_general(p_data):
	var text_loc_id = p_data["Text"]["Loc_ID"]
	if !text_loc_id.is_empty():
		var real_text = _get_real_text(tr(text_loc_id))
		_a_Text.set_text("[center]%s" % real_text)

func _load_data_pos(p_data):
	var type = p_data["Pos"]["Type"]
	var name_type = p_data["Pos"]["Name_Type"]
	var text_box_size = _a_Text_Box.get_size()
	if type == "Custom":
		var custom_pos = p_data["Pos"]["Custom"]
		var pos = custom_pos - (text_box_size / 2)
		_a_Text_Box.set_position(pos)
	else:
		var vp_size = Global.get_base_vp_size()
		var pos = Global.get_layout_pos(text_box_size, vp_size, type, 16)
		_a_Text_Box.set_position(pos)
	
	match name_type:
		"Top": _a_Text_Box.move_child(_a_Name, 0)
		"Bottom": _a_Text_Box.move_child(_a_Name, 1)
	_a_Text_Box.set_pivot_offset(text_box_size / 2)
	
	var name_loc_id = p_data["Name"]["Loc_ID"]
	if !name_loc_id.is_empty():
		_a_Name_Text.set_text("[center]%s" % tr(name_loc_id))
	else:
		_a_Name.hide()
	
	var show_arrow = p_data["Show_Arrow"]
	_a_Arrow.set_visible(show_arrow)

func _load_data_sprites(p_data):
	var mini_bust_path = p_data["Mini_Bust"]
	if mini_bust_path.is_empty():
		_a_Rect.custom_minimum_size.x = 548 - _a_Mini_Bust.custom_minimum_size.x
		_a_Mini_Bust.hide()
	else:
		_a_Rect.custom_minimum_size.x = 548
		_a_Mini_Bust.set_texture(load(mini_bust_path))

func _on_Character_Timer_timeout():
	var visible_chars = _a_Text.get_visible_characters()
	var key = str(visible_chars)
	if _a_text_args.has(key):
		var text_args = _a_text_args[key]
		var command = text_args["Command"]
		var args = text_args["Args"]
		
		_handle_command(command, args)
		_a_text_args.erase(key)
		return
	
	if _a_play_vox && visible_chars % _e_chars_per_vox == 0:
		_a_Vox.play()
	
	var text_length = _a_Text.get_total_character_count()
	if visible_chars == text_length:
		_a_text_finished = true
		_a_Character_Timer.stop()
		
		match _a_process_type:
			"Main":
				_a_Proceed_Dot.show()
			"Sub":
				var wait_time = 1 + _e_read_time_per_char * text_length
				_a_Auto_Proceed.start(wait_time)
	else:
		_a_Text.set_visible_characters(visible_chars + 1)

func _on_anim_finished(p_anim):
	if p_anim == "Fade_In" || p_anim == "Faded_In":
		_a_Character_Timer.start(_e_time_between_chars)
	elif p_anim == "Fade_Out":
		await get_tree().process_frame
		completed.emit()
		queue_free()

func _on_Auto_Proceed_timeout():
	if _a_fade_out:
		_a_Anims.play("Fade_Out")
	else:
		await get_tree().process_frame
		completed.emit()
		queue_free()
	_a_Auto_Proceed.stop()
