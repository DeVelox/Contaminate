class_name Rocket extends Ammo

signal explosion_sound

@onready var explosion: Area2D = $Explosion
@onready var collision: CollisionShape2D = $Explosion/CollisionShape2D


func _on_contact(_body: Node2D) -> void:
	await get_tree().create_timer(0.1).timeout
	explosion_sound.emit()
	explosion.monitoring = true
	explosion.monitorable = true
	collision.disabled = false
	await get_tree().create_timer(0.1).timeout
	queue_free()


func _on_explosion(body: Node2D) -> void:
	if body is Enemy:
		if randf() < 0.1:
			UpgradeManager.on_hit.emit(body)
		body.damage(damage)


func _explosion_sound() -> void:
	SoundManager.sfx(SoundManager.EXPLOSION)