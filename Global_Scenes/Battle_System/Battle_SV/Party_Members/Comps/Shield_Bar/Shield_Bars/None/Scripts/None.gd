extends "res://Global_Scenes/Battle_System/Battle_SV/Party_Members/Comps/Shield_Bar/Shield_Bars/Scripts/Shield_Bar_Base.gd"

func process_effect(p_entity):
	p_entity.comph().call_comp("Status", "add_status", ["Empowered_Attack", 1])
