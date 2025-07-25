extends CanvasLayer

var _a_Chapter_Entry_Scene = preload("res://Global_Scenes/Debug/General/Change_Chapter/Chapter_Entry.tscn")

@onready var _a_Return = get_node("Control/VBox/Return")
@onready var _a_Chapters = get_node("Control/VBox/Scroll/Chapters/VBox")
@onready var _a_Chapters_Heading = get_node("Control/VBox/Scroll/Chapters/Heading")
@onready var _a_Curr = get_node("Control/VBox/Scroll/Chapters/Curr/Value")

func _ready():
	_a_Return.pressed.connect(_on_Return_pressed)
	Databases.data_loaded.connect(_on_Databases_data_loaded)
	
	_a_Chapters_Heading.set_text("[center][u]%s" % tr("DEBUG_GENERAL_CHAPTERS"))
	
	close()

func open():
	var progress_si = Global.get_singleton(self, "Progress")
	var chapter = progress_si.get_chapter()
	for child in _a_Chapters.get_children():
		var child_chapter = child.get_text()
		var same_chapter = child_chapter == chapter
		child.set_visible(!same_chapter)
	
	_a_Curr.set_text(chapter)
	
	show()

func close():
	hide()

func _create_chapter_list():
	var chapters = Progress.get_chapters()
	for chapter in chapters:
		var instance = _a_Chapter_Entry_Scene.instantiate()
		instance.pressed.connect(_on_Chapter_Select_pressed.bind(chapter))
		instance.set_text(chapter)
		
		_a_Chapters.add_child(instance)

func _on_Return_pressed():
	close()

func _on_Databases_data_loaded():
	_create_chapter_list()

func _on_Chapter_Select_pressed(p_chapter):
	Progress.change_chapter(p_chapter)
	close()
