class Stats:
	var attack
	var accuracy
	var speed
	var evade
	var defense

	func _init(attack=0, accuracy=0, speed=0, defense=0, evade=0):
		self.attack = attack
		self.accuracy = accuracy
		self.speed = speed
		self.defense = defense
		self.evade = evade

class CombatCreature:
	var scene = null
	var is_queued = false
	var size = null

	var _name = null
	var _max_health = null
	var _health = null
	var _stats = null
	var _bonuses = null
	var _moves = null
	var _ticks = null

	func _init(name, scene, size, position, max_health, health, stats=null, bonuses=null):
		self._name = name
		self.size = size
		self._max_health = max_health
		self._health = health
		if stats:
			self._stats = stats
		else:
			self._stats = Stats.new(1, 1, 1, 1, 1)
		if bonuses:
			self._bonuses = bonuses
		else:
			self._bonuses = Stats.new(0, 0, 0, 0, 0)
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
		var processed_name = self._name
		if !self.is_active():
			processed_name += " (Dead)"
		return processed_name
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

	func is_active():
		return self._health > 0
	func update_health_percentage():
		var percentage = self.get_health_percentage()
		self.scene.health.value = percentage
	func update_ticks():
		var current_ticks = self.get_ticks()
		self.scene.ticks.value = current_ticks

	# TODO: Remove below once moves are created
	func basic_damage(attack, atk_bonus, value):
		return (pow(attack * 2, value)) + (atk_bonus * value)
	func basic_accuracy(accuracy, acc_bonus):
		return 90 + pow(4, accuracy) + (1.5 * acc_bonus)
