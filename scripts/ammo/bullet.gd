class_name Bullet extends Ammo


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		var current_damage = damage * 2 if is_crit else damage
		var current_bonus_damage = bonus_damage * 2 if is_crit else bonus_damage
		if penetration >= 0:
			if randf() < proc_coeff:
				if is_crit:
					UpgradeManager.on_crit.emit(body)
				UpgradeManager.on_hit.emit(body)
			body.damage(current_damage + current_bonus_damage)
			penetration -= 1
		else:
			queue_free()
