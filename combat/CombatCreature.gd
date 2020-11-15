extends "res://game/Creature.gd"

const Move = preload("res://game/Move.gd")

const TEXTURE_FILE_EXTENSION = ".png"
const ANIMATION_FILE_EXTENSION = ".tres"

var scene = null
var is_queued = false
var _ticks = null
var _moves = null

func _init(tier, name, scene, size, position, max_health, health, moves, stats, bonuses, base_path, behavior).(tier, name, size, max_health, health, stats, bonuses, base_path, behavior):
	self._ticks = 0
	self._moves = moves

	# Setup Scene
	scene.set("position", position)
	scene.creature_name = self._name
	scene.show_name = true
	scene.creature_size = self.size
	scene.texture_path = file_paths[base_path] + str(tier) + TEXTURE_FILE_EXTENSION
	scene.idle_path = file_paths[base_path] + str(tier) + ANIMATION_FILE_EXTENSION
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
func get_move(position=null):
	var move
	if position:
		move = self._moves[position]
	else:
		move = self._moves[randi() % self._moves.size()]
	return move

func is_active():
	return self._health > 0
func update_health_percentage():
	var percentage = self.get_health_percentage()
	self.scene.health.value = percentage
func update_ticks():
	var current_ticks = self.get_ticks()
	self.scene.ticks.value = current_ticks

func choose_move():
	self._moves[randi() % self._moves]

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
