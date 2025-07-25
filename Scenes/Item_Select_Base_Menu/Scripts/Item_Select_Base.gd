extends MarginContainer

signal item_pressed(p_instance)
signal group_changed(p_group)
signal group_mouse_entered()
signal group_mouse_exited()

@export var _e_tabs: Array[String] = ["General", "Key", "Equipment"]
@export var _e_tabs_visible = true
@export var _e_item_key_prefix : String = ""

var _a_Item_Entry_Scene = preload("res://Scenes/Item_Entry/Item_Entry_Inventory.tscn")

const _a_TAB_ENTRY_SCENE_PATH = "res://Scenes/Item_Select_Base_Menu/Tab_Entry/%s.tscn"

@onready var _a_Sort_By = get_node("Grid/List/Options/Sort_By")
@onready var _a_Search = get_node("Grid/List/Options/Search")
@onready var _a_Items = get_node("Grid/List/Items")
@onready var _a_Info = get_node("Grid/HBox/Info")

var _a_instance = null # Selected item instance
var _a_items = {} # Match key to instance
var _a_tab_instances = {} # Match key to instance

func _ready():
	_a_Sort_By.option_selected.connect(_on_Sort_By_option_selected)
	_a_Search.input_text_changed.connect(_on_Search_input_text_changed)
	_a_Items.tab_changed.connect(_on_Items_tab_changed)
	_a_Info.use_pressed.connect(_on_Info_use_pressed)
	Virtual_Keyboard.opened.connect(_on_Virtual_Keyboard_opened)
	Virtual_Keyboard.closed.connect(_on_Virtual_Keyboard_closed)
	
	for i in _e_tabs.size():
		var key = _e_tabs[i]
		var scene = load(_a_TAB_ENTRY_SCENE_PATH % key)
		var instance = scene.instantiate()
		instance.group_changed.connect(_on_Tab_Entry_group_changed)
		instance.group_mouse_entered.connect(_on_Tab_Entry_group_mouse_entered)
		instance.group_mouse_exited.connect(_on_Tab_Entry_group_mouse_exited)
		var item_type_icon_path = Global.get_item_type_icon_path()
		var texture = load(item_type_icon_path % [key, key])
		_a_Items.set_tab_icon.call_deferred(i, texture)
		_a_Items.set_tab_title.call_deferred(i, "")
		
		_a_tab_instances[key] = instance
		_a_Items.add_child(instance)
	
	_a_Items.set_tabs_visible(_e_tabs_visible)

func open():
	var global_si = Global.get_singleton(self, "Global")
	global_si.item_amount_changed.connect(_on_Global_item_amount_changed)
	
	_instantiate_items()
	
	var group = get_curr_group()
	await get_tree().process_frame
	_grab_first_focus()
	group_changed.emit(group)
	
	show()

func close():
	var global_si = Global.get_singleton(self, "Global")
	global_si.item_amount_changed.disconnect(_on_Global_item_amount_changed)
	
	_clear_items()
	hide()

func _clear_items():
	for tab_instance in _a_tab_instances.values():
		tab_instance.clear_items()

func _instantiate_items():
	pass

func instantiate_item(_p_key):
	pass

func change_item_amount(p_key, p_amount):
	var instance = _a_items[p_key]
	instance.change_amount(p_amount)

func _update_items_visibility(p_text):
	var curr_tab = _a_Items.get_current_tab_control()
	var curr_group = curr_tab.get_curr_group_instance()
	var items = curr_group.get_children()
	for item in items:
		if item.get_amount() == 0:
			item.hide()
			continue
		
		if p_text.is_empty():
			item.show()
			continue
		
		var item_name = item.get_name()
		if p_text in item_name.to_upper():
			item.show()
		else:
			item.hide()

func _selected_group_changed():
	var text = _a_Search.get_input_text()
	var text_upper = text.to_upper()
	_update_items_visibility(text_upper)
	_sort_items()
	
	_a_Info.close()
	_grab_first_focus()

func _sort_items():
	var curr_tab = _a_Items.get_current_tab_control()
	var curr_group = curr_tab.get_curr_group_instance()
	var args = _a_Sort_By.get_selected_args()
	var method_name = args[0]
	var rel = args[1]
	PropertySorter.sort(curr_group, method_name, rel)

func _grab_first_focus():
	var curr_tab = _a_Items.get_current_tab_control()
	var first = curr_tab.get_first_item_curr()
	if first == null:
		return
	
	first.grab_select_focus()
	_selected_item_changed(first)

func _selected_item_changed(p_instance):
	var key = p_instance.get_key()
	_a_Info.display(key)
	
	_a_instance = p_instance

func _get_instantiate_item(p_item_key):
	return p_item_key.begins_with(_e_item_key_prefix)

func get_curr_group():
	var curr_tab = _a_Items.get_current_tab_control()
	var curr_group = curr_tab.get_curr_group()
	
	return curr_group

func _on_Item_pressed(p_instance):
	_selected_item_changed(p_instance)
	item_pressed.emit(p_instance)

func _on_Sort_By_option_selected():
	_sort_items()

func _on_Search_input_text_changed(p_text):
	var text_upper = p_text.to_upper()
	_update_items_visibility(text_upper)

func _on_Items_tab_changed(_p_idx):
	_selected_group_changed()
	
	var group = get_curr_group()
	group_changed.emit(group)

func _on_Info_use_pressed():
	pass

func _on_Global_item_amount_changed(p_key, _p_amount, p_diff):
	if !_a_items.has(p_key):
		instantiate_item(p_key)
	
	var instance = _a_items[p_key]
	instance.change_amount(p_diff)

func _on_Virtual_Keyboard_opened():
	set_process_unhandled_input(false)

func _on_Virtual_Keyboard_closed():
	set_process_unhandled_input(true)

func _on_Tab_Entry_group_changed(p_group):
	# GODOT 4.3 ISSUE: call_deferred()
	_selected_group_changed.call_deferred()
	group_changed.emit(p_group)

func _on_Tab_Entry_group_mouse_entered():
	group_mouse_entered.emit()

func _on_Tab_Entry_group_mouse_exited():
	group_mouse_exited.emit()
