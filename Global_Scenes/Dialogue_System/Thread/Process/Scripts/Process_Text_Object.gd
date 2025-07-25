extends "res://Global_Scenes/Dialogue_System/Thread/Process/Scripts/Process_Base.gd"

@onready var _a_Mouse_Input = get_node("Mouse_Input")

var _a_instance_type = "" # Key/Speech_Bubble
var _a_speech_bubble = null # Speech_Bubble instance
var _a_has_choices = false # Has a_speech_bubble choices?
var _a_choices = {} # Choices data

func _ready():
	super()
	_set_data_object()
	_set_data_general()
	_set_data_choice()
	
	_a_Character_Timer.start(_e_time_between_chars)
	if _a_process_type == "Main":
		_a_Mouse_Input.gui_input.connect(_on_Mouse_Input_gui_input)
	set_process_unhandled_key_input(_a_process_type == "Main")
	_a_Mouse_Input.set_visible(_a_process_type == "Main")

func _unhandled_key_input(p_event):
	_handle_input(p_event)

func reset():
	super()
	_a_speech_bubble.reset(true)

func _handle_input(p_event):
	if p_event.is_action_pressed("Proceed_Dialogue"):
		get_viewport().set_input_as_handled()
		
		if _a_text_finished:
			_a_speech_bubble.reset(_a_fade_out)
			completed.emit()
			queue_free()
		else:
			var text_length = _a_speech_bubble.get_text_length()
			_a_speech_bubble.set_text_visible_characters(text_length)
			
			_a_text_finished = true
			if _a_has_choices:
				_a_speech_bubble.open_choices_box(_a_choices)
				set_process_unhandled_key_input(false)
			else:
				_a_speech_bubble.show_proceed_dot()
			_a_Character_Timer.stop()

func set_instance_type(p_instance_type):
	_a_instance_type = p_instance_type

func set_process_mode_(p_process_mode):
	super(p_process_mode)
	_a_speech_bubble.set_process_mode(p_process_mode)

func _set_data_object():
	if _a_instance_type == "Key":
		var data = _a_args["Data"][_a_type]["Object"]
		var object_key = data["Object"]
		if object_key != null:
			var global_si = Global.get_singleton(self, "Global")
			var instance = global_si.get_object(object_key)
			_a_speech_bubble = instance.comph().get_comp("Speech_Bubble")
	_a_speech_bubble.tree_exiting.connect(_on_Speech_Bubble_tree_exiting)
	_a_speech_bubble.choice_selected.connect(_on_Speech_Bubble_choice_selected)

func _set_data_general():
	var data = _a_args["Data"][_a_type]["General"]
	var text_loc_id = data["Text"]["Loc_ID"]
	if !text_loc_id.is_empty():
		var ensure_visibility = _a_args["Data"][_a_type]["Object"]["Ensure_Visibility"]
		var real_text = _get_real_text(tr(text_loc_id))
		_a_speech_bubble.set_text(real_text)
		_a_speech_bubble.set_process_mode(process_mode)
		_a_speech_bubble.open(ensure_visibility)

func _set_data_choice():
	var data = _a_args["Data"][_a_type]["Choice"]
	var entries = data["Entries"]
	if !entries.is_empty():
		_a_has_choices = true
		_a_choices = data

func _on_Character_Timer_timeout():
	var visible_chars = _a_speech_bubble.get_text_visible_characters()
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
	
	var text_length = _a_speech_bubble.get_text_length()
	if visible_chars == text_length:
		_a_text_finished = true
		_a_Character_Timer.stop()
		
		match _a_process_type:
			"Main":
				if _a_has_choices:
					_a_speech_bubble.open_choices_box(_a_choices)
					set_process_unhandled_key_input(false)
				else:
					_a_speech_bubble.show_proceed_dot()
			"Sub":
				var wait_time = 1 + _e_read_time_per_char * text_length
				_a_Auto_Proceed.start(wait_time)
	else:
		_a_speech_bubble.set_text_visible_characters(visible_chars + 1)

func _on_Auto_Proceed_timeout():
	_a_speech_bubble.reset(_a_fade_out)
	_a_Auto_Proceed.stop()
	completed.emit()
	queue_free()

func _on_Mouse_Input_gui_input(p_event):
	_handle_input(p_event)

func _on_Speech_Bubble_tree_exiting():
	_a_Character_Timer.stop()
	_a_Auto_Proceed.stop()

func _on_Speech_Bubble_choice_selected(p_value):
	_a_speech_bubble.reset(_a_fade_out)
	await get_tree().process_frame
	choice_selected.emit(p_value)
	completed.emit()
	queue_free()
