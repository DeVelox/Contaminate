class_name Elite extends Enemy

var hits: int = 3


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if hits > 0:
			hits -= 1
		else:
			get_parent().get_parent().enemy_instances.erase(self)
			queue_free()
