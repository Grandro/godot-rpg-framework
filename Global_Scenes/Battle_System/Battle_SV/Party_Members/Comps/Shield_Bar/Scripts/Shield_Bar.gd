extends Node3D

const _a_SHIELD_BAR_SCENE_PATH = "res://Global_Scenes/Battle_System/Battle_SV/Party_Members/Comps/Shield_Bar/Shield_Bars/%s/%s.tscn"

var _a_entity : Character3DObject = null
var _a_entity_comph : CompHandler = null

var _a_instance = null # Shield_Bar instance of equipped Shield
var _a_max_shield = 0
var _a_shield = 0

func _ready():
	hide()

func init(p_entity):
	_a_entity = p_entity
	_a_entity_comph = p_entity.comph()
	
	_a_entity_comph.comps_registered.connect(_on_Comp_Handler_comps_registered)

func open(p_shield_gain):
	_a_shield += p_shield_gain
	_a_instance.play_anim("Fade_In")
	
	show()

func _equip_shield(p_key):
	_a_instance = _instantiate_shield_bar(p_key)
	add_child(_a_instance)
	_a_max_shield = _a_instance.get_progress_max()

func _unequip_shield():
	_a_instance.queue_free()

func _instantiate_shield_bar(p_key):
	var scene = load(_a_SHIELD_BAR_SCENE_PATH % [p_key, p_key])
	var instance = scene.instantiate()
	instance.anim_finished.connect(_on_Shield_Bar_anim_finished)
	instance.progress_updated.connect(_on_Shield_Bar_progress_updated)
	
	return instance

func _update_progress():
	_a_instance.update_progress(_a_shield)

func get_save_data():
	return {}

func load_data(_p_data):
	pass

func load_data_init():
	pass

func _on_Comp_Handler_comps_registered():
	var equipment_comp = _a_entity_comph.get_comp("Equipment")
	equipment_comp.equipped.connect(_on_Equipment_equipped)
	equipment_comp.unequipped.connect(_on_Equipment_unequipped)
	
	var shield_key = equipment_comp.get_equipable("Shield")
	if shield_key.is_empty():
		_equip_shield("None")
	else:
		_equip_shield(shield_key)

func _on_Shield_Bar_anim_finished(p_name):
	match p_name:
		"Fade_In": _update_progress()
		"Fade_Out": hide()

func _on_Shield_Bar_progress_updated():
	if _a_shield >= _a_max_shield:
		_a_shield = 0
		_a_instance.set_progress_value(0)
		_a_instance.process_effect(_a_entity)
	
	_a_instance.play_anim("Fade_Out")

func _on_Equipment_equipped(p_group, p_key):
	if p_group != "Shield":
		return
	
	_equip_shield(p_key)

func _on_Equipment_unequipped(p_group):
	if p_group != "Shield":
		return
	
	_unequip_shield()
