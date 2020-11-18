extends "res://game/Creature.gd"

const Move = preload("res://game/Move.gd")

enum CombatantType {
	ENEMY,
	ALLY,
}

var scene = null
var is_queued = false
var _ticks = null
var _moves = null
var type = null

func _init(type, name, scene, size, max_health, health, moves, stats, bonuses, base_path, behavior).(name, size, max_health, health, stats, bonuses, base_path, behavior):
	self.type = type
	self._ticks = 0
	self._moves = moves
	self.scene = scene

# name
func get_name():
	var processed_name = .get_name()
	if !self.is_active():
		processed_name += " (Dead)"
	return processed_name
# ticks
func get_ticks():
	return self._ticks
func set_ticks(value):
	self._ticks = value
func add_ticks(value):
	self._ticks += value * self._stats.speed
# moves
func get_moves():
	return self._moves
func get_move(position=null):
	var move
	if position:
		move = self._moves[position]
	else:
		move = self._moves[randi() % self._moves.size()]
	return move
func choose_move():
	self._moves[randi() % self._moves]

func is_active():
	return self._health > 0
func update_health_percentage():
	var percentage = self.get_health_percentage()
	self.scene.health.value = percentage
func update_ticks():
	var current_ticks = self.get_ticks()
	self.scene.ticks.value = current_ticks

func choose_target(move, target_list):
	var target = null
	if move.type == Move.MoveType.HEAL:
		target = self
	else:
		match self._behavior:
#            Behavior.STUPID:
			_:
				while target == null:
					var target_position = randi() % target_list.size()
					var potential_target = target_list[target_position]
					if potential_target.is_active():
						target = potential_target
	return target
