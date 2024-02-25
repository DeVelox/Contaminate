class_name Ammo extends Area2D

@export var damage: int
@export var speed: float
@export var distance: float
@export var size: float
@export var penetration: int

@export var heat_max: float
@export var heat_shot: float
@export var heat_rate: float
@export var heat_cooldown: float

@export var spread: float
@export var fire_rate: float
@export var bullet_count: int
@export var wave_count: int

@export var crit_chance: float
@export var crit_damage: float
@export var proc_coeff: float

var origin: Vector2
var direction: Vector2
var range_squared: float

var buff_dict: Dictionary = {
	MechanicsManager.BuffType.DAMAGE: {"multi": [], "multi_calc": 0.0, "flat": [], "flat_calc": 0.0}
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = origin
	range_squared = pow(distance, 2)

	buff_dict[MechanicsManager.BuffType.DAMAGE]["multi"].resize(MechanicsManager.BuffBucket.size())
	buff_dict[MechanicsManager.BuffType.DAMAGE]["flat"].resize(MechanicsManager.BuffBucket.size())
	buff_dict[MechanicsManager.BuffType.DAMAGE]["multi"].fill(0.0)
	buff_dict[MechanicsManager.BuffType.DAMAGE]["flat"].fill(0.0)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	global_position += speed * delta * direction
	if global_position.distance_squared_to(origin) > range_squared:
		queue_free()
