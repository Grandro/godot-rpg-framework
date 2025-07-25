extends VBoxContainer

signal entry_moved(p_old_idx, p_new_idx)
signal entry_select_pressed(p_instance)
signal entry_tree_entered(p_instance)
signal entry_tree_exited(p_idx)
signal entry_deleting(p_instance)

@export var _e_entry_scene: PackedScene = preload("res://Global_Scenes/Debug/Scenes/Entry_List/Entries/Entry.tscn")
@export var _e_delete_loc_id: String = ""
@export var _e_enumerate: bool = false
@export var _e_show_arrows: bool = true
@export var _e_show_duplicate: bool = true
@export var _e_show_delete: bool = true
@export var _e_confirm_delete: bool = true
@export var _e_show_search: bool = true
@export var _e_show_add: bool = true
@export var _e_can_change_name: bool = true
@export var _e_ensure_unique_names: bool = true

@onready var _a_Search = get_node("Search")
@onready var _a_Scroll = get_node("Scroll")
@onready var _a_VBox = get_node("Scroll/VBox")
@onready var _a_Add = get_node("Add")

var _a_entries = {} # Match name to instance

func _ready():
	_a_Search.input_text_changed.connect(_on_Search_input_text_changed)
	_a_Add.pressed.connect(_on_Add_pressed)
	
	_a_Search.set_visible(_e_show_search)
	_a_Add.set_visible(_e_show_add)

func clear_entries():
	_a_entries.clear()
	for child in _a_VBox.get_children():
		child.tree_exiting.disconnect(_on_Entry_tree_exiting)
		_a_VBox.remove_child(child)
		child.queue_free()

func instantiate_entry(p_name = ""):
	var can_change_name = _e_can_change_name && !_e_enumerate
	var instance = _e_entry_scene.instantiate()
	instance.up_pressed.connect(_on_Entry_up_pressed.bind(instance))
	instance.down_pressed.connect(_on_Entry_down_pressed.bind(instance))
	instance.select_pressed.connect(_on_Entry_select_pressed)
	instance.duplicate_pressed.connect(_on_Entry_duplicate_pressed.bind(instance))
	instance.delete_pressed.connect(_on_Entry_delete_pressed.bind(instance))
	instance.name_requested.connect(_on_Entry_name_requested.bind(instance))
	instance.ready.connect(_on_Entry_ready)
	instance.tree_entered.connect(_on_Entry_tree_entered.bind(instance))
	instance.tree_exiting.connect(_on_Entry_tree_exiting.bind(instance))
	instance.set_duplicate_visible.call_deferred(_e_show_duplicate)
	instance.set_arrows_visible.call_deferred(_e_show_arrows)
	instance.set_delete_visible.call_deferred(_e_show_delete)
	instance.set_can_change_name.call_deferred(can_change_name)
	
	if !_e_enumerate:
		if p_name.is_empty():
			p_name = "Entry"
		if _e_ensure_unique_names:
			p_name = _make_name_unique(p_name)
		instance.set_name_.call_deferred(p_name)
		instance.name_changed.connect.call_deferred(_on_Entry_name_changed)
		_a_entries[p_name] = instance
	
	return instance

func instantiate_entry_from_data(p_data):
	var name_ = p_data["Name"]
	var instance = instantiate_entry(name_)
	
	return instance

func add_entry(p_instance):
	_a_VBox.add_child(p_instance)

func _update_enumeration():
	if !_e_enumerate:
		return
	
	_a_entries.clear()
	for i in _a_VBox.get_child_count():
		var child = _a_VBox.get_child(i)
		var name_ = str(i)
		child.set_name_(name_)
		_a_entries[name_] = child

func _update_arrows_visible():
	var arrows_visible = _e_show_arrows && _a_VBox.get_child_count() > 1
	for child in _a_VBox.get_children():
		child.set_arrows_visible(arrows_visible)

func _make_name_unique(p_name):
	if !_a_entries.has(p_name):
		return p_name
	
	var i = 1
	var name_ = "%s_%d" % [p_name, i]
	while _a_entries.has(name_):
		i += 1
		name_ = "%s_%d" % [p_name, i]
	
	return name_

func _can_drop_data(_p_position, p_instance):
	return is_ancestor_of(p_instance)

func _drop_data(p_position, p_instance):
	var children = _a_VBox.get_children()
	var old_idx = p_instance.get_index()
	var new_idx = 0
	for i in children.size() - 1:
		var first = children[i]
		var second = children[i + 1]
		var first_pos = first.get_position() + first.get_size() / 2
		var second_pos = second.get_position() + second.get_size() / 2
		
		if p_position.y > first_pos.y && p_position.y < second_pos.y:
			# Between first and second
			new_idx = i + 1
			break
		elif i == 0 && p_position.y < first_pos.y:
			# Above first
			new_idx = 0
			break
		elif i == children.size() - 2 && p_position.y > second_pos.y:
			# Under last
			new_idx = children.size()
			break
	
	if old_idx < new_idx:
		new_idx -= 1
	
	_a_VBox.move_child(p_instance, new_idx)
	_update_enumeration()
	
	entry_moved.emit(old_idx, new_idx)

