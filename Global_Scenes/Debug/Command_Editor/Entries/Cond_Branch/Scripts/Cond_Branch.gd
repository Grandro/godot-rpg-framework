extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Branch.gd"

@onready var _a_Else = get_node("HBox/VBox/Branches/Else")

func _ready():
	super()
	
	_a_Else.base_focus_entered.connect(_on_Unselectable_focus_entered)
	_a_Else.base_gui_input.connect(_on_Unselectable_gui_input)
	for child in _a_Branches.get_children():
		child.progress_focus_entered.connect(_on_Unselectable_focus_entered)
		child.progress_gui_input.connect(_on_Unselectable_gui_input)
	
	_a_Else.set_base_desc(tr("DEBUG_CUTSCENES_ELSE"))
	_a_Else.hide()

func update_display():
	super()
	_a_Else.set_base_desc_modulate(_e_color)

# Breakable: Items: ["Menus"]["Items"]["Item"]["Value"],
#					["Menus"]["Items"]["Amount"]["Value"]["Min"]["Value"] /
#					["Menus"]["Items"]["Amount"]["Value"]["Max"]["Value"]
#			 Script: ["Menus"]["Script"]["Instance_Key"]
func _update_warnings_add():
	var menus_data = _a_data["Menus"]
	for key in menus_data:
		match key:
			"Items": _update_warnings_add_items(menus_data[key])
			"Script": _update_warnings_add_script(menus_data[key])

func _update_warnings_add_items(p_data):
	var item_key = p_data["Item"]["Value"]
	if item_key.is_empty():
		return
	
	var items_data = Databases.get_data("Items")
	if !items_data.has(item_key):
		var value_keys = ["Menus", "Items", "Item", "Value"]
		var args = _Warning_Args_String.new(item_key, value_keys)
		_a_warnings.push_back(args)
	else:
		var stack = items_data[item_key].get_stack_()
		var max_value = p_data["Amount"]["Value"]["Max"]["Value"]
		if max_value > stack:
			var min_value = p_data["Amount"]["Value"]["Min"]["Value"]
			var value = "%s - %s" % [str(min_value), str(max_value)]
			var value_keys_min = ["Menus", "Items", "Amount", "Value", "Min", "Value"]
			var value_keys_max = ["Menus", "Items", "Amount", "Value", "Max", "Value"]
			var value_keys = [value_keys_min, value_keys_max]
			var args = _Warning_Args_Range.new(value, value_keys, 0, stack)
			_a_warnings.push_back(args)

func _update_warnings_add_script(p_data):
	_update_warnings_add_expression(p_data, ["Menus", "Script", "Instance_Key"])

func _update_display_main_base_args():
	var option_key = _a_data["Key"]
	var text = "%s: " % tr("DEBUG_CUTSCENES_%s" % option_key.to_upper())
	var menu_data = _a_data["Menus"][option_key]
	match option_key:
		"Items":
			var key_text = _get_display_text(menu_data["Item"])
			text += key_text
			
			var amount_type = menu_data["Amount"]["Type"]
			var amount_args = menu_data["Amount"][amount_type]
			match amount_type:
				"Var":
					var amount_text = _get_var_display_text(amount_args)
					text += amount_text
				
				"Value":
					var amount_min_text = _get_display_text(amount_args["Min"])
					var amount_max_text = _get_display_text(amount_args["Max"])
					text += ", %s " % tr("DEBUG_CUTSCENES_AMOUNT")
					text += "%s - %s" % [amount_min_text, amount_max_text]
		
		"Script":
			var instance_key = menu_data["Instance_Key"]
			var expression = menu_data["Expression"]
			text += instance_key
			text += ": %s" % expression
	
	_a_Main.set_base_args(text)

func _update_branches():
	var base_min_size = _a_Main.get_base_margin_min_size()
	var margin = _get_main_arg_margin()
	var else_branch = _a_data["Else_Branch"]
	_a_Else.set_base_margin_min_size(Vector2(margin, base_min_size.y))
	_a_Else.set_visible(else_branch)
	
	if !_is_branch_used(_a_process_branch_idx):
		swap_process(0)
	
	for child in _a_Branches.get_children():
		var process_margin = child.get_process_margin_instance()
		process_margin.custom_minimum_size.x = margin
		child.set_collapse_visible(true)
	_a_End.set_left_margin(margin)
