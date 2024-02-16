class_name Player extends CharacterBody2D

const SPEED = 300.0


func _physics_process(delta: float) -> void:
	var direction := (
		Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
		. normalized()
	)
	if direction:
		velocity = lerp(velocity, direction * SPEED, 0.25)
	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.25)

	move_and_slide()
