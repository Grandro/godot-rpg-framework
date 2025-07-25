extends HBoxContainer

@onready var _a_Image = get_node("Image")
@onready var _a_Text = get_node("Text")

func set_texture_atlas(p_texture_atlas):
	var texture = _a_Image.get_texture()
	texture.set_atlas(p_texture_atlas)

func set_text(p_text):
	_a_Text.set_text(p_text)
