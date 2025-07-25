extends "res://Global_Scenes/Dialogue_System/Thread/Process/Scripts/Process_Base.gd"

@onready var _a_Left_Sprite = get_node("Control/Left_Sprite")
@onready var _a_Right_Sprite = get_node("Control/Right_Sprite")
@onready var _a_Text = get_node("Control/Info/Margin/Text")
@onready var _a_Proceed_Dot = get_node("Control/Info/Proceed_Dot")
@onready var _a_Anims = get_node("Control/Anims")

func _ready():
	super()
	_a_Anims.animation_finished.connect(_on_anim_finished)
	
	_set_data_general()
	_set_data_sprites()
	
	if _a_fade_in:
		_a_Anims.play("Fade_In")
	else:
		_a_Anims.play("Faded_In")
	
	if _a_process_type == "Sub" || _a_process_type == "Manual":
		set_process_input(false)
	
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

func _set_data_general():
	var data = _a_args["Data"][_a_type]["General"]
	var text_loc_id = data["Text"]["Loc_ID"]
	if !text_loc_id.is_empty():
		var real_text = _get_real_text(tr(text_loc_id))
		_a_Text.set_text("[center]%s" % real_text)

func _set_data_sprites():
	var data = _a_args["Data"][_a_type]["Sprites"]
	var left_path = data["Left"]
	var right_path = data["Right"]
	if !left_path.is_empty():
		_a_Left_Sprite.set_texture(load(left_path))
	if !right_path.is_empty():
		_a_Right_Sprite.set_texture(load(right_path))

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
	
	if p_anim == "Fade_Out":
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
