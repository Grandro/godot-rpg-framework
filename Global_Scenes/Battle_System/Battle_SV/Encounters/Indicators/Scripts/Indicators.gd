extends Node3D

@onready var _a_Enemy_Select = get_node("Enemy_Select")
@onready var _a_Command_Circle = get_node("Command_Circle")
@onready var _a_Reaction = get_node("Reaction")
@onready var _a_Specials_Menu = get_node("Specials_Menu")

func open_enemy_select():
	_a_Enemy_Select.open()

func close_enemy_select():
	_a_Enemy_Select.close()

func update_enemy_select(p_instance, p_init):
	_a_Enemy_Select.update(p_instance, p_init)

func open_command_circle(p_pos):
	_a_Command_Circle.open(p_pos)

func close_command_circle():
	_a_Command_Circle.close()

func open_reaction(p_reactions):
	_a_Reaction.open(p_reactions)

func close_reaction():
	_a_Reaction.close()

func open_specials_menu():
	_a_Specials_Menu.open()

func close_specials_menu():
	_a_Specials_Menu.close()

func set_command_circle_command_text(p_text):
	_a_Command_Circle.set_command_text(p_text)
