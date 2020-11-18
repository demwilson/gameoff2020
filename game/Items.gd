const Item = preload("res://game/Item.gd")
const Move = preload("res://game/Move.gd")

enum LootType {
	ITEM,
	OXYGEN,
	CURRENCY
}
enum ItemList {
	CROWBAR,
	FLIMSY_SWORD,
	CYBERNETIC_EYE,
	FIREBOLT,
	ROBOT_T1,
}

const LootTypeMap = [
	"ITEM",
	"OXYGEN",
	"CURRENCY"
]

# List positions match LootType enum
const LOOT_PROBABILITY_WEIGHTS = [60, 30, 10]
# list positions match ItemType enum in Item
const ITEM_PROBABILITY_WEIGHTS = [94, 3, 2, 1]

const CURRENCY_BASE = 10
const OXYGEN_BASE = 5
const ITEM_COUNT_BASE = 2

var _items = null

func _init(items):
	self._items = items

func get_item_by_id(id):
	if id < self._items.size():
		return self._items[id]
	return null

func generate_loot(tier_level, player=null):
	var loot_type = Global.get_random_type_by_weight(LOOT_PROBABILITY_WEIGHTS)
	var loot = null
	match loot_type:
		LootType.ITEM:
			var item_count = get_random_count(ITEM_COUNT_BASE, tier_level)
			loot = generate_items(tier_level, item_count)
		LootType.OXYGEN:
			loot = get_random_count(OXYGEN_BASE, tier_level)
		LootType.CURRENCY:
			loot = get_random_count(CURRENCY_BASE, tier_level)

	if player:
		match loot_type:
			LootType.ITEM:
				var loot_ids = []
				for item in loot:
					loot_ids.append(item.id)
				player.add_items(loot_ids)
			LootType.OXYGEN:
				player.add_oxygen(loot)
			LootType.CURRENCY:
				Global.currency += loot

	Global.log(Settings.LogLevel.TRACE, "[generate_loot] Type: " + LootTypeMap[loot_type] + " | Loot: " + str(loot))
	return {
		"type": loot_type,
		"items": loot
	}

func generate_items(tier_level, count):
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

static func filter_item_list_by_type(list, type):
	var filtered_list = []
	for item in list:
		if item.type == type:
			filtered_list.append(item)
	return filtered_list

static func filter_item_list_by_modifier_type(list, modifier_type):
	var filtered_list = []
	for item in list:
		if item.modifier[Item.ITEM_MODIFIER_TYPE] == modifier_type:
			filtered_list.append(item)
	return filtered_list


static func get_random_count(base, multiplier):
	return 1 + Global.random.randi() % (base * multiplier)
