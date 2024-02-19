extends Node2D

@export var player: Player
@export var weapon: Weapon
@export var enemy: PackedScene
@export var elite: PackedScene

@export var horde_size: int = 100
@export var update_frequency: float = 0.1
@export_range(0.0, 1.0) var elite_chance: float = 0.01

var enemy_instances: Array[Enemy]
var spawn_area: float
var trigger_radius: float
var player_distance: float
var update: float = update_frequency
var spawned: bool


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_area = 0.5 * horde_size
	trigger_radius = pow(spawn_area * 1.5, 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player_distance = global_position.distance_squared_to(player.global_position)
	player.flicker_intensity = clamp(100000.0 / player_distance, 0.05, 0.25)
	if not spawned and player_distance < trigger_radius:
		_spawn_enemies()
	if not enemy_instances.is_empty():
		update -= delta
		if update < delta:
			for i in enemy_instances:
				i.direction = (player.global_position - i.global_position).normalized()
			update = update_frequency


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
