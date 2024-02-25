class_name Pistol extends Weapon

var ammo: Ammo
var shoot_func: Callable = _shoot_gun
var gun_offset: float = 15
var gun_length: float = 20

@onready var player: Player = get_node("/root/Main/Player")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(gun_offset, 0)
	ammo = get_child(1)
	ammo = WeaponManager.apply_ammo_upgrades(ammo, self, get_children())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	_point_gun(player, gun_offset)
	player.progress_bar.value = heat_level

	if Input.is_action_just_pressed("shoot"):
		# Ability to override per weapon or just use player default
		#player.aggro_shoot_radius = 300
		player.just_shot.emit()
		shoot_func.call(player, ammo, gun_length)
