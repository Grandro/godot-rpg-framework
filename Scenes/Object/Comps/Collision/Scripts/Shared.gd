extends "res://Scripts/Extension_Base.gd"

var _a_entity_entity = null

func init(p_entity_entity):
	_a_entity_entity = p_entity_entity
	
	p_entity_entity.visibility_changed.connect(_on_entity_entity_visibility_changed)

func _on_entity_entity_visibility_changed():
	var is_visible_ = _a_entity_entity.is_visible()
	_a_entity.set_disabled.call_deferred(!is_visible_)
