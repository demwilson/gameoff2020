extends "res://game/Creature.gd"

var scene = null
var is_queued = false
var size = null
var _ticks = null
var _moves = null

func _init(name, scene, size, position, max_health, health, moves, stats, bonuses).(name, max_health, health, stats, bonuses):
	self.size = size
	self._ticks = 0
	self._moves = moves

	# Setup Scene
	scene.set("position", position)
	scene.creature_name = self._name
	scene.show_name = true
	scene.creature_size = self.size
	# TODO: determine by creature type
	if name == Global.PLAYER_NAME:
		scene.texture_path = "res://assets/Tony_Created_Assets/astro_idle.png"
		scene.idle_path = "combat/animations/astronaut_idle.tres"
	else:
		scene.texture_path = "res://assets/dead_hue.png"
		scene.idle_path = "combat/animations/hue_idle.tres"
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
