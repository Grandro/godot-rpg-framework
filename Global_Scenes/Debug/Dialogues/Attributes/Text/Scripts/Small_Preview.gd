extends Control

@onready var _a_VBox = get_node("VBox")
@onready var _a_Text_Box = get_node("VBox/Text_Box")
@onready var _a_Name = get_node("VBox/Text_Box/Name")
@onready var _a_Dialogue = get_node("VBox/Text_Box/Dialogue")
@onready var _a_Mini_Bust = get_node("VBox/Text_Box/Dialogue/Margin/HBox/Mini_Bust")
@onready var _a_Margin = get_node("VBox/Margin")
@onready var _a_Arrow = get_node("VBox/Margin/Arrow")
@onready var _a_Choices_Box = get_node("VBox/Margin/Choices_Box")

var _a_type = "" # Layout/Custom
var _a_custom = "" # Custom value
var _a_name_type = "" # Top/Bottom

func _ready():
	_a_Text_Box.resized.connect(_on_Text_Box_resized)
	
	_a_Name.hide()
	_a_Mini_Bust.hide()
	_a_Arrow.hide()
	_a_Choices_Box.hide()

func update():
	if _a_type == "Custom":
		_update_by_custom()
	else:
		_update_by_layout()

func _update_by_custom():
	var custom = _a_custom
	var arrow_visible = _a_Arrow.is_visible()
	if arrow_visible:
		# Get arrow pointing
		var arrow_pos = _a_Arrow.get_position() + _a_Margin.get_position()
		var arrow_size = _a_Arrow.get_size()
		arrow_size.x /= 2
		custom -= arrow_pos + arrow_size
	else:
		# Get dialogue text pos center
		var dialogue_pos = _a_Dialogue.get_position()
		var dialogue_size = _a_Dialogue.get_size() / 2
		custom -= dialogue_pos + dialogue_size
	
	_a_VBox.set_position(custom)

func _update_by_layout():
	var size_ = _a_VBox.get_size()
	var vp_size = Vector2(128, 72)
	var pos = Global.get_layout_pos(size_, vp_size, _a_type, 2)
	_a_VBox.set_position(pos)

func _update_name_pos():
	match _a_name_type:
		"Top": _a_Text_Box.move_child(_a_Name, 0)
		"Bottom": _a_Text_Box.move_child(_a_Name, 1)

func set_type(p_type):
	_a_type = p_type

func set_custom(p_custom):
	_a_custom = p_custom

func set_name_type(p_name_type):
	_a_name_type = p_name_type
	_update_name_pos()
	await get_tree().process_frame
	update()

func set_name_visible(p_visible):
	_a_Name.set_visible(p_visible)

func set_arrow_visible(p_visible):
	_a_Arrow.set_visible(p_visible)

func set_choices_box_visible(p_visible):
	_a_Choices_Box.set_visible(p_visible)

func set_choices_box_layout(p_layout):
	match p_layout:
		"Left": _a_Choices_Box.set_h_size_flags(0)
		"Center": _a_Choices_Box.set_h_size_flags(4)
		"Right": _a_Choices_Box.set_h_size_flags(8)

func _on_Text_Box_resized():
	await get_tree().process_frame
	update()
