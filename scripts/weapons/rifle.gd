class_name Rifle extends Weapon

@onready var player: Player = get_node("/root/Main/Player")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(gun_offset, 0)
	ammo = get_child(1).duplicate()
	get_child(1).queue_free()
	gun_offset = 30
	gun_length = 40
	#ammo = WeaponManager.apply_ammo_upgrades(ammo, self, get_children())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_point_gun(player.velocity)
	player.progress_bar.value = heat_level

	if not gun_overheat:
		heat_level -= ammo.heat_rate * delta

	if Input.is_action_just_pressed("shoot"):
		if gun_overheat:
			return
		if heat_level <= ammo.heat_max:
			heat_level += ammo.heat_shot
		else:
			gun_overheat = true
			SoundManager.sfx(SoundManager.OVERHEAT)
			await get_tree().create_timer(ammo.heat_cooldown).timeout
			gun_overheat = false
			return

		# Ability to override per weapon or just use player default
		#player.aggro_shoot_radius = 300
		player.just_shot.emit()
		SoundManager.sfx(SoundManager.RIFLE)
		_shoot_gun(player.velocity, ammo)
