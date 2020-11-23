enum StatType {
	ATTACK,
	ACCURACY,
	SPEED,
	DEFENSE,
	EVADE
}

const ATTACK = "attack"
const ACCURACY = "accuracy"
const SPEED = "speed"
const DEFENSE = "defense"
const EVADE = "evade"
const StatTypeMap = ["Attack", "Accuracy", "Speed", "Defense", "Evade"]

var attack
var accuracy
var speed
var evade
var defense

func _init(initial_arg=0, accuracy=0, speed=0, defense=0, evade=0):
	if typeof(initial_arg) == TYPE_ARRAY:
		self.attack = initial_arg[StatType.ATTACK]
		self.accuracy = initial_arg[StatType.ACCURACY]
		self.speed = initial_arg[StatType.SPEED]
		self.defense = initial_arg[StatType.DEFENSE]
		self.evade = initial_arg[StatType.EVADE]
	else:
		self.attack = initial_arg
		self.accuracy = accuracy
		self.speed = speed
		self.defense = defense
		self.evade = evade

func get_properties():
	return [ATTACK, ACCURACY, SPEED, DEFENSE, EVADE]
