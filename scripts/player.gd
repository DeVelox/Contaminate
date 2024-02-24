class_name Player extends CharacterBody2D

signal just_shot
signal stat_changed(stat)

const CAMERA_SPEED = 50.0
const LIGHT = 0.25
const LIGHT_SHAKE = 25

@export var base_speed: float = 140.0
@export var min_speed: float = 10.0
@export var max_speed: float = 500.0
@export var aggro_radius: float
@export var aggro_shoot_radius: float
@export_enum("light_ahead", "camera_ahead", "camera_drag") var camera: String

var health: int = 5
var invuln_frames: int
var roll_disabled: int
var direction: Vector2
var light_energy: float
var flicker_intensity: float = 0.05
var speed: float
var update_rate: float = 0.1
var update_rate_curr: float
var buff_dict: Dictionary = {
	MechanicsManager.BuffType.SPEED: {"multi": [], "multi_calc": 0.0, "flat": [], "flat_calc": 0.0}
}

@onready var sprite: Sprite2D = $Sprite2D
@onready var player_camera: Camera2D = $Camera2D
@onready var pickup_radius: Area2D = $PickupRadius
@onready var shadow_caster: PointLight2D = $ShadowCaster
@onready var progress_bar: TextureProgressBar = $TextureProgressBar
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var aggro_collision: CollisionShape2D = $AggroRange/CollisionShape2D
@onready var invuln: Timer = $Invuln
@onready var hud := get_node("/root/Main/Menus/HUD")


func _ready() -> void:
	shadow_caster.energy = LIGHT
	aggro_collision.shape.radius = aggro_radius
	just_shot.connect(_expand_aggro_range)
	hud.update_health(health)

	buff_dict[MechanicsManager.BuffType.SPEED]["multi"].resize(MechanicsManager.BuffBucket.size())
	buff_dict[MechanicsManager.BuffType.SPEED]["flat"].resize(MechanicsManager.BuffBucket.size())
	buff_dict[MechanicsManager.BuffType.SPEED]["multi"].fill(0.0)
	buff_dict[MechanicsManager.BuffType.SPEED]["flat"].fill(0.0)

	stat_changed.connect(_speed_calc)


func _physics_process(delta: float) -> void:
	speed = clamp(
		(
			(base_speed + buff_dict[MechanicsManager.BuffType.SPEED]["flat_calc"])
			* (1 + buff_dict[MechanicsManager.BuffType.SPEED]["multi_calc"])
		),
		min_speed,
		max_speed
	)

	direction = (
		Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	)
	if direction:
		velocity = lerp(velocity, direction * speed, 0.25)
	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.25)

	move_and_slide()
	_roll()
	_pickup()
	_move_enemies(delta)

	#shadow_caster.energy = lerp(shadow_caster.energy, light_energy, 0.1)
	point_light_2d.offset = lerp(
		point_light_2d.offset,
		Vector2(randf_range(-LIGHT_SHAKE, LIGHT_SHAKE), randf_range(-LIGHT_SHAKE, LIGHT_SHAKE)),
		0.25
	)


func _roll() -> void:
	if Input.is_action_just_pressed("roll") and not roll_disabled:
		SoundManager.sfx(SoundManager.ROLL)
		collision.set_deferred("disabled", true)
		invuln_frames = 3
		roll_disabled = 60
		velocity = direction * speed * 6
		UpgradeManager.on_roll.emit(self)
	if roll_disabled > 0:
		roll_disabled -= 1
	if invuln_frames > 0:
		invuln_frames -= 1
	else:
		collision.set_deferred("disabled", false)


func _pickup() -> void:
	for i in pickup_radius.get_overlapping_bodies():
		i.global_position = lerp(i.global_position, global_position, 0.1)
		if i.global_position.distance_squared_to(global_position) < 25:
			i.activate()


func _camera_mode(mode: String) -> void:
	match mode:
		"light_ahead":
			shadow_caster.position = lerp(shadow_caster.position, direction * CAMERA_SPEED, 0.1)
		"camera_ahead":
			player_camera.offset = lerp(player_camera.offset, direction * CAMERA_SPEED, 0.1)
		"camera_drag":
			player_camera.offset = lerp(player_camera.offset, -direction * CAMERA_SPEED, 0.1)
		_:
			return


func _on_flicker_timeout() -> void:
	light_energy = randf_range(LIGHT - flicker_intensity, LIGHT + flicker_intensity)


func damage(attack: int) -> void:
	if invuln.time_left:
		return
	if health > 1:
		SoundManager.sfx(SoundManager.HIT)
		health -= attack
		invuln.start(0.5)
	else:
		SoundManager.sfx(SoundManager.DEATH)
		health -= attack
		hide()
		set_physics_process(false)
		var pikachu := Sprite2D.new()
		pikachu.texture = load("res://assets/pikachu.png")
		pikachu.scale = Vector2(0.1, 0.1)
		pikachu.global_position = global_position
		get_tree().root.add_child(pikachu)
		var tween := create_tween()
		tween.tween_property(pikachu, "scale", Vector2(1.0, 1.0), 0.5)
	hud.update_health(health)


func _expand_aggro_range() -> void:
	aggro_collision.shape.radius = aggro_shoot_radius
	await get_tree().create_timer(0.1).timeout
	aggro_collision.shape.radius = aggro_radius


func _on_aggro_range_body_entered(body: Node2D) -> void:
	SoundManager.crossfade(SoundManager.MUSIC_COMBAT)
	if body is Elite:
		body.set_elite_aggro()
	if body is Enemy:
		body.set_aggro(true)


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is Enemy:
		damage(body.attack)


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


func _sum(a: float, b: float) -> float:
	return a + b


func _speed_calc(buff_type) -> void:
	buff_dict[buff_type]["multi_calc"] = buff_dict[buff_type]["multi"].reduce(_sum)
	buff_dict[buff_type]["flat_calc"] = buff_dict[buff_type]["flat"].reduce(_sum)


func _move_enemies(delta: float) -> void:
	if update_rate_curr < 0:
		get_tree().call_group("aggro", "set_direction", global_position)
		update_rate_curr = update_rate
	else:
		update_rate_curr -= delta
