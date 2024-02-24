class_name Ammo extends Area2D

var damage: int
var speed: float
var pen: int
var lifetime: float
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
