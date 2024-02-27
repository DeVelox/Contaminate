class_name Enemy extends StaticBody2D

@export var health: int
@export var attack: int = 1
@export var base_speed: float
@export var min_speed: float = 10.0
@export var max_speed: float = 200.0
@export var tier: int
@export var cost: int
@export var bobbing: float = 45.0
@export var deaggro_radius: float = 1000.0

var direction := Vector2.ZERO
var motion := Vector2.ZERO
var velocity := Vector2.ZERO
var infection_count: int = 0
var bob: float
var speed: float

var buff_dict: Dictionary = {
	MechanicsManager.BuffType.SPEED: {"multi": [], "multi_calc": 0.0, "flat": [], "flat_calc": 0.0}
}

var enemy_id: int

@onready var sprite: Sprite2D = $Sprite2D
@onready var outline: Sprite2D = $Outline
@onready var deaggro: VisibleOnScreenNotifier2D = $Deaggro
@onready var infection_timer: Timer = $InfectionTimer
@onready var enemies := get_node("/root/Main/LightMask/Enemies")
@onready var enemies_afk := get_node("/root/Main/EnemiesAFK")

static var id: int


func _ready() -> void:
	id += 1
	enemy_id = id

	deaggro.scale = Vector2(deaggro_radius / 10, deaggro_radius / 10)
	deaggro.screen_exited.connect(set_aggro.bind(false))

	buff_dict[MechanicsManager.BuffType.SPEED]["multi"].resize(MechanicsManager.BuffBucket.size())
	buff_dict[MechanicsManager.BuffType.SPEED]["flat"].resize(MechanicsManager.BuffBucket.size())
	buff_dict[MechanicsManager.BuffType.SPEED]["multi"].fill(0.0)
	buff_dict[MechanicsManager.BuffType.SPEED]["flat"].fill(0.0)

	$Sprite2D.hide()
	set_physics_process(false)

	if self is Elite:
		initialise()
	if self is Boss:
		set_aggro(true)


func _physics_process(delta: float) -> void:
	speed = clamp(
		(
			(base_speed + buff_dict[MechanicsManager.BuffType.SPEED]["flat_calc"])
			* (1 + buff_dict[MechanicsManager.BuffType.SPEED]["multi_calc"])
		),
		min_speed,
		max_speed
	)
	#if enemy_id == 1:
	#print_debug(speed)
	motion = (direction * speed * delta)
	velocity = lerp(velocity, motion, 0.1)
	if velocity.x < 0:
		$Sprite2D.flip_h = true
		$Outline.flip_h = true
	else:
		$Sprite2D.flip_h = false
		$Outline.flip_h = false
	bob = randf_range(-bobbing, bobbing)
	sprite.rotation_degrees = lerp(sprite.rotation_degrees, bob, 0.1)
	outline.rotation_degrees = lerp(sprite.rotation_degrees, bob, 0.1)
	move_and_collide(velocity, false, 1.0)


func damage(amount: int) -> void:
	health -= amount
	try_kill()


func try_kill() -> bool:
	if health <= 0:
		kill()
		return true
	return false


func kill() -> void:
	if randf() < 0.05:
		var drop = load("res://entities/upgrades/pickup.tscn").instantiate()
		drop.position = global_position
		get_tree().current_scene.add_child.call_deferred(drop)

	UpgradeManager.on_kill.emit(self)
	remove_from_group("aggro")
	queue_free()


func infect() -> void:
	if infection_timer.is_stopped():
		infection_timer.start()
	infection_count += MechanicsManager.get_infection_count()


func set_aggro(aggro: bool) -> void:
	if aggro:
		add_to_group("aggro")
		reparent.call_deferred(enemies)
		$Sprite2D.show()
		set_physics_process(true)
	else:
		remove_from_group("aggro")
		reparent.call_deferred(enemies_afk)
		$Sprite2D.hide()
		set_physics_process(false)


func set_direction(player_pos: Vector2) -> void:
	direction = (player_pos - global_position).normalized()


func _check_infection() -> void:
	if infection_count > 0:
		health -= MechanicsManager.get_infection_damage()
		infection_count -= 1
		try_kill()
	else:
		infection_timer.stop()


func initialise() -> void:
	# Implemented just so Elite can override
	pass
