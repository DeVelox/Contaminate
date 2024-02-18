extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	OmniManager.on_kill.connect(_lightning_strike)
	$Area2D/CollisionShape2D.disable = true
	$Area2D.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _lightning_strike(enemy: Enemy) -> void:
	var effect = get_child(0).duplicate()
