extends CanvasLayer

var _a_HBox_Entry = preload("res://Global_Scenes/Debug/General/Teleport_Scene/HBox_Entry.tscn")
var _a_VBox_Entry = preload("res://Global_Scenes/Debug/General/Teleport_Scene/VBox_Entry.tscn")

@onready var _a_Return = get_node("Control/VBox/Return")
@onready var _a_Teleportations = get_node("Control/VBox/Scroll/VBox/Teleportations/VBox")
@onready var _a_Teleportations_Heading = get_node("Control/VBox/Scroll/VBox/Teleportations/Heading")

func _ready():
	_a_Return.pressed.connect(_on_Return_pressed)
	Databases.data_loaded.connect(_on_Databases_data_loaded)
	
	update_trans()
	
	hide()

func update_trans():
	_a_Teleportations_Heading.set_text("[center][u]%s" % tr("DEBUG_GENERAL_TELEPORTATIONS"))

func open():
	show()

func close():
	hide()

func _create_teleport_list():
	var data = Databases.get_data("Maps")
	for key in data:
		var vbox_instance = _a_VBox_Entry.instantiate()
		vbox_instance.set_heading_text.call_deferred(key)
		
		for destination in data[key].get_destinations():
			var dest = [key, destination]
			var hbox_instance = _a_HBox_Entry.instantiate()
			hbox_instance.select_pressed.connect(_on_Normal_Select_pressed.bind(dest))
			hbox_instance.set_select_text.call_deferred(destination)
			
			vbox_instance.add_child(hbox_instance)
		_a_Teleportations.add_child(vbox_instance)

func _on_Return_pressed():
	close()

func _on_Databases_data_loaded():
	_create_teleport_list()

func _on_Normal_Select_pressed(p_dest):
	Scene_Manager.change_scene_dest(p_dest)
	Debug.close()
	close()
