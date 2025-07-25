extends "res://Global_Scenes/Debug/Command_Edit/Command_Preview_Base/Scripts/Command_Preview_Base.gd"

var _a_Outline_2D = preload("res://Global_Resources/Materials/2D/Outline.tres")
var _a_Outline_Display_3D = preload("res://Global_Resources/Materials/3D/Outline_Display.tres")

@onready var _a_Object = get_node("Window/Contents/Margin/HBox/Right/Options/VBox/Object")

var _a_revert_data = {} # objects revert data
var _a_object = null # Selected object to erase material

func _ready():
	super()
	_a_Object.selected.connect(_on_Object_selected)

func open(p_instance, p_data, p_res_data):
	_a_revert_data = p_res_data["Objects"]
	
	_create_objects()
	_revert_objects()
	
	super(p_instance, p_data, p_res_data)

func _select_default_object(p_res_data):
	var key = p_res_data["Default_Object"]
	if !key.is_empty() && _a_Object.has_key(key):
		_a_Object.select(key)

func _create_objects():
	var preview_vp = get_preview_vp_instance()
	_a_Object.set_viewport(preview_vp)
	_a_Object.update_options()

func _revert_objects():
	for i in _a_Object.get_count():
		var instance = _a_Object.get_value(i)
		var key = instance.comph().call_comp("Reference", "get_key")
		if !_a_revert_data.has(key):
			continue
		
		var properties = _a_revert_data[key]["Properties"]
		for comp_key in properties:
			for property in properties[comp_key]:
				_revert_object_property(instance, comp_key, property)
		
		if instance.comph().has_comp("Equipment"):
			var equipables = _a_revert_data[key]["Equipables"]
			for group in equipables:
				_revert_object_equipable(instance, group)

func _set_object_revert_property_value(p_instance, p_comp_key, p_property, p_value):
	var key = p_instance.comph().call_comp("Reference", "get_key")
	var object_args = _a_revert_data.get_or_add(key, {})
	var properties_args = object_args.get_or_add("Properties", {})
	var comp_args = properties_args.get_or_add(p_comp_key, {})
	comp_args[p_property] = p_value

func _get_object_revert_comp_args(p_instance, p_comp_key):
	var key = p_instance.comph().call_comp("Reference", "get_key")
	var revert_args = _a_revert_data.get(key)
	if revert_args == null: return null
	var properties_args = _a_revert_data[key]["Properties"]
	var comp_args = properties_args.get(p_comp_key)
	if comp_args == null: return null
	
	return comp_args

func _get_object_revert_property_value(p_instance, p_comp_key, p_property):
	var comp_args = _get_object_revert_comp_args(p_instance, p_comp_key)
	if comp_args == null: return null
	if !comp_args.has(p_property): return null
	return comp_args[p_property]

func _revert_object_property(p_instance, p_comp_key, p_property):
	var comp_args = _get_object_revert_comp_args(p_instance, p_comp_key)
	if comp_args == null: return
	if !comp_args.has(p_property): return
	
	var comp = p_instance.comph().get_comp(p_comp_key)
	var property_args = p_property.split(".")
	var property_instance = _get_property_instance(comp, property_args)
	var value = comp_args[p_property]
	var curr_value = property_instance.get(property_args[-1])
	if value != curr_value:
		property_instance.set(property_args[-1], value)
	
	if p_instance.comph().has_comp("Anims"):
		p_instance.comph().call_comp("Anims", "update_anim")

func _get_property_instance(p_instance, p_args):
	var instance = p_instance
	for i in p_args.size() - 1:
		instance = instance.get(p_args[i])
	
	return instance

func _set_object_revert_equipable(p_instance, p_group):
	var key = p_instance.comph().call_comp("Reference", "get_key")
	var equipable = p_instance.comph().call_comp("Equipment", "get_equipable", [p_group])
	var object_args = _a_revert_data.get_or_add(key, {})
	var equipables_args = object_args.get_or_add("Equipables", {})
	equipables_args[p_group] = equipable

