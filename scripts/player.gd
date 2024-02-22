class_name Player extends CharacterBody2D

signal just_shot

const SPEED = 300.0
const CAMERA_SPEED = 50.0
const LIGHT = 0.25
const LIGHT_SHAKE = 25

@export var aggro_radius: float
@export var aggro_shoot_radius: float
@export_enum("light_ahead", "camera_ahead", "camera_drag") var camera: String

var health: int = 50
var invuln_frames: int
var roll_disabled: int
var direction: Vector2
var light_energy: float
var flicker_intensity: float = 0.05
@onready var pistol: Pistol = $Pistol
@onready var sprite: Sprite2D = $Sprite2D
@onready var player_camera: Camera2D = $Camera2D
@onready var pickup_radius: Area2D = $PickupRadius
@onready var shadow_caster: PointLight2D = $ShadowCaster
@onready var progress_bar: TextureProgressBar = $TextureProgressBar
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var aggro_collision: CollisionShape2D = $AggroRange/CollisionShape2D


func _ready() -> void:
	shadow_caster.energy = LIGHT
	aggro_collision.shape.radius = aggro_radius
	just_shot.connect(_expand_aggro_range)


func _physics_process(_delta: float) -> void:
	direction = (
		Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	)
	if direction:
		velocity = lerp(velocity, direction * SPEED, 0.25)
	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.25)

	move_and_slide()
	_roll()
	_pickup()

	#shadow_caster.energy = lerp(shadow_caster.energy, light_energy, 0.1)
	point_light_2d.offset = lerp(
		point_light_2d.offset,
		Vector2(randf_range(-LIGHT_SHAKE, LIGHT_SHAKE), randf_range(-LIGHT_SHAKE, LIGHT_SHAKE)),
		0.25
	)
	progress_bar.value = pistol.heat_level


func _roll() -> void:
	if Input.is_action_just_pressed("roll") and not roll_disabled:
		collision.set_deferred("disabled", true)
		invuln_frames = 3
		roll_disabled = 60
		velocity = direction * SPEED * 6
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
	if health > 0:
		health -= attack
	else:
		hide()
		set_physics_process(false)
		var pikachu := Sprite2D.new()
		pikachu.texture = load("res://assets/pikachu.png")
		pikachu.scale = Vector2(0.1, 0.1)
		pikachu.global_position = global_position
		get_tree().root.add_child(pikachu)
		var tween := create_tween()
		tween.tween_property(pikachu, "scale", Vector2(1.0, 1.0), 0.5)

func _expand_aggro_range() -> void:
	aggro_collision.shape.radius = aggro_shoot_radius
	await get_tree().create_timer(0.1).timeout
	aggro_collision.shape.radius = aggro_radius

func _on_aggro_range_body_entered(body: Node2D) -> void:
	if body is Elite:
		body.set_elite_aggro()
	if body is Enemy:
		body.set_aggro(true)


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is Enemy:
		damage(body.attack)
