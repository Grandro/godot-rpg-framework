extends "res://Scripts/Extension_Base.gd"

var _a_Interaction = null
var _a_Camera = null
var _a_Operate = null
var _a_Interaction_System = null

func ready():
	_a_Interaction = _a_entity.get_node("Interactions/1")
	_a_Camera = _a_entity.get_node("Camera")
	_a_Operate = _a_entity.get_node("Operate")
	_a_Interaction_System = _a_entity.get_node("Interaction_System")
	
	_a_Operate.to_disabled.connect(_on_Operate_to_disabled)
	_a_Operate.to_enabled.connect(_on_Operate_to_enabled)
	_a_Interaction.area_entered.connect(_a_Interaction_System._on_Interaction_area_entered)
	_a_Interaction.area_exited.connect(_a_Interaction_System._on_Interaction_area_exited)
	
	if Global.is_instance_in_game_world(_a_entity):
		var global_si = Global.get_singleton(_a_entity, "Global")
		var dialogue_system_si = Global.get_singleton(_a_entity, "Dialogue_System")
		var cutscene_system_si = Global.get_singleton(_a_entity, "Cutscene_System")
		dialogue_system_si.main_started.connect(_on_Dialogue_System_main_started)
		dialogue_system_si.main_completed.connect(_on_Dialogue_System_main_completed)
		cutscene_system_si.main_started.connect(_on_Cutscene_System_main_started)
		cutscene_system_si.main_completed.connect(_on_Cutscene_System_main_completed)
		
		global_si.set_player(_a_entity)
		global_si.set_curr_camera(_a_Camera)

func input(p_event):
	if p_event.is_action_pressed("Open_Main_Menu"):
		if Main_Menu.is_openable():
			Main_Menu.open()
			
			var vp = _a_entity.get_viewport()
			vp.set_input_as_handled()
	
	elif p_event.is_action_pressed("OK"):
		var body = _a_Interaction_System.get_body()
		if body != null:
			var area = _a_Interaction_System.get_area()
			body.comph().call_comp("Interactions", "interaction", [area])
			
			var vp = _a_entity.get_viewport()
			vp.set_input_as_handled()

func _on_Operate_to_disabled():
	_a_entity.set_process_input(false)

func _on_Operate_to_enabled():
	_a_entity.set_process_input(true)

func _on_Dialogue_System_main_started(_p_key):
	_a_Operate.disable()

func _on_Dialogue_System_main_completed():
	_a_Operate.enable()

func _on_Cutscene_System_main_started(_p_key):
	_a_Operate.disable()

func _on_Cutscene_System_main_completed():
	_a_Operate.enable()
