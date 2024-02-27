class_name Spawner extends Node2D

enum Danger { LOW1, LOW2, MEDIUM1, MEDIUM2, HIGH, EXTREME, ELITES }


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
			Danger.LOW1:
				budget = 100
				elite_count = 0
			Danger.LOW2:
				budget = 200
				elite_count = 1
			Danger.MEDIUM1:
				budget = 300
				elite_count = 2
			Danger.MEDIUM2:
				budget = 350
				elite_count = 4
			Danger.HIGH:
				budget = 600
				elite_count = 7
			Danger.EXTREME:
				budget = 1000
				elite_count = 25
			Danger.ELITES:
				budget = 500
				elite_count = 20


# Editor exports
@export var spawn_locations: Node2D

@export var enemy_pool: String
@export var enemy_eights: String

@export var danger: Danger = Danger.LOW1

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

# Unused
var spawn_rate: float
var waves: int

@onready var enemy_container: Node2D = get_node("/root/Main/EnemiesAFK")
@onready var player: Player = get_node("/root/Main/Player")

static var id: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if enemy_pool:
		enemies = _enemy_pool_to_array()

	severity = Severity.new(danger)

	if spawn_locations:
		for i in spawn_locations.get_children():
			spawns.append(i.global_position)
		spawn = spawns.pick_random()
		spawn_area = 0.25 * severity.budget
		trigger_radius = pow(max(540, spawn_area * 4), 2)

	id += 1
	instance_id = id
	enemy_group = "enemy" + str(instance_id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if player_distance < trigger_radius:
		_spawn_enemies()


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

	spawned = true
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
		enemy_container.add_child.call_deferred(i)
		queue_free()


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
