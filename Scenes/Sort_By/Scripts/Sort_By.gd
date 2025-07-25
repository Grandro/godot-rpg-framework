extends VBoxContainer

signal option_selected()

const _a_SORT_LOC_ID = "SORT_%s_%s"

@export var _e_sort_args : Dictionary = {} # Match key to sort method name
@export var _e_relations : Array[String] = ["Low", "High"]

@onready var _a_Options = get_node("Options")

func _ready():
	_a_Options.item_selected.connect(_on_Options_item_selected)
	
	_create_sort_types()

func _create_sort_types():
	var i = 0
	for key in _e_sort_args:
		var method_name = _e_sort_args[key]
		for rel in _e_relations:
			var loc_id = _a_SORT_LOC_ID % [key.to_upper(), rel.to_upper()]
			_a_Options.add_item(tr(loc_id))
			_a_Options.set_item_metadata(i, [method_name, rel])
			i += 1

func get_selected_args():
	return _a_Options.get_selected_metadata()

func _on_Options_item_selected(_p_idx):
	option_selected.emit()
