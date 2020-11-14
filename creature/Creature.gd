const Stats = preload("res://creature/Stats.gd")

const BASE_BONUSES = [0, 0, 0, 0, 0]
const BASE_STATS = [1, 1, 1, 1, 1]

var _name = null
var _max_health = null
var _health = null
var _stats = null
var _bonuses = null
var _moves = null

func _init(name, max_health, health, stats=null, bonuses=null):
	self._name = name
	self._max_health = max_health
	self._health = health
	if stats:
		self._stats = stats
	else:
		self._stats = Stats.new(BASE_STATS)
	if bonuses:
		self._bonuses = bonuses
	else:
		self._bonuses = Stats.new(BASE_BONUSES)
	
	# TODO: Replace with actual moves
	self._moves = [
		{
			"name": "Basic Attack",
			"level": 1,
			"damage": funcref(self, "basic_damage"),
			"low": 1,
			"high": 2,
			"accuracy": funcref(self, "basic_accuracy"),
		}
	]

# name
func get_name():
	return self._name
func set_name(value):
	self._name = value
# health
func get_health():
	return self._health
func get_max_health():
	return self._max_health
func get_health_percentage():
	return (self._health / self._max_health) * 100
func set_health(value):
	if value > self._max_health:
		value = self._max_health
	elif value < 0:
		value = 0
	self._health = value
	if self._health <= 0:
		self._ticks = 0
func add_health(value):
	self.set_health(self._health + value)
# stats
func get_stat(type):
	return self._stats[type]
# bonuses
func get_bonus(type):
	return self._bonuses[type]
# moves
func get_move(position=null):
	var move
	if position:
		move = self._moves[position]
	else:
		move = self._moves[randi() % self._moves.size()]
	return move

# TODO: Remove below once moves are created
func basic_damage(attack, atk_bonus, value):
	return (pow(attack * 2, value)) + (atk_bonus * value)
func basic_accuracy(accuracy, acc_bonus):
	return 90 + pow(4, accuracy) + (1.5 * acc_bonus)
