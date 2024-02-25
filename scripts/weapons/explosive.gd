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
func _process(delta: float) -> void:
	_try_shoot(player, ammo, SoundManager.ROCKET, delta)



