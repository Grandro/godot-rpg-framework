extends PanelContainer

signal back_pressed()

@export var _e_show_back: bool = false

const _a_OBJECTIVE_SCENE_PATH = "res://Global_Scenes/Main_Menu/Sub_Menus/Quests/Info/Objective_%s.tscn"

@onready var _a_Back = get_node("Margin/VBox/Back")
@onready var _a_Heading = get_node("Margin/VBox/VBox/VBox/Heading")
@onready var _a_Desc = get_node("Margin/VBox/VBox/VBox/Desc")
@onready var _a_Objectives = get_node("Margin/VBox/VBox/Objectives")

var _a_key = "" # Quest key

func _ready():
	_a_Back.pressed.connect(_on_Back_pressed)
	
	_a_Back.set_visible(_e_show_back)

func display(p_key):
	_a_key = p_key
	_clear_objectives()
	
	var quest_args = Databases.get_data_entry("Quests", p_key)
	var quest_name = tr(quest_args.get_name_())
	var quest_desc = tr(quest_args.get_desc())
	_a_Heading.set_text("[center]%s" % quest_name)
	_a_Desc.set_text("[center]%s" % quest_desc)
	
	var progress_si = Global.get_singleton(self, "Progress")
	var quests_progress = progress_si.get_quests()
	var quest_progress = quests_progress[p_key]
	var quest_progress_obj = quest_progress.get_objective_instances()
	for instance in quest_progress_obj:
		_instantiate_objective(instance)
	
	show()

func close():
	_a_key = ""
	hide()

func _clear_objectives():
	for child in _a_Objectives.get_children():
		child.queue_free()

func _instantiate_objective(p_objective_instance):
	var data = p_objective_instance.get_data()
	var type = data.get_type()
	var scene = load(_a_OBJECTIVE_SCENE_PATH % type)
	var instance = scene.instantiate()
	instance.set_objective_instance(p_objective_instance)
	
	_a_Objectives.add_child(instance)

func is_quest_open(p_key):
	return _a_key == p_key

func get_key():
	return _a_key

func _on_Back_pressed():
	back_pressed.emit()
