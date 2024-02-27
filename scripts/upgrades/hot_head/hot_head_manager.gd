extends Upgrade

var bonus_crit_chance: float = 0.2
var bonus_heat_cost: float = 0.2


func _init() -> void:
	_register()


func add() -> void:
	var player = UpgradeManager.get_player()
	player.base_crit_chance += bonus_crit_chance
	player.heat_cost_multi += bonus_heat_cost
	UpgradeManager.available_upgrades.erase(uname)


func remove() -> void:
	UpgradeManager.available_upgrades.append(uname)


func _register() -> void:
	uname = "HotHead"
	type = Type.GENERAL
	rarity = Rarity.COMMON
	description = "Get an extra heart and a full heal"
	logic = "res://scripts/upgrades/hot_head/hot_head_manager.gd"
	icon = "res://assets/art/upgrades/dice-fire.svg"
	level = 0
	UpgradeManager.upgrades[uname] = self
	UpgradeManager.available_upgrades.append(uname)
