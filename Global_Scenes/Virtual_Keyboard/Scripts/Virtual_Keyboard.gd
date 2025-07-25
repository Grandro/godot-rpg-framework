extends CanvasLayer

signal opened()
signal closed()
signal input_proceeded(p_input)

@export var _e_hold_down: float = 0.16
@export var _e_max_input: int = 30

const _a_DIRS = ["down", "left", "right", "up"]

var _a_Keys_HBox_Scene = preload("res://Global_Scenes/Virtual_Keyboard/Keys_HBox.tscn")
var _a_Key_Scene = preload("res://Global_Scenes/Virtual_Keyboard/Key.tscn")

@onready var _a_Control = get_node("Control")
@onready var _a_Hold_Down = get_node("Control/Hold_Down")
@onready var _a_Back_Text = get_node("Control/Explanation/Back/Text")
@onready var _a_Proceed_Text = get_node("Control/Explanation/Proceed/Text")
@onready var _a_Input_Text = get_node("Control/VBox/HBox/Input")
@onready var _a_Keys_HBoxs = get_node("Control/VBox/Keys_HBoxs")
@onready var _a_SFX_Dir_Pressed = get_node("SFX/Dir_Pressed")
@onready var _a_SFX_Button_Down = get_node("SFX/Button_Down")
@onready var _a_SFX_Button_Up = get_node("SFX/Button_Up")
@onready var _a_SFX_Back = get_node("SFX/Back")
@onready var _a_SFX_Proceed = get_node("SFX/Proceed")

var _a_held_dir = ""
var _a_input = ""
var _a_button_down = false
var _a_focused_color = Color.WHITE

func _ready():
	_a_Hold_Down.timeout.connect(_on_Hold_Down_timeout)
	Databases.data_loaded.connect(_on_Databases_data_loaded)
	Global_Data.keyboard_layout_changed.connect(_on_Global_Data_keyboard_layout_changed)
	
	_a_Hold_Down.set_wait_time(_e_hold_down)
	
	set_process(false)
	set_process_input(false)
	
	_a_Control.hide()

func _process(_p_delta):
	if !_a_held_dir.is_empty():
		var event_name = "ui_%s" % _a_held_dir
		if !Input.is_action_pressed(event_name):
			_a_held_dir = ""
			_a_Hold_Down.stop()

func _input(p_event):
	if !_a_button_down:
		for dir in _a_DIRS:
			var event_name = "ui_%s" % dir
			if p_event.is_action_pressed(event_name):
				_a_held_dir = dir
				_a_Hold_Down.start()
	
	if p_event.is_action_pressed("ui_cancel"):
		if _a_input.is_empty():
			_a_SFX_Back.set_pitch_scale(1.0)
			_a_SFX_Back.play()
			close()
		else:
			_a_SFX_Back.set_pitch_scale(1.25)
			_a_SFX_Back.play()
			_a_input = _a_input.left(_a_input.length() - 1)
			_a_Input_Text.set_text(_a_input)
			_update_back_text()
		get_viewport().set_input_as_handled()
	
	elif p_event.is_action_pressed("Joy_X"):
		_input_proceeded()
		get_viewport().set_input_as_handled()

func update_trans():
	_update_back_text()
	_a_Proceed_Text.set_text(tr("PROCEED"))

func open(p_input = ""):
	var hbox = _a_Keys_HBoxs.get_child(0)
	var instance = hbox.get_child(0)
	instance.grab_focus()
	_a_input = p_input
	_a_Input_Text.set_text(p_input)
	_update_back_text()
	_a_Control.show()
	
	opened.emit()
	
	# Fix for Joypad_Up/Left/Right/Up being pressed (Sound being played)
	#await get_tree().process_frame
	#await get_tree().process_frame
	
	set_process(true)
	set_process_input(true)

func close():
	input_proceeded.emit(_a_input)
	_reset()
	closed.emit()

func _input_proceeded():
	_a_SFX_Proceed.play()
	close()

func _reset():
	set_process(false)
	set_process_input(false)
	_set_keys_focus_mode(_a_Control.FOCUS_ALL)
	_a_input = ""
	_a_Input_Text.set_text("")
	_a_Hold_Down.stop()
	_a_Control.hide()

func _update_key_instances(p_keyboard_layout):
	for child in _a_Keys_HBoxs.get_children():
		_a_Keys_HBoxs.remove_child(child)
		child.queue_free()
	
	var data = Databases.get_data_entry("Keyboard_Layouts", p_keyboard_layout)
	for entry in data.get_layout():
		var keys_hbox = _a_Keys_HBox_Scene.instantiate()
		for idx in entry:
			var instance = _a_Key_Scene.instantiate()
			instance.button_down.connect(_on_Key_button_down.bind(instance))
			instance.button_up.connect(_on_Key_button_up)
			instance.focus_entered.connect(_on_Key_focus_entered.bind(instance))
			instance.focus_exited.connect(_on_Key_focus_exited.bind(instance))
			instance.set_char_idx(idx)
			instance.set_name(str(idx))
			instance.set_key_texture.call_deferred(idx)
			
			keys_hbox.add_child(instance)
		_a_Keys_HBoxs.add_child(keys_hbox)
	
	_set_focus_neighbours()

