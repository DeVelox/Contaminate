class_name Ammo extends Area2D

@export var damage: int
@export var speed: float
@export var pen: int
@export var lifetime: float
var origin: Vector2
var direction: Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = origin


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += speed * delta * direction
	await get_tree().create_timer(lifetime).timeout
	queue_free()
