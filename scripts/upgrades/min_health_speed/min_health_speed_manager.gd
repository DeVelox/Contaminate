extends Upgrade

var health_bonus_threshold: int = 1
var speed_bonus: float = 1.2


func _init() -> void:
	_register()


func add() -> void:
	if not UpgradeManager.on_hurt.is_connected(_add_speed):
		UpgradeManager.on_hurt.connect(_add_speed)
	if not UpgradeManager.on_heal.is_connected(_remove_speed):
		UpgradeManager.on_heal.connect(_remove_speed)
	UpgradeManager.available_upgrades.erase(uname)


func remove() -> void:
	if UpgradeManager.on_hurt.is_connected(_add_speed):
		UpgradeManager.on_hurt.disconnect(_add_speed)
	if UpgradeManager.on_heal.is_connected(_remove_speed):
		UpgradeManager.on_heal.disconnect(_remove_speed)
	UpgradeManager.available_upgrades.append(uname)


func _register() -> void:
	uname = "Last Stand"
	type = Type.GENERAL
	rarity = Rarity.COMMON
	description = "Gain bonus move speed when on low health"
	logic = "res://scripts/upgrades/min_health_speed/min_health_speed_manager.gd"
	icon = "res://assets/art/upgrades/life-support.svg"
	level = 0
	UpgradeManager.upgrades[uname] = self
	UpgradeManager.available_upgrades.append(uname)


func _add_speed(player: Player) -> void:
	if player.health <= health_bonus_threshold:
		player.base_speed *= speed_bonus


func _remove_speed(player: Player) -> void:
	if player.health > health_bonus_threshold:
		player.base_speed /= speed_bonus
