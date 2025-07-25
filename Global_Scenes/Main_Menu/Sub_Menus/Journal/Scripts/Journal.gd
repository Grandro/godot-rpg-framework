extends Control

signal closed(p_data)

@export_enum("Main_Menu", "Title_Screen") var _e_context = "Main_Menu"
@export_enum("Read", "Write") var _e_state = "Read"

@onready var _a_Back = get_node("Back")
@onready var _a_Heading = get_node("VBox/Heading")
@onready var _a_Entries = get_node("VBox/Entries")
@onready var _a_Arrow = get_node("Arrow")

var _a_idx = 0

func _ready():
	_a_Back.select_pressed.connect(_on_Back_select_pressed)
	
	var save_file_idx = Global_Data.get_save_file_idx()
	_a_idx = max(0, save_file_idx - 1)
	
	_init_entries()
	_set_heading(_e_state)

func _unhandled_input(p_event):
	if p_event.is_action_pressed("ui_cancel"):
		_close()

func open(_p_data = {}):
	set_process_unhandled_input(true)
	show()
	
	var child = _a_Entries.get_child(_a_idx)
	child.grab_select_focus.call_deferred()

func _close(p_exit = false):
	match _e_context:
		"Main_Menu":
			if p_exit:
				Main_Menu.close()
			queue_free()
		
		"Title_Screen":
			set_process_unhandled_input(false)
			hide()
	
	var data = {}
	closed.emit(data)

func _init_entries():
	var children = _a_Entries.get_children()
	for i in children.size():
		var child = children[i]
		child.select_pressed.connect(_on_Entry_Select_pressed.bind(child))
		child.select_focus_entered.connect(_on_Entry_Select_focus_entered.bind(i))
		
		var path = Global.get_save_path() % str(i + 1)
		var empty = !FileAccess.file_exists(path)
		if !empty:
			var data = Data_Parser.load_var_data(path)
			child.update_display(data)
		child.set_empty(empty)

func _change_arrow_pos(p_idx):
	var instance = _a_Entries.get_child(p_idx)
	var size_x = instance.get_size().x
	var pos_x = instance.get_global_position().x
	var arrow_size_x = _a_Arrow.get_size().x
	var arrow_pos_x = pos_x + (0.5 * size_x) - (0.5 * arrow_size_x)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_a_Arrow, "position:x", arrow_pos_x, 0.2)

func _set_heading(p_state):
	_a_Heading.set_text(tr("MAIN_MENU_JOURNAL_%s" % p_state.to_upper()))

func _on_Back_select_pressed():
	_close()

func _on_Entry_Select_pressed(p_instance):
	var messages_si = Global.get_singleton(self, "Messages")
	match _e_state:
		"Write":
			set_process_unhandled_input(false)
			messages_si.show_proceed(tr("WRITE_READ_PROCEEDWRITE"), self, [p_instance])
		"Read":
			if !p_instance.is_empty():
				set_process_unhandled_input(false)
				messages_si.show_proceed(tr("WRITE_READ_PROCEEDREAD"), self, [p_instance])

func _on_Entry_Select_focus_entered(p_idx):
	_change_arrow_pos(p_idx)
	_a_idx = p_idx

func MESSAGES_PROCEED(p_response, p_value):
	match p_response:
		"Yes":
			var save_file_idx = _a_idx + 1
			var global_si = Global.get_singleton(self, "Global")
			match _e_state:
				"Write": global_si.save_file_data(save_file_idx)
				"Read": global_si.load_file_data(save_file_idx)
			_close(true)
		
		"No":
			var instance = p_value[0]
			instance.grab_select_focus()
	
	set_process_unhandled_input(true)
