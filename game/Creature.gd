enum CreatureSize {
	NONE,
	MEDIUM,
	LARGE_TALL,
	LARGE_WIDE,
	LARGE,
}

const Stats = preload("res://game/Stats.gd")

const BASE_BONUSES = [0, 0, 0, 0, 0]
const BASE_STATS = [1, 1, 1, 1, 1]

var _name = null
var _max_health = null
var _health = null
var _stats = null
var _bonuses = null

func _init(name, max_health, health, stats, bonuses):
	self._name = name
	self._max_health = max_health
	self._health = health
	self._stats = stats
	self._bonuses = bonuses

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
