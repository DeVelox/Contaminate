class_name Enemy extends StaticBody2D

@export var hits := 1
@export var shake := 1.0
@export var speed := 100.0
var direction := Vector2.ZERO
var motion := Vector2.ZERO
var velocity := Vector2.ZERO


func _physics_process(delta: float) -> void:
	motion = (
		direction * speed * delta + Vector2(randf_range(-shake, shake), randf_range(-shake, shake))
	)
	velocity = lerp(velocity, motion, 0.1)
	move_and_collide(velocity, false, 0.1)


func destroy() -> void:
	if hits > 0:
		hits -= 1
	else:
		get_parent().enemy_instances.erase(self)
		queue_free()
