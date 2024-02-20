class_name Spawner extends Node2D

enum Danger { LOW, MEDIUM, HIGH, EXTREME, BOSS }
enum Rarity { COMMON, RARE, UNIQUE }

class EnemyType:
	var basic_enemy: PackedScene
	var elite_enemy: PackedScene
	var boss_enemy: PackedScene
	
	func _init(enemy: String) -> void:
		if not ResourceLoader.exists("res://entities/enemies/" + enemy + ".tscn"):
			return
		basic_enemy = load("res://entities/enemies/" + enemy + ".tscn")
		elite_enemy = load("res://entities/enemies/" + enemy + "_elite.tscn")
		boss_enemy = load("res://entities/enemies/" + enemy + "_boss.tscn")


class ZoneSeverity:
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
@export var spawn_locations: Node2D:
	set(sl):
		spawn_locations = sl
		if spawn_locations:
			for i in spawn_locations.get_children():
				spawns.append(i.global_position)
			spawn = spawns.pick_random()

@export var enemy_pool: String:
	set(ep):
		enemy_pool = ep
		if enemy_pool:
			enemies = _enemy_pool_to_array()

@export var danger: Danger:
	set(t):
		danger = t
		severity = ZoneSeverity.new(danger)

@export var rarity: Rarity


# Keep track of enemy ownership
static var id: int
var instance_id: int:
	set(iid):
		instance_id = iid
		enemy_group = "enemy" + str(instance_id)

# Internal
var enemy_instances: Array[Enemy]
var physics_disabled: bool
var spawned: bool

# Derived
var player_distance: float:
	get:
		return spawn.distance_squared_to(player.global_position)
var trigger_radius: float:
	get:
		return pow(spawn_area * 4, 2)
var spawn_area: float:
	get:
		return 0.25 * severity.budget
var enemy_group: String
var enemies: Array[EnemyType]
var spawn: Vector2
var spawns: Array[Vector2]
var severity: ZoneSeverity
var original_location: Vector2

# Unused
var spawn_rate: float
var waves: int

# Optional
var update_rate: float = 0.1

@onready var enemy_manager: Spawner = $"."
@onready var light_mask_node: Sprite2D = get_node("/root/Main/LightMask")
@onready var player: Player = get_node("/root/Main/Player")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Move node under light mask so enemies get masked by light
	reparent.call_deferred(light_mask_node)
	original_location = global_position

	id += 1
	instance_id = id
	
	print_debug(EnemyType.new("patat"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Lock in position so it doesn't move with the light mask
	global_position = original_location
	player.flicker_intensity = clamp(100000.0 / player_distance, 0.05, 0.25)

	if player_distance < trigger_radius:
		_spawn_enemies()
	_move_enemies()
	await get_tree().create_timer(update_rate).timeout


func _enemy_pool_to_array() -> Array[EnemyType]:
	var enemy_array: Array[EnemyType] = []
	var enemy: EnemyType
	var enemy_string := enemy_pool.replace(" ", "")
	for i in enemy_string.split(","):
		if not ResourceLoader.exists("res://entities/enemies/" + i + ".tscn"):
			continue
		enemy = EnemyType.new(i)
		if enemy:
			enemy_array.append(enemy)
	return enemy_array

func _spawn_enemies() -> void:
	if spawned:
		return

	var enemy: EnemyType = enemies.pick_random()
	var enemy_instance: Enemy
	var budget: int = severity.budget

	for i in severity.boss_count:
		enemy_instance = enemy.boss_enemy.instantiate()
		enemy_instance.add_to_group(enemy_group)
		enemy_instances.append(enemy_instance)
		budget -= enemy_instance.cost

	for i in severity.elite_count:
		enemy_instance = enemy.elite_enemy.instantiate()
		enemy_instance.add_to_group(enemy_group)
		enemy_instances.append(enemy_instance)
		budget -= enemy_instance.cost

	while budget > 0:
		enemy_instance = enemy.basic_enemy.instantiate()
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

	if not enemy_instances.is_empty():
		for i in enemy_instances:
			i.direction = (player.global_position - i.global_position).normalized()

func set_enemy_physics() -> void:
	if not physics_disabled:
		physics_disabled = true
		get_tree().call_group(enemy_group, "enable_physics")
	elif physics_disabled:
		physics_disabled = false
		get_tree().call_group(enemy_group, "enable_physics")
