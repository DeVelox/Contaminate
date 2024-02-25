extends Upgrade

var duration: float = 0.5
var buff_type = MechanicsManager.BuffType.SPEED
var buff_bucket = MechanicsManager.BuffBucket.ROLL
var amount: float = 200.0
var multi: bool = true


func _init() -> void:
	_register()


func add() -> void:
	if not UpgradeManager.on_roll.is_connected(_speed_burst):
		UpgradeManager.on_roll.connect(_speed_burst)
	UpgradeManager.available_upgrades.erase(uname)


func remove() -> void:
	if UpgradeManager.on_roll.is_connected(_speed_burst):
		UpgradeManager.on_roll.disconnect(_speed_burst)
	UpgradeManager.available_upgrades.append(uname)


func _speed_burst(player: Player) -> void:
	MechanicsManager.apply_buff(player, duration, amount, buff_type, multi, buff_bucket)


func _register() -> void:
	uname = "RollingMomentum"
	type = Type.GENERAL
	rarity = Rarity.COMMON
	description = "Get a quick speed surge after rolling"
	logic = "res://scripts/upgrades/rolling_momentum/rolling_momentum_manager.gd"
	icon = "res://assets/pikachu.png"
	level = 0
	UpgradeManager.upgrades[uname] = self
	UpgradeManager.available_upgrades.append(uname)
