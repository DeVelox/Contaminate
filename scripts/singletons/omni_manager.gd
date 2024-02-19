@tool
extends Node

signal on_roll(player: Player)
signal on_move(player: Player)

signal on_shoot(weapon: Weapon)

signal on_kill(enemy: Enemy)
signal on_crit(enemy: Enemy)
signal on_hit(enemy: Enemy)
signal on_damage(enemy: Enemy)

var upgrades: Dictionary


func _ready() -> void:
	_register_upgrades("res://scripts/upgrades", "manager.gd")


func create_scene(scene) -> void:
	get_tree().root.add_child.call_deferred(scene)


func add_upgrade(upgrade: String) -> void:
	if upgrades[upgrade].level == 0:
		load(upgrades[upgrade].logic).new()
		upgrades[upgrade].level += 1


func _register_upgrades(folder: String, script: String) -> void:
	var dir = DirAccess.open(folder)
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if dir.current_is_dir():
				_register_upgrades(folder + "/" + file, script)
			elif file.ends_with(script):
				load(folder + "/" + file).new(true)
			file = dir.get_next()
