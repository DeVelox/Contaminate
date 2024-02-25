class_name Weapon extends Node2D

var ammo: Ammo
var shoot_func: Callable = _shoot_gun
var gun_offset: float = 15
var gun_length: float = 20
var gun_overheat: bool
var heat_level: float


func _point_gun(player_velocity: Vector2) -> void:
	if not player_velocity.is_zero_approx():
		position = player_velocity.normalized() * gun_offset
		rotation = player_velocity.angle()
	if player_velocity.x < 0:
		$Sprite2D.flip_v = true
	else:
		$Sprite2D.flip_v = false


func _shoot_gun(player_velocity: Vector2, load_ammo: Ammo) -> void:
	var pass_ammo = load_ammo.duplicate()
	var direction = (
		player_velocity.normalized()
		if load_ammo.direction == Vector2.ZERO
		else load_ammo.direction.normalized()
	)
	if direction.is_zero_approx():
		direction = Vector2.RIGHT.rotated(rotation)
	pass_ammo.origin = global_position + direction * gun_length
	pass_ammo.direction = direction
	get_tree().root.add_child(pass_ammo)
