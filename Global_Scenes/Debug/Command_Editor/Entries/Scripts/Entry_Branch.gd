extends "res://Global_Scenes/Debug/Command_Editor/Entries/Scripts/Entry_Command.gd"

signal unselectable_focus_entered()
signal unselectable_right_clicked(p_pos)
signal request_empty_entry(p_idx, p_margin, p_entries)
signal request_command_entry(p_command, p_entry_data, p_idx, p_margin, p_entries)

@export var _e_start_branch_idx : int = 0

@onready var _a_End = get_node("HBox/VBox/End")

var _a_process_branch_idx = -1

func _ready():
	super()
	_a_End.focus_entered.connect(_on_Unselectable_focus_entered)
	_a_End.gui_input.connect(_on_Unselectable_gui_input)
	
	_a_End.set_desc(tr("DEBUG_CUTSCENES_END"))

func connect_to_editor(p_editor):
	super(p_editor)
	unselectable_focus_entered.connect(p_editor._on_Entry_unselectable_focus_entered)
	unselectable_right_clicked.connect(p_editor._on_Entry_unselectable_right_clicked)
	request_empty_entry.connect(p_editor._on_Entry_request_empty_entry.bind(self))
	request_command_entry.connect(p_editor._on_Entry_request_command_entry.bind(self))

func add_res_data(p_res_data, p_args = []):
	var branch_idx = _a_process_branch_idx
	var end_idx = -1
	if !p_args.is_empty():
		branch_idx = p_args[0]
		end_idx = p_args[1]
	
	var entries = get_entries(branch_idx)
	for i in entries.size():
		if i == end_idx:
			break
		
		var entry = entries[i]
		entry.add_res_data(p_res_data)

func update_data(p_data):
	var is_empty_ = _a_data.is_empty()
	super(p_data)
	
	if is_empty_:
		_init_branches()
	_update_branches()

func swap_process(p_branch_idx):
	if _a_process_branch_idx != -1:
		set_process_visible(_a_process_branch_idx, false)
	
	set_process_visible(p_branch_idx, true)
	_a_process_branch_idx = p_branch_idx

func swap_process_next():
	var child_amount = _a_Branches.get_child_count()
	var next_branch_idx = (_a_process_branch_idx + 1) % child_amount
	swap_process(next_branch_idx)

func update_display():
	super()
	_a_End.set_desc_modulate(_e_color)

func _init_branches():
	var margin = _get_main_arg_margin()
	var branches = _a_args["Branches"]
	if branches.is_empty():
		_init_branches_new(margin)
	else:
		_init_branches_data(branches, margin)
	
	var process_branch_idx = _a_args["Process_Branch_Idx"]
	swap_process(process_branch_idx)

func _init_branches_new(p_margin):
	var child_count = _a_Branches.get_child_count()
	for i in range(_e_start_branch_idx, child_count):
		var child = _a_Branches.get_child(i)
		var entries = child.get_entries_instance()
		request_empty_entry.emit(i, p_margin, entries)

func _init_branches_data(p_data, p_margin):
	var child_count = _a_Branches.get_child_count()
	for i in range(_e_start_branch_idx, child_count):
		var branch = _a_Branches.get_child(i)
		var entries = branch.get_entries_instance()
		
		if p_data.has(i):
			var entries_data = p_data[i]["Entries"]
			for entry_data in entries_data:
				var command = entry_data["Command"]
				request_command_entry.emit(command, entry_data, i, p_margin, entries)
		
		if i > 0:
			# Main Branch doesnt need margin/show
			var base_min_size = branch.get_base_margin_min_size()
			var desc_pos = _a_Main.get_base_desc_position() / 2
			branch.set_base_margin_min_size(Vector2(desc_pos.x, base_min_size.y))
			branch.show()
		
		request_empty_entry.emit(i, p_margin, entries)
	
	for branch_idx in _a_args["Branches"]:
		var collapsed = _a_args["Branches"][branch_idx]["Collapsed"]
		_set_collapsed(branch_idx, collapsed)

func _update_branches():
	pass

func set_args(p_args):
	super(p_args)
	if !_a_args.has("Branches"):
		_a_args["Branches"] = {}
	if !_a_args.has("Process_Branch_Idx"):
		_a_args["Process_Branch_Idx"] = 0

func _set_collapsed(p_branch_idx, p_collapsed):
	var branch = _a_Branches.get_child(p_branch_idx)
	branch.set_collapsed(p_collapsed)

func get_cutscene_data():
	var branch = _a_Branches.get_child(_a_process_branch_idx)
	var data = branch.get_cutscene_data()
	
	return data

func get_editor_data():
	_a_args["Branches"].clear()
	var idxs = get_used_branches_idxs()
	for i in idxs:
		var child = _a_Branches.get_child(i)
		_a_args["Branches"][i] = child.get_data()
	_a_args["Process_Branch_Idx"] = _a_process_branch_idx
	
	return super()

func _on_Unselectable_focus_entered():
	unselectable_focus_entered.emit()

func _on_Unselectable_gui_input(p_event):
	if p_event.is_action_pressed("Mouse_Right"):
		var pos = p_event.get_global_position()
		unselectable_right_clicked.emit(pos)
