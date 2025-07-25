extends "res://Scenes/Item_Select_Base_Menu/Scripts/Item_Select_Base.gd"

signal select_pressed(p_key, p_stack, p_texture)

func _ready():
	super()
	_a_Info.select_pressed.connect(_on_Info_select_pressed)

func open(p_key = ""):
	await super()
	if !p_key.is_empty():
		_grab_item_focus(p_key)

func _instantiate_items():
	var items_data = Databases.get_data("Items")
	for key in items_data:
		if _get_instantiate_item(key):
			instantiate_item(key)
	
	_sort_items.call_deferred()

func instantiate_item(p_key):
	var item_args = Databases.get_data_entry("Items", p_key)
	var item_type = item_args.get_type()
	var item_group = item_args.get_group()
	var tab_instance = _a_tab_instances[item_type]
	
	var item_name = item_args.get_name_()
	var item_texture = item_args.get_texture()
	var stack = item_args.get_stack_()
	var instance = _a_Item_Entry_Scene.instantiate()
	instance.pressed.connect(_on_Item_pressed.bind(instance))
	instance.set_key(p_key)
	instance.set_name_(item_name)
	instance.set_type(item_type)
	#instance.set_group(item_group)
	instance.set_texture.call_deferred(item_texture)
	instance.set_amount.call_deferred(stack)
	
	_a_items[p_key] = instance
	tab_instance.add_item(instance, item_group)

func _grab_item_focus(p_key):
	var item_instance = _a_items[p_key]
	var type = item_instance.get_type()
	var tab_instance = _a_tab_instances[type]
	var idx = tab_instance.get_index()
	_a_Items.set_current_tab(idx)
	
	item_instance.grab_select_focus()
	_selected_item_changed(item_instance)

func get_first_data():
	var data = {}
	var items_data = Databases.get_data("Items")
	var item_keys = items_data.keys()
	if item_keys.size() > 0:
		var key = item_keys[0]
		data["Key"] = key
		data["Stack"] = items_data[key].get_stack()
	
	return data

func _on_Info_select_pressed():
	var key = _a_instance.get_key()
	var stack = _a_instance.get_amount()
	var texture = _a_instance.get_texture()
	select_pressed.emit(key, stack, texture)
