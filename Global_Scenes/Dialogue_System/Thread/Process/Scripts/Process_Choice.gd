extends "res://Global_Scenes/Dialogue_System/Thread/Process/Scripts/Process_Base.gd"

@onready var _a_Choice_1 = get_node("Control/Choice/Margin/VBox/HBox_1/Choice_1/Select")
@onready var _a_Choice_2 = get_node("Control/Choice/Margin/VBox/HBox_1/Choice_2/Select")
@onready var _a_Choice_3 = get_node("Control/Choice/Margin/VBox/HBox_2/Choice_3/Select")
@onready var _a_Choice_4 = get_node("Control/Choice/Margin/VBox/HBox_2/Choice_4/Select")
@onready var _a_Name = get_node("Control/Name")
@onready var _a_Name_Text = get_node("Control/Name/Margin/Text")
@onready var _a_Anims = get_node("Control/Anims")

var _a_choices = [] # Choice Select instances

func _ready():
	super()
	_a_Anims.animation_finished.connect(_on_anim_finished)
	
	_a_choices = [_a_Choice_1, _a_Choice_2, _a_Choice_3, _a_Choice_4]
	_set_data_choice()
	
	if _a_fade_in:
		_a_Anims.play("Fade_In")
	else:
		_a_Anims.play("Faded_In")

func _set_data_choice():
	var data = _a_args["Data"]["Choice"]
	var choices = data["Entries"]
	for i in choices.size():
		var args = choices[i]
		var instance = _a_choices[i]
		var loc_id = args["Loc_ID"]
		var value = args["Value"]
		instance.pressed.connect(_on_Choice_pressed.bind(value))
		instance.set_text(tr(loc_id))
	
	var name_id = data["Name_ID"]
	if !name_id.is_empty():
		_a_Name_Text.set_text(tr(name_id))
	else:
		_a_Name.hide()

func _on_anim_finished(p_anim):
	if p_anim == "Fade_Out":
		await get_tree().process_frame
		completed.emit()
		queue_free()

func _on_Choice_pressed(p_value):
	choice_selected.emit(p_value)
	_a_Anims.play("Fade_Out")
