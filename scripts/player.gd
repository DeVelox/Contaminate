class_name Player extends CharacterBody2D

const SPEED = 300.0
const CAMERA_SPEED = 50.0
const LIGHT = 0.25

@export_enum("light_ahead", "camera_ahead", "camera_drag") var camera: String

var direction: Vector2
var light_energy: float
var flicker_intensity: float = 0.05
@onready var pistol: Pistol = $Pistol
@onready var camera_2d: Camera2D = $Camera2D
@onready var pickup_radius: Area2D = $PickupRadius
@onready var shadow_caster: PointLight2D = $ShadowCaster
@onready var progress_bar: TextureProgressBar = $TextureProgressBar


func _ready() -> void:
	shadow_caster.energy = LIGHT


func _physics_process(_delta: float) -> void:
	direction = (
		Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	)
	if direction:
		velocity = lerp(velocity, direction * SPEED, 0.25)
	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.25)

	move_and_slide()

	shadow_caster.energy = lerp(shadow_caster.energy, light_energy, 0.1)
	progress_bar.value = pistol.heat_level

	for i in pickup_radius.get_overlapping_bodies():
		i.global_position = lerp(i.global_position, global_position, 0.1)
		if i.global_position.distance_squared_to(global_position) < 25:
			i.activate()


func _camera_mode(mode: String) -> void:
	match mode:
		"light_ahead":
			shadow_caster.position = lerp(shadow_caster.position, direction * CAMERA_SPEED, 0.1)
		"camera_ahead":
			camera_2d.offset = lerp(camera_2d.offset, direction * CAMERA_SPEED, 0.1)
		"camera_drag":
			camera_2d.offset = lerp(camera_2d.offset, -direction * CAMERA_SPEED, 0.1)
		_:
			return

func _on_flicker_timeout() -> void:
	light_energy = randf_range(LIGHT - flicker_intensity, LIGHT + flicker_intensity)
