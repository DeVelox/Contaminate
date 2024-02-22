class_name Enemy extends StaticBody2D

enum SpeedGroup {SHOCK, KNEE_CAP, BOOST, MISC}

const BASE_SPEED = 100.0
const MIN_SPEED = 10.0
const MAX_SPEED = 200.0

@export var health := 100
@export var attack := 1
@export var speed := 100.0
@export var tier := 1
@export var cost := 1
var direction := Vector2.ZERO
var motion := Vector2.ZERO
var velocity := Vector2.ZERO
var physics := true
var infection_count: int = 0

var speed_flat: Array[float]
var speed_multi: Array[float]

var enemy_id: int
static var id: int

@onready var infection_timer: Timer = $InfectionTimer

func _ready() -> void:
	id += 1
	enemy_id = id
	
	speed_flat.resize(SpeedGroup.size())
	speed_multi.resize(SpeedGroup.size())
	
	#apply_speed_mod(5, -50, true, SpeedGroup.KNEE_CAP)
	#apply_speed_mod(5, -20, true, SpeedGroup.KNEE_CAP)
	#apply_speed_mod(2, 30, false, SpeedGroup.BOOST)


func _physics_process(delta: float) -> void:
	speed = clamp((BASE_SPEED + speed_flat.reduce(_sum)) * (1 + speed_multi.reduce(_sum)), MIN_SPEED, MAX_SPEED)
	#if enemy_id == 1:
		#print_debug(speed)
	motion = (direction * speed * delta)
	velocity = lerp(velocity, motion, 0.1)
	move_and_collide(velocity, false, 1.0)

func _process(_delta: float) -> void:
	set_physics_process(physics)
	

func damage(amount) -> void:
	health -= amount
	try_kill()

func try_kill() -> bool:
	if health <= 0:
		kill()
		return true
	return false

func kill() -> void:
	var drop = load("res://entities/upgrades/pickup.tscn").instantiate()
	drop.position = global_position
	get_tree().root.add_child.call_deferred(drop)

	UpgradeManager.on_kill.emit(self)
	get_parent().enemy_instances.erase(self)
	queue_free()

func apply_speed_mod(duration: float, amount: float, multi: bool = false, group: SpeedGroup = SpeedGroup.MISC) -> void:
	if group == SpeedGroup.MISC:
		if multi:
			speed_multi[group] += amount / 100.0
			await get_tree().create_timer(duration).timeout
			speed_multi[group] -= amount / 100.0
		else:
			speed_flat[group] += amount
			await get_tree().create_timer(duration).timeout
			speed_flat[group] -= amount
	else:
		if multi and absf(amount / 100.0) > absf(speed_multi[group]):
			speed_multi[group] = amount / 100.0
			await get_tree().create_timer(duration).timeout
			speed_multi[group] = 0.0
		elif absf(amount) > absf(speed_flat[group]):
			speed_flat[group] = amount
			await get_tree().create_timer(duration).timeout
			speed_flat[group] = 0.0

func infect() -> void:
	if infection_timer.is_stopped():
		infection_timer.start()
	infection_count += MechanicsManager.get_infection_count()

func disable_physics() -> void:
	physics = false

func enable_physics() -> void:
	physics = true

func _check_infection() -> void:
	if infection_count > 0:
		health -= MechanicsManager.get_infection_damage()
		infection_count -= 1
		try_kill()
	else:
		infection_timer.stop()

func _sum(a: float, b: float) -> float:
	return a + b
