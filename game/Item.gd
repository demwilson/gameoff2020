enum ItemType {
	BONUS,
	MOVE,
	ALLY,
	STAT,
}
enum ItemTier {
	GAME_START,
	LEVEL_ONE,
	LEVEL_TWO,
	LEVEL_THREE,
}

const GEAR_MODIFIER_TYPE = 0
const GEAR_MODIFIER_VALUE = 1


var id
var name
var tier
var type
var description
var modifier
var image = null

func _init(id, name, tier, type, description, modifier, image=null):
	self.id = id
	self.name = name
	self.tier = tier
	self.type = type
	self.description = description
	self.modifier = modifier
	self.image = image

func get_description():
	var modifier_text = ""
	match self.type:
		ItemType.BONUS:
			var modifier_amount = str(self.modifier[GEAR_MODIFIER_VALUE])
			var modifier_type = self.modifier[GEAR_MODIFIER_TYPE]
			modifier_text =  "+" + modifier_amount +" bonus to " + modifier_type + "."
		ItemType.STAT:
			var modifier_amount = str(self.modifier[GEAR_MODIFIER_VALUE])
			var modifier_type = self.modifier[GEAR_MODIFIER_TYPE]
			modifier_text =  "+" + modifier_amount +" to " + modifier_type + "."
		ItemType.MOVE:
			var move = Global.moves.get_move_by_id(self.modifier)
			modifier_text =  "This gives you the ability " + move.name + "."
			
	return self.description + ' ' + str(modifier_text)
