extends Character2DObject

var _a_Shared = preload("res://Scenes/Player/Scripts/Shared.gd")

var _a_shared = null

func _ready():
	_a_shared = _a_Shared.new(self)
	super()
	
	_a_shared.ready()

func _input(p_event):
	_a_shared.input(p_event)
