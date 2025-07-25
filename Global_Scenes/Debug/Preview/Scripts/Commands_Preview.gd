extends CanvasLayer

@onready var _a_Background = get_node("Background")
@onready var _a_Window = get_node("Window")
@onready var _a_Preview = get_node("Window/Contents/Preview")

func _ready():
	_a_Window.hidden.connect(_on_Window_hidden)
	Debug.closing.connect(_on_Debug_closing)
	
	_a_Background.hide()
	_a_Window.hide()

func open(p_cutscene_data, p_skip_idxs):
	_a_Preview.open()
	_a_Background.grab_focus()
	_a_Window.set_position(Vector2.ZERO)
	
	await get_tree().process_frame
	
	var preview_scene = _a_Preview.get_preview_scene()
	var cutscene_system_si = Global.get_singleton(preview_scene, "Cutscene_System")
	cutscene_system_si.cutscene_from_data(preview_scene, p_cutscene_data, 
										  "Main", p_skip_idxs)
	
	_a_Background.show()
	_a_Window.show()

func _on_Window_hidden():
	_a_Preview.close()
	_a_Background.hide()

func _on_Debug_closing():
	_a_Window.hide()
