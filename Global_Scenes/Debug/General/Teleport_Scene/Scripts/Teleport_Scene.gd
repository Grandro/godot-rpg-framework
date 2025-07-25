extends HBoxContainer

@onready var _a_Desc = get_node("Desc")
@onready var _a_Select = get_node("Select")
@onready var _a_Select_Teleport = get_node("Select_Teleport")

func _ready():
	_a_Select.pressed.connect(_on_Select_pressed)
	Debug.closing.connect(_on_Debug_closing)

func update_trans():
	_a_Desc.set_text(tr("DEBUG_GENERAL_TELEPORT_SCENE"))
	_a_Select.set_text(tr("SELECT"))

func _on_Select_pressed():
	_a_Select_Teleport.open()

func _on_Debug_closing():
	_a_Select_Teleport.close()
