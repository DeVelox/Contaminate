extends Upgrade

var damage_bonus: int = 1


func _init() -> void:
	_register()


func add() -> void:
	if not UpgradeManager.on_heal.is_connected(_add_damage):
		UpgradeManager.on_heal.connect(_add_damage)
	if not UpgradeManager.on_hurt.is_connected(_remove_damage):
		UpgradeManager.on_hurt.connect(_remove_damage)
	UpgradeManager.available_upgrades.erase(uname)


func remove() -> void:
	if UpgradeManager.on_heal.is_connected(_add_damage):
		UpgradeManager.on_heal.disconnect(_add_damage)
	if UpgradeManager.on_hurt.is_connected(_remove_damage):
		UpgradeManager.on_hurt.disconnect(_remove_damage)
	UpgradeManager.available_upgrades.append(uname)


func _register() -> void:
	uname = "MaxHealthDamage"
	type = Type.GENERAL
	rarity = Rarity.COMMON
	description = "Whenever you crit increase your crit chance for a short duration"
	logic = "res://scripts/upgrades/max_health_damage/max_health_damage_manager.gd"
	icon = "res://assets/art/upgrades/heart-battery.svg"
	level = 0
	UpgradeManager.upgrades[uname] = self
	UpgradeManager.available_upgrades.append(uname)


func _add_damage(_enemy: Enemy) -> void:
	var player = UpgradeManager.get_player()
	if player.health == player.max_health:
		player.damage += damage_bonus


func _remove_damage(_enemy: Enemy) -> void:
	var player = UpgradeManager.get_player()
	if player.health == player.max_health - 1:
		player.damage -= damage_bonus
