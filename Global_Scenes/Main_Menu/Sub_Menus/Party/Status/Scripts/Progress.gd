extends VBoxContainer

@onready var a_Exp = get_node("Exp/Value")
@onready var a_Next_Lvl = get_node("Next_Lvl/Value")

func open(p_pm_key, p_progress):
	var pm_args = Databases.get_data_entry("Party_Members", p_pm_key)
	var lvl = p_progress["Lvl"]
	var exp_ = p_progress["Exp"]
	var next_lvl_exp = pm_args.get_exp_till_next_lvl(lvl + 1)
	var next_lvl = next_lvl_exp - exp_
	a_Exp.set_text(str(exp_))
	a_Next_Lvl.set_text(str(next_lvl))
