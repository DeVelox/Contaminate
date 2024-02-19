extends Node


func shoot(ammo: Ammo) -> void:
	if ammo is Bullet:
		get_tree().root.add_child(ammo)


func apply_ammo_upgrades(ammo_type: Ammo, weapon: Weapon, upgrade_array: Array[Node]) -> Variant:
	var load_ammo = ammo_type
	for i in upgrade_array:
		if i is AmmoUpgrade:
			weapon.remove_child(i)
			load_ammo.add_child(i)
	return load_ammo
