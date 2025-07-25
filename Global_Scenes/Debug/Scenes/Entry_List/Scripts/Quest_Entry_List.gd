extends "res://Global_Scenes/Debug/Scenes/Entry_List/Scripts/Entry_List.gd"

func _ready():
	super()
	var progress_si = Global.get_singleton(self, "Progress")
	progress_si.progress_changed.connect(_on_Progress_progress_changed)

func instantiate_entries():
	var progress_si = Global.get_singleton(self, "Progress")
	var quests_data = Databases.get_data("Quests")
	var quests_progress = progress_si.get_quests()
	for key in quests_progress:
		var quest_data = quests_data[key]
		var type = quest_data.get_type()
		if type == "Main" || type == "Side":
			var instance = instantiate_entry_(key)
			add_entry(instance)

func instantiate_entry_(p_key = ""):
	var instance = instantiate_entry(p_key)
	instance.set_key(p_key)
	instance.update_data.call_deferred()
	
	return instance

func instantiate_entry_from_data(p_data):
	var key = p_data["Key"]
	var instance = instantiate_entry_(key)
	
	return instance

func delete_entry(p_key):
	var instance = _a_entries[p_key]
	instance.queue_free()

func has_entry(p_key):
	return _a_entries.has(p_key)

func _on_Progress_progress_changed():
	for child in get_entries():
		child.update_data()
