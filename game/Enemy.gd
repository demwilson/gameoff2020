extends "res://game/Creature.gd"

var _moves = null

func _init(tier, name, size, max_health, health, stats, bonuses, base_path, behavior, moves).(tier, name, size, max_health, health, stats, bonuses, base_path, behavior):
	self._moves = moves

func get_moves():
	return self._moves
func get_stats():
	return self._stats
func get_bonuses():
	return self._bonuses
