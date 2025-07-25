extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Preview_Object.gd"

@onready var _a_Keep_Dir = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Keep_Dir")
@onready var _a_Backwards = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Backwards")
@onready var _a_Anim_All = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Anim_All")
@onready var _a_Anim_Keep_Dir = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Anim_Keep_Dir")
@onready var _a_Speed = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Speed")
@onready var _a_Wait_Finish = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Wait_Finish")

var _a_keep_dir = true # Backup keep dir when instance without movement comp is selected

func _ready():
	super()
	_a_Keep_Dir.toggled.connect(_on_Keep_Dir_toggled)
	_a_Backwards.pressed.connect(_on_Backwards_pressed)
	_a_Anim_All.selected.connect(_on_Anim_All_selected)
	_a_Anim_Keep_Dir.selected.connect(_on_Anim_Keep_Dir_selected)
	_a_Speed.value_changed.connect(_on_Speed_value_changed)
	
	_a_Anim_Keep_Dir.hide()

func open(p_instance, p_data, p_res_data):
	super(p_instance, p_data, p_res_data)
	
	_play_selected_anim()
	
	_a_Window.show()
	show()

func _open_init(p_res_data):
	super(p_res_data)
	_a_Object.load_data_init()
	_select_default_object(p_res_data)
	_selected_object_changed()
	_a_Keep_Dir.load_data_init()
	_a_Backwards.load_data_init()
	_a_Anim_All.load_data_init()
	_a_Anim_Keep_Dir.load_data_init()
	_a_Speed.load_data_init()
	_a_Wait_Finish.load_data_init()

func _open_load(p_data, p_res_data):
	super(p_data, p_res_data)
	_a_Object.load_data(p_data["Object"])
	_selected_object_changed()
	_a_Keep_Dir.load_data(p_data["Keep_Dir"])
	_a_Backwards.load_data(p_data["Backwards"])
	_a_Anim_All.load_data(p_data["Anim_All"])
	_a_Anim_Keep_Dir.load_data(p_data["Anim_Keep_Dir"])
	_a_Speed.load_data(p_data["Speed"])
	_a_Wait_Finish.load_data(p_data["Wait_Finish"])

func _selected_object_changed():
	super()
	if is_instance_valid(_a_object):
		if _a_object.comph().has_comp("Movement"):
			_a_object.comph().call_comp("Movement", "stop")
	
	_a_object = _a_Object.get_selected_value()
	var anim_list = Array(_a_object.comph().call_comp("Anims", "get_animation_list"))
	_a_Anim_All.set_options(anim_list)
	_a_Anim_Keep_Dir.set_options(anim_list)
	_a_Anim_All.update_options()
	_a_Anim_Keep_Dir.update_options()
	
	var has_movement = _a_object.comph().has_comp("Movement")
	_a_Keep_Dir.set_visible(has_movement)
	if has_movement:
		_a_Keep_Dir.set_pressed(_a_keep_dir)
	else:
		_a_keep_dir = _a_Keep_Dir.is_pressed()
		_a_Keep_Dir.set_pressed(false)

func _play_selected_anim():
	var instance = _a_Object.get_selected_value()
	var anim_list = instance.comph().call_comp("Anims", "get_animation_list")
	if anim_list.is_empty():
		return
	
	var anim_name = ""
	var keep_dir = _a_Keep_Dir.is_pressed()
	if keep_dir && _a_Keep_Dir.is_visible():
		var anims = _a_Anim_Keep_Dir.get_selected_key()
		var dir = _get_object_revert_property_value(instance, "Movement", "_a_shared._a_dir")
		if dir == null:
			dir = instance.comph().call_comp("Movement", "get_dir")
		if anims.has(dir):
			anim_name = anims[dir]
	else:
		anim_name = _a_Anim_All.get_selected_key()
	
	if !anim_name.is_empty():
		var speed = _a_Speed.get_value()
		var backwards = _a_Backwards.is_pressed()
		instance.comph().call_comp("Anims", "play_anim", [anim_name, speed, backwards])

func _get_save_data():
	var data = super()
	data["Keep_Dir"] = _a_Keep_Dir.get_save_data()
	data["Backwards"] = _a_Backwards.get_save_data()
	data["Anim_All"] = _a_Anim_All.get_save_data()
	data["Anim_Keep_Dir"] = _a_Anim_Keep_Dir.get_save_data()
	data["Speed"] = _a_Speed.get_save_data()
	data["Wait_Finish"] = _a_Wait_Finish.get_save_data()
	
	return data

func _on_Object_selected():
	super()
	_play_selected_anim()

func _on_Keep_Dir_toggled(p_toggled):
	_a_Anim_All.set_visible(!p_toggled)
	_a_Anim_Keep_Dir.set_visible(p_toggled)
	_play_selected_anim()

func _on_Backwards_pressed():
	_play_selected_anim()

func _on_Anim_All_selected():
	_play_selected_anim()

func _on_Anim_Keep_Dir_selected():
	_play_selected_anim()

func _on_Speed_value_changed(_p_value):
	_play_selected_anim()
