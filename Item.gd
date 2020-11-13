enum ItemType {
    STAT,
    ALLY,
    MOVE,
    BONUS
}
var name
var type
var description
var modifier
var image = null

func _init(name, type, description, modifier, image=null):
    self.name = name
    self.type = type
    self.description = description
    self.modifier = modifier
    self.image = image