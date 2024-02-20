class_name Bullet extends Ammo


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = origin


func _init():
	speed = 300
	pen = 10


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += speed * delta * direction
	await get_tree().create_timer(3).timeout
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		if pen >= 0:
			UpgradeManager.on_hit.emit(body)
			body.damage()
			pen -= 1
		else:
			queue_free()
		
