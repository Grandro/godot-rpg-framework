extends CanvasLayer

signal command_selected(p_command)
signal closed()

@onready var _a_Window = get_node("Window")
@onready var _a_Movement_Heading = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Movement/Heading")
@onready var _a_Set_Move_Route = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Movement/VBox/Set_Move_Route")
@onready var _a_Change_Dir = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Movement/VBox/Change_Dir")
@onready var _a_Tween = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Movement/VBox/Tween")
@onready var _a_Play_Anim = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Movement/VBox/Play_Anim")
@onready var _a_Teleport_Object = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Movement/VBox/Teleport_Object")
@onready var _a_Jump = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Movement/VBox/Jump")
@onready var _a_Camera_Heading = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Camera/Heading")
@onready var _a_Move_Free_Camera = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Camera/VBox/Move_Free_Camera")
@onready var _a_Change_Camera = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Camera/VBox/Change_Camera")
@onready var _a_Flow_Control_Heading = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Flow_Control/Heading")
@onready var _a_Cond_Branch = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Flow_Control/VBox/Cond_Branch")
@onready var _a_Match = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Flow_Control/VBox/Match")
@onready var _a_Loop = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Flow_Control/VBox/Loop")
@onready var _a_Sub_Process = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Flow_Control/VBox/Sub_Process")
@onready var _a_Wait_For_Sub_Process = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Flow_Control/VBox/Wait_For_Sub_Process")
@onready var _a_Exit_Cutscene = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Flow_Control/VBox/Exit_Cutscene")
@onready var _a_Items_Heading = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Items/Heading")
@onready var _a_Change_Item_Amount = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Items/VBox/Change_Item_Amount")
@onready var _a_Change_Equipable = get_node("Window/Contents/Margin/Tab/1/HSplit/Left/Items/VBox/Change_Equipable")
@onready var _a_Timing_Heading = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Timing/Heading")
@onready var _a_Wait = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Timing/VBox/Wait")
@onready var _a_Audio_Heading = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Audio/Heading")
@onready var _a_Play_Audio = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Audio/VBox/Play_Audio")
@onready var _a_Misc_Heading = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Misc/Heading")
@onready var _a_Script = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Misc/VBox/Script")
@onready var _a_Change_State = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Misc/VBox/Change_State")
@onready var _a_Show_Dialogue = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Misc/VBox/Show_Dialogue")
@onready var _a_Show_Popup = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Misc/VBox/Show_Popup")
@onready var _a_Show_Overlay = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Misc/VBox/Show_Overlay")
@onready var _a_Teleport = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Misc/VBox/Teleport")
@onready var _a_Change_Visibility = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Misc/VBox/Change_Visibility")
@onready var _a_Comment = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Misc/VBox/Comment")
@onready var _a_Default_Object_Key = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Misc/VBox/Default_Object_Key")
@onready var _a_Disable_Object = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Misc/VBox/Disable_Object")
@onready var _a_Change_Cutscene_Args = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Misc/VBox/Change_Cutscene_Args")
@onready var _a_Change_Dialogue_Args = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Misc/VBox/Change_Dialogue_Args")
@onready var _a_Change_Cutscene_Args_Idx = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Misc/VBox/Change_Cutscene_Args_Idx")
@onready var _a_Change_Dialogue_Args_Idx = get_node("Window/Contents/Margin/Tab/1/HSplit/Right/Misc/VBox/Change_Dialogue_Args_Idx")

func _ready():
	_a_Window.closed.connect(_on_Window_closed)
	
	_connect_commands()
	_update_heading_trans()
	
	_a_Window.show()
	hide()

