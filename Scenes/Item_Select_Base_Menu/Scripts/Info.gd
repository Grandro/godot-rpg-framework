extends PanelContainer

signal use_pressed()
signal select_pressed()

@export var _e_can_use: bool = true
@export var _e_select_mode: bool = false

@onready var _a_VBox = get_node("Margin/VBox")
@onready var _a_Name = get_node("Margin/VBox/Name")
@onready var _a_Image = get_node("Margin/VBox/Image")
@onready var _a_Desc = get_node("Margin/VBox/VBox/Desc")
@onready var _a_Stats = get_node("Margin/VBox/VBox/Stats")
@onready var _a_Stats_HP = get_node("Margin/VBox/VBox/Stats/Left/HP/Value")
@onready var _a_Stats_SP = get_node("Margin/VBox/VBox/Stats/Left/SP/Value")
@onready var _a_Stats_ATK = get_node("Margin/VBox/VBox/Stats/Left/ATK/Value")
@onready var _a_Stats_MAG = get_node("Margin/VBox/VBox/Stats/Middle/MAG/Value")
@onready var _a_Stats_DEF = get_node("Margin/VBox/VBox/Stats/Middle/DEF/Value")
@onready var _a_Stats_SPEED = get_node("Margin/VBox/VBox/Stats/Middle/SPEED/Value")
@onready var _a_Stats_LUCK = get_node("Margin/VBox/VBox/Stats/Right/LUCK/Value")
@onready var _a_Options = get_node("Margin/VBox/VBox/Options")
@onready var _a_Use = get_node("Margin/VBox/VBox/Options/Use")
@onready var _a_Select = get_node("Margin/VBox/VBox/Options/Select")

func _ready():
	_a_Use.pressed.connect(_on_Use_pressed)
	_a_Select.pressed.connect(_on_Select_pressed)
	
	_a_Select.set_visible(_e_select_mode)
	_a_VBox.hide()

func display(p_key):
	var item_args = Databases.get_data_entry("Items", p_key)
	var item_name = item_args.get_name_()
	var item_desc = item_args.get_desc()
	var item_category_type = item_args.get_category_type()
	var item_texture = item_args.get_texture()
	_a_Name.set_text(item_name)
	_a_Image.set_texture(item_texture)
	_a_Desc.set_text("[center]%s" % tr(item_desc))
	
	match item_category_type:
		"Consumable":
			_a_Options.show()
			_a_Stats.hide()
			_a_Use.set_visible(_e_can_use)
		"Static":
			_a_Options.set_visible(_e_select_mode)
			_a_Stats.hide()
			_a_Use.hide()
		"Equipable":
			_update_stats(item_args.get_stats())
			_a_Options.set_visible(_e_select_mode)
			_a_Stats.show()
			_a_Use.hide()
	_a_VBox.show()

func close():
	_a_VBox.hide()

func _update_stats(p_stats):
	_a_Stats_HP.set_text(str(p_stats.get_HP()))
	_a_Stats_SP.set_text(str(p_stats.get_SP()))
	_a_Stats_ATK.set_text(str(p_stats.get_ATK()))
	_a_Stats_MAG.set_text(str(p_stats.get_MAG()))
	_a_Stats_DEF.set_text(str(p_stats.get_DEF()))
	_a_Stats_SPEED.set_text(str(p_stats.get_SPEED()))
	_a_Stats_LUCK.set_text(str(p_stats.get_LUCK()))

func set_options_disabled(p_disabled):
	_a_Use.set_disabled(p_disabled)
	_a_Select.set_disabled(p_disabled)

func _on_Use_pressed():
	use_pressed.emit()

func _on_Select_pressed():
	select_pressed.emit()
