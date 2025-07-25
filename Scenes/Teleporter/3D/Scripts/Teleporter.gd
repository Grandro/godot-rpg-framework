extends Node3DObject

signal teleported()

@export var _e_destination: Array[String] = []

@onready var _a_Interactions = get_node("Interactions")

func _ready():
	super()
	_a_Interactions.interacted.connect(_on_Interactions_interacted)

func get_destination():
	return _e_destination

func get_save_data():
	var data = super()
	data["Destination"] = _e_destination
	
	return data

func load_data(p_data):
	super(p_data)
	_e_destination = p_data["Destination"]

func _on_Interactions_interacted():
	teleported.emit()
