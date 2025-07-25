extends "res://Scripts/Extension_Base.gd"

signal equipped(p_group, p_key)
signal unequipped(p_group)

var _a_entity_entity_comph : CompHandler = null

var _a_scenes = {}
var _a_groups = {} # Match group to instance
var _a_equipables = {} # Match group to equipable key

func ready():
	for group_instance in _a_entity.get_children():
		for child in group_instance.get_children():
			child.queue_free()
		
		var group = group_instance.get_name()
		_a_groups[group] = group_instance
	
	for group in _a_groups:
		_a_equipables[group] = ""

func init(p_entity_entity):
	_a_entity_entity_comph = p_entity_entity.comph()
	
	var anims_comp = _a_entity_entity_comph.get_comp("Anims")
	anims_comp.anim_seeked.connect(_on_Anims_anim_seeked)
	anims_comp.anim_stopped.connect(_on_Anims_anim_stopped)
	anims_comp.anim_played.connect(_on_Anims_anim_played)

func play_anim_all(p_name, p_speed, p_backwards):
	for group_instance in _a_entity.get_children():
		for child in group_instance.get_children():
			child.play_anim(p_name, p_speed, p_backwards)

func seek_anim_all(p_seconds, p_update):
	for group_instance in _a_entity.get_children():
		for child in group_instance.get_children():
			child.seek_anim(p_seconds, p_update)

func stop_anim_all(p_keep_state):
	for group_instance in _a_entity.get_children():
		for child in group_instance.get_children():
			child.stop_anim(p_keep_state)

func equip_both(p_group, p_key):
	# Can be used for Party_Member and non-Party_Member
	# equip is called by Global if this is Party_Member
	var pm_key = _get_pm_key()
	if pm_key.is_empty():
		equip(p_group, p_key)
	else:
		var global_si = Global.get_singleton(_a_entity, "Global")
		global_si.equip_party_member(pm_key, p_group, p_key)

func equip(p_group, p_key):
	if !_a_groups.has(p_group):
		return
	
	var group_instance = _a_groups[p_group]
	for child in group_instance.get_children():
		child.queue_free()
	
	var scene = _a_scenes[p_group][p_key]
	var instance = scene.instantiate()
	instance.set_name(p_key)
	
	_a_equipables[p_group] = p_key
	group_instance.add_child(instance)
	
	_a_entity_entity_comph.call_comp("Anims", "update_anim")
	equipped.emit(p_group, p_key)

func unequip_both(p_group):
	# Can be used for Party_Member and non-Party_Member
	# unequip is called by Global if this is Party_Member
	
	var pm_key = _get_pm_key()
	if pm_key.is_empty():
		unequip(p_group)
	else:
		var global_si = Global.get_singleton(_a_entity, "Global")
		global_si.unequip_party_member(pm_key, p_group)

func unequip(p_group):
	var group_instance = _a_groups[p_group]
	for child in group_instance.get_children():
		child.queue_free()
	
	_a_equipables[p_group] = ""
	
	_a_entity_entity_comph.call_comp("Anims", "update_anim")
	unequipped.emit(p_group)

func _update_equipables():
	for group in _a_groups:
		_update_equipable(group)

func _update_equipable(p_group):
	var key = _a_equipables[p_group]
	if !key.is_empty():
		equip(p_group, key)

func set_scenes(p_scenes):
	_a_scenes = p_scenes

func get_scenes():
	return _a_scenes

func get_equipable(p_group):
	return _a_equipables[p_group]

func get_equipables():
	return _a_equipables

func get_equipable_instance(p_group, p_key):
	var group_instance = _a_groups[p_group]
	var instance = group_instance.get_node(p_key)
	
	return instance

func _get_pm_key():
	var pm_key = ""
	if _a_entity_entity_comph.has_comp("Party_Member"):
		pm_key = _a_entity_entity_comph.call_comp("Party_Member", "get_pm_key")
	
	return pm_key

func get_save_data():
	return _a_equipables

func load_data(p_data):
	var pm_key = _get_pm_key()
	if pm_key.is_empty():
		_a_equipables = p_data
	else:
		var global_si = Global.get_singleton(_a_entity, "Global")
		for group in _a_groups:
			var equipable = global_si.get_party_member_equipable(pm_key, group)
			_a_equipables[group] = equipable
	
	_update_equipables()

func load_data_init():
	var pm_key = _get_pm_key()
	if !pm_key.is_empty():
		var global_si = Global.get_singleton(_a_entity, "Global")
		for group in _a_groups:
			var equipable = global_si.get_party_member_equipable(pm_key, group)
			_a_equipables[group] = equipable
	
	_update_equipables()

func _on_Anims_anim_seeked(p_seconds, p_update):
	seek_anim_all(p_seconds, p_update)

func _on_Anims_anim_stopped(p_keep_state):
	stop_anim_all(p_keep_state)

func _on_Anims_anim_played(p_name):
	var anim_comp = _a_entity_entity_comph.get_comp("Anims")
	var speed = anim_comp.get_playing_speed()
	var pos = anim_comp.get_current_animation_position()
	var backwards = speed < 0.0
	play_anim_all(p_name, speed, backwards)
	if backwards:
		var length = anim_comp.get_current_animation_length()
		if pos < length:
			seek_anim_all(pos, false)
	else:
		if pos > 0.0:
			seek_anim_all(pos, false)
