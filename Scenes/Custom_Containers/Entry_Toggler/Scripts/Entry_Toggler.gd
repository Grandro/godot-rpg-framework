extends BoxContainer

signal toggled(p_instance)

@export var _e_entry_scene: PackedScene = preload("res://Scenes/Custom_Containers/Entry_Toggler/Entries/Entry.tscn")

var _a_entry = null # Currently toggled entry

func _ready():
	for child in get_children():
		child.select_toggled.connect(_on_Entry_select_toggled.bind(child))
	
	if get_child_count() > 0:
		_toggle_first()

func instantiate_entry(p_select_text = "", p_texture = null):
	var instance = _e_entry_scene.instantiate()
	instance.ready.connect(_on_Entry_ready)
	instance.select_toggled.connect(_on_Entry_select_toggled.bind(instance))
	instance.set_select_text.call_deferred(p_select_text)
	instance.set_texture.call_deferred(p_texture)
	
	return instance

func add_entry(p_instance):
	add_child(p_instance)

func _toggle_first():
	var first = get_child(0)
	_toggle(first)

func _toggle(p_instance):
	if _a_entry != null:
		_a_entry.set_select_disabled(false)
		_a_entry.set_select_pressed(false)
	
	p_instance.set_select_disabled(true)
	toggled.emit(p_instance)
	
	_a_entry = p_instance

func _on_Entry_ready():
	if get_child_count() == 1:
		_toggle_first()

func _on_Entry_select_toggled(p_pressed, p_instance):
	if !p_pressed:
		return
	_toggle(p_instance)
