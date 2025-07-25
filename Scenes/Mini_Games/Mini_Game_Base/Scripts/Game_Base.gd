extends Node2D

signal finished()

@onready var _a_Background = get_node("Canvas_1/Background")

func _ready():
	_a_Background.hide()
	hide()

func open():
	_a_Background.show()
	show()

func close():
	_a_Background.hide()
	hide()
	
	finished.emit()
