extends Upgrade

const LIGHTNING_ROD = preload("res://entitites/upgrades/lightning_rod.tscn")


# Called when the node enters the scene tree for the first time.
func _init(register: bool = false) -> void:
	if register:
		_register()
	else:
		OmniManager.on_hit.connect(_summon_lightning)


func _summon_lightning(enemy) -> void:
	var lightning = LIGHTNING_ROD.instantiate()
	lightning.global_position = enemy.global_position
	OmniManager.create_scene(lightning)


func _register() -> void:
	uname = "Lightning"
	type = Type.GENERAL
	rarity = Rarity.RARE
	logic = "res://scripts/upgrades/lightning_rod/ligthning_rod_manager.gd"
	level = 0

	OmniManager.upgrades[uname] = self
