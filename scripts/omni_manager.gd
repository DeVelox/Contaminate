extends Node

const LIGHTNING = preload("res://entitites/effects/lightning.tscn")

signal on_roll(player: Player)
signal on_move(player: Player)

signal on_shoot(weapon: Weapon)

signal on_kill(enemy: Enemy)
signal on_crit(enemy: Enemy)
signal on_hit(enemy: Enemy)
signal on_damage(enemy:Enemy)

func _ready() -> void:
	on_kill.connect(lightning)

func lightning(enemy: Enemy) -> void:
	var effect = LIGHTNING.instantiate()
	effect.position = enemy.global_position
	get_tree().root.add_child.call_deferred(effect)
	
	
