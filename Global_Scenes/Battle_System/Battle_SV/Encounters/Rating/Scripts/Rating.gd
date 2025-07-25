extends Node3D

@export var _e_nothing_color: Color = Color.WHITE
@export var _e_OK_color: Color = Color.WHITE
@export var _e_good_color: Color = Color.WHITE
@export var _e_great_color: Color = Color.WHITE
@export var _e_delay_time: float = 2.0

const _a_RATING_LOC_ID = "SV_DAMAGE_RATING_%s"

@onready var _a_Text = get_node("VP/Text")
@onready var _a_Anims = get_node("Anims")
@onready var _a_Delay = get_node("Delay")

func _ready():
	_a_Anims.animation_finished.connect(_on_anim_finished)
	_a_Delay.timeout.connect(_on_Delay_timeout)
	
	_a_Delay.set_wait_time(_e_delay_time)
	
	hide()

func display(p_pos, p_rating):
	var rating_text = tr(_a_RATING_LOC_ID % p_rating.to_upper())
	var font = _a_Text.get("theme_override_fonts/normal_font")
	var text_size = font.get_string_size(rating_text)
	_a_Text.set_size(text_size)
	_a_Text.set_pivot_offset(text_size / 2)
	
	match p_rating:
		"Nothing":
			_a_Text.set_text(rating_text)
			_a_Text.set("theme_override_colors/default_color", _e_nothing_color)
		"OK":
			_a_Text.set_text(rating_text)
			_a_Text.set("theme_override_colors/default_color", _e_OK_color)
		"Good":
			_a_Text.set_text(rating_text)
			_a_Text.set("theme_override_colors/default_color", _e_good_color)
		"Great":
			_a_Text.set_text(rating_text)
			_a_Text.set("theme_override_colors/default_color", _e_great_color)
		"Excellent":
			var prefix = "[rainbow freq=0.4 sat=0.8 val=0.8]"
			_a_Text.set_text("%s%s" % [prefix, rating_text])
	
	_a_Anims.play("Fade_In")
	_a_Delay.start()
	
	set_global_position(p_pos)
	show()

func _on_anim_finished(p_name):
	match p_name:
		"Fade_Out":
			hide()

func _on_Delay_timeout():
	_a_Anims.play("Fade_Out")
