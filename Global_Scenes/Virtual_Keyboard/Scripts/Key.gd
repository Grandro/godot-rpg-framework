extends TextureButton

const _a_KEY_PATH = "res://Global_Resources/Sprites/Keys/%s.png"

@onready var _a_Anims = get_node("Anims")

var _a_char_idx = -1
var _a_button_down = false

func _ready():
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func set_key_texture(p_key):
	var texture = load(_a_KEY_PATH % p_key)
	set_texture_normal(texture)
	set_texture_focused(texture)

func set_char_idx(p_char_idx):
	_a_char_idx = p_char_idx

func get_char_idx():
	return _a_char_idx

func _on_button_down():
	_a_button_down = true
	_a_Anims.play("Scale_Down")

func _on_button_up():
	if _a_button_down:
		_a_button_down = false
		_a_Anims.play("Scale_Up")
