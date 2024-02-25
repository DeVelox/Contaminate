class_name Ammo extends Area2D

@export var damage: int
@export var speed: float
@export var distance: float
@export var size: float
@export var penetration: int

@export var fire_rate: float
@export var bullet_count: int
@export var wave_count: int

@export var crit_chance: float
@export var crit_damage: float
@export var proc_coeff: float


var fired: bool
var origin: Vector2
var direction: Vector2
var range_squared: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = origin
	range_squared = pow(distance, 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += speed * delta * direction
	if fired and global_position.distance_squared_to(origin) > range_squared:
		queue_free()
