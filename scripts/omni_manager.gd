extends Node

signal on_roll(player: Player)
signal on_move(player: Player)

signal on_shoot(weapon: Weapon)

signal on_kill(enemy: Enemy)
signal on_crit(enemy: Enemy)
signal on_hit(enemy: Enemy)
signal on_damage(enemy:Enemy)

func _ready() -> void:
	var lightning_rod = load("res://scripts/upgrades/lightning_rod/ligthning_rod_manager.gd")
	lightning_rod.new()
	
	
func create_scene(scene) -> void:
	get_tree().root.add_child.call_deferred(scene)
	
