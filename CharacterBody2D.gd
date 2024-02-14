extends CharacterBody2D


const SPEED = 300.0


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_h := Input.get_axis("ui_left", "ui_right")
	var direction_v := Input.get_axis("ui_up", "ui_down")
	
	if direction_h or direction_v:
		velocity = lerp(velocity, Vector2(direction_h, direction_v).normalized() * SPEED, 0.25)
	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.25)

	move_and_slide()
