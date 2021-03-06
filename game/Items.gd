const Item = preload("res://game/Item.gd")
const Move = preload("res://game/Move.gd")
const LootItem = preload("res://game/LootItem.gd")

enum LootType {
	GEAR,
	OXYGEN,
	CURRENCY
}

enum ItemList {
	MELEE_T0 = 0,
	MELEE_T1 = 11,
	MAGIC_T1 = 12,
	HEAL_T1 = 13,
	MELEE_T2 = 24,
	MAGIC_T2 = 25,
	HEAL_T2 = 26,
	MELEE_T3 = 36,
	MAGIC_T3 = 37,
	HEAL_T3 = 38,
	BOSS_KEY = 39,
}

const BEST_MELEE_DESCENDING = [ItemList.MELEE_T3, ItemList.MELEE_T2, ItemList.MELEE_T1, ItemList.MELEE_T0]
const BEST_MAGIC_DESCENDING = [ItemList.MAGIC_T3, ItemList.MAGIC_T2, ItemList.MAGIC_T1]
const BEST_HEAL_DESCENDING = [ItemList.HEAL_T3, ItemList.HEAL_T2, ItemList.HEAL_T1]

const LootTypeMap = [
	"GEAR",
	"OXYGEN",
	"CURRENCY"
]

# List positions match LootType enum
const LOOT_CHANCE = 80
const LOOT_CHANCE_MAX_RAND = 100
const LOOT_PROBABILITY_WEIGHTS = [60, 25, 15]
# list positions match ItemType enum in Item
const ITEM_PROBABILITY_WEIGHTS = [75, 15, 5, 5]

const CURRENCY_BASE = 10
const OXYGEN_BASE = 5
const GEAR_COUNT_BASE = 1
const DEFAULT_MULTIPLIER = 1
const DEFAULT_COUNT = 1

var _items = null

func _init(items):
	self._items = items

func generate_combat_loot(tier_level, last_combat_enemies=DEFAULT_COUNT):
	var item_count = 0
	# Check if each enemy will drop loot
	for _i in range(last_combat_enemies):
		var rand = get_random_count(LOOT_CHANCE_MAX_RAND)
		if rand <= LOOT_CHANCE:
			item_count += 1
	var loot_bag = generate_loot(tier_level, item_count)
	# Add the guaranteed currency for the combat
	var combat_currency = LootItem.new(LootType.CURRENCY, tier_level * last_combat_enemies)
	loot_bag.append(combat_currency)
	Global.log(Global.LogLevel.TRACE, "[generate_combat_loot] Combat Loot Bag Size: " + str(loot_bag.size()))
	return loot_bag

func generate_loot(tier_level, item_count=DEFAULT_COUNT):
	var loot_type = Global.get_random_type_by_weight(LOOT_PROBABILITY_WEIGHTS)
	var loot_bag = []
	for _i in range(item_count):
		var loot = null
		match loot_type:
			LootType.GEAR:
				var item = generate_items(tier_level)
				loot = LootItem.new(loot_type, item[0])
			LootType.OXYGEN:
				loot = LootItem.new(loot_type, get_random_count(OXYGEN_BASE, tier_level))
			LootType.CURRENCY:
				loot = LootItem.new(loot_type, get_random_count(CURRENCY_BASE, tier_level))
		if loot:
			loot_bag.append(loot)
		Global.log(Global.LogLevel.TRACE, "[generate_loot] Type: " + LootTypeMap[loot.type] + " | Loot: " + str(loot.item))
	Global.log(Global.LogLevel.INFO, "[generate_loot] Loot Bag Size: " + str(loot_bag.size()))
	return loot_bag

func apply_loot_bag(loot_bag, player):
	for loot in loot_bag:
		match loot.type:
			LootType.GEAR:
				player.add_item(loot.item.id)
				if loot.item.id == ItemList.BOSS_KEY:
					player.set_floor_key(true)
			LootType.OXYGEN:
				player.add_oxygen(loot.item)
			LootType.CURRENCY:
				Global.currency += loot.item

func generate_items(tier_level, count=DEFAULT_COUNT):
	var item_list = []
	var possible_loot = get_items_by_tier(tier_level)
	for _i in range(count):
		# determine item type looted
		var item_type = Global.get_random_type_by_weight(ITEM_PROBABILITY_WEIGHTS)
		var filtered_list = filter_item_list_by_type(possible_loot, item_type)
		# add random item from filtered list
		var filtered_list_size = filtered_list.size()
		if filtered_list_size > 0:
			var item = filtered_list[Global.random.randi() % filtered_list_size]
			item_list.append(item)
	return item_list

func generate_boss_key():
	var item = get_item_by_id(ItemList.BOSS_KEY)
	return LootItem.new(LootType.GEAR, item)

func get_item_by_id(item_id):
	for item in self._items:
		if item.id == item_id:
			return item
	return null

func get_items_by_tier(tier_level):
	var items = []
	for item in self._items:
		if item.tier == tier_level:
			items.append(item)
	return items

func get_random_item(tier, item_type, modifier_type=null):
	var items_by_tier = get_items_by_tier(tier)
	var filtered_list = filter_item_list_by_type(items_by_tier, item_type)
	var items = filtered_list
	var item = null
	
	# modifier_type is only available on ItemType of BONUS and STAT
	if modifier_type:
		items = filter_item_list_by_modifier_type(items, modifier_type)
	if items.size() > 0:
		item = items[randi() % items.size()]
	return item

func roll_up_item(roll_item):
	for item in self._items:
		if item.tier > roll_item.tier && item.type == roll_item.type:
			if roll_item.type == Item.ItemType.BONUS || roll_item.type == Item.ItemType.STAT:
				if item.modifier[Item.GEAR_MODIFIER_TYPE] == roll_item.modifier[Item.GEAR_MODIFIER_TYPE]:
					return item
			else:
				return item
	return null

static func filter_item_list_by_type(list, type):
	var filtered_list = []
	for item in list:
		if item.type == type:
			filtered_list.append(item)
	return filtered_list

static func filter_item_list_by_modifier_type(list, modifier_type):
	var filtered_list = []
	for item in list:
		if item.modifier[Item.GEAR_MODIFIER_TYPE] == modifier_type:
			filtered_list.append(item)
	return filtered_list

static func get_random_count(base, multiplier=DEFAULT_MULTIPLIER):
	return 1 + Global.random.randi() % (base * multiplier)
