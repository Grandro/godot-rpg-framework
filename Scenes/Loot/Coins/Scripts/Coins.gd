extends MarginContainer

@onready var _a_Curr = get_node("Margin/Curr/Text")
@onready var _a_Gain = get_node("Margin/Gain/Text")
@onready var _a_Audio_Gain = get_node("Audio/Gain")

var _a_curr_coins = -1
var _a_gain_coins = -1

func open(p_loot):
	var global_si = Global.get_singleton(self, "Global")
	_a_curr_coins = global_si.get_coins()
	_a_gain_coins = 0
	if p_loot.has("$Coins"):
		_a_gain_coins = p_loot["$Coins"]
	
	global_si.change_coins_amount(_a_gain_coins)
	_a_Curr.set_text(str(_a_curr_coins))
	_a_Gain.set_text(str(_a_gain_coins))

func count_up():
	if _a_gain_coins == 0:
		return
	
	var new_coins = _a_curr_coins + _a_gain_coins
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_method(_set_curr_coins_text, _a_curr_coins, new_coins, 1.0)

func _set_curr_coins_text(p_coins):
	if _a_curr_coins == p_coins:
		return
	
	_a_curr_coins = p_coins
	_a_Curr.set_text(str(p_coins))
	_a_Audio_Gain.play()
