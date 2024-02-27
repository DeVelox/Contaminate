extends Upgrade

var damage_bonus: int = 1
var heal_amount: int = 1

func _init() -> void:
	_register()


func add() -> void:
	if not UpgradeManager.on_heal.is_connected(_add_damage):
		UpgradeManager.on_heal.connect(_add_damage)
	if not UpgradeManager.on_hurt.is_connected(_remove_damage):
		UpgradeManager.on_hurt.connect(_remove_damage)
	var player = UpgradeManager.get_player()
	player.heal(heal_amount)
	UpgradeManager.available_upgrades.erase(uname)


func remove() -> void:
	if UpgradeManager.on_heal.is_connected(_add_damage):
		UpgradeManager.on_heal.disconnect(_add_damage)
	if UpgradeManager.on_hurt.is_connected(_remove_damage):
		UpgradeManager.on_hurt.disconnect(_remove_damage)
	UpgradeManager.available_upgrades.append(uname)


func _register() -> void:
	uname = "Vigor"
	type = Type.GENERAL
	rarity = Rarity.COMMON
	description = "Gain bonus damage when on full health, heal 1 Heart."
	logic = "res://scripts/upgrades/max_health_damage/max_health_damage_manager.gd"
	icon = "res://assets/art/upgrades/heart-battery.svg"
	level = 0
	UpgradeManager.upgrades[uname] = self
	UpgradeManager.available_upgrades.append(uname)


func _add_damage(player: Player) -> void:
	if player.health == player.max_health:
		player.damage_bonus += damage_bonus

func _remove_damage(player: Player) -> void:
	if player.health == player.max_health - 1:
		player.damage_bonus -= damage_bonus
