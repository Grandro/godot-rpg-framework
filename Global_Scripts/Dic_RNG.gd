extends Object
class_name DicRNG

var _a_dic = null
var _a_total_values = 0

func roll_key():
	var rolled_key = null
	var rndm = randi() % _a_total_values + 1
	var value = 0
	for key in _a_dic:
		value += _a_dic[key]
		if rndm <= value:
			rolled_key = key
			break
	
	return rolled_key

func set_dic(p_dic):
	_a_dic = p_dic
	
	_a_total_values = 0
	for value in p_dic.values():
		_a_total_values += value
