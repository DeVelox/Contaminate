class_name Pistol extends Weapon

@export var ammo_type: PackedScene

var ammo: Ammo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ammo = ammo_type.instantiate()
	ammo = WeaponManager.apply_ammo_upgrades(ammo, self, get_children())
	
func _init() -> void:
	fire_rate = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		for i in fire_rate:
			var pass_ammo = ammo.duplicate()
			pass_ammo.direction = get_parent().velocity.normalized()
			if pass_ammo.direction.is_zero_approx():
				pass_ammo.direction = Vector2.ONE.normalized()
			pass_ammo.origin = global_position
			WeaponManager.shoot(pass_ammo)
			await get_tree().create_timer(0.1).timeout
