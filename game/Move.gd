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
	ACID_SPIT,
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
	["acid_spit", Vector2(-16, 8), 43, 1, false],
]

var id
var name
var type
var level
var animation_path
var previous_tiers
var low
var high
var damage
var accuracy

func _init(id, name, level, type, animation_path, low, high, damage, accuracy=null, previous_tiers=null):
	self.id = id
	self.name = name
	self.type = type
	self.level = level
	self.animation_path = animation_path
	self.previous_tiers = previous_tiers
	self.low = low
	self.high = high
	self.damage = damage
	self.accuracy = accuracy


static func calculate_damage(formula, stat, bonus, variance):
	return (formula[MoveFormula.BASE] + (formula[MoveFormula.MULTIPLIER] * stat) + bonus) * variance

static func calculate_accuracy(formula, stat, bonus):
	var accuracy_calculation = formula[MoveFormula.BASE] + (formula[MoveFormula.MULTIPLIER] * stat) + bonus
	Global.log(Global.LogLevel.TRACE, "ACCURACY: " + str(accuracy_calculation))
	return accuracy_calculation
