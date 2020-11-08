class CombatCreature:
	var _name = null
	var _max_health = null
	var _health = null
	var _stats = null
	var _bonuses = null
	var _moves = null
	var _ticks = null

	func _init(name, max_health, health, attack=1, accuracy=1, speed=1, defense=1, dodge=1, attack_bonus=0, accuracy_bonus=0, dodge_bonus=0, defense_bonus=0):
		self._name = name
		self._max_health = max_health
		self._health = health
		self._stats = {
			"attack": attack,
			"accuracy": accuracy,
			"speed": speed,
			"defense": defense,
			"dodge": dodge,
		}
		self._bonuses = {
			"attack": attack_bonus,
			"accuracy": accuracy_bonus,
			"dodge": dodge_bonus,
			"defense": defense_bonus,
		}
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
		self._ticks = 0

	# name
	func get_name():
		return self._name
	func set_name(value):
		self._name = value

	# ticks
	func get_ticks():
		return self._ticks
	func set_ticks(value):
		self._ticks = value
	func add_ticks(value):
		self._ticks += value * self._stats.speed
	# health
	func get_health():
		return self._health
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

	func is_active():
		return self._health > 0

	func basic_damage(attack, atk_bonus, value):
		return (pow(attack * 2, value)) + (atk_bonus * value)
	func basic_accuracy(accuracy, acc_bonus):
		return 90 + pow(4, accuracy) + (1.5 * acc_bonus)
