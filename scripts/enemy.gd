class_name Enemy extends StaticBody2D

var direction := Vector2.ZERO

func _physics_process(delta: float) -> void:
	move_and_collide(direction * delta)


func _on_area_entered(area: Area2D) -> void:
	if area is Bullet:
		get_parent().enemy_instances.erase(self)
		queue_free()
