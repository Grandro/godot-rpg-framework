extends Resource
class_name QuestData

@export var _e_key: String = ""
@export_enum("Main", "Main_Sub", "Side", "Side_Sub") var _e_type = "Main"
@export var _e_location: String = ""
@export var _e_name: String = "" # Loc_ID
@export var _e_desc: String = "" # Loc_ID
@export var _e_objectives: Array[ObjectiveData] = []
@export var _e_rewards: Dictionary = {} # Match key to amount

func get_key():
	return _e_key

func get_type():
	return _e_type

func get_location():
	return _e_location

func get_name_():
	return _e_name

func get_desc():
	return _e_desc

func get_objectives():
	return _e_objectives
