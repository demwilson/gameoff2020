extends "res://game/Creature.gd"

const Item = preload("res://game/Item.gd")

const ITEM_MODIFIER_TYPE = 0
const ITEM_MODIFIER_VALUE = 1

var _items = null
var _max_oxygen = null
var _oxygen = null
var _combat_count = 0

func _init(name, size, max_health, health, max_oxygen, oxygen, stats, bonuses, items, base_path, behavior=Behavior.PLAYER, tier="").(tier, name, size, max_health, health, stats, bonuses, base_path, behavior):
	self._max_oxygen = max_oxygen
	self._oxygen = oxygen
	self._items = items

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
	var fOxygen = float(self._oxygen)
	var fMaxOxygen = float(self._max_oxygen)
	var fpercentage = (fOxygen / fMaxOxygen) * 100
	return int(fpercentage)
func set_oxygen(value):
	if value > self._max_oxygen:
		value = self._max_oxygen
	elif value < 0:
		value = 0
	self._oxygen = value
func add_oxygen(value):
	self.set_oxygen(self._oxygen + value)

func get_combat_count():
	return self._combat_count
func add_combat_count(value):
	self.set_combat_count(self._combat_count + value)
func set_combat_count(value):
	self._combat_count = value

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

func get_stats():
	if !self._stats:
		return Stats.new()

	var processed = []
	var properties = self._stats.get_properties()
	for property in properties:
		processed.append(self.get_stat(property))
	return Stats.new(processed)

func get_bonuses():
	if !self._bonuses:
		return Stats.new()

	var processed = []
	var properties = self._bonuses.get_properties()
	for property in properties:
		processed.append(self.get_bonus(property))
	return Stats.new(processed)

func get_moves():
	var moves = []
	for item_id in self._items:
		var item = Global.items.get_item_by_id(item_id)
		if item.type == Item.ItemType.MOVE:
				moves.append(item.modifier)
	return moves

func get_allies():
	var allies = []
	for item_id in self._items:
		var item = Global.items.get_item_by_id(item_id)
		if item.type == Item.ItemType.ALLY:
				allies.append(item.modifier)
	return allies
