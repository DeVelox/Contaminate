extends Upgrade

const LIGHTNING_ROD = preload("res://entities/upgrades/lightning_rod.tscn")
const SPAWN_CHANCE = 0.5


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
	if randf() > SPAWN_CHANCE:
		return
	var lightning = LIGHTNING_ROD.instantiate()
	lightning.global_position = enemy.global_position
	UpgradeManager.create_scene(lightning)


func _register() -> void:
	uname = "Smite"
	type = Type.GENERAL
	rarity = Rarity.RARE
	description = "When you hit an enemy there is a chance to summon a lightning strike."
	logic = "res://scripts/upgrades/lightning_rod/lightning_rod_manager.gd"
	icon = "res://assets/art/upgrades/lightning-branches.svg"
	level = 0

	UpgradeManager.upgrades[uname] = self
	UpgradeManager.available_upgrades.append(uname)
