const Enemy = preload("res://game/Enemy.gd")

enum EnemyList {
	DOG_T1,
	DOG_T2,
	TARDIGRADE_T1,
	TARDIGRADE_T2,
	ROBOT_T1,
	ROBOT_T2,
	BOSS_T0,
}

var _enemies = null

func _init(enemies):
	self._enemies = enemies

func get_random_enemy_by_tier_level(tier_level):
	if Global.boss_fight:
		Global.boss_fight = false
		return self._enemies[EnemyList.BOSS_T0]
	
	var enemies_tier_list = []
	for enemy in self._enemies:
		if enemy.get_tier() == tier_level:
			enemies_tier_list.append(enemy)
	var selected_enemy_position = Global.random.randi() % enemies_tier_list.size()
	return enemies_tier_list[selected_enemy_position]

func get_enemy_by_id(id):
	if id < self._enemies.size():
		return self._enemies[id]
	return null
