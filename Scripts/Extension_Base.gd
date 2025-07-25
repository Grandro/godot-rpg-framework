extends Object

var _a_entity = null

func _init(p_entity):
	_a_entity = p_entity
	
	p_entity.tree_exiting.connect(_on_Entity_tree_exiting)

func _on_Entity_tree_exiting():
	free.call_deferred()
