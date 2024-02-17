class_name Enemy extends StaticBody2D

var hits := 1
var direction := Vector2.ZERO


func _physics_process(delta: float) -> void:
	move_and_collide(direction * delta + Vector2(randf_range(-1, 1), randf_range(-1, 1)))


func destroy() -> void:
	if hits > 0:
		hits -= 1
	else:
		get_parent().enemy_instances.erase(self)
		queue_free()
