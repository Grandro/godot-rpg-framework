extends MarginContainer

signal select_pressed()

@onready var _a_Select = get_node("Select")
@onready var _a_Anchor = get_node("Anchor")
@onready var _a_Image_Anims = get_node("Anchor/Image/Anims")

func _ready():
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_Select.focus_entered.connect(_on_Select_focus_entered)
	_a_Select.focus_exited.connect(_on_Select_focus_exited)

func grab_select_focus():
	_a_Select.grab_focus()

func _on_Select_pressed():
	select_pressed.emit()

func _on_Select_focus_entered():
	_a_Anchor.set_z_index(1)
	_a_Image_Anims.play("Zoom_In")

func _on_Select_focus_exited():
	_a_Anchor.set_z_index(0)
	_a_Image_Anims.play("Zoom_Out")
