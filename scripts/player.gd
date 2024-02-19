class_name Player extends CharacterBody2D

const SPEED = 300.0
const CAMERA_SPEED = 50.0
const LIGHT = 0.25

@export_enum("light_ahead", "camera_ahead", "camera_drag") var camera: String

var light_energy: float = 0.25
var flicker_intensity: float = 0.05


func _ready() -> void:
	$ShadowCaster.energy = LIGHT


func _physics_process(_delta: float) -> void:
	var direction := (
		Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	)
	if direction:
		velocity = lerp(velocity, direction * SPEED, 0.25)
	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.25)

	move_and_slide()

	$ShadowCaster.energy = lerp($ShadowCaster.energy, light_energy, 0.1)
	$TextureProgressBar.value = $Pistol.heat_level

	match camera:
		"light_ahead":
			$ShadowCaster.position = lerp($ShadowCaster.position, direction * CAMERA_SPEED, 0.1)
			$EnemyCulling.position = lerp($EnemyCulling.position, direction * CAMERA_SPEED, 0.1)
		"camera_ahead":
			$Camera2D.offset = lerp($Camera2D.offset, direction * CAMERA_SPEED, 0.1)
		"camera_drag":
			$Camera2D.offset = lerp($Camera2D.offset, -direction * CAMERA_SPEED, 0.1)
		_:
			pass

	for i in $PickupRadius.get_overlapping_bodies():
		i.global_position = lerp(i.global_position, global_position, 0.1)
		if i.global_position.distance_squared_to(global_position) < 25:
			i.activate()


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.show()


func _on_area_2d_2_body_exited(body: Node2D) -> void:
	if body is Enemy:
		body.hide()


func _on_flicker_timeout() -> void:
	light_energy = randf_range(LIGHT - flicker_intensity, LIGHT + flicker_intensity)
