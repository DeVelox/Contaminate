class_name Spawner extends Node2D

enum Danger { LOW, MEDIUM, HIGH, EXTREME, BOSS }


class EnemyType:
	var basic_enemy: PackedScene
	var elite_enemy: PackedScene
	var boss_enemy: PackedScene
	var weight: float = 1.0

	func _init(enemy: String) -> void:
		if not ResourceLoader.exists("res://entities/enemies/" + enemy + "_basic.tscn"):
			return
		basic_enemy = load("res://entities/enemies/" + enemy + "_basic.tscn")
		elite_enemy = load("res://entities/enemies/" + enemy + "_elite.tscn")
		boss_enemy = load("res://entities/enemies/" + enemy + "_boss.tscn")


class Severity:
	var budget: int
	var elite_count: int
	var boss_count: int

	func _init(danger: Danger) -> void:
		match danger:
			Danger.LOW:
				budget = 100
				elite_count = 0
			Danger.MEDIUM:
				budget = 300
				elite_count = 1
			Danger.HIGH:
				budget = 500
				elite_count = 3
			Danger.EXTREME:
				budget = 1000
				elite_count = 5
			Danger.BOSS:
				budget = 300
				boss_count = 1


# Editor exports
@export var spawn_locations: Node2D

@export var enemy_pool: String
@export var enemy_eights: String

@export var danger: Danger

# Keep track of enemy ownership
var instance_id: int

# Internal
var enemy_instances: Array[Enemy]
var enemy_random: EnemyType:
	get:
		return _get_random_enemy()
var physics_disabled: bool
var spawned: bool

# Derived
var player_distance: float:
	get:
		return spawn.distance_squared_to(player.global_position)
var trigger_radius: float
var spawn_area: float
var enemy_group: String
var enemies: Array[EnemyType]
var spawn: Vector2
var spawns: Array[Vector2]
var severity: Severity
var original_location: Vector2

# Unused
var spawn_rate: float
var waves: int

# Optional
var update_rate: float = 0.1
var update_rate_curr: float

@onready var enemy_manager: Spawner = $"."
@onready var light_mask_node: Sprite2D = get_node("/root/Main/LightMask")
@onready var player: Player = get_node("/root/Main/Player")

static var id: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Move node under light mask so enemies get masked by light
	reparent.call_deferred(light_mask_node)
	original_location = global_position
	
	if enemy_pool:
		enemies = _enemy_pool_to_array()
	
	if danger:
		severity = Severity.new(danger)
		
	if spawn_locations:
		for i in spawn_locations.get_children():
			spawns.append(i.global_position)
		spawn = spawns.pick_random()
		spawn_area = 0.25 * severity.budget
		trigger_radius = pow(spawn_area * 4, 2)

	id += 1
	instance_id = id
	enemy_group = "enemy" + str(instance_id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Lock in position so it doesn't move with the light mask
	global_position = original_location
	#player.flicker_intensity = clamp(100000.0 / player_distance, 0.05, 0.25)

	
	if player_distance < trigger_radius:
		_spawn_enemies()

	if update_rate_curr < 0:
		_move_enemies()
		update_rate_curr = update_rate
	else:
		update_rate_curr -= delta


func _enemy_pool_to_array() -> Array[EnemyType]:
	var enemy_array: Array[EnemyType] = []
	var enemy: EnemyType
	var enemy_string := enemy_pool.replace(" ", "")
	var j: PackedStringArray
	for i in enemy_string.split(","):
		j = i.split(":")
		if not ResourceLoader.exists("res://entities/enemies/" + j[0] + "_basic.tscn"):
			continue
		enemy = EnemyType.new(j[0])
		if j.size() > 1:
			enemy.weight = float(j[1])
		if enemy:
			enemy_array.append(enemy)
	return enemy_array


func _spawn_enemies() -> void:
	if spawned:
		return

	_normalize_weights()
	var enemy_instance: Enemy
	var budget: int = severity.budget

	for i in severity.boss_count:
		enemy_instance = enemy_random.boss_enemy.instantiate()
		enemy_instance.add_to_group(enemy_group)
		enemy_instances.append(enemy_instance)
		budget -= enemy_instance.cost

	for i in severity.elite_count:
		enemy_instance = enemy_random.elite_enemy.instantiate()
		enemy_instance.add_to_group(enemy_group)
		enemy_instances.append(enemy_instance)
		budget -= enemy_instance.cost

	while budget > 0:
		enemy_instance = enemy_random.basic_enemy.instantiate()
		enemy_instance.add_to_group(enemy_group)
		enemy_instances.append(enemy_instance)
		budget -= enemy_instance.cost

	for i in enemy_instances:
		# Square spawn
		#i.position = Vector2(
		#	randf_range(-spawn_area, spawn_area), randf_range(-spawn_area, spawn_area)
		#)

		# Circle spawn
		i.position = (
			spawn
			+ (
				Vector2.ONE.normalized().rotated(randf_range(0.0, 1.0) * 2 * PI)
				* randfn(spawn_area, spawn_area / 2)
			)
		)
		enemy_manager.add_child.call_deferred(i)
	spawned = true


func _move_enemies() -> void:
	if not spawned:
		return

	get_tree().call_group("aggro", "set_direction", player.global_position)


func _sum_weights() -> float:
	var accum: float = 0.0
	for i in enemies:
		accum += i.weight
	return accum


func _normalize_weights() -> void:
	var sum: float = _sum_weights()
	for i in enemies:
		i.weight /= sum


func _get_random_enemy() -> EnemyType:
	var accum: float = 0.0
	var rand: float = randf_range(0.0, 1.0)
	for i in enemies:
		accum += i.weight
		if rand <= accum:
			return i
	return
