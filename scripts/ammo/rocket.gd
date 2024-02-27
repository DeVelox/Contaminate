class_name Rocket extends Ammo

signal explosion_sound

@onready var explosion: Area2D = $Explosion
@onready var collision: CollisionShape2D = $Explosion/CollisionShape2D


func on_contact(_body: Node2D) -> void:
	await get_tree().create_timer(0.02).timeout
	explosion_sound.emit()
	explosion.monitoring = true
	explosion.monitorable = true
	collision.disabled = false
	await get_tree().create_timer(0.1).timeout
	queue_free()


func _on_explosion(body: Node2D) -> void:
	if body is Enemy:
		var current_damage = damage * 2 if is_crit else damage
		var current_bonus_damage = bonus_damage * 2 if is_crit else bonus_damage
		if randf() < proc_coeff:
			if is_crit:
				UpgradeManager.on_crit.emit(body)
			UpgradeManager.on_hit.emit(body)
		body.damage(current_damage + current_bonus_damage)


func _explosion_sound() -> void:
	SoundManager.sfx(SoundManager.EXPLOSION)
