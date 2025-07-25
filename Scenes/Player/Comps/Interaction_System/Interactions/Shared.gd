extends "res://Scenes/Object/Comps/Interactions/Scripts/Shared.gd"

func init(p_entity_entity):
	super(p_entity_entity)
	
	var entity_entity_comph = p_entity_entity.comph()
	var operate_comp = entity_entity_comph.get_comp("Operate")
	operate_comp.to_disabled.connect(_on_Operate_to_disabled)
	operate_comp.to_enabled.connect(_on_Operate_to_enabled)

func _on_Operate_to_disabled():
	_a_Default_Interaction.set_monitoring(false)

func _on_Operate_to_enabled():
	_a_Default_Interaction.set_monitoring(true)
