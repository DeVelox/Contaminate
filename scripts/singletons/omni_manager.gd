@tool
extends Node

signal done_selecting
signal show_tutorial

signal on_roll(player: Player)
signal on_move(player: Player)
signal on_heal(player: Player)
signal on_hurt(player: Player)

signal on_shoot(weapon: Weapon)

signal on_kill(enemy: Enemy)
signal on_crit(enemy: Enemy)
signal on_hit(enemy: Enemy)
signal on_damage(enemy: Enemy)

var upgrades: Dictionary
var available_upgrades: Array[StringName]


func _ready() -> void:
	_register_upgrades("res://scripts/upgrades", "manager.gd")


func create_scene(scene) -> void:
	get_tree().root.add_child.call_deferred(scene)


func add_upgrade(upgrade: String) -> void:
	if upgrades[upgrade].level == 0:
		var hud := get_node("/root/Main/Menus/HUD")
		hud.update_upgrade_list(upgrades[upgrade].icon)
		upgrades[upgrade].level += 1
		upgrades[upgrade].add()


func remove_upgrade(upgrade: String) -> void:
	if upgrades[upgrade].level > 0:
		upgrades[upgrade].level = 0
		upgrades[upgrade].remove()


func random_upgrades(all: bool = false) -> Array[Upgrade]:
	var selection := available_upgrades.duplicate()
	var selected_upgrades: Array[Upgrade] = []
	var random_selection: String
	var num_upgrades: int = selection.size() if all else 3
	for i in num_upgrades:
		if not selection.is_empty():
			random_selection = selection.pick_random()
			selected_upgrades.append(upgrades[random_selection])
			selection.erase(random_selection)
	return selected_upgrades


func reset_upgrades() -> void:
	for i in upgrades:
		remove_upgrade(i)


func _register_upgrades(folder: String, script: String) -> void:
	var dir = DirAccess.open(folder)
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if dir.current_is_dir():
				_register_upgrades(folder + "/" + file, script)
			elif file.ends_with(script):
				load(folder + "/" + file).new()
			file = dir.get_next()


func get_player() -> Player:
	var player: Player = get_node("/root/Main/Player")
	return player
