extends Node3D

func get_place_pos(p_amount):
	var place_pos = []
	var parent = get_child(p_amount - 1)
	for child in parent.get_children():
		var pos = child.get_position()
		place_pos.append(pos)
	
	return place_pos
