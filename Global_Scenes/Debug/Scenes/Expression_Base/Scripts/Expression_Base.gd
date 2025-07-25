extends HBoxContainer

@export var _e_create_curr_scene: bool = false
@export var _e_create_objects: bool = false
@export var _e_create_singletons: bool = false

@onready var _a_Instance_Desc = get_node("VBox/VBox/HBox/Instance/Desc")
@onready var _a_Instance = get_node("VBox/VBox/HBox/Instance/Options")
@onready var _a_Execute = get_node("VBox/VBox/HBox/Execute")
@onready var _a_Comp_HBox = get_node("VBox/VBox/Comp")
@onready var _a_Comp_Desc = get_node("VBox/VBox/Comp/Desc")
@onready var _a_Comp = get_node("VBox/VBox/Comp/Options")
@onready var _a_Expression_Desc = get_node("VBox/VBox/Expression/Desc")
@onready var _a_Expression_Value = get_node("VBox/VBox/Expression/VBox/Value")
@onready var _a_Expression_Error = get_node("VBox/VBox/Expression/VBox/Error")
@onready var _a_Attributes = get_node("VBox/VBox/Attributes")

var _a_self_key = ""
var _a_self = null
var _a_instance_idxs = {} # Match instance key to idx
var _a_comp_idxs = {} # Match comp key to idx
var _a_keys_idx = -1 # only key instances can be removed or added 
					# -> save last idx before singletons
var _a_instance = null
var _a_attr_select = null

func _ready():
	_a_Instance.item_selected.connect(_on_Instance_item_selected)
	_a_Comp.item_selected.connect(_on_Comp_item_selected)
	_a_Execute.pressed.connect(_on_Execute_pressed)
	_a_Attributes.pressed.connect(_on_Attributes_pressed)
	
	_a_attr_select = Debug.get_attr_select()

func update_trans():
	_a_Instance_Desc.set_text(tr("DEBUG_EXPRESSION_INSTANCE"))
	_a_Execute.set_text(tr("DEBUG_EXPRESSION_EXECUTE"))
	_a_Comp_Desc.set_text(tr("DEBUG_EXPRESSION_COMP"))
	_a_Expression_Desc.set_text(tr("DEBUG_EXPRESSION"))
	_a_Attributes.set_text(tr("DEBUG_EXPRESSION_ATTRIBUTES"))

func update_self(p_self_key):
	var global_si = Global.get_singleton(self, "Global")
	_a_self_key = p_self_key
	_a_self = global_si.get_object(p_self_key)

func update_instances():
	_a_Instance.clear()
	_a_instance_idxs.clear()
	
	var idx = 0
	if is_instance_valid(_a_self):
		var metadata = _Instance_Metadata.new(_a_self_key, _a_self, "Object")
		_a_Instance.add_item("Self")
		_a_Instance.set_item_metadata(idx, metadata)
		_a_instance_idxs["$Self"] = idx
		idx += 1
	
	if _e_create_curr_scene:
		var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
		var curr_scene = scene_manager_si.get_curr_scene_instance()
		var metadata = _Instance_Metadata.new("$Curr_Scene", curr_scene, "Curr_Scene")
		_a_Instance.add_item("Curr_Scene")
		_a_Instance.set_item_metadata(idx, metadata)
		_a_instance_idxs["$Curr_Scene"] = idx
		idx += 1
	
	if _e_create_objects:
		var global_si = Global.get_singleton(self, "Global")
		var instances = global_si.get_all_objects(["Reference"])
		for instance in instances:
			if instance == _a_self:
				continue
			var key = instance.comph().call_comp("Reference", "get_key")
			if key.is_empty() || _a_instance_idxs.has(key):
				continue
			
			var metadata = _Instance_Metadata.new(key, instance, "Object")
			_a_Instance.add_item(key)
			_a_Instance.set_item_metadata(idx, metadata)
			_a_instance_idxs[key] = idx
			idx += 1
	
	_a_keys_idx = idx
	
	if _e_create_singletons:
		var root = get_tree().get_root()
		for i in root.get_child_count() - 1:
			var child = root.get_child(i)
			var key = child.get_name() # Singletons have no key
			var metadata = _Instance_Metadata.new(key, child, "Singleton")
			_a_Instance.add_item(key)
			_a_Instance.set_item_metadata(idx, metadata)
			_a_instance_idxs[key] = idx
			idx += 1

func _update_expression_error(p_expression):
	var metadata = _a_Instance.get_selected_metadata()
	var instance = metadata.get_instance()
	if !is_instance_valid(instance):
		_a_Expression_Error.set("theme_override_colors/font_color", Color.WHITE)
		_a_Expression_Error.set_text(tr("DEBUG_EXPRESSION_NO_INSTANCE"))
		return
	
	var expr = Expression.new()
	var error = expr.parse(p_expression)
	var error_text = ""
	if error == OK:
		var type = metadata.get_type()
		if type == "Object":
			var comp = _a_Comp.get_selected_metadata()
			instance = instance.comph().get_comp(comp)
		
		var res = expr.execute([], instance, false)
		if expr.has_execute_failed():
			_a_Expression_Error.set("theme_override_colors/font_color", Color.RED)
			error_text = tr("DEBUG_EXPRESSION_EXECUTE_FAILED")
		else:
			_a_Expression_Error.set("theme_override_colors/font_color", Color.GREEN)
			error_text = "%s!: %s" % [tr("DEBUG_EXPRESSION_SUCCESS"), res]
	else:
		_a_Expression_Error.set("theme_override_colors/font_color", Color.RED)
		error_text = expr.get_error_text()
	
	_a_Expression_Error.set_text(error_text)

