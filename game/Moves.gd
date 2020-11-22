const Move = preload("res://game/Move.gd")

enum MoveList {
	MELEE_T0,
	MELEE_T1,
	MELEE_T2,
	MELEE_T3,
	HEAL_T1,
	HEAL_T2,
	HEAL_T3,
	PSY_T1,
	PSY_T2,
	PSY_T3,
}

var _moves = null

func _init(moves):
	self._moves = moves

func get_move_by_id(move_id):
	if move_id < _moves.size():
		return _moves[move_id]
	return null
