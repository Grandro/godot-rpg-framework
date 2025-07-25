extends HBoxContainer

const _a_ENTRY_SCENE_PATH = "res://Global_Scenes/Battle_System/Battle_SV/Result/Party_Members/Entries/%s.tscn"

var _a_entries = {} # Match pm_key to instance

func open(p_exp):
	var global_si = Global.get_singleton(self, "Global")
	var party_members = global_si.get_party_members_active()
	var pm_data = Databases.get_data("Party_Members")
	for pm_key in party_members:
		var party_member = party_members[pm_key]
		var pm_args = pm_data[pm_key]
		var progress = party_member["Progress"]
		var scene = load(_a_ENTRY_SCENE_PATH % pm_key)
		var instance = scene.instantiate()
		instance.open.call_deferred(pm_args, progress, p_exp)
		
		_a_entries[pm_key] = instance
		add_child(instance)

func close():
	_a_entries.clear()
	for child in get_children():
		child.queue_free()