func set_entry_scene(p_entry_scene):
	_e_entry_scene = p_entry_scene

func get_entry(p_idx):
	return _a_VBox.get_child(p_idx)

func get_entries():
	return _a_VBox.get_children()

func get_entry_count():
	return _a_VBox.get_child_count()

func set_vertical_scroll_mode(p_scroll_mode):
	_a_Scroll.set_vertical_scroll_mode(p_scroll_mode)

func set_show_duplicate(p_show_duplicate):
	_e_show_duplicate = p_show_duplicate
	for child in _a_VBox.get_children():
		child.set_duplicate_visible(p_show_duplicate)

func set_show_arrows(p_show_arrows):
	_e_show_arrows = p_show_arrows
	_update_arrows_visible()

func set_show_delete(p_show_delete):
	_e_show_delete = p_show_delete
	for child in _a_VBox.get_children():
		child.set_delete_visible(p_show_delete)

func set_show_add(p_show_add):
	_e_show_add = p_show_add
	_a_Add.set_visible(p_show_add)

func get_save_data():
	var data = {}
	for child in _a_VBox.get_children():
		var name_ = child.get_name_()
		data[name_] = child.get_save_data()
	
	return data

func load_data(p_data):
	clear_entries()
	for entry_data in p_data.values():
		var instance = instantiate_entry_from_data(entry_data)
		instance.load_data.call_deferred(entry_data)
		add_entry(instance)

func _on_Search_input_text_changed(p_text):
	var upper_text = p_text.to_upper()
	for child in _a_VBox.get_children():
		if upper_text.is_empty():
			child.set_visible_by_search(true)
			continue
		
		var name_ = child.get_name_()
		if upper_text in name_.to_upper():
			child.set_visible_by_search(true)
		else:
			child.set_visible_by_search(false)

func _on_Add_pressed():
	pass

func _on_Entry_up_pressed(p_instance):
	var old_idx = p_instance.get_index()
	var new_idx = old_idx - 1
	if old_idx == 0:
		var child_count = _a_VBox.get_child_count()
		new_idx = child_count - 1
	
	_a_VBox.move_child(p_instance, new_idx)
	_update_enumeration()
	entry_moved.emit(old_idx, new_idx)

func _on_Entry_down_pressed(p_instance):
	var child_count = _a_VBox.get_child_count()
	var old_idx = p_instance.get_index()
	var new_idx = old_idx + 1
	if old_idx == child_count - 1:
		new_idx = 0
	
	_a_VBox.move_child(p_instance, new_idx)
	_update_enumeration()
	entry_moved.emit(old_idx, new_idx)

func _on_Entry_select_pressed(p_instance):
	entry_select_pressed.emit(p_instance)

func _on_Entry_duplicate_pressed(p_instance):
	var data = p_instance.get_save_data()
	var instance = instantiate_entry_from_data(data.duplicate(true))
	add_entry(instance)

func _on_Entry_delete_pressed(p_instance):
	if _e_confirm_delete:
		var messages = Debug.get_messages()
		messages.show_proceed(tr(_e_delete_loc_id), self, p_instance)
	else:
		entry_deleting.emit(p_instance)
		_a_VBox.remove_child(p_instance)
		p_instance.queue_free()

func _on_Entry_name_requested(p_name, p_instance):
	if _e_ensure_unique_names:
		var unique_name = _make_name_unique(p_name)
		p_instance.set_name_(unique_name)
	else:
		p_instance.set_name_(p_name)

func _on_Entry_name_changed(p_old_name, p_new_name):
	_a_entries[p_new_name] = _a_entries[p_old_name]
	_a_entries.erase(p_old_name)

func _on_Entry_ready():
	_update_enumeration()
	_update_arrows_visible()

func _on_Entry_tree_entered(p_instance):
	entry_tree_entered.emit(p_instance)

func _on_Entry_tree_exiting(p_instance):
	var idx = p_instance.get_index()
	var name_ = p_instance.get_name_()
	p_instance.tree_exited.connect(_on_Entry_tree_exited.bind(idx, name_))

func _on_Entry_tree_exited(p_idx, p_name):
	_update_enumeration()
	if !_e_enumerate:
		_a_entries.erase(p_name)
	_update_arrows_visible()
	entry_tree_exited.emit(p_idx)

func MESSAGES_PROCEED(p_response, p_instance):
	if p_response == "Yes":
		entry_deleting.emit(p_instance)
		_a_VBox.remove_child(p_instance)
		p_instance.queue_free()
