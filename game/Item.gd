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
}

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
