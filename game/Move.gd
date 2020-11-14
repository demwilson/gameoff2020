enum MoveType {
	DAMAGE,
	HEAL,
}

enum MoveFormula {
	BASE,
	POW,
	MULTIPLIER
}

var name
var type
var level
var base
var low
var high
var damage
var accuracy

func _init(name, level, type, low, high, damage, accuracy=null, base=null):
	self.name = name
	self.type = type
	self.level = level
	self.base = base
	self.low = low
	self.high = high
	self.damage = damage
	self.accuracy = accuracy


static func calculate_damage(formula, stat, bonus, value):
	return formula[MoveFormula.BASE] + pow((formula[MoveFormula.POW] * stat), value) + (bonus * value)

static func calculate_accuracy(formula, stat, bonus):
	return formula[MoveFormula.BASE] + pow(formula[MoveFormula.POW], stat) + (formula[MoveFormula.MULTIPLIER] * bonus)
