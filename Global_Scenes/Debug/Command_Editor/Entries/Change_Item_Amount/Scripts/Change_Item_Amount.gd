extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Command.gd"

# Breakable: ["Item"]["Value"], ["Amount"]["Value"]
func _update_warnings_add():
	var items_data = Databases.get_data("Items")
	var item_key = _a_data["Item"]["Value"]
	if !items_data.has(item_key):
		var value_keys = ["Item", "Value"]
		var args = _Warning_Args_String.new(item_key, value_keys)
		_a_warnings.push_back(args)
	else:
		var amount = _a_data["Amount"]["Value"]
		var item_args = items_data[item_key]
		var item_stack = item_args.get_stack_()
		if amount > item_stack:
			var value_keys = ["Amount", "Value"]
			var args = _Warning_Args_Int.new(amount, value_keys, 0, item_stack)
			_a_warnings.push_back(args)

func _update_display_main_base_args():
	var type = _a_data["Type"]["Value"]
	var item_text = _get_display_text(_a_data["Item"])
	var amount_text = _get_display_text(_a_data["Amount"])
	
	var text = item_text
	match type:
		"Gain": text += " +"
		"Lose": text += " -"
	text += str(amount_text)
	_a_Main.set_base_args(text)
