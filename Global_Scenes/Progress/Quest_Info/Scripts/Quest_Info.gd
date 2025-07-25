extends Control

const _a_CHAPTER_NAME_LOC_ID = "PROGRESS_%s_NAME"
const _a_TYPE_LOC_ID = "PROGRESS_QUEST_TYPE_%s"
const _a_STATUS_LOC_ID = "PROGRESS_QUEST_INFO_STATUS_%s"

@onready var _a_Chapter = get_node("Info/Margin/VBox/Heading/Chapter/Right")
@onready var _a_Name = get_node("Info/Margin/VBox/Heading/Name")
@onready var _a_Type = get_node("Info/Margin/VBox/Heading/Type")
@onready var _a_Rewards = get_node("Info/Margin/VBox/Rewards")
@onready var _a_Status = get_node("Info/Margin/VBox/Status")
@onready var _a_Anims = get_node("Anims")
@onready var _a_Audio_Start = get_node("Audio/Start")

var _a_status = "" # Start / Complete

func _ready():
	_a_Anims.animation_finished.connect(_on_Anims_anim_finished)
	
	set_process_input(false)
	hide()

func _input(p_event):
	if p_event.is_action_pressed("Proceed_Dialogue"):
		_a_Anims.play("Fade_Out")

func open(p_key, p_status):
	_a_status = p_status
	
	var global_si = Global.get_singleton(self, "Global")
	var progress_si = Global.get_singleton(self, "Progress")
	var chapter = progress_si.get_chapter()
	global_si.pause()
	set_chapter(chapter)
	
	var data = Databases.get_data_entry("Quests", p_key)
	var type = data.get_type()
	var name_ = data.get_name_()
	_a_Type.set_text(tr(_a_TYPE_LOC_ID % type.to_upper()))
	_a_Name.set_text(tr(name_))
	_a_Status.set_text(tr(_a_STATUS_LOC_ID % p_status.to_upper()))
	
	match p_status:
		"Start": _a_Rewards.hide()
		"Complete": _a_Rewards.show()
	
	_a_Audio_Start.play()
	_a_Anims.play("Fade_In")
	
	show()

func _close():
	var global_si = Global.get_singleton(self, "Global")
	set_process_input(false)
	global_si.unpause()
	hide()

func _faded_in():
	match _a_status:
		"Start":
			set_process_input(true)
		"Complete":
			pass

func set_chapter(p_chapter):
	var text = _a_CHAPTER_NAME_LOC_ID % p_chapter.to_upper()
	_a_Chapter.set_text(text)

func _on_Anims_anim_finished(p_name):
	match p_name:
		"Fade_In":
			_faded_in()
		"Fade_Out":
			_close()
