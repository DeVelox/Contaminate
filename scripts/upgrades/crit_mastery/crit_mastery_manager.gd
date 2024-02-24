extends Upgrade

@onready var player: Player = get_node("/root/Main/Player")

var crit_chance_bonus: float  = 0.2
var non_crit_damage_reduction: float = 0.2


func _init() -> void:
	_register()


func add() -> void:
	player.max_health += 1
	player.health = player.max_health
	UpgradeManager.available_upgrades.erase(uname)


func remove() -> void:
	UpgradeManager.available_upgrades.append(uname)


func _register() -> void:
	uname = "HealthUp"
	type = Type.GENERAL
	rarity = Rarity.COMMON
	description = "Get an extra heart and a full heal"
	logic = "res://scripts/upgrades/health_up/health_up_manager.gd"
	icon = "res://assets/heart.png"
	level = 0
	UpgradeManager.upgrades[uname] = self
	UpgradeManager.available_upgrades.append(uname)
