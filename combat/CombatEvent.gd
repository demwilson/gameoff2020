class CombatEvent:
	var action_type = null
	var creature = null
	var target = null

	func _init(action_type, creature, target):
		self.action_type = action_type
		self.creature = creature
		self.target = target
