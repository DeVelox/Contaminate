class_name Enemy extends StaticBody2D

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

@onready var infection_timer: Timer = $InfectionTimer


func _physics_process(delta: float) -> void:
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
