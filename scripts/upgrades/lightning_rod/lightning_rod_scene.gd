extends Area2D

const DAMAGE_DURATION = 0.1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(DAMAGE_DURATION).timeout
	body_entered.disconnect(_on_body_entered)
	await get_tree().create_timer(1).timeout
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.damage(1)
