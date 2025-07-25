extends CanvasLayer

signal closed()
signal property_selected(p_property)
signal method_selected(p_method)

@onready var _a_Back = get_node("Margin/Back")
@onready var _a_Properties_Heading = get_node("Margin/HBox/Properties/Heading")
@onready var _a_Properties = get_node("Margin/HBox/Properties/Entries")
@onready var _a_Methods_Heading = get_node("Margin/HBox/Methods/Heading")
@onready var _a_Methods = get_node("Margin/HBox/Methods/Entries")

func _ready():
	_a_Back.pressed.connect(_on_Back_pressed)
	_a_Properties.entry_select_pressed.connect(_on_Properties_entry_select_pressed)
	_a_Methods.entry_select_pressed.connect(_on_Methods_entry_select_pressed)
	Debug.closing.connect(_on_Debug_closing)

func update_trans():
	_a_Properties_Heading.set_text(tr("DEBUG_PROPERTIES"))
	_a_Methods_Heading.set_text(tr("DEBUG_METHODS"))

func open():
	show()

func close():
	hide()
	closed.emit()

func update_list(p_instance):
	_a_Properties.clear_entries()
	_a_Methods.clear_entries()
	
	var properties = p_instance.get_property_list()
	for args in properties:
		var usage = args["usage"]
		if !Debug.is_usage_for_editor(usage):
			continue
		
		var property = args["name"]
		var instance = _a_Properties.instantiate_entry(property)
		instance.set_select_clip_text.call_deferred(true)
		instance.set_select_tooltip_text.call_deferred(property)
		_a_Properties.add_entry(instance)
	
	var methods = p_instance.get_method_list()
	for args in methods:
		var method = args["name"]
		var instance = _a_Methods.instantiate_entry(method)
		instance.set_select_clip_text.call_deferred(true)
		instance.set_select_tooltip_text.call_deferred(method)
		_a_Methods.add_entry(instance)

func _on_Back_pressed():
	close()

func _on_Debug_closing():
	close()

func _on_Properties_entry_select_pressed(p_instance):
	var property = p_instance.get_select_text()
	property_selected.emit(property)
	close()

func _on_Methods_entry_select_pressed(p_instance):
	var method = p_instance.get_select_text()
	method_selected.emit(method)
	close()
