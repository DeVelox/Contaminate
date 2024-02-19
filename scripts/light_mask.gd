extends Sprite2D

@export var player: Player


func _process(_delta) -> void:
	global_position = player.global_position
