extends "res://Scripts/Extension_Base.gd"

func init(p_entity_entity):
	var entity_entity_comph = p_entity_entity.comph()
	var camera_comp = entity_entity_comph.get_comp("Camera")
	camera_comp.made_current.connect(_on_Camera_made_current)

func get_save_data():
	var data = {}
	data["Curr"] = _a_entity.is_current()
	
	return data

func load_data(p_data):
	if p_data["Curr"]:
		_a_entity.make_current()

func _on_Camera_made_current():
	_a_entity.make_current()
