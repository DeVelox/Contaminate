class_name Enemy extends StaticBody2D

signal speed_changed

enum SpeedGroup { SHOCK, KNEE_CAP, BOOST, MISC }

@export var health: int = 10
@export var attack: int = 1
@export var base_speed: float = 100.0
@export var min_speed: float = 10.0
@export var max_speed: float = 200.0
@export var tier: int = 1
@export var cost: int = 1
@export var bobbing: float = 45.0
@export var deaggro_radius: float = 1000.0

var direction := Vector2.ZERO
var motion := Vector2.ZERO
var velocity := Vector2.ZERO
var infection_count: int = 0

var speed: float
var speed_flat: Array[float]
var speed_flat_calc: float
var speed_multi: Array[float]
var speed_multi_calc: float

var enemy_id: int

@onready var sprite: Sprite2D = $Sprite2D
@onready var deaggro: VisibleOnScreenNotifier2D = $Deaggro
@onready var infection_timer: Timer = $InfectionTimer

static var id: int


func _ready() -> void:
	id += 1
	enemy_id = id

	deaggro.scale = Vector2(deaggro_radius / 10, deaggro_radius / 10)
	deaggro.screen_exited.connect(set_aggro.bind(false))

	speed_flat.resize(SpeedGroup.size())
	speed_multi.resize(SpeedGroup.size())

	speed_changed.connect(_speed_calc)
	
	$Sprite2D.hide()
	set_physics_process(false)

	#apply_speed_mod(5, -50, true, SpeedGroup.KNEE_CAP)
	#apply_speed_mod(5, -20, true, SpeedGroup.KNEE_CAP)
	#apply_speed_mod(2, 30, false, SpeedGroup.BOOST)


func _physics_process(delta: float) -> void:
	speed = clamp((base_speed + speed_flat_calc) * (1 + speed_multi_calc), min_speed, max_speed)
	#if enemy_id == 1:
	#print_debug(speed)
	motion = (direction * speed * delta)
	velocity = lerp(velocity, motion, 0.1)
	sprite.rotation_degrees = lerp(sprite.rotation_degrees, randf_range(-bobbing, bobbing), 0.1)
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
	get_parent().enemy_instances.erase(self)
	queue_free()


func apply_speed_mod(
	duration: float, amount: float, multi: bool = false, group: SpeedGroup = SpeedGroup.MISC
) -> void:
	if group == SpeedGroup.MISC:
		if multi:
			speed_multi[group] += amount / 100.0
			speed_changed.emit()
			await get_tree().create_timer(duration).timeout
			speed_multi[group] -= amount / 100.0
			speed_changed.emit()
		else:
			speed_flat[group] += amount
			speed_changed.emit()
			await get_tree().create_timer(duration).timeout
			speed_flat[group] -= amount
			speed_changed.emit()
	else:
		if multi and absf(amount / 100.0) > absf(speed_multi[group]):
			speed_multi[group] = amount / 100.0
			speed_changed.emit()
			await get_tree().create_timer(duration).timeout
			speed_multi[group] = 0.0
			speed_changed.emit()
		elif absf(amount) > absf(speed_flat[group]):
			speed_flat[group] = amount
			speed_changed.emit()
			await get_tree().create_timer(duration).timeout
			speed_flat[group] = 0.0
			speed_changed.emit()


func infect() -> void:
	if infection_timer.is_stopped():
		infection_timer.start()
	infection_count += MechanicsManager.get_infection_count()


func set_aggro(aggro: bool) -> void:
	if aggro:
		add_to_group("aggro")
		$Sprite2D.show()
		set_physics_process(true)
	else:
		remove_from_group("aggro")
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


func _sum(a: float, b: float) -> float:
	return a + b


func _speed_calc() -> void:
	speed_multi_calc = speed_multi.reduce(_sum)
	speed_flat_calc = speed_flat.reduce(_sum)
