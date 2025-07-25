extends CanvasLayer

@export_enum("Left", "Right") var _e_pos = "Right"

@onready var _a_Margin = get_node("Margin")
@onready var _a_Panel = get_node("Margin/Panel")
@onready var _a_Value = get_node("Margin/Panel/Value")

func _ready():
	_a_Panel.gui_input.connect(_on_Panel_gui_input)
	set_pos(_e_pos)

func _process(_p_delta):
	var fps = Engine.get_frames_per_second()
	_a_Value.set_text(str(int(fps)))

func set_pos(p_pos):
	match p_pos:
		"Left": _a_Margin.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		"Right": _a_Margin.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	
	_e_pos = p_pos

func get_pos():
	return _e_pos

func _on_Panel_gui_input(p_event):
	if p_event.is_action_pressed("Mouse_Left"):
		if _e_pos == "Left":
			set_pos("Right")
		else:
			set_pos("Left")
