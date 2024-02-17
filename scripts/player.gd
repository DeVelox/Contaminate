class_name Player extends CharacterBody2D

const SPEED = 300.0
const CAMERA_SPEED = 50.0

@export_enum("light_ahead", "camera_ahead", "camera_drag") var camera: String

func _physics_process(delta: float) -> void:
	var direction := (
		Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	)
	if direction:
		velocity = lerp(velocity, direction * SPEED, 0.25)
	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.25)
		
	match camera:
		"light_ahead":
			$PointLight2D.position = lerp($PointLight2D.position, direction * CAMERA_SPEED, 0.1)
			$PointLight2D2.position = lerp($PointLight2D2.position, direction * CAMERA_SPEED, 0.1)
			$EnemyCulling.position = lerp($EnemyCulling.position, direction * CAMERA_SPEED, 0.1)
		"camera_ahead":
			$Camera2D.offset = lerp($Camera2D.offset, direction * CAMERA_SPEED, 0.1)
		"camera_drag":
			$Camera2D.offset = lerp($Camera2D.offset, -direction * CAMERA_SPEED, 0.1)
		_:
			pass

	move_and_slide()

	$TextureProgressBar.value = $Pistol.heat_level


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.show()


func _on_area_2d_2_body_exited(body: Node2D) -> void:
	if body is Enemy:
		body.hide()
