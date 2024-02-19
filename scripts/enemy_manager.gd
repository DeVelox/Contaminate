extends Node2D

@export var player: Player
@export var weapon: Weapon
@export var enemy: PackedScene
@export var elite: PackedScene

@export var horde_size: int = 100
@export var elite_count: int = 1
@export var update_frequency: float = 0.1
@export var leash_time: float = 10.0

var enemy_instances: Array[Enemy]
var spawn_point: Vector2
var spawn_area: float
var trigger_radius: float
var leash_radius: float
var player_distance: float
var destination: Vector2
var update: float = update_frequency
var spawned: bool
var leashed: bool
var physics_disabled: bool

@onready var leash_timer: Timer = $LeashTimer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_point = global_position
	spawn_area = 0.4 * horde_size
	trigger_radius = pow(spawn_area * 2, 2)
	leash_radius = pow(spawn_area * 4, 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = spawn_point
	player_distance = global_position.distance_squared_to(player.global_position)
	player.flicker_intensity = clamp(100000.0 / player_distance, 0.05, 0.25)
	if not spawned and player_distance < trigger_radius:
		_spawn_enemies()

	if player_distance > leash_radius:
		destination = spawn_point
		if spawned and not leashed and leash_timer.is_stopped():
			leash_timer.start(leash_time)
			leashed = true
	else:
		destination = player.global_position
		if leashed and not leash_timer.is_stopped():
			leash_timer.stop()
		leashed = false
		_set_enemy_physics()

	if not enemy_instances.is_empty():
		update -= delta
		if update < delta:
			for i in enemy_instances:
				i.direction = (destination - i.global_position).normalized()
			update = update_frequency


func _spawn_enemies() -> void:
	spawned = true
	for i in horde_size:
		enemy_instances.append(enemy.instantiate())
	for i in elite_count:
		enemy_instances.append(elite.instantiate())
	for i in enemy_instances:
		i.position = Vector2(
			randf_range(-spawn_area, spawn_area), randf_range(-spawn_area, spawn_area)
		)
		#i.position = (
		#Vector2.ONE.normalized().rotated(randf_range(0.0, 1.0) * 2 * PI)
		#* randf_range(0.0, spawn_area)
		#)
		add_child.call_deferred(i)
	horde_size = 0
	elite_count = 0


func _set_enemy_physics() -> void:
	if leashed and not physics_disabled:
		physics_disabled = true
		for i in enemy_instances:
			i.disable_physics()
	elif not leashed and physics_disabled:
		physics_disabled = false
		for i in enemy_instances:
			i.enable_physics()
