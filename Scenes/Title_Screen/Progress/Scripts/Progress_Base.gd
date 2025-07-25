extends Control

const _a_LOCALE_LOC_ID = "LOCALE_%s"
const _a_LOCALE_ICON_PATH = "res://Global_Resources/Sprites/Icons/Locales/%s.png"

@onready var _a_Locale = get_node("Locale")
@onready var _a_Menu_Journal = get_node("Journal")
@onready var _a_Menu_Options = get_node("Options")
@onready var _a_Menu_Credits = get_node("Credits")

var _a_locale_idxs = {} # Match locale to idx

func _ready():
	_a_Locale.item_selected.connect(_on_Locale_item_selected)
	
	_create_locale_options()
	
	var locale = Global_Data.get_locale()
	var idx = _a_locale_idxs[locale]
	_a_Locale.select(idx)
	
	_a_Menu_Journal.hide()

func _create_locale_options():
	var loaded_locales = TranslationServer.get_loaded_locales()
	for i in loaded_locales.size():
		var locale = loaded_locales[i]
		var text = tr(_a_LOCALE_LOC_ID % locale.to_upper())
		var icon = load(_a_LOCALE_ICON_PATH % locale)
		
		_a_locale_idxs[locale] = i
		_a_Locale.add_icon_item(icon, text)
		_a_Locale.set_item_metadata(i, locale)

func _on_Locale_item_selected(p_idx):
	var locale = _a_Locale.get_item_metadata(p_idx)
	Global_Data.set_locale(locale)
	Global_Data.save_data()

func _on_Start_pressed():
	var global_si = Global.get_singleton(self, "Global")
	
	#var dest = ["Debug_3D", "Start"]
	#var dest = ["Debug_2D", "Start"]
	var dest = ["Game_Over", "Start"]
	
	var scene_manager_si = Global.get_singleton(self, "Scene_Manager")
	global_si.start_game()
	scene_manager_si.change_scene_dest(dest)
	
	#var enc_key = ""
	#
	#var battle_system_si = Global.get_singleton(self, "Battle_System")
	#var battle_sv = battle_system_si.get_battle_sv()
	#global_si.start_game()
	#battle_sv.battle(enc_key, BattleSV.MAP_RES.ENEMY)

func _on_Load_pressed():
	_a_Menu_Journal.open()

func _on_Options_pressed():
	_a_Menu_Options.open()

func _on_Credits_pressed():
	_a_Menu_Credits.open()

func _on_Quit_pressed():
	get_tree().quit()
