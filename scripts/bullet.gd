class_name Bullet extends Ammo


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		if pen >= 0:
			UpgradeManager.on_hit.emit(body)
			body.damage(damage)
			pen -= 1
		else:
			queue_free()
