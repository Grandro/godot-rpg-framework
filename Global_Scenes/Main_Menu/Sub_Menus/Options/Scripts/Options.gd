extends Control

signal closed(p_data)

@export_enum("Main_Menu", "Title_Screen") var _e_context = "Main_Menu"

@onready var _a_Back = get_node("Back")
@onready var _a_Tabs = get_node("Margin/VBox/Tabs")

func _ready():
	_a_Back.select_pressed.connect(_on_Back_select_pressed)
	
	update_trans()
	
	var data = Global_Data.get_entry_data("Options")
	for child in _a_Tabs.get_children():
		var key = child.get_name()
		child.load_data(data[key])

func open(_p_data = {}):
	show()

func _close():
	Global_Data.save_data()
	
	match _e_context:
		"Main_Menu": queue_free()
		"Title_Screen": hide()
	
	var data = {}
	closed.emit(data)

func update_trans():
	var children = _a_Tabs.get_children()
	for i in children.size():
		var child = children[i]
		var key = child.get_name()
		var text = tr("OPTIONS_%s" % key.to_upper())
		_a_Tabs.set_tab_title(i, text)

func _on_Back_select_pressed():
	_close()
