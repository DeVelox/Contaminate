extends Upgrade

var damage: int = 2
var delay: float = 5.0
var hit_chance: float = 0.5
var texture = preload("res://assets/art/upgrades/william-tell-skull.svg")


func _init() -> void:
	_register()


func add() -> void:
	if not UpgradeManager.on_hit.is_connected(_do_damage):
		UpgradeManager.on_hit.connect(_do_damage)
	UpgradeManager.available_upgrades.erase(uname)


func remove() -> void:
	if UpgradeManager.on_hit.is_connected(_do_damage):
		UpgradeManager.on_hit.disconnect(_do_damage)
	UpgradeManager.available_upgrades.append(uname)


func _register() -> void:
	uname = "MarkForDeath"
	type = Type.GENERAL
	rarity = Rarity.COMMON
	description = "Whenever you damage an enemy there is a chance to mark it dealing damage after a delay"
	logic = "res://scripts/upgrades/damage_after_delay/damage_after_delay_manager.gd"
	icon = "res://assets/winchester-rifle.svg"
	level = 0
	UpgradeManager.upgrades[uname] = self
	UpgradeManager.available_upgrades.append(uname)


func _do_damage(enemy: Enemy) -> void:
	if randf() > hit_chance:
		return
	if enemy.is_in_group("markedForDeath"):
		return
	enemy.add_to_group("markedForDeath")
	var mark := TextureRect.new()
	mark.texture = texture
	enemy.add_child(mark)
	await get_tree().create_timer(delay).timeout
	mark.queue_free()
	if is_instance_valid(enemy):
		enemy.damage(damage)
