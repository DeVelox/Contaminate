class_name Explosive extends Weapon

@onready var player: Player = get_node("/root/Main/Player")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(gun_offset, 0)
	ammo = get_child(1).duplicate()
	get_child(1).queue_free()
	gun_offset = 15
	gun_length = 20
	#ammo = WeaponManager.apply_ammo_upgrades(ammo, self, get_children())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_point_gun(player.velocity)
	player.progress_bar.value = heat_level

	if Input.is_action_just_pressed("shoot"):
		# Ability to override per weapon or just use player default
		#player.aggro_shoot_radius = 300
		player.just_shot.emit()
		_shoot_gun(player.velocity, ammo)
