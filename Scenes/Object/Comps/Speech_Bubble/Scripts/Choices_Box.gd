extends MarginContainer

signal choice_selected(p_value)

var _a_Choice_Entry_Scene = preload("res://Global_Scenes/Dialogue_System/Choice_Entry.tscn")

@onready var _a_Choices = get_node("Margin/Choices")

func _ready():
	hide()

func open(p_args):
	var pos_type = p_args["Pos"]["Type"]
	match pos_type:
		"Left": set_h_size_flags(0)
		"Center": set_h_size_flags(4)
		"Right": set_h_size_flags(8)
	
	var global_si = Global.get_singleton(self, "Global")
	var grab_focus_ = true
	for args in p_args["Entries"].values():
		var loc_id = args["Loc_ID"]["Loc_ID"]
		var value = args["Value"]
		var conditions = args["Conditions"]
		var disabled = false
		for condition_args in conditions.values():
			if !global_si.execute_expr_from_data(condition_args["Expression"]):
				disabled = true
				break
		
		var instance = _a_Choice_Entry_Scene.instantiate()
		instance.pressed.connect(_on_Choice_Entry_pressed.bind(value))
		instance.set_text(tr(loc_id))
		instance.set_disabled(disabled)
		if grab_focus_ && !disabled:
			instance.grab_focus.call_deferred()
			grab_focus_ = false
		
		_a_Choices.add_child(instance)
	
	_set_choices_font_color.call_deferred(Color.WHITE)
	
	show()

func _set_choices_font_color(p_color):
	for child in _a_Choices.get_children():
		child.set("custom_colors/font_color_focus", p_color)
		child.set("custom_colors/font_color_hover", p_color)
		child.set("custom_colors/font_color_pressed", p_color)

func _on_Choice_Entry_pressed(p_value):
	for child in _a_Choices.get_children():
		child.queue_free()
	
	choice_selected.emit(p_value)
	
	hide()
