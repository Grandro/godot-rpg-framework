extends VBoxContainer

@onready var _a_Master = get_node("Master")
@onready var _a_BGM = get_node("BGM")
@onready var _a_BGS = get_node("BGS")
@onready var _a_SFX = get_node("SFX")

func _ready():
	_a_Master.value_changed.connect(_on_Master_value_changed)
	_a_BGM.value_changed.connect(_on_BGM_value_changed)
	_a_BGS.value_changed.connect(_on_BGS_value_changed)
	_a_SFX.value_changed.connect(_on_SFX_value_changed)

func load_data(p_data):
	_a_Master.load_data(p_data["Master"])
	_a_BGM.load_data(p_data["BGM"])
	_a_BGS.load_data(p_data["BGS"])
	_a_SFX.load_data(p_data["SFX"])

func _on_Master_value_changed(p_value):
	Global_Data.set_options_audio_volume_master(p_value)

func _on_BGM_value_changed(p_value):
	Global_Data.set_options_audio_volume_BGM(p_value)

func _on_BGS_value_changed(p_value):
	Global_Data.set_options_audio_volume_BGS(p_value)

func _on_SFX_value_changed(p_value):
	Global_Data.set_options_audio_volume_SFX(p_value)
