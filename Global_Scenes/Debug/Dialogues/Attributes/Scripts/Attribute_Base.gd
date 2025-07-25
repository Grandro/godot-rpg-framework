extends TabContainer

func open(p_data):
	for child in get_children():
		var key = child.get_key()
		if p_data.is_empty():
			child.open_init()
		else:
			child.open(p_data[key])
	
	show()

func close():
	hide()

func set_tabs_keys_type(p_keys_type):
	for child in get_children():
		child.set_keys_type(p_keys_type)

func _set_tab_hidden(p_instance, p_hidden):
	var idx = p_instance.get_index()
	set_tab_hidden(idx, p_hidden)

func get_save_data():
	var data = {}
	for child in get_children():
		var key = child.get_key()
		data[key] = child.get_save_data()
	
	return data
