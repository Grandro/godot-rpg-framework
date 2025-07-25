extends Node3D

signal changed(p_command)
signal selected(p_command)

@export var _e_radius: float = 0.75

const _a_COMMAND_TEXTURE_PATH = "res://Global_Scenes/Battle_System/Battle_SV/Encounters/Command_Circle/Sprites/Commands/%s.png"

var _a_Command_Entry_Scene = preload("res://Global_Scenes/Battle_System/Battle_SV/Encounters/Command_Circle/Command_Entry.tscn")

@onready var _a_Commands = get_node("Commands")
@onready var _a_Jump_Delay = get_node("Jump_Delay")
@onready var _a_Nav = get_node("Nav")

var _a_enabled = true
var _a_radius = 0.0 # Current radius
var _a_angle = 90.0 # Current angle
var _a_angle_step = 0.0 # Step from box to box
var _a_command_idx = 0 # Idx of selected command
var _a_command_entries = {} # Match idx to instance
var _a_command_instance = null # Currently selected command instance
var _a_commands_moving = false # Are the commands moving?
var _a_can_move_commands = false # Can move commands?
var _a_jump_queued = false # Is jump queued?
var _a_jumping = false # Is jumping?

var _a_instance = null # Party_Member instance

func _ready():
	_a_Jump_Delay.timeout.connect(_on_Jump_Delay_timeout)
	
	set_process(false)
	set_process_unhandled_input(false)
	
	hide()

func _process(_p_delta):
	var children = _a_Commands.get_children()
	_a_angle_step = 360.0 / children.size()
	var curr_angle = _a_angle
	for child in children:
		var x = cos(deg_to_rad(curr_angle)) * _a_radius * 2.0
		var z = sin(deg_to_rad(curr_angle)) * _a_radius
		child.set_position(Vector3(x, 0.0, z))
		
		curr_angle -= _a_angle_step
	
	if !_a_enabled:
		return
	
	if _a_jump_queued && !_a_commands_moving:
		_a_jumping = true
		_a_can_move_commands = false
		_a_instance.comph().call_subcomp("Movement", "Jump", "jump", [8.5])
		_a_Jump_Delay.start()
		
		_a_jump_queued = false
	
	if _a_can_move_commands:
		if Input.is_action_just_pressed("ui_left"):
			_move("Left")
		elif Input.is_action_just_pressed("ui_right"):
			_move("Right")
	
	if Input.is_action_pressed("OK"):
		if !_a_jumping:
			_a_jump_queued = true

func open(p_instance):
	_a_instance = p_instance
	
	var movement_jump_comp = _a_instance.comph().get_subcomp("Movement", "Jump")
	movement_jump_comp.jumped.connect(_on_Character_jumped)
	
	var pos = p_instance.get_global_position()
	pos += p_instance.get_command_circle_offset()
	set_global_position(pos)
	
	var commands = p_instance.get_active_actions("Commands")
	for i in commands.size():
		var command = commands[i]
		var instance = _a_Command_Entry_Scene.instantiate()
		var texture = load(_a_COMMAND_TEXTURE_PATH % command)
		instance.set_name(command)
		instance.set_command(command)
		instance.set_image_texture.call_deferred(texture)
		
		_a_command_entries[i] = instance
		_a_Commands.add_child(instance)
	_a_command_instance = _a_command_entries[0]
	_a_command_instance.play_anim("Selected")
	
	if commands.size() > 1:
		_a_can_move_commands = true
	
	# Tween radius
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "_a_radius", _e_radius, 0.25).from(0.0)
	
	set_process(true)
	set_process_unhandled_input(true)
	
	var command = _a_command_instance.get_command()
	changed.emit(command)
	
	show()

func close():
	var movement_jump_comp = _a_instance.comph().get_subcomp("Movement", "Jump")
	movement_jump_comp.jumped.disconnect(_on_Character_jumped)
	
	_a_angle = 90.0
	_a_command_idx = 0
	
	_a_command_entries.clear()
	for child in _a_Commands.get_children():
		child.queue_free()
	set_process(false)
	set_process_unhandled_input(false)
	
	hide()

func _move(p_dir):
	var new_angle = snapped(_a_angle - 90.0, _a_angle_step)
	match p_dir:
		"Left": new_angle += _a_angle_step
		"Right": new_angle -= _a_angle_step
	new_angle += 90.0
	
	var child_count = _a_Commands.get_child_count()
	var duration = 0.5 / child_count
	var tween = create_tween()
	tween.finished.connect(_on_Tween_finished)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "_a_angle", new_angle, duration)
	_a_Nav.play()
	
	_a_commands_moving = true

func set_enabled(p_enabled):
	_a_enabled = p_enabled

func _on_Tween_finished():
	_a_angle = fmod(_a_angle, 360.0)
	if _a_angle > 0:
		_a_command_idx = int(abs(_a_angle - 90.0) / _a_angle_step)
	else:
		_a_command_idx = int(abs(360.0 + _a_angle - 90.0) / _a_angle_step)
	_a_commands_moving = false
	
	var instance = _a_command_entries[_a_command_idx]
	instance.play_anim("Selected")
	_a_command_instance.stop_anim()
	_a_command_instance = instance
	
	var command = _a_command_instance.get_command()
	changed.emit(command)

func _on_Jump_Delay_timeout():
	_a_command_instance.play_anim("Bounce_Up")

func _on_Character_jumped():
	var command = _a_command_instance.get_command()
	_a_instance.comph().call_comp("States", "set_state_tmp", ["Idle"])
	_a_instance.comph().call_comp("Anims", "update_anim")
	
	selected.emit(command)
	_a_jumping = false
