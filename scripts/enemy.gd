class_name Enemy extends Area2D

func _on_area_entered(area: Area2D) -> void:
	if area is Bullet:
		get_parent().get_parent().enemy_instances.erase(self)
		queue_free()
