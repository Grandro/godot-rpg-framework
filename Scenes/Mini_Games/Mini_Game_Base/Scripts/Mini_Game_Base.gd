extends Control

signal closed()

@export var _e_BGM : AudioStream = null
@export var _e_in_nutOS: bool = false

@onready var _a_Intro = get_node("Canvas/Intro")

var _a_game_play = null

func _ready():
	_a_game_play = get_node("Game_Play")
	
	_a_Intro.proceed_pressed.connect(_on_Intro_proceed_pressed)
	_a_game_play.finished.connect(_on_Game_Play_finished)
	
	hide()

func open():
	var audio_manager_si = Global.get_singleton(self, "Audio_Manager")
	audio_manager_si.play_bgm(_e_BGM)
	
	_a_Intro.open()
	show()

func close():
	var audio_manager_si = Global.get_singleton(self, "Audio_Manager")
	var bgm_path = _e_BGM.get_path()
	var bgm_file_name = bgm_path.get_file()
	audio_manager_si.stop_bgm(bgm_file_name)
	
	hide()
	closed.emit()

func _on_Intro_proceed_pressed():
	_a_game_play.open()

func _on_Game_Play_finished():
	close()
