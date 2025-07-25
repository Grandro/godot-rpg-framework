extends VBoxContainer

@export var _e_heading_loc_id : String = ""
@export var _e_var_select_scene : PackedScene = null

@onready var _a_HBox = get_node("HBox")
@onready var _a_Heading = get_node("HBox/Heading")

var _a_var_select = null

func _ready():
	update_trans()
	
	if _e_var_select_scene:
		_a_var_select = _e_var_select_scene.instantiate()
		_a_var_select.active_toggled.connect(_on_Var_Select_active_toggled)
		
		_a_HBox.add_child(_a_var_select)

func update_trans():
	_a_Heading.set_text(tr(_e_heading_loc_id))

func get_save_data():
	var data = {}
	data["Type"] = "Value"
	if _a_var_select:
		if _a_var_select.is_active():
			data["Type"] = "Var"
		data["Var"] = _a_var_select.get_save_data()
	
	return data

func load_data(p_data):
	if _a_var_select:
		_a_var_select.load_data(p_data["Var"])

func load_data_init():
	if _a_var_select:
		_a_var_select.load_data_init()

func _on_Var_Select_active_toggled(_p_toggled):
	pass
