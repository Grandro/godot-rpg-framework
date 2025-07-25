extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Branch.gd"

@onready var _a_Battle_Won = get_node("HBox/VBox/Branches/Battle_Won")
@onready var _a_Battle_Lost = get_node("HBox/VBox/Branches/Battle_Lost")

func _ready():
	super()
	
	for i in _a_Branches.get_child_count():
		var child = _a_Branches.get_child(i)
		child.progress_focus_entered.connect(_on_Unselectable_focus_entered)
		child.progress_gui_input.connect(_on_Unselectable_gui_input)
		if i > 0:
			child.base_focus_entered.connect(_on_Unselectable_focus_entered)
			child.base_gui_input.connect(_on_Unselectable_gui_input)
	
	_a_Battle_Won.set_base_desc(tr("DEBUG_CUTSCENES_BATTLE_WON"))
	_a_Battle_Lost.set_base_desc(tr("DEBUG_CUTSCENES_BATTLE_LOST"))
	_a_Battle_Won.hide()
	_a_Battle_Lost.hide()

func swap_process_next():
	var child_amount = _a_Branches.get_child_count()
	var next_branch_idx = max(1, (_a_process_branch_idx + 1) % child_amount)
	swap_process(next_branch_idx)

func update_display():
	super()
	_a_Battle_Won.set_base_desc_modulate(_e_color)
	_a_Battle_Lost.set_base_desc_modulate(_e_color)

# Breakable: ["Teleportation"]["Value"], ["Destination"]["Value"]
func _update_warnings_add():
	var type = _a_data["Type"]["Value"]
	var teleportation = _a_data["Teleportation"]["Value"]
	match type:
		"Map":
			var maps_data = Databases.get_data("Maps")
			if !maps_data.has(teleportation):
				var value_keys = ["Teleportation", "Value"]
				var args = _Warning_Args_String.new(teleportation, value_keys)
				_a_warnings.push_back(args)
			else:
				var destination = _a_data["Destination"]["Value"]
				var destinations = maps_data[teleportation].get_destinations()
				if !destinations.has(destination):
					var value_keys = ["Destination", "Value"]
					var args = _Warning_Args_String.new(destination, value_keys)
					_a_warnings.push_back(args)
		
		"Battle":
			var enc_data = Databases.get_data("SV_Encounters")
			if !enc_data.has(teleportation):
				var value_keys = ["Teleportation", "Value"]
				var args = _Warning_Args_String.new(teleportation, value_keys)
				_a_warnings.push_back(args)

func _update_display_main_base_args():
	var type = _a_data["Type"]["Value"]
	var type_text = _get_display_text(_a_data["Type"])
	var teleportation_text = _get_display_text(_a_data["Teleportation"])
	
	var text = type_text
	text += ", %s" % teleportation_text
	if type == "Map":
		var destination_text = _get_display_text(_a_data["Destination"])
		text += ", %s" % destination_text
	_a_Main.set_base_args(text)

func _update_branches():
	var type = _a_data["Type"]["Value"]
	match type:
		"Map":
			_a_Battle_Won.hide()
			_a_Battle_Lost.hide()
			_a_End.hide()
			set_process_visible(_a_process_branch_idx, false)
		
		"Battle":
			var handle_lost_battle = _a_data["Handle_Lost_Battle"]["Value"]
			var base_min_size = _a_Main.get_base_margin_min_size()
			var margin = _get_main_arg_margin()
			var margin_min_size = Vector2(margin, base_min_size.y)
			_a_Battle_Won.set_base_margin_min_size(margin_min_size)
			_a_Battle_Lost.set_base_margin_min_size(margin_min_size)
			_a_Battle_Won.show()
			_a_Battle_Lost.set_visible(handle_lost_battle)
			
			if !_is_branch_used(_a_process_branch_idx):
				swap_process(1)
			
			for i in range(1, _a_Branches.get_child_count()):
				var child = _a_Branches.get_child(i)
				var process_margin = child.get_process_margin_instance()
				process_margin.custom_minimum_size.x = margin
				child.set_collapse_visible(true)
			set_process_visible(_a_process_branch_idx, true)
			_a_End.set_left_margin(margin)
			_a_End.show()

func set_args(p_args):
	super(p_args)
	if !_a_args.has("Process_Branch_Idx"):
		_a_args["Process_Branch_Idx"] = 1
