class_name Elite extends Enemy

@export var reinforcement_radius: float = 100

var got_the_boys: bool

@onready var aggro_range: Area2D = $AggroRange
@onready var collision: CollisionShape2D = $AggroRange/CollisionShape2D


func _ready() -> void:
	collision.shape.radius = reinforcement_radius
	_monitoring(false)


func set_elite_aggro() -> void:
	if not got_the_boys:
		got_the_boys = true
		_monitoring(true)


func _get_the_boys(body: Node2D) -> void:
	_monitoring(false)
	if body is Elite:
		body.set_elite_aggro()
	if body is Enemy:
		body.set_aggro(true)
	aggro_range.queue_free()


func _monitoring(active: bool) -> void:
	aggro_range.set_deferred("monitoring", active)
	aggro_range.set_deferred("monitorable", active)
