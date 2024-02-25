class_name Weapon extends Node2D

var ammo: Ammo
var shoot_func: Callable = _shoot_gun
var gun_offset: float = 15
var gun_length: float = 20
var gun_overheat: bool
var gun_heat_cooldown: bool
var heat_level: float


func _point_gun(player_velocity: Vector2) -> void:
	if not player_velocity.is_zero_approx():
		position = player_velocity.normalized() * gun_offset
		rotation = player_velocity.angle()
	if player_velocity.x < 0:
		$Sprite2D.flip_v = true
	else:
		$Sprite2D.flip_v = false


func _try_shoot(player: Player, load_ammo: Ammo, sfx: AudioStream, delta: float) -> void:
	_point_gun(player.velocity)
	player.progress_bar.value = heat_level
	if gun_heat_cooldown:
		return
	if gun_overheat:
		if heat_level == 0:
			gun_overheat = false
	else:
		if Input.is_action_just_pressed("shoot"):
			heat_level = min(load_ammo.heat_shot + heat_level, load_ammo.heat_max)
			# Ability to override per weapon or just use player default
			#player.aggro_shoot_radius = 300
			player.just_shot.emit()
			SoundManager.sfx(sfx)
			_shoot_gun(player.velocity, load_ammo)
			if heat_level == load_ammo.heat_max:
				_overheat()
				
				
	heat_level = max(0, heat_level - ammo.heat_rate * delta)

func _shoot_gun(player_velocity: Vector2, load_ammo: Ammo) -> void:
	@warning_ignore("integer_division")
	var angle := (load_ammo.bullet_count / 2) * -load_ammo.spread
	var start_direction := player_velocity if not player_velocity.is_zero_approx() else Vector2.RIGHT
	for i in load_ammo.bullet_count:
		load_ammo.direction = start_direction.rotated(deg_to_rad(angle))
		angle += load_ammo.spread
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
		pass_ammo.direction.normalized()
		get_tree().root.add_child(pass_ammo)

func _overheat() -> void:
	gun_heat_cooldown = true
	gun_overheat = true
	SoundManager.sfx(SoundManager.OVERHEAT)
	await get_tree().create_timer(ammo.heat_cooldown).timeout
	gun_heat_cooldown = false
