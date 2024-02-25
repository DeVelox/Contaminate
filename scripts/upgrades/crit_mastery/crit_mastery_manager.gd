extends Upgrade

var crit_chance_bonus: float = 0.05
var buff_duration: float = 3.0
var buff_type = MechanicsManager.BuffType.CRIT_CHANCE
var buff_bucket = MechanicsManager.BuffBucket.MISC
var multi = false


func _init() -> void:
	_register()


func add() -> void:
	if not UpgradeManager.on_crit.is_connected(_add_crit):
		UpgradeManager.on_crit.connect(_add_crit)
	UpgradeManager.available_upgrades.erase(uname)


func remove() -> void:
	if UpgradeManager.on_crit.is_connected(_add_crit):
		UpgradeManager.on_crit.disconnect(_add_crit)
	UpgradeManager.available_upgrades.append(uname)


func _register() -> void:
	uname = "CritMastery"
	type = Type.GENERAL
	rarity = Rarity.COMMON
	description = "Whenever you crit increase your crit chance for a short duration"
	logic = "res://scripts/upgrades/crit_mastery/crit_mastery_manager.gd"
	icon = "res://assets/winchester-rifle.svg"
	level = 0
	UpgradeManager.upgrades[uname] = self
	UpgradeManager.available_upgrades.append(uname)


func _add_crit(_enemy: Enemy) -> void:
	var player = UpgradeManager.get_player()
	MechanicsManager.apply_buff(
		player, buff_duration, crit_chance_bonus, buff_type, multi, buff_bucket
	)
