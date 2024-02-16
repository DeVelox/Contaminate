class_name Elite extends Enemy

var hits: int = 3


func _on_elite_area_entered(area: Area2D) -> void:
	if area is Bullet:
		if hits > 0:
			hits -= 1
		else:
			get_parent().get_parent().enemy_instances.erase(self)
			queue_free()
