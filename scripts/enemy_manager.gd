extends Node

@export var player: Player
@export var enemy: PackedScene
@export var elite: PackedScene

@export var horde_size: int = 100
@export var group_size: int = 10
@export_range(0.0, 1.0) var elite_chance: float = 0.01

var enemy_instances: Array[Enemy]
var enemy_groups: Array[Node2D]
var spawn_area: float

@onready var trigger: CollisionShape2D = $Area2D/CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_area = min(2.5 * horde_size, 512)
	trigger.shape.radius = spawn_area


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not enemy_groups.is_empty():
		for i in enemy_groups:
			i.global_position = (
				lerp(i.global_position, player.global_position, 0.1 * delta)
				+ (player.global_position - i.global_position).normalized().rotated(
					randf_range(-PI / 2, PI / 2)
				)
			)


func _on_area_2d_area_entered(area: Area2D) -> void:
	for i in horde_size:
		if randf_range(0.0, 1.0) < elite_chance:
			enemy_instances.append(elite.instantiate())
		else:
			enemy_instances.append(enemy.instantiate())
			
	var group: Node2D
	for i in enemy_instances.size() - 1:
		if not i % group_size:
			group = Node2D.new()
			enemy_groups.append(group)
			add_child.call_deferred(group)
		enemy_instances[i].position = (
			Vector2.ONE.normalized().rotated(randf_range(0.0, 1.0) * 2 * PI)
			* randf_range(0.0, spawn_area)
		)
		group.add_child.call_deferred(enemy_instances[i])
