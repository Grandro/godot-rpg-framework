extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Base.gd"

@onready var _a_Type = get_node("Window/Contents/Margin/VBox/Type")
@onready var _a_Teleportation = get_node("Window/Contents/Margin/VBox/Teleportation")
@onready var _a_Destination = get_node("Window/Contents/Margin/VBox/Destination")
@onready var _a_Handle_Lost_Battle = get_node("Window/Contents/Margin/VBox/Handle_Lost_Battle")

func _ready():
	_a_OK = get_node("Window/Contents/Margin/VBox/HBox/OK")
	_a_Cancel = get_node("Window/Contents/Margin/VBox/HBox/Cancel")
	super()
	
	_a_Type.selected.connect(_on_Type_selected)
	_a_Teleportation.selected.connect(_on_Teleportation_selected)
	
	_a_Type.update_options()

func open(p_instance, p_data, p_res_data):
	super(p_instance, p_data, p_res_data)
	
	_a_Window.show()
	show()

func _open_init(_p_res_data):
	_a_Type.load_data_init()
	_selected_type_changed()
	_a_Teleportation.load_data_init()
	_selected_teleportation_changed()
	_a_Destination.load_data_init()
	_a_Handle_Lost_Battle.load_data_init()

func _open_load(p_data, _p_res_data):
	_a_Type.load_data(p_data["Type"])
	_selected_type_changed()
	_a_Teleportation.load_data(p_data["Teleportation"])
	_selected_teleportation_changed()
	_a_Destination.load_data(p_data["Destination"])
	_a_Handle_Lost_Battle.load_data(p_data["Handle_Lost_Battle"])

func _update_teleportations():
	var teleportation_location_keys = _get_teleportation_location_keys()
	_a_Teleportation.set_options(teleportation_location_keys)
	_a_Teleportation.update_options()

func _update_destinations():
	var destination_keys = _get_destination_keys()
	_a_Destination.set_options(destination_keys)
	_a_Destination.update_options()

func _selected_type_changed():
	var type = _a_Type.get_selected_key()
	_a_Destination.set_visible(type == "Map")
	_a_Handle_Lost_Battle.set_visible(type == "Battle")
	
	_update_teleportations()
	_update_destinations()

func _selected_teleportation_changed():
	_update_destinations()

func _get_teleportation_location_keys():
	var type = _a_Type.get_selected_key()
	var data = {}
	match type:
		"Map": data = Databases.get_data("Maps")
		"Battle": data = Databases.get_data("SV_Encounters")
	return data.keys()

func _get_destination_keys():
	var type = _a_Type.get_selected_key()
	var tp = _a_Teleportation.get_selected_key()
	var args = {}
	match type:
		"Map":
			var data = Databases.get_data_entry("Maps", tp)
			args = data.get_destinations()
	return args.keys()

func _get_save_data():
	var data = {}
	data["Type"] = _a_Type.get_save_data()
	data["Teleportation"] = _a_Teleportation.get_save_data()
	data["Destination"] = _a_Destination.get_save_data()
	data["Handle_Lost_Battle"] = _a_Handle_Lost_Battle.get_save_data()
	
	return data

func _on_Type_selected():
	_selected_type_changed()

func _on_Teleportation_selected():
	_selected_teleportation_changed()