func update_trans():
	_a_Set_Move_Route.set_text(tr("DEBUG_CUTSCENES_COMMANDS_SET_MOVE_ROUTE"))
	_a_Change_Dir.set_text(tr("DEBUG_CUTSCENES_COMMANDS_CHANGE_DIR"))
	_a_Tween.set_text(tr("DEBUG_CUTSCENES_COMMANDS_TWEEN"))
	_a_Play_Anim.set_text(tr("DEBUG_CUTSCENES_COMMANDS_PLAY_ANIM"))
	_a_Teleport_Object.set_text(tr("DEBUG_CUTSCENES_COMMANDS_TELEPORT_OBJECT"))
	_a_Jump.set_text(tr("DEBUG_CUTSCENES_COMMANDS_JUMP"))
	_a_Move_Free_Camera.set_text(tr("DEBUG_CUTSCENES_COMMANDS_MOVE_FREE_CAMERA"))
	_a_Change_Camera.set_text(tr("DEBUG_CUTSCENES_COMMANDS_CHANGE_CAMERA"))
	_a_Cond_Branch.set_text(tr("DEBUG_CUTSCENES_COMMANDS_COND_BRANCH"))
	_a_Match.set_text(tr("DEBUG_CUTSCENES_COMMANDS_MATCH"))
	_a_Loop.set_text(tr("DEBUG_CUTSCENES_COMMANDS_LOOP"))
	_a_Sub_Process.set_text(tr("DEBUG_CUTSCENES_COMMANDS_SUB_PROCESS"))
	_a_Wait_For_Sub_Process.set_text(tr("DEBUG_CUTSCENES_COMMANDS_WAIT_FOR_SUB_PROCESS"))
	_a_Exit_Cutscene.set_text(tr("DEBUG_CUTSCENES_COMMANDS_EXIT_CUTSCENE"))
	_a_Change_Item_Amount.set_text(tr("DEBUG_CUTSCENES_COMMANDS_CHANGE_ITEM_AMOUNT"))
	_a_Change_Equipable.set_text(tr("DEBUG_CUTSCENES_COMMANDS_CHANGE_EQUIPABLE"))
	_a_Wait.set_text(tr("DEBUG_CUTSCENES_COMMANDS_WAIT"))
	_a_Play_Audio.set_text(tr("DEBUG_CUTSCENES_COMMANDS_PLAY_AUDIO"))
	_a_Script.set_text(tr("DEBUG_CUTSCENES_COMMANDS_SCRIPT"))
	_a_Change_State.set_text(tr("DEBUG_CUTSCENES_COMMANDS_CHANGE_STATE"))
	_a_Show_Dialogue.set_text(tr("DEBUG_CUTSCENES_COMMANDS_SHOW_DIALOGUE"))
	_a_Show_Popup.set_text(tr("DEBUG_CUTSCENES_COMMANDS_SHOW_POPUP"))
	_a_Show_Overlay.set_text(tr("DEBUG_CUTSCENES_COMMANDS_SHOW_OVERLAY"))
	_a_Teleport.set_text(tr("DEBUG_CUTSCENES_COMMANDS_TELEPORT"))
	_a_Change_Visibility.set_text(tr("DEBUG_CUTSCENES_COMMANDS_CHANGE_VISIBILITY"))
	_a_Comment.set_text(tr("DEBUG_CUTSCENES_COMMANDS_COMMENT"))
	_a_Default_Object_Key.set_text(tr("DEBUG_CUTSCENES_COMMANDS_DEFAULT_OBJECT_KEY"))
	_a_Disable_Object.set_text(tr("DEBUG_CUTSCENES_COMMANDS_DISABLE_OBJECT"))
	_a_Change_Cutscene_Args.set_text(tr("DEBUG_CUTSCENES_COMMANDS_CHANGE_CUTSCENE_ARGS"))
	_a_Change_Dialogue_Args.set_text(tr("DEBUG_CUTSCENES_COMMANDS_CHANGE_DIALOGUE_ARGS"))
	_a_Change_Cutscene_Args_Idx.set_text(tr("DEBUG_CUTSCENES_COMMANDS_CHANGE_CUTSCENE_ARGS_IDX"))
	_a_Change_Dialogue_Args_Idx.set_text(tr("DEBUG_CUTSCENES_COMMANDS_CHANGE_DIALOGUE_ARGS_IDX"))
	
	_update_heading_trans()

func _update_heading_trans():
	_a_Movement_Heading.set_text("[u][center]%s" % tr("DEBUG_CUTSCENES_COMMANDS_LIST_MOVEMENT"))
	_a_Camera_Heading.set_text("[u][center]%s" % tr("DEBUG_CUTSCENES_COMMANDS_LIST_CAMERA"))
	_a_Flow_Control_Heading.set_text("[u][center]%s" % tr("DEBUG_CUTSCENES_COMMANDS_LIST_FLOW_CONTROL"))
	_a_Items_Heading.set_text("[u][center]%s" % tr("DEBUG_CUTSCENES_COMMANDS_LIST_ITEMS"))
	_a_Timing_Heading.set_text("[u][center]%s" % tr("DEBUG_CUTSCENES_COMMANDS_LIST_TIMING"))
	_a_Audio_Heading.set_text("[u][center]%s" % tr("DEBUG_CUTSCENES_COMMANDS_LIST_AUDIO"))
	_a_Misc_Heading.set_text("[u][center]%s" % tr("DEBUG_CUTSCENES_COMMANDS_LIST_MISC"))

func open():
	_a_Window.show()
	show()

func close():
	_a_Window.hide()
	hide()
	closed.emit()

func _connect_commands():
	var instances = get_tree().get_nodes_in_group("Cutscene_Command")
	for instance in instances:
		# Fix for Commands_List in Cutscenes/Stater
		if instance.get_owner() == self:
			instance.pressed.connect(_on_Command_pressed.bind(instance))

func _on_Window_closed():
	close()

func _on_Command_pressed(p_instance):
	var command = p_instance.get_command()
	command_selected.emit(command)