func _revert_object_equipable(p_instance, p_group):
	var key = p_instance.comph().call_comp("Reference", "get_key")
	var equipables = _a_revert_data[key]["Equipables"]
	var equipable = equipables.get(p_group)
	if equipable == null:
		return
	
	match equipable:
		"": p_instance.comph().call_comp("Equipment", "unequip", [p_group])
		_: p_instance.comph().call_comp("Equipment", "equip", [p_group, equipable])

func _selected_object_changed():
	if _a_object != null:
		_activate_outline(_a_object, false)
	
	var selected = _a_Object.get_selected_value()
	_activate_outline(selected, true)
	
	var curr_scene_dim = Scene_Manager.get_curr_scene_dim()
	var selected_dim = _get_object_dim(selected)
	if curr_scene_dim == selected_dim:
		var selected_pos = selected.get_position()
		_a_free_camera.set_position(selected_pos)
	
	if selected_dim == "2D":
		var canvas_layer = selected.get_canvas_layer_node()
		if canvas_layer == null:
			_a_Preview.set_VP_size_2d_override(Vector2.ZERO)
		else:
			var base_vp_size = Global.get_base_vp_size()
			_a_Preview.set_VP_size_2d_override(base_vp_size)

func _activate_outline(p_instance, p_activate):
	var dim = _get_object_dim(p_instance)
	match dim:
		"2D": _activate_outline_2D(p_instance, p_activate)
		"3D": _activate_outline_3D(p_instance, p_activate)

func _activate_outline_2D(p_instance, p_activate):
	if p_activate:
		if p_instance.comph().has_comp("Display"):
			p_instance.comph().call_comp("Display", "set_material", [_a_Outline_2D])
	else:
		if p_instance.comph().has_comp("Display"):
			p_instance.comph().call_comp("Display", "set_material", [null])

func _activate_outline_3D(p_instance, p_activate):
	if p_activate:
		if p_instance.comph().has_comp("Display"):
			var outline_mat = _prep_outline_display_3D(p_instance)
			p_instance.comph().call_comp("Display", "set_material_override", [outline_mat])
		elif p_instance.comph().has_comp("Model"):
			pass
		else:
			pass
	else:
		if p_instance.comph().has_comp("Display"):
			p_instance.comph().call_comp("Display", "set_material_override", [null])
		elif p_instance.comph().has_comp("Model"):
			pass
		else:
			pass

func _prep_outline_display_3D(p_instance):
	var outline_mat = _a_Outline_Display_3D.duplicate()
	var texture = p_instance.comph().call_comp("Display", "get_texture")
	outline_mat.set("shader_parameter/sprite_texture", texture)
	
	return outline_mat

func _get_object_dim(p_instance):
	if p_instance is Node2D: return "2D"
	if p_instance is Node3D: return "3D"

func _grid_point_to_pos(p_point):
	var grid_step = _a_Grid_Step.get_value()
	var grid_start = _a_Grid_Offset.get_value()
	var pos = Global.grid_point_to_pos(p_point, grid_step, grid_start)
	
	return pos

func _pos_to_grid_point(p_pos):
	var grid_step = _a_Grid_Step.get_value()
	var grid_start = _a_Grid_Offset.get_value()
	var point = Global.pos_to_grid_point(p_pos, grid_step, grid_start)
	
	return point

func _get_save_data():
	var data = super()
	data["Object"] = _a_Object.get_save_data()
	data["Object"]["Properties"] = {}
	data["Object"]["Equipables"] = {}
	_adjust_object_properties(data["Object"]["Properties"])
	_adjust_object_equipables(data["Object"]["Equipables"])
	
	return data

func _adjust_object_properties(_p_properties):
	pass

func _adjust_object_equipables(_p_equipables):
	pass

func _on_Object_selected():
	_selected_object_changed()