func _add_item_at_idx(p_text, p_metadata, p_idx):
	var args = []
	var item_count = _a_Instance.get_item_count()
	for i in range(p_idx, item_count):
		var idx = item_count - 1 - (i - p_idx)
		var text = _a_Instance.get_item_text(idx)
		var metadata = _a_Instance.get_item_metadata(idx)
		args.push_front([text, metadata])
		_a_Instance.remove_item(idx)
	
	_a_Instance.add_item(p_text)
	_a_Instance.set_item_metadata(p_idx, p_metadata)
	
	for i in args.size():
		var idx = p_idx + 1 + i
		_a_Instance.add_item(args[i][0])
		_a_Instance.set_item_metadata(idx, args[i][1])

func _shift_instance_key_idxs(p_start, p_amount):
	var item_count = _a_Instance.get_item_count()
	for i in range(p_start, item_count):
		var args = _a_Instance.get_item_metadata(i)
		var key = args[0]
		_a_instance_idxs[key] += p_amount

func _selected_instance_changed():
	var metadata = _a_Instance.get_selected_metadata()
	var instance = metadata.get_instance()
	var type = metadata.get_type()
	
	var is_object = type == "Object"
	_a_Comp_HBox.set_visible(is_object)
	if is_object:
		_update_comps(instance)
		var comp = _a_Comp.get_selected_metadata()
		instance = instance.comph().get_comp(comp)
	
	_a_instance = instance

func _selected_comp_changed():
	var metadata = _a_Instance.get_selected_metadata()
	var comp = _a_Comp.get_selected_metadata()
	var instance = metadata.get_instance()
	_a_instance = instance.comph().get_comp(comp)

func _update_comps(p_instance):
	_a_Comp.clear()
	_a_comp_idxs.clear()
	
	var comps = p_instance.comph().get_comps()
	var comp_keys = comps.keys()
	for i in comp_keys.size():
		var comp = comp_keys[i]
		_a_comp_idxs[comp] = i
		_a_Comp.add_item(comp)
		_a_Comp.set_item_metadata(i, comp)

func get_self_key():
	return _a_self_key

func get_save_data():
	var data = {}
	var metadata = _a_Instance.get_selected_metadata()
	var type = metadata.get_type()
	data["Instance_Key"] = metadata.get_key()
	data["Comp"] = ""
	if type == "Object":
		data["Comp"] = _a_Comp.get_selected_metadata()
	data["Expression"] = _a_Expression_Value.get_text()
	data["Type"] = type
	
	return data

func load_data(p_data):
	var instance_key = p_data["Instance_Key"]
	var type = p_data["Type"]
	var expression = p_data["Expression"]
	var idx = 0
	if !instance_key.is_empty():
		if _a_self_key != instance_key:
			idx = _a_instance_idxs[instance_key]
	
	_a_Instance.select(idx)
	_selected_instance_changed()
	if type == "Object":
		var comp = p_data["Comp"]
		idx = _a_comp_idxs[comp]
		_a_Comp.select(idx)
		_selected_comp_changed()
	_a_Expression_Value.set_text(expression)

func load_data_init():
	_a_Instance.select(0)
	_selected_instance_changed()
	_a_Expression_Value.set_text("")

func _on_Instance_item_selected(_p_idx):
	_selected_instance_changed()

func _on_Comp_item_selected(_p_idx):
	_selected_comp_changed()

func _on_Execute_pressed():
	var expression = _a_Expression_Value.get_text()
	_update_expression_error(expression)

func _on_Attributes_pressed():
	_a_attr_select.closed.connect(_on_Attr_Select_closed)
	_a_attr_select.method_selected.connect(_on_Attr_Select_method_selected)
	_a_attr_select.property_selected.connect(_on_Attr_Select_property_selected)
	_a_attr_select.update_list(_a_instance)
	_a_attr_select.open()

func _on_Attr_Select_closed():
	_a_attr_select.closed.disconnect(_on_Attr_Select_closed)
	_a_attr_select.method_selected.disconnect(_on_Attr_Select_method_selected)
	_a_attr_select.property_selected.disconnect(_on_Attr_Select_property_selected)

func _on_Attr_Select_property_selected(p_property):
	var text = _a_Expression_Value.get_text()
	var new_text = text + p_property
	_a_Expression_Value.set_text(new_text)

func _on_Attr_Select_method_selected(p_method):
	var text = _a_Expression_Value.get_text()
	var new_text = text + p_method + "()"
	_a_Expression_Value.set_text(new_text)

class _Instance_Metadata:
	var _a_key = ""
	var _a_instance = null
	var _a_type = "" # Object/Curr_Scene/Singleton
	
	func _init(p_key, p_instance, p_type):
		_a_key = p_key
		_a_instance = p_instance
		_a_type = p_type
	
	func get_key():
		return _a_key
	
	func get_instance():
		return _a_instance
	
	func get_type():
		return _a_type
