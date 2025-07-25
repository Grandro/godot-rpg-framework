extends "res://Global_Scenes/Debug/Scenes/Entry_List/Entries/Scripts/Entry.gd"

var _a_Check_Image = preload("res://Global_Resources/Sprites/UI/Check.png")
var _a_Cross_Image = preload("res://Global_Resources/Sprites/UI/Cross.png")

@onready var _a_Completed = get_node("HBox/VBox/Margin/Margin/HBox/Completed")
@onready var _a_Sub_Quests = get_node("HBox/VBox/Options/Sub_Quests/Entry_List")

var _a_key = ""

func _ready():
	super()
	_a_Sub_Quests.entry_select_pressed.connect(_on_Sub_Quest_Entry_select_pressed)
	
	var entry_scene = load("res://Global_Scenes/Debug/Scenes/Entry_List/Entries/Quest_Entry.tscn")
	_a_Sub_Quests.set_entry_scene(entry_scene)

func update_data():
	var progress_si = Global.get_singleton(self, "Progress")
	var quest_data_args = Databases.get_data_entry("Quests", _a_key)
	var quest_data_obj = quest_data_args.get_objectives()
	
	var quests_progress = progress_si.get_quests()
	var quest_progress = quests_progress[_a_key]
	var quest_progress_obj = quest_progress.get_objective_instances()
	
	var quest_name = tr(quest_data_args.get_name_())
	var quest_active = quest_progress.is_active()
	_a_Name.set_text(quest_name)
	_set_completed(!quest_active)
	
	# Create Sub-Quests
	_a_Sub_Quests.clear_entries()
	
	var has_sub_quests = false
	for i in quest_progress_obj.size():
		var data_obj_args = quest_data_obj[i]
		var type = data_obj_args.get_type()
		if type != "Sub_Quest":
			continue
		var sub_quest = data_obj_args.get_sub_quest()
		var sub_quest_key = sub_quest.get_key()
		if !progress_si.is_quest_started(sub_quest_key):
			continue
		
		var instance = _a_Sub_Quests.instantiate_entry_(sub_quest_key)
		_a_Sub_Quests.add_entry(instance)
		
		has_sub_quests = true
	
	_a_Collapse.set_visible(has_sub_quests)

func set_key(p_key):
	_a_key = p_key

func get_key():
	return _a_key

func _set_completed(p_completed):
	if p_completed:
		_a_Completed.set_texture(_a_Check_Image)
	else:
		_a_Completed.set_texture(_a_Cross_Image)

func get_save_data():
	var data = super()
	data["Key"] = get_key()
	data["Sub_Quests"] = _a_Sub_Quests.get_save_data()
	
	return data

func load_data(p_data):
	super(p_data)
	
	var sub_quests = p_data["Sub_Quests"]
	for i in sub_quests.size():
		var entry_args = sub_quests[i]
		var instance = _a_Sub_Quests.get_entry(i)
		instance.load_data(entry_args)

func _on_Sub_Quest_Entry_select_pressed(p_instance):
	select_pressed.emit(p_instance)
