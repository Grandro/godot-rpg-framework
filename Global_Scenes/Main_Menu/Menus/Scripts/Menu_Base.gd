extends Control

signal request_menu(p_scene)
signal request_sub_menu(p_key, p_scene)

@export var _e_sub_menus: Array[String] = []

var _a_data = {}
var _a_selected = null # Selected Menu_Icon

func open():
	_a_selected.grab_image_focus()
	show()

func close():
	hide()
	queue_free()

func _init_menu_icons(p_parent):
	var select = true
	for child in p_parent.get_children():
		var key = child.get_key()
		var unlocked = _a_data[key]["Unlocked"]
		child.pressed.connect(_on_Menu_Icon_pressed.bind(child))
		child.set_visible(unlocked)
		
		if select && unlocked:
			_a_selected = child
			select = false

func get_sub_menus():
	return _e_sub_menus

func set_data(p_data):
	_a_data = p_data

func _on_Menu_Icon_pressed(p_instance):
	_a_selected = p_instance
	
	var scene = p_instance.get_menu_scene()
	var type = p_instance.get_type()
	match type:
		"Menu":
			request_menu.emit(scene)
		"Sub_Menu":
			var key = p_instance.get_key()
			request_sub_menu.emit(key, scene)
