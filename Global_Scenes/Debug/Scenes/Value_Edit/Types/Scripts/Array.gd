extends VBoxContainer

signal value_changed(p_value)

var _a_Value_Edit_Scene = load("res://Global_Scenes/Debug/Scenes/Value_Edit/Value_Edit.tscn")

@onready var _a_Select = get_node("Select")
@onready var _a_Value = get_node("Value")
@onready var _a_Size = get_node("Value/Size/Margin/HBox/Value")
@onready var _a_Entries = get_node("Value/Entries")

var _a_value = []
var _a_children_type = "Null"
var _a_children_editable = false

func _ready():
	_a_Select.pressed.connect(_on_Select_pressed)
	_a_Size.value_changed.connect(_on_Size_value_changed)
	
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
	var entries_count = _a_Entries.get_child_count()
	var value_size = _a_value.size()
	var dif = value_size - entries_count
	if dif > 0:
		for i in range(entries_count, value_size):
			var instance = _instantiate_value_edit(str(i))
			_a_Entries.add_child(instance)
	else:
		for i in range(entries_count - 1, value_size - 1, -1):
			var child = _a_Entries.get_child(i)
			_delete_value_entry(child)
	
	for i in value_size:
		var child = _a_Entries.get_child(i)
		var value = _a_value[i]
		child.set_value(value)

func _clear_value_entries():
	for child in _a_Entries.get_children():
		_delete_value_entry(child)

func _delete_value_entry(p_instance):
	p_instance.tree_exiting.disconnect(_on_Value_Edit_tree_exiting)
	p_instance.delete()
	_a_Entries.remove_child(p_instance)

func _update_select_text():
	var size_ = _a_value.size()
	var text = "Array (size %s)" % size_
	_a_Select.set_text(text)
	_a_Size.set_value(size_)

func _instantiate_value_edit(p_text):
	var instance = _a_Value_Edit_Scene.instantiate()
	instance.value_changed.connect(_on_Value_Edit_value_changed.bind(instance))
	instance.tree_exiting.connect(_on_Value_Edit_tree_exiting.bind(instance))
	instance.set_type(_a_children_type)
	instance.set_removable(true)
	instance.set_editable.call_deferred(_a_children_editable)
	instance.set_text.call_deferred(p_text)
	instance.show_text.call_deferred()
	
	return instance

func set_default_value():
	set_value([])

func set_value(p_value):
	_a_value = p_value
	_update_select_text()
	
	if _a_Value.is_visible():
		_update_value_entries()

func get_value():
	return _a_value.duplicate(true)

func set_editable(p_editable):
	_a_Size.set_editable(p_editable)
	for child in _a_Entries.get_children():
		child.set_editable(p_editable)

func set_children_type(p_children_type):
	_a_children_type = p_children_type

func set_children_editable(p_children_editable):
	_a_children_editable = p_children_editable

func _on_Select_pressed():
	if _a_Value.is_visible():
		_close_value()
	else:
		_open_value()

func _on_Size_value_changed(p_value):
	_a_value.resize(p_value)
	_update_select_text()
	
	if _a_Value.is_visible():
		_update_value_entries()

func _on_Value_Edit_value_changed(p_value, p_instance):
	var idx = p_instance.get_index()
	_a_value[idx] = p_value
	
	value_changed.emit(_a_value)

func _on_Value_Edit_tree_exiting(p_instance):
	var idx = p_instance.get_index()
	p_instance.tree_exited.connect(_on_Value_Edit_tree_exited.bind(idx))

func _on_Value_Edit_tree_exited(p_idx):
	_a_value.pop_at(p_idx)
	_update_select_text()
	
	for i in _a_Entries.get_child_count():
		var child = _a_Entries.get_child(i)
		child.set_text(str(i))
	
	value_changed.emit(_a_value)
