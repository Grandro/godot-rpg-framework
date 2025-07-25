extends "res://Global_Scenes/Main_Menu/Sub_Menus/Quests/Info/Scripts/Info_Base.gd"

signal pin_toggled(p_toggled)

@onready var _a_Pin = get_node("Margin/VBox/Pin")

func _ready():
	super()
	_a_Pin.toggled.connect(_on_Pin_toggled)

func display(p_key):
	super(p_key)
	
	var progress_si = Global.get_singleton(self, "Progress")
	var is_pinned = progress_si.is_quest_pinned(p_key)
	_a_Pin.toggled.disconnect(_on_Pin_toggled)
	_a_Pin.set_pressed(is_pinned)
	_a_Pin.toggled.connect(_on_Pin_toggled)

func _on_Pin_toggled(p_toggled):
	pin_toggled.emit(p_toggled)
