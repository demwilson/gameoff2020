const Move = preload("res://game/Move.gd")

enum MoveList {
	BASIC_ATTACK,
	FIREBOLT,
	FIREBALL,
	HEAL,
}

var moves = null

func _init():
	self.moves = [
		Move.new("Basic Attack", 1, Move.MoveType.DAMAGE, 1, 2, [0, 2], [90, 1, 2]),
		Move.new("Firebolt", 1, Move.MoveType.DAMAGE, 1, 5, [0, 2], [95, 0, 1]),
		Move.new("Fireball", 2, Move.MoveType.DAMAGE, 1, 2, [25, 2], [50, 4, 1.5], MoveList.FIREBOLT),
		Move.new("Heal", 1, Move.MoveType.HEAL, 1, 2, [0, 2]),
	]

func get_move_by_id(move_id):
	if move_id < moves.size():
		return moves[move_id]
	return null
