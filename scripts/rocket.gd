class_name Rocket extends Ammo

@onready var explosion: Area2D = $Explosion
@onready var collision: CollisionShape2D = $Explosion/CollisionShape2D

func _on_contact(_body: Node2D) -> void:
	await get_tree().create_timer(0.5).timeout
	SoundManager.sfx(SoundManager.BOOM)
	explosion.monitoring = true
	explosion.monitorable = true
	collision.disabled = false
	await get_tree().create_timer(0.1).timeout
	queue_free()
	
func _on_explosion(body: Node2D) -> void:
	if body is Enemy:
		UpgradeManager.on_hit.emit(body)
		body.damage(damage)
