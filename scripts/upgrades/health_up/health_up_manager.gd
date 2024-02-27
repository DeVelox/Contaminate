extends Upgrade

var max_health_bonus: int = 1


func _init() -> void:
	_register()


func add() -> void:
	var player = UpgradeManager.get_player()
	player.max_health += 1
	player.heal(player.max_health)
	UpgradeManager.available_upgrades.erase(uname)


func remove() -> void:
	UpgradeManager.available_upgrades.append(uname)


func _register() -> void:
	uname = "HealthUp"
	type = Type.GENERAL
	rarity = Rarity.COMMON
	description = "Get an extra heart and a full heal"
	logic = "res://scripts/upgrades/health_up/health_up_manager.gd"
	icon = "res://assets/art/upgrades/self-love.svg"
	level = 0
	UpgradeManager.upgrades[uname] = self
	UpgradeManager.available_upgrades.append(uname)
