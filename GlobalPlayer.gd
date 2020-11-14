extends "res://creature/Creature.gd"

const Item = preload("res://Item.gd")

const ITEM_MODIFIER_TYPE = 0
const ITEM_MODIFIER_VALUE = 1

var _items = null
var _max_oxygen = null
var _oxygen = null

func _init(name, max_health, health, max_oxygen, oxygen, stats=null, bonuses=null, items=null).(name, max_health, health, stats, bonuses):
	self._max_oxygen = max_oxygen
	self._oxygen = oxygen
	if items:
		self._items = items
	else:
		self._items = []

# items
func add_item(item):
	self._items.append(item)

func get_stat(type):
	var bonus = .get_stat(type)
	for item in self._items:
		if item.type == Item.ItemType.STAT && item.modifier[ITEM_MODIFIER_TYPE] == type:
				bonus += item.modifier[ITEM_MODIFIER_VALUE]
	return bonus

func get_bonus(type):
	var bonus = .get_bonus(type)
	for item in self._items:
		if item.type == Item.ItemType.BONUS && item.modifier[ITEM_MODIFIER_TYPE] == type:
				bonus += item.modifier[ITEM_MODIFIER_VALUE]
	return bonus

func get_combat_stats():
	if !self._stats:
		return Stats.new()

	var processed = []
	var properties = self._stats.get_properties()
	for property in properties:
		processed.append(self.get_stat(property))
	return Stats.new(processed)

func get_combat_bonuses():
	if !self._bonuses:
		return Stats.new()

	var processed = []
	var properties = self._bonuses.get_properties()
	for property in properties:
		processed.append(self.get_bonus(property))
	return Stats.new(processed)