extends CanvasLayer

const _a_BUTTON_TEXTURE_PATH = "res://Global_Resources/Sprites/SV/%s_Button_Spritesheet.png"
const _a_REACTION_LOC_ID = "SV_REACTIONS_%s"

var _a_Reaction_Entry_Scene = preload("res://Global_Scenes/Battle_System/Battle_SV/Encounters/Indicators/Reaction_Entry.tscn")

@onready var _a_Reactions_VBox = get_node("Reactions/VBox")
@onready var _a_Reactions_Anims = get_node("Reactions/Anims")

func _ready():
	_a_Reactions_Anims.animation_finished.connect(_on_Reactions_Anims_anim_finished)
	
	hide()

func open(p_reactions):
	for key in p_reactions:
		var button_key = p_reactions[key]
		var instance = _a_Reaction_Entry_Scene.instantiate()
		var texture = load(_a_BUTTON_TEXTURE_PATH % button_key)
		var loc_id = _a_REACTION_LOC_ID % key.to_upper()
		var text = tr(loc_id)
		instance.set_texture_atlas.call_deferred(texture)
		instance.set_text.call_deferred(text)
		
		_a_Reactions_VBox.add_child(instance)
	
	_a_Reactions_Anims.play("Fade_In")
	show()

func close():
	_a_Reactions_Anims.play("Fade_Out")

func _on_Reactions_Anims_anim_finished(p_anim_name):
	match p_anim_name:
		"Fade_Out":
			for child in _a_Reactions_VBox.get_children():
				child.queue_free()
			hide()
