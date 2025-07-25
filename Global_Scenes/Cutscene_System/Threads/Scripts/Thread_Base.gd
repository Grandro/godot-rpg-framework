extends Node

signal completed()

var _a_curr_scene = null
var _a_command = ""
var _a_args = {}
var _a_skip = false # Skip this command?
var _a_emitted_completed = false # Only emit completed once
var _a_loads_data = false

var _a_object = null # Object instance if used by command
var _a_comp = null # Comp of _a_object if used by command

# Revert properties when this thread is loaded from data
# (Because it was mid-execution on save)
var _a_revert_on_load = {} # Match instance key to {Property: Value}

func _ready():
	tree_exiting.connect(_on_tree_exiting)

func skip():
	pass

func _process_command():
	if _a_skip:
		skip()

func _emit_completed():
	if !_a_emitted_completed:
		completed.emit()
		_a_emitted_completed = true

func _add_revert_property(p_instance, p_object_key, p_comp_key, p_property):
	if !_a_revert_on_load.has(p_object_key):
		_a_revert_on_load[p_object_key] = {}
	if !_a_revert_on_load[p_object_key].has(p_comp_key):
		_a_revert_on_load[p_object_key][p_comp_key] = {}
	var value = p_instance.get(p_property)
	_a_revert_on_load[p_object_key][p_comp_key][p_property] = value

func set_curr_scene(p_curr_scene):
	_a_curr_scene = p_curr_scene

func set_command(p_command):
	_a_command = p_command

func get_command():
	return _a_command

func set_args(p_args):
	_a_args = p_args

func set_skip(p_skip):
	_a_skip = p_skip

func set_loads_data(p_loads_data):
	_a_loads_data = p_loads_data

func get_save_data():
	var data = {}
	data["Command"] = _a_command
	data["Revert"] = {}
	data["Revert"]["On_Load"] = _a_revert_on_load
	data["Process_Mode"] = get_process_mode()
	data["Args"] = {}
	
	return data

func load_data(p_data):
	var global_si = Global.get_singleton(self, "Global")
	var on_load_args = p_data["Revert"]["On_Load"]
	for object_key in on_load_args:
		var object = global_si.get_object(object_key)
		for comp_key in on_load_args[object_key]:
			var comp = object.comph().get_comp(comp_key)
			for property in on_load_args[object_key][comp_key]:
				var value = on_load_args[object_key][comp_key][property]
				comp.set(property, value)
	
	set_process_mode(p_data["Process_Mode"])

func _on_tree_exiting():
	if is_instance_valid(_a_object):
		_a_object.comph().call_comp("Cutscene", "decrease_in_cutscene")
