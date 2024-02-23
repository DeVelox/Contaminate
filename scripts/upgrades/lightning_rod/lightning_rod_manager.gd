extends Upgrade

const LIGHTNING_ROD = preload("res://entities/upgrades/lightning_rod.tscn")


func _init() -> void:
	_register()


func add() -> void:
	if not UpgradeManager.on_hit.is_connected(_summon_lightning):
		UpgradeManager.on_hit.connect(_summon_lightning)
	UpgradeManager.available_upgrades.erase(uname)


func remove() -> void:
	if UpgradeManager.on_hit.is_connected(_summon_lightning):
		UpgradeManager.on_hit.disconnect(_summon_lightning)
	UpgradeManager.available_upgrades.append(uname)


func _summon_lightning(enemy) -> void:
	var lightning = LIGHTNING_ROD.instantiate()
	lightning.global_position = enemy.global_position
	UpgradeManager.create_scene(lightning)


func _register() -> void:
	uname = "Lightning"
	type = Type.GENERAL
	rarity = Rarity.RARE
	description = "Does the zap-zap."
	logic = "res://scripts/upgrades/lightning_rod/lightning_rod_manager.gd"
	icon = "res://assets/lightning-branches.svg"
	level = 0

	UpgradeManager.upgrades[uname] = self
	UpgradeManager.available_upgrades.append(uname)
