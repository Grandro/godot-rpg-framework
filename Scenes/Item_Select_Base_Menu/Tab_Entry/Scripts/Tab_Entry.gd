extends ScrollContainer

signal group_changed(p_group)
signal group_mouse_entered()
signal group_mouse_exited()

@export var _e_type: String = ""
@export var _e_groups: Array[String] = []
@export var _e_has_icons: bool = false

var _a_Group_Entry_Scene = preload("res://Scenes/Item_Select_Base_Menu/Tab_Entry/Scenes/Group_Entry.tscn")

@onready var _a_Icons = get_node("VBox/Icons")
@onready var _a_Icons_Toggler = get_node("VBox/Icons/Toggler")
@onready var _a_HSep = get_node("VBox/HSep")
@onready var _a_Groups = get_node("VBox/Groups")

var _a_groups = {} # Match key to instance
var _a_group_instance = null # Current group instance
var _a_group = "" # Current group

func _ready():
	_a_Icons_Toggler.toggled.connect(_on_Icons_Toggler_toggled)
	
	for i in _e_groups.size():
		var group = _e_groups[i]
		var group_instance = _a_Group_Entry_Scene.instantiate()
		group_instance.mouse_entered.connect(_on_Group_Entry_mouse_entered)
		group_instance.mouse_exited.connect(_on_Group_Entry_mouse_exited)
		
		if i == 0:
			_a_group_instance = group_instance
			_a_group = group
		else:
			group_instance.hide()
		_a_groups[group] = group_instance
		_a_Groups.add_child(group_instance)
		
		if _e_has_icons:
			var item_type_icon_path = Global.get_item_type_icon_path()
			var texture = load(item_type_icon_path % [_e_type, group])
			var instance = _a_Icons_Toggler.instantiate_entry_("", texture, group)
			_a_Icons_Toggler.add_entry(instance)
	
	_a_Icons.set_visible(_e_has_icons)
	_a_HSep.set_visible(_e_has_icons)

func add_item(p_instance, p_group):
	var group = _a_groups[p_group]
	group.add_child(p_instance)

func clear_items():
	for group in _a_groups.values():
		for child in group.get_children():
			child.queue_free()

func move_item_curr(p_instance, p_idx):
	_a_group_instance.move_child(p_instance, p_idx)

func get_type():
	return _e_type

func get_groups_():
	return _e_groups

func get_first_item_curr():
	var first = null
	for child in _a_group_instance.get_children():
		if child.get_amount() > 0:
			first = child
			break
	
	return first

func get_curr_group_instance():
	return _a_group_instance

func get_curr_group():
	return _a_group

func _on_Icons_Toggler_toggled(p_instance):
	_a_group_instance.hide()
	
	var group = p_instance.get_key()
	_a_group_instance = _a_groups[group]
	_a_group_instance.show()
	_a_group = group
	
	group_changed.emit(group)

func _on_Group_Entry_mouse_entered():
	group_mouse_entered.emit()

func _on_Group_Entry_mouse_exited():
	group_mouse_exited.emit()
