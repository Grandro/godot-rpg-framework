extends Node
class_name PropertySorter

static func sort(p_parent, p_method_name, p_rel):
	var sort_arr = []
	var children = p_parent.get_children()
	for child in children:
		var value = child.call(p_method_name)
		sort_arr.push_back([value, child])
	sort_arr.sort_custom(Callable(Global, "sort_%s" % p_rel.to_lower()))
	
	for i in sort_arr.size():
		var child = sort_arr[i][1]
		p_parent.move_child(child, i)
