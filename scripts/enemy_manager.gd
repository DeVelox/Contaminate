extends Node2D

@export var player: Player
@export var enemy: PackedScene
@export var elite: PackedScene

@export var horde_size: int = 100
@export var update_frequency: float = 0.1
#@export var group_size: int = 10
@export_range(0.0, 1.0) var elite_chance: float = 0.01

var enemy_instances: Array[Enemy]
#var enemy_groups: Array[Node2D]
var spawn_area: float
var trigger_radius: float
var update: float = update_frequency
var spawned: bool

@onready var sprite_2d: Sprite2D = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_area = 0.5 * horde_size
	trigger_radius = pow(spawn_area * 1.5, 2)
	sprite_2d.scale = Vector2.ONE * (spawn_area * 3) / 512


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not spawned and global_position.distance_squared_to(player.global_position) < trigger_radius:
		_spawn_enemies()
	if not enemy_instances.is_empty():
		update -= delta
		if update < delta:
			for i in enemy_instances:
				i.direction = (player.global_position - i.global_position).normalized()
			update = update_frequency
			
	# No groups pls
	#var group: Node2D
	#for i in enemy_instances.size() - 1:
	#if not i % group_size:
	#group = Node2D.new()
	#enemy_groups.append(group)
	#add_child.call_deferred(group)
	#enemy_instances[i].position = (
	#Vector2.ONE.normalized().rotated(randf_range(0.0, 1.0) * 2 * PI)
	#* randf_range(0.0, spawn_area)
	#)


func _spawn_enemies() -> void:
	spawned = true
	for i in horde_size:
		if randf_range(0.0, 1.0) < elite_chance:
			enemy_instances.append(elite.instantiate())
		else:
			enemy_instances.append(enemy.instantiate())
		enemy_instances[i].position = (
			Vector2.ONE.normalized().rotated(randf_range(0.0, 1.0) * 2 * PI)
			* randf_range(0.0, spawn_area)
		)
		add_child.call_deferred(enemy_instances[i])
