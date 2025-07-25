extends "res://Scenes/Item_Select_Base_Menu/Scripts/Item_Select_Base.gd"

func _instantiate_items():
	var inventory = Global.get_inventory()
	for type in _e_tabs:
		var tab_instance = _a_tab_instances[type]
		var groups = tab_instance.get_groups_()
		for group in groups:
			for key in inventory[type][group]:
				if _get_instantiate_item(key):
					instantiate_item(key)
	
	_sort_items.call_deferred()

func instantiate_item(p_key):
	var item_args = Databases.get_data_entry("Items", p_key)
	var item_type = item_args.get_type()
	var item_group = item_args.get_group()
	var global_si = Global.get_singleton(self, "Global")
	var inventory = global_si.get_inventory()
	var inventory_args = inventory[item_type][item_group][p_key]
	var tab_instance = _a_tab_instances[item_type]
	
	var item_name = item_args.get_name_()
	var item_texture = item_args.get_texture()
	var amount = inventory_args["Amount"]
	var instance = _a_Item_Entry_Scene.instantiate()
	instance.pressed.connect(_on_Item_pressed.bind(instance))
	instance.set_texture.call_deferred(item_texture)
	instance.set_amount.call_deferred(amount)
	instance.set_key(p_key)
	instance.set_name_(item_name)
	
	_a_items[p_key] = instance
	tab_instance.add_item(instance, item_group)

func set_info_options_disabled(p_disabled):
	_a_Info.set_options_disabled(p_disabled)
