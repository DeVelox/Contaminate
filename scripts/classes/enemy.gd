class_name Enemy extends StaticBody2D

signal stat_changed(stat)


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

var buff_dict: Dictionary = {
	MechanicsManager.BuffType.SPEED: {"multi": [], "multi_calc": 0.0, "flat": [], "flat_calc": 0.0}
}

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

	buff_dict[MechanicsManager.BuffType.SPEED]["multi"].resize(MechanicsManager.BuffBucket.size())
	buff_dict[MechanicsManager.BuffType.SPEED]["flat"].resize(MechanicsManager.BuffBucket.size())
	buff_dict[MechanicsManager.BuffType.SPEED]["multi"].fill(0.0)
	buff_dict[MechanicsManager.BuffType.SPEED]["flat"].fill(0.0)

	stat_changed.connect(_speed_calc)

	$Sprite2D.hide()
	set_physics_process(false)


#
#apply_buff(5, -50, BuffType.SPEED, true, BuffBucket.KNEE_CAP)
#apply_buff(5, -20, BuffType.SPEED,  true, BuffBucket.KNEE_CAP)
#apply_buff(2, 30, BuffType.SPEED,  false, BuffBucket.BOOST)


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
	queue_free()


func apply_buff(
	duration: float,
	amount: float,
	buff_type,
	multi: bool = false,
	group = MechanicsManager.BuffBucket.MISC
) -> void:
	if group == MechanicsManager.BuffBucket.MISC:
		if multi:
			buff_dict[buff_type]["multi"][group] += amount / 100.0
			stat_changed.emit(buff_type)
			await get_tree().create_timer(duration).timeout
			buff_dict[buff_type]["multi"][group] -= amount / 100.0
			stat_changed.emit(buff_type)
		else:
			buff_dict[buff_type]["flat"][group] += amount
			stat_changed.emit(buff_type)
			await get_tree().create_timer(duration).timeout
			buff_dict[buff_type]["flat"][group] -= amount
			stat_changed.emit(buff_type)
	else:
		if multi and absf(amount / 100.0) > absf(buff_dict[buff_type]["multi"][group]):
			buff_dict[buff_type]["multi"][group] = amount / 100.0
			stat_changed.emit(buff_type)
			await get_tree().create_timer(duration).timeout
			buff_dict[buff_type]["multi"][group] = 0.0
			stat_changed.emit(buff_type)
		elif absf(amount) > absf(buff_dict[buff_type]["flat"][group]):
			buff_dict[buff_type]["flat"][group] = amount
			stat_changed.emit(buff_type)
			await get_tree().create_timer(duration).timeout
			buff_dict[buff_type]["flat"][group] = 0.0
			stat_changed.emit(buff_type)


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


func _speed_calc(buff_type) -> void:
	buff_dict[buff_type]["multi_calc"] = buff_dict[buff_type]["multi"].reduce(_sum)
	buff_dict[buff_type]["flat_calc"] = buff_dict[buff_type]["flat"].reduce(_sum)
