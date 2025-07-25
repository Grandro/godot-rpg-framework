extends Node3D

@onready var _a_Reference_Key = get_node("Reference_Key")

func _ready():
	if !OS.is_debug_build():
		queue_free()

func init(p_entity):
	var entity_comph = p_entity.comph()
	if entity_comph.has_comp("Reference"):
		var key = entity_comph.call_comp("Reference", "get_key")
		_a_Reference_Key.set_text("Key: %s" % key)

func get_save_data():
	return {}

func load_data(_p_data):
	pass

func load_data_init():
	pass
