const Move = preload("res://game/Move.gd")

enum MoveList {
	BASIC_ATTACK,
	FIREBOLT,
	FIREBALL,
	HEAL,
}

var _moves = null

func _init(moves):
	self._moves = moves

func get_move_by_id(move_id):
	if move_id < _moves.size():
		return _moves[move_id]
	return null
