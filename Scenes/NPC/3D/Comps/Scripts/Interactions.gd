extends "res://Scenes/Object/Comps/3D/Interactions/Scripts/Interactions.gd"

@export var _e_look_at_player: bool = true

var _a_entity_comph : CompHandler = null

func init(p_entity):
	super(p_entity)
	_a_entity_comph = p_entity.comph()

func interaction_activate(_p_area, p_dir):
	super(_p_area, p_dir)
	
	if _e_look_at_player:
		var opposite_dir = Global.get_opposite_dir(p_dir)
		_a_entity_comph.call_comp("Movement", "set_dir", [opposite_dir])
		_a_entity_comph.call_comp("Anims", "update_anim")

func set_look_at_player(p_look_at_player):
	_e_look_at_player = p_look_at_player

func get_save_data():
	var data = super()
	data["Look_At_Player"] = _e_look_at_player
	
	return data

func load_data(p_data):
	super(p_data)
	_e_look_at_player = p_data["Look_At_Player"]
