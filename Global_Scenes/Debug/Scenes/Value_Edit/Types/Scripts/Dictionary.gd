extends VBoxContainer

signal value_changed(p_value)

var _a_Value_Edit_Scene = load("res://Global_Scenes/Debug/Scenes/Value_Edit/Value_Edit.tscn")

@onready var _a_Select = get_node("Select")
@onready var _a_Value = get_node("Value")
@onready var _a_Entries = get_node("Value/Entries")
@onready var _a_New_Key = get_node("Value/New_Key/Margin/HBox/Value")
@onready var _a_New_Value_HBox = get_node("Value/New_Value/Margin/HBox")
@onready var _a_Add = get_node("Value/Add")

var _a_value = {}
var _a_children_type = "Null"
var _a_children_editable = false

var _a_value_edit = null

func _ready():
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_Add.pressed.connect(_on_Add_pressed)
	
	_a_value_edit = _a_Value_Edit_Scene.instantiate()
	_a_value_edit.set_type(_a_children_type)
	_a_value_edit.set_editable.call_deferred(_a_children_editable)
	_a_New_Value_HBox.add_child(_a_value_edit)
	
	_close_value()
	set_default_value()

func expand(p_depth):
	_open_value()
	
	if p_depth != -1:
		p_depth -= 1
	if p_depth == 0:
		return
	
	for child in _a_Entries.get_children():
		child.expand(p_depth)

func delete():
	_clear_value_entries()
	queue_free()

func _open_value():
	_update_value_entries()
	_a_Value.show()

func _close_value():
	_clear_value_entries()
	_a_Value.hide()

func _update_value_entries():
	_clear_value_entries()
	
	for key in _a_value:
		var value = _a_value[key]
		var instance = _instantiate_value_edit(key)
		instance.set_value.call_deferred(value)
		
		_a_Entries.add_child(instance)

func _clear_value_entries():
	for child in _a_Entries.get_children():
		child.tree_exited.disconnect(_on_Value_Edit_tree_exited)
		
		_a_Entries.remove_child(child)
		child.queue_free()

func _update_select_text():
	var size_ = _a_value.size()
	var text = "Dictionary (size %s)" % size_
	_a_Select.set_text(text)

func _instantiate_value_edit(p_key):
	var instance = _a_Value_Edit_Scene.instantiate()
	instance.value_changed.connect(_on_Value_Edit_value_changed.bind(p_key))
	instance.tree_exited.connect(_on_Value_Edit_tree_exited.bind(p_key))
	instance.set_type(_a_value_edit.get_type())
	instance.set_removable(true)
	instance.set_editable.call_deferred(_a_children_editable)
	instance.set_text.call_deferred(p_key)
	instance.show_text.call_deferred()
	
	return instance

func set_default_value():
	set_value({})

func set_value(p_value):
	_a_value = p_value
	_update_select_text()
	
	if _a_Value.is_visible():
		_update_value_entries()

func get_value():
	return _a_value.duplicate(true)

func set_editable(p_editable):
	for child in _a_Entries.get_children():
		child.set_editable(p_editable)
	_a_New_Key.set_editable(p_editable)
	_a_value_edit.set_editable(p_editable)
	_a_Add.set_disabled(!p_editable)

func set_children_type(p_children_type):
	_a_children_type = p_children_type

func set_children_editable(p_children_editable):
	_a_children_editable = p_children_editable

func _on_Select_pressed():
	if _a_Value.is_visible():
		_close_value()
	else:
		_open_value()

func _on_Add_pressed():
	var key = _a_New_Key.get_text()
	_a_New_Key.set_text("")
	
	if key.is_empty() || _a_value.has(key):
		return
	
	var value = _a_value_edit.get_value()
	_a_value[key] = value
	_a_value_edit.set_instance_default_value()
	_update_select_text()
	
	if _a_Value.is_visible():
		_update_value_entries()

func _on_Value_Edit_value_changed(p_value, p_key):
	_a_value[p_key] = p_value
	value_changed.emit(_a_value)

func _on_Value_Edit_tree_exited(p_key):
	_a_value.erase(p_key)
	_update_select_text()
	
	value_changed.emit(_a_value)
