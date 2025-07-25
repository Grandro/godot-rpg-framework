extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Base.gd"

@onready var _a_Menus = get_node("Window/Contents/Margin/VBox/Menus")
@onready var _a_Else_Branch = get_node("Window/Contents/Margin/VBox/Else_Branch/Value")

var _a_key = "Items"
var _a_menus = {} # Match key to instance

func _ready():
	_a_OK = get_node("Window/Contents/Margin/VBox/HBox/OK")
	_a_Cancel = get_node("Window/Contents/Margin/VBox/HBox/Cancel")
	super()
	
	_a_Menus.tab_changed.connect(_on_Menus_tab_changed)
	
	for child in _a_Menus.get_children():
		var key = child.get_key()
		_a_menus[key] = child

func open(p_instance, p_data, p_res_data):
	super(p_instance, p_data, p_res_data)
	
	var instance = _a_menus[_a_key]
	instance.show()
	
	_a_Window.show()
	show()

func _open_init(_p_res_data):
	for instance in _a_Menus.get_children():
		instance.load_data({})

func _open_load(p_data, _p_res_data):
	var menus_data = p_data["Menus"]
	for key in menus_data:
		var instance = _a_menus[key]
		instance.load_data(menus_data[key])
	
	_a_key = p_data["Key"]
	_a_Else_Branch.set_pressed(p_data["Else_Branch"])

func _get_save_data():
	var data = {}
	data["Menus"] = {}
	for key in _a_menus:
		var instance = _a_menus[key]
		data["Menus"][key] = instance.get_save_data()
	data["Key"] = _a_key
	data["Else_Branch"] = _a_Else_Branch.is_pressed()
	
	return data

func _on_Menus_tab_changed(p_idx):
	var instance = _a_Menus.get_tab_control(p_idx)
	var key = instance.get_key()
	instance.show()
	_a_key = key
