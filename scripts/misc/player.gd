class_name Player extends CharacterBody2D

signal just_shot

const CAMERA_SPEED = 50.0
const LIGHT = 0.25
const LIGHT_SHAKE = 25

@export var base_speed: float = 140.0
@export var min_speed: float = 10.0
@export var max_speed: float = 500.0
@export var aggro_radius: float
@export var aggro_shoot_radius: float
@export_enum("light_ahead", "camera_ahead", "camera_drag") var camera: String

var max_health: int = 5
var health: int = max_health
var invuln_frames: int
var roll_duration: int
var roll_disabled: int
var direction: Vector2
var light_energy: float
var pbv: float
var speed: float
var update_rate: float = 0.1
var update_rate_curr: float
var base_crit_chance: float = 0.05
var crit_chance: float = base_crit_chance
var heat_cost_multi: float = 1.0
var damage_bonus: int = 0

var buff_dict: Dictionary = {
	MechanicsManager.BuffType.SPEED: {"multi": [], "multi_calc": 0.0, "flat": [], "flat_calc": 0.0},
	MechanicsManager.BuffType.CRIT_CHANCE:
	{"multi": [], "multi_calc": 0.0, "flat": [], "flat_calc": 0.0}
}

@onready var sprite: Sprite2D = $Sprite2D
@onready var player_camera: Camera2D = $Camera2D
@onready var pickup_radius: Area2D = $PickupRadius
@onready var shadow_caster: PointLight2D = $ShadowCaster
@onready var creepy_noise: Timer = $Noise
@onready var progress_bar: TextureProgressBar = $TextureProgressBar
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var aggro_collision: CollisionShape2D = $AggroRange/CollisionShape2D
@onready var invuln: Timer = $Invuln
@onready var hud := get_node("/root/Main/Menus/HUD")
@onready var vignette := get_node("/root/Main/Shaders/Vignette")


func _ready() -> void:
	shadow_caster.energy = LIGHT
	aggro_collision.shape.radius = aggro_radius
	just_shot.connect(_expand_aggro_range)
	hud.update_health(health, max_health)

	for mehcanic in buff_dict:
		buff_dict[mehcanic]["multi"].resize(MechanicsManager.BuffBucket.size())
		buff_dict[mehcanic]["flat"].resize(MechanicsManager.BuffBucket.size())
		buff_dict[mehcanic]["multi"].fill(0.0)
		buff_dict[mehcanic]["flat"].fill(0.0)


func _physics_process(delta: float) -> void:
	_calculate_properties()

	direction = (
		Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	)
	if roll_duration == 0:
		if direction:
			velocity = lerp(velocity, direction * speed, 0.25)
		else:
			velocity = lerp(velocity, Vector2.ZERO, 0.25)
	
	if velocity.x < 0:
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false

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

	pbv = progress_bar.value / 100
	progress_bar.self_modulate = Color(pbv, 1 - pbv, 1 - pbv)


func _calculate_properties() -> void:
	speed = clamp(
		(
			(base_speed + buff_dict[MechanicsManager.BuffType.SPEED]["flat_calc"])
			* (1 + buff_dict[MechanicsManager.BuffType.SPEED]["multi_calc"])
		),
		min_speed,
		max_speed
	)

	crit_chance = clamp(
		(
			(base_crit_chance + buff_dict[MechanicsManager.BuffType.CRIT_CHANCE]["flat_calc"])
			* (1 + buff_dict[MechanicsManager.BuffType.CRIT_CHANCE]["multi_calc"])
		),
		0.0,
		5.0
	)
	# print_debug(crit_chance)


func _roll() -> void:
	if Input.is_action_just_pressed("roll") and not roll_disabled:
		SoundManager.sfx(SoundManager.ROLL)
		collision.set_deferred("disabled", true)
		invuln_frames = 5
		roll_duration = 10
		roll_disabled = 120
		velocity = direction * speed * 6
		UpgradeManager.on_roll.emit(self)
	if roll_duration > 0:
		roll_duration -= 1
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


func damage(attack: int) -> void:
	if invuln.time_left:
		return
	if health > 1:
		SoundManager.sfx(SoundManager.HIT)
		health -= attack
		UpgradeManager.on_hit.emit(self)
		invuln.start(0.5)
	else:
		SoundManager.sfx(SoundManager.DEATH)
		health -= attack
		hide()
		hud.reset_upgrade_list()
		set_physics_process(false)
		var tween := create_tween()
		tween.tween_property(vignette.material, "shader_parameter/vignette_intensity", 50.0, 2.0)
		tween.tween_callback(hud.pause_game)
		# RIP Pikachu
		# var pikachu := Sprite2D.new()
		# pikachu.texture = load("res://assets/pikachu.png")
		# pikachu.scale = Vector2(0.1, 0.1)
		# pikachu.global_position = global_position
		# get_tree().root.add_child(pikachu)
		# var tween := create_tween()
		# tween.tween_property(pikachu, "scale", Vector2(1.0, 1.0), 0.5)

	hud.update_health(health, max_health)


func heal(amount: int) -> void:
	health = min(max_health, health + amount)
	UpgradeManager.on_heal.emit(self)
	hud.update_health(health, max_health)


func _expand_aggro_range() -> void:
	aggro_collision.shape.radius = aggro_shoot_radius
	await get_tree().create_timer(0.1).timeout
	aggro_collision.shape.radius = aggro_radius


func _on_aggro_range_body_entered(body: Node2D) -> void:
	SoundManager.crossfade(SoundManager.MUSIC_COMBAT)
	if creepy_noise.is_stopped():
		SoundManager.sfx(SoundManager.CREATURES)
		creepy_noise.wait_time = randf_range(20, 30)
		creepy_noise.start()
	if body is Elite:
		body.set_elite_aggro()
	if body is Enemy:
		body.set_aggro(true)


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is Enemy:
		damage(body.attack)


func _move_enemies(delta: float) -> void:
	if update_rate_curr < 0:
		get_tree().call_group("aggro", "set_direction", global_position)
		update_rate_curr = update_rate
	else:
		update_rate_curr -= delta


func _on_boss_timeout() -> void:
	# Figure out which bosses we have
	var enemy_container: Node2D = get_node("/root/Main/EnemiesAFK")
	var boss1 := load("res://entities/enemies/grunt_boss.tscn").instantiate() as Boss
	var boss2 := load("res://entities/enemies/tank_boss.tscn").instantiate() as Boss

	if $Boss.wait_time <= 300:
		boss1.global_position = global_position + (Vector2(randf(), randf()).normalized() * 500)
		enemy_container.add_child.call_deferred(boss1)
		$Boss.start(600)
	else:
		boss2.global_position = global_position + (Vector2(randf(), randf()).normalized() * 500)
		enemy_container.add_child.call_deferred(boss2)
		

