extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Base.gd"

func _ready():
	_a_OK = get_node("Window/Contents/Margin/HBox/OK")
	_a_Cancel = get_node("Window/Contents/Margin/HBox/Cancel")
	super()

func open(p_instance, p_data, p_res_data):
	super(p_instance, p_data, p_res_data)
	
	_a_Window.show()
	show()
