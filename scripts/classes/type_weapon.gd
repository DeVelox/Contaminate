class_name Weapon extends Node2D

var heat_level: float
var fire_rate: float


func _point_gun(player: Player, gun_offset: float) -> void:
	if not player.velocity.is_zero_approx():
		position = player.velocity.normalized() * gun_offset
		rotation = player.velocity.angle()
	if player.velocity.x < 0:
		$Sprite2D.flip_v = true
	else:
		$Sprite2D.flip_v = false


func _shoot_gun(player: Player, ammo: Ammo, gun_length: float) -> void:
	SoundManager.sfx(SoundManager.PISTOL)
	var pass_ammo = ammo.duplicate()
	var direction = player.velocity.normalized()
	if direction.is_zero_approx():
		direction = Vector2(1, 0)
	pass_ammo.origin = global_position + direction * gun_length
	pass_ammo.direction = direction
	WeaponManager.shoot(pass_ammo)
