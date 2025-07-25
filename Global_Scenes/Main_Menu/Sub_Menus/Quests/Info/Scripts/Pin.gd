extends Button

var _a_Pin_Texture = preload("res://Global_Resources/Sprites/UI/Pin.png")
var _a_Pinned_Texture = preload("res://Global_Resources/Sprites/UI/Pinned.png")

func _ready():
	toggled.connect(_on_toggled)

func _on_toggled(p_toggled):
	if p_toggled:
		set_text(tr("PINNED"))
		set_button_icon(_a_Pinned_Texture)
	else:
		set_text(tr("PIN"))
		set_button_icon(_a_Pin_Texture)
