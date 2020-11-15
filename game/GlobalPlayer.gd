extends "res://game/Creature.gd"

const Item = preload("res://game/Item.gd")

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
func get_items():
	return self._items
func add_item(item):
	self._items.append(item)
func add_items(items):
	for item in items:
		self._items.append(item)
# oxygen
func get_oxygen():
	return self._oxygen
func get_max_oxygen():
	return self._max_oxygen
func get_oxygen_percentage():
	return (self._oxygen / self._max_oxygen) * 100
func set_oxygen(value):
	if value > self._max_oxygen:
		value = self._max_oxygen
	elif value < 0:
		value = 0
	self._oxygen = value
func add_oxygen(value):
	self.set_oxygen(self._oxygen + value)

func get_stat(type):
	var bonus = .get_stat(type)
	for item_id in self._items:
		var item = Global.items.get_item_by_id(item_id)
		if item.type == Item.ItemType.STAT && item.modifier[ITEM_MODIFIER_TYPE] == type:
				bonus += item.modifier[ITEM_MODIFIER_VALUE]
	return bonus

func get_bonus(type):
	var bonus = .get_bonus(type)
	for item_id in self._items:
		var item = Global.items.get_item_by_id(item_id)
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

func get_combat_moves():
	var moves = []
	for item_id in self._items:
		var item = Global.items.get_item_by_id(item_id)
		if item.type == Item.ItemType.MOVE:
				moves.append(item.modifier)
	return moves
