extends "res://game/Creature.gd"

var id = null
var _tier = null
var _moves = null

func _init(id, tier, name, size, max_health, health, stats, bonuses, base_path, behavior, moves).(name, size, max_health, health, stats, bonuses, base_path, behavior):
	self.id = id
	self._moves = moves
	self._tier = tier

# tier
func get_tier():
	return self._tier
func get_moves():
	return self._moves
func get_stats():
	return self._stats
func get_bonuses():
	return self._bonuses
