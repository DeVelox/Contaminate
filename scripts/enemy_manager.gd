extends Node

@export var player: Player
@export var enemy: PackedScene
@export var elite: PackedScene

@export var horde_size: int = 100
@export_range(0.0, 1.0) var elite_chance: float = 0.01

var enemy_instances: Array[Enemy]

@onready var trigger: CollisionShape2D = $Area2D/CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trigger.shape.radius = min(2.5 * horde_size, 512)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not enemy_instances.is_empty():
		for i in enemy_instances:
			i.global_position = (
				lerp(i.global_position, player.global_position, 0.2 * delta)
				+ Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0))
			)


func _on_area_2d_area_entered(area: Area2D) -> void:
	for i in horde_size:
		if randf_range(0.0, 1.0) < elite_chance:
			enemy_instances.append(elite.instantiate())
		else:
			enemy_instances.append(enemy.instantiate())

	for i in enemy_instances:
		i.position = (
			Vector2.ONE.normalized().rotated(randf_range(0.0, 1.0) * 2 * PI)
			* randf_range(0.0, min(2.5 * horde_size, 512))
		)
		add_child.call_deferred(i)