func _update_back_text():
	if _a_input.is_empty():
		_a_Back_Text.set_text(tr("CLOSE"))
	else:
		_a_Back_Text.set_text(tr("BACK"))

func _set_focus_neighbours():
	var hboxs_count = _a_Keys_HBoxs.get_child_count()
	for i in hboxs_count:
		var hbox_instance = _a_Keys_HBoxs.get_child(i)
		var key_count = hbox_instance.get_child_count()
		for j in key_count:
			var key_instance = hbox_instance.get_child(j)
			var down = null
			var left = null
			var right = null
			var up = null
			
			# Left
			if j == 0:
				left = hbox_instance.get_child(key_count - 1)
			else:
				left = hbox_instance.get_child(j - 1)
			
			# Right
			if j == key_count - 1:
				right = hbox_instance.get_child(0)
			else:
				right = hbox_instance.get_child(j + 1)
			
			# Down
			var down_hbox = null
			if i == hboxs_count - 1:
				down_hbox = _a_Keys_HBoxs.get_child(0)
			else:
				down_hbox = _a_Keys_HBoxs.get_child(i + 1)
			
			var down_hbox_key_count = down_hbox.get_child_count()
			var dif = abs(key_count - down_hbox_key_count)
			var thresh = dif / 2
			if down_hbox_key_count <= key_count:
				if j - thresh < 0:
					down = down_hbox.get_child(0)
				elif j - thresh >= down_hbox_key_count:
					down = down_hbox.get_child(down_hbox_key_count - 1)
				else:
					down = down_hbox.get_child(j - thresh)
			else:
				down = down_hbox.get_child(j + thresh)
			
			# Up
			var up_hbox = null
			if i == 0:
				up_hbox = _a_Keys_HBoxs.get_child(hboxs_count - 1)
			else:
				up_hbox = _a_Keys_HBoxs.get_child(i - 1)
			
			var up_hbox_key_count = up_hbox.get_child_count()
			dif = abs(key_count - up_hbox_key_count)
			thresh = dif / 2
			
			if up_hbox_key_count <= key_count:
				if j - thresh < 0:
					up = up_hbox.get_child(0)
				elif j - thresh >= up_hbox_key_count:
					up = up_hbox.get_child(up_hbox_key_count - 1)
				else:
					up = up_hbox.get_child(j - thresh)
			else:
				up = up_hbox.get_child(j + thresh)
			
			key_instance.set_focus_neighbor(SIDE_LEFT, left.get_path())
			key_instance.set_focus_neighbor(SIDE_RIGHT, right.get_path())
			key_instance.set_focus_neighbor(SIDE_BOTTOM, down.get_path())
			key_instance.set_focus_neighbor(SIDE_TOP, up.get_path())

func _set_keys_focus_mode(p_focus_mode, p_except = null):
	for hbox_instance in _a_Keys_HBoxs.get_children():
		for key_instance in hbox_instance.get_children():
			if key_instance != p_except:
				key_instance.set_focus_mode(p_focus_mode)

func _on_Hold_Down_timeout():
	var focus_owner = get_viewport().gui_get_focus_owner()
	var next_path = NodePath()
	match _a_held_dir:
		"down": next_path = focus_owner.get_focus_neighbor(SIDE_BOTTOM)
		"left": next_path = focus_owner.get_focus_neighbor(SIDE_LEFT)
		"right": next_path = focus_owner.get_focus_neighbor(SIDE_RIGHT)
		"up": next_path = focus_owner.get_focus_neighbor(SIDE_TOP)
	
	var next_instance = get_node(next_path)
	next_instance.grab_focus()

func _on_Databases_data_loaded():
	var keyboard_layout = Global_Data.get_options_controls_keyboard_layout()
	_update_key_instances(keyboard_layout)

func _on_Global_Data_keyboard_layout_changed(p_keyboard_layout):
	_update_key_instances(p_keyboard_layout)

func _on_Key_button_down(p_instance):
	_a_SFX_Button_Down.play()
	
	_a_button_down = true
	_set_keys_focus_mode(_a_Control.FOCUS_NONE, p_instance)
	if _a_input.length() == _e_max_input:
		return
	
	var char_idx = p_instance.get_char_idx()
	_a_input += char(char_idx)
	_a_Input_Text.set_text(_a_input)
	_update_back_text()

func _on_Key_button_up():
	if _a_button_down:
		_a_SFX_Button_Up.play()
	
	_a_button_down = false
	_set_keys_focus_mode(_a_Control.FOCUS_ALL)

func _on_Key_focus_entered(p_instance):
	p_instance.set_self_modulate(_a_focused_color)
	_a_SFX_Dir_Pressed.play()

func _on_Key_focus_exited(p_instance):
	p_instance.set_self_modulate(Color.WHITE)
