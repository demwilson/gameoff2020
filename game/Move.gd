enum MoveType {
	DAMAGE,
	HEAL,
}

enum MoveFormula {
	BASE,
	MULTIPLIER,
}

enum AnimationPath {
	BASIC_ATTACK,
	FIREBOLT,
	HEAL,
}

enum AnimationDetail {
	BASE_NAME,
	VECTOR_OFFSET,
	HFRAMES,
	VFRAMES,
	SELF_TARGET,
}

const animation_details = [
	["melee_attack",  Vector2(-16, 8), 34, 1, false],
	["fireball_power_up", Vector2(-16, 8), 23, 1, false],
	["healing", Vector2(0, -32), 51, 1, true],
]

var name
var type
var level
var animation_path
var base
var low
var high
var damage
var accuracy

func _init(name, level, type, animation_path, low, high, damage, accuracy=null, base=null):
	self.name = name
	self.type = type
	self.level = level
	self.animation_path = animation_path
	self.base = base
	self.low = low
	self.high = high
	self.damage = damage
	self.accuracy = accuracy


static func calculate_damage(formula, stat, bonus, variance):
	return (formula[MoveFormula.BASE] + (formula[MoveFormula.MULTIPLIER] * stat) + bonus) * variance

static func calculate_accuracy(formula, stat, bonus):
	return formula[MoveFormula.BASE] + (formula[MoveFormula.MULTIPLIER] * stat) + bonus
