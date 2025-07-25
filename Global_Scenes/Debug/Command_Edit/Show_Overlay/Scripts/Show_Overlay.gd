extends "res://Global_Scenes/Debug/Command_Edit/Scripts/Command_Base.gd"

const _a_DEFAULT_BG_COLOR = Color(0.26, 0.26, 0.27, 1.0)

@onready var _a_Preview_Background = get_node("Window/Contents/Margin/HBox/Preview/Margin/Background")
@onready var _a_Preview_Trans = get_node("Window/Contents/Margin/HBox/Preview/Margin/Overlays/Trans")
@onready var _a_Preview_Trans_Anims = get_node("Window/Contents/Margin/HBox/Preview/Margin/Overlays/Trans/Anims")
@onready var _a_Color_Preview = get_node("Window/Contents/Margin/HBox/Preview/Color/Preview")
@onready var _a_Color_Pipette = get_node("Window/Contents/Margin/HBox/Preview/Color/Pipette")
@onready var _a_Options = get_node("Window/Contents/Margin/HBox/VBox/Options")
@onready var _a_Type = get_node("Window/Contents/Margin/HBox/VBox/Options/Type")
@onready var _a_Mask = get_node("Window/Contents/Margin/HBox/VBox/Options/Mask")
@onready var _a_Anim = get_node("Window/Contents/Margin/HBox/VBox/Options/Anim")
@onready var _a_Wait_Finish = get_node("Window/Contents/Margin/HBox/VBox/Options/Wait_Finish")
@onready var _a_Pick_Color = get_node("Window/Contents/Margin/HBox/VBox/Pick_Color")

func _ready():
	_a_OK = get_node("Window/Contents/Margin/HBox/VBox/HBox/OK")
	_a_Cancel = get_node("Window/Contents/Margin/HBox/VBox/HBox/Cancel")
	super()
	
	_a_Color_Pipette.pressed.connect(_on_Pipette_pressed)
	_a_Type.selected.connect(_on_Type_selected)
	_a_Mask.file_path_changed.connect(_on_Mask_file_path_changed)
	_a_Anim.selected.connect(_on_Anim_selected)
	_a_Pick_Color.color_changed.connect(_on_Pick_Color_color_changed)
	
	_a_Type.update_options()
	
	_a_Options.show()
	_a_Pick_Color.hide()

func open(p_instance, p_data, p_res_data):
	super(p_instance, p_data, p_res_data)
	
	_update_anim()
	
	_a_Window.show()
	show()

func _open_init(_p_res_data):
	_a_Preview_Background.set_color(_a_DEFAULT_BG_COLOR)
	_a_Color_Preview.set_color(_a_DEFAULT_BG_COLOR)
	_a_Type.load_data_init()
	_selected_type_changed()
	_a_Mask.load_data_init()
	_selected_mask_changed()
	_a_Anim.load_data_init()
	_a_Wait_Finish.load_data_init()

func _open_load(p_data, _p_res_data):
	var bg_color = p_data["BG_Color"]
	_a_Preview_Background.set_color(bg_color)
	_a_Color_Preview.set_color(bg_color)
	_a_Type.load_data(p_data["Type"])
	_selected_type_changed()
	_a_Mask.load_data(p_data["Mask"])
	_selected_mask_changed()
	_a_Anim.load_data(p_data["Anim"])
	_a_Wait_Finish.load_data(p_data["Wait_Finish"])

func _selected_type_changed():
	var type = _a_Type.get_selected_key()
	_a_Mask.set_visible(type == "Trans")
	
	match type:
		"Trans":
			var anim_list = _a_Preview_Trans_Anims.get_animation_list()
			_a_Anim.set_options(anim_list)
			_a_Anim.update_options()
	_update_anim()

func _selected_mask_changed():
	var texture = _a_Mask.get_image_texture()
	var mat = _a_Preview_Trans.get_material()
	mat.set_shader_parameter("mask", texture)
	_update_anim()

func _update_anim():
	var type = _a_Type.get_selected_key()
	var anim = _a_Anim.get_selected_key()
	match type:
		"Trans":
			_a_Preview_Trans_Anims.play(anim)

func _get_save_data():
	var data = {}
	data["BG_Color"] = _a_Preview_Background.get_color()
	data["Type"] = _a_Type.get_save_data()
	data["Mask"] = _a_Mask.get_save_data()
	data["Anim"] = _a_Anim.get_save_data()
	data["Wait_Finish"] = _a_Wait_Finish.get_save_data()
	
	return data

func _on_Pipette_pressed():
	_a_Options.visible = !_a_Options.visible
	_a_Pick_Color.visible = !_a_Pick_Color.visible

func _on_Type_selected():
	_selected_type_changed()

func _on_Mask_file_path_changed(_p_file_path):
	_selected_mask_changed()

func _on_Anim_selected():
	_update_anim()

func _on_Pick_Color_color_changed(p_color):
	_a_Preview_Background.set_color(p_color)
	_a_Color_Preview.set_color(p_color)
