extends "res://game/Creature.gd"

const Move = preload("res://game/Move.gd")

enum CombatantType {
	ENEMY,
	ALLY,
}

const MAX_RANDOM_TARGET = 10

var scene = null
var is_queued = false
var _ticks = null
var _moves = null
var type = null
var _current_target = null

func _init(type, name, scene, size, max_health, health, moves, stats, bonuses, base_path, behavior).(name, size, max_health, health, stats, bonuses, base_path, behavior):
	self.type = type
	self._ticks = 0
	self._moves = moves
	self.scene = scene

# name
func get_name():
	var processed_name = .get_name()
	if !self.is_alive():
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
		move = self._moves[Global.random.randi() % self._moves.size()]
	return move
func choose_move():
	self._moves[Global.random.randi() % self._moves]

func is_alive():
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
		return self
	else:
		match self._behavior:
			Behavior.FOCUSED:
				if _current_target && _current_target.is_alive():
					target = _current_target
				else:
					target = get_target_by_random(target_list)
			Behavior.PACK:
				target = get_target_by_lowest_health(target_list)
			Behavior.BOSS:
				if _current_target && _current_target.is_alive():
					target = _current_target
				elif target_list[Global.PLAYER_POSITION_COMBAT].is_alive():
					target = target_list[Global.PLAYER_POSITION_COMBAT]
				else:
					target = get_target_by_random(target_list)
			_: # Behavior.STUPID
				target = get_target_by_random(target_list)
	_current_target = target
	return target

func get_target_by_random(target_list):
	var target_list_size = target_list.size()
	for _i in range(MAX_RANDOM_TARGET):
		var target_position = Global.random.randi() % target_list_size
		var potential_target = target_list[target_position]
		if potential_target.is_alive():
			return potential_target
	while target_list_size > 0:
		var target = target_list[target_list_size - 1]
		if target.is_alive():
			return target
		target_list_size -= 1
	# If everything failed, target no one
	return null
	
func get_target_by_lowest_health(target_list):
	var target_list_size = target_list.size()
	var target = null
	for i in range(target_list_size):
		var possible_target = target_list[i]
		if !target || possible_target.get_health() <= target.get_health():
			target = possible_target
	return target
