class_name Weapon extends Node2D

var ammo: Ammo
var shoot_func: Callable = _shoot_gun
var _aim_direction: Vector2
var mouse_aim: Vector2
var gun_offset: float = 30
var gun_length: float = 10
var gun_overheat: bool
var gun_heat_cooldown: bool
var heat_level: float
var symbol: TextureRect

func _point_gun(aim_direction: Vector2) -> void:
	if not aim_direction.is_zero_approx():
		position = aim_direction.normalized() * gun_offset
		rotation = aim_direction.angle()
	if aim_direction.x < 0:
		$Sprite2D.flip_v = true
	else:
		$Sprite2D.flip_v = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_aim = get_global_mouse_position()

func _try_shoot(player: Player, load_ammo: Ammo, sfx: AudioStream, delta: float) -> void:
	# _aim_direction = player.velocity.normalized().snapped(Vector2.ONE)
	_aim_direction = (mouse_aim - player.global_position)
	_point_gun(_aim_direction)
	player.progress_bar.value = heat_level
	if gun_heat_cooldown:
		return
	if gun_overheat:
		if heat_level == 0:
			gun_overheat = false
			_overheat_symbol(false)
	else:
		if Input.is_action_just_pressed("shoot"):
			var is_crit: bool = (
				true if randf() < player.crit_chance + ammo.crit_chance else false
			)
			load_ammo.bonus_damage = player.damage_bonus
			heat_level = min(
				load_ammo.heat_shot * player.heat_cost_multi + heat_level, load_ammo.heat_max
			)
			# Ability to override per weapon or just use player default
			#player.aggro_shoot_radius = 300
			player.just_shot.emit()
			SoundManager.sfx(sfx)
			_shoot_gun(_aim_direction, load_ammo, is_crit)
			if heat_level == load_ammo.heat_max:
				_overheat()

	heat_level = max(0, heat_level - ammo.heat_rate * delta)

func _shoot_gun(aim_direction: Vector2, load_ammo: Ammo, is_crit: bool) -> void:
	@warning_ignore("integer_division")
	var angle := (load_ammo.bullet_count / 2) * - load_ammo.spread
	var start_direction := (
		aim_direction if not aim_direction.is_zero_approx() else Vector2.RIGHT
	)
	for i in load_ammo.bullet_count:
		load_ammo.direction = start_direction.rotated(deg_to_rad(angle))
		angle += load_ammo.spread
		var pass_ammo := load_ammo.duplicate() as Ammo
		var direction = (
			aim_direction.normalized()
			if load_ammo.direction == Vector2.ZERO
			else load_ammo.direction.normalized()
		)
		if direction.is_zero_approx():
			direction = Vector2.RIGHT.rotated(rotation)
		pass_ammo.origin = global_position + direction * gun_length
		pass_ammo.direction = direction
		pass_ammo.direction.normalized()
		if is_crit:
			pass_ammo.is_crit = true
		get_tree().root.add_child(pass_ammo)

func _overheat() -> void:
	gun_heat_cooldown = true
	gun_overheat = true
	_overheat_symbol(true)
	SoundManager.sfx(SoundManager.OVERHEAT)
	await get_tree().create_timer(ammo.heat_cooldown).timeout
	gun_heat_cooldown = false

func _overheat_symbol(enable: bool) -> void:
	if enable:
		var player = get_node("/root/Main/Player")
		symbol = TextureRect.new()
		symbol.texture = load("res://assets/art/stopwatch.svg")
		symbol.position = Vector2( - 10, -50)
		symbol.scale = Vector2(0.04, 0.04)
		player.add_child(symbol)
	else:
		symbol.queue_free()
