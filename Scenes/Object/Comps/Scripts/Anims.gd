extends AnimationPlayer

signal anim_seeked(p_seconds, p_update)
signal anim_stopped(p_reset)
signal anim_played(p_name)

@export var _e_seek_on_load : bool = true

var _a_entity_comph : CompHandler = null

func init(p_entity):
	_a_entity_comph = p_entity.comph()
	_a_entity_comph.comps_registered.connect(_on_Comp_Handler_comps_registered)

func update_anim():
	if !_a_entity_comph.has_comp("States"):
		return
	
	var state_tmp = _a_entity_comph.call_comp("States", "get_state_tmp")
	var dir = ""
	if _a_entity_comph.has_comp("Movement"):
		dir = _a_entity_comph.call_comp("Movement", "get_dir")
		
		if _a_entity_comph.has_comp("Display"):
			var display_comp = _a_entity_comph.get_comp("Display")
			var billboard = display_comp.get_billboard()
			if billboard:
				var rotation_degrees = display_comp.get_global_rotation_degrees()
				dir = Global.get_dir_rotated(dir, rotation_degrees.y)
	
	if dir.is_empty():
		play_anim(state_tmp)
	else:
		var anim_name = "%s_%s" % [state_tmp, dir]
		play_anim(anim_name)

func play_anim(p_name, p_speed = 1.0, p_backwards = false):
	if p_backwards:
		play(p_name, -1, -p_speed, true)
	else:
		play(p_name, -1, p_speed)
	
	anim_played.emit(p_name)

func seek_anim(p_seconds, p_update = false):
	seek(p_seconds, p_update)
	anim_seeked.emit(p_seconds, p_update)

func stop_anim(p_keep_state = false):
	stop(p_keep_state)
	anim_stopped.emit(p_keep_state)

func get_save_data():
	var data = {}
	var curr = ""
	var pos = 0.0
	if is_playing():
		curr = get_current_animation()
		pos = get_current_animation_position()
	data["Curr"] = curr
	data["Pos"] = pos
	
	return data

func load_data(p_data):
	var curr = p_data["Curr"]
	if !curr.is_empty():
		var pos = p_data["Pos"]
		play_anim(curr)
		if _e_seek_on_load:
			seek_anim(pos, true)

func load_data_init():
	pass

func _on_Comp_Handler_comps_registered():
	update_anim()
