extends Node

const LIGHTNING_ROD = preload("res://entitites/upgrades/lightning_rod.tscn")
# Called when the node enters the scene tree for the first time.
func _init() -> void:
	OmniManager.on_hit.connect(_summon_lightning)


func _summon_lightning(enemy) -> void:
	var lightning = LIGHTNING_ROD.instantiate()
	lightning.global_position = enemy.global_position
	OmniManager.create_scene(lightning)
