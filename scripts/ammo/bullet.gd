class_name Bullet extends Ammo


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		if penetration >= 0:
			if is_crit:
				UpgradeManager.on_crit.emit(body)
				damage *= 2
				bonus_damage *= 2
			UpgradeManager.on_hit.emit(body)
			body.damage(damage + bonus_damage)
			penetration -= 1
		else:
			queue_free()
