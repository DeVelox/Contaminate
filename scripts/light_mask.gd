extends Sprite2D

@export var player: Player
var original_location: Vector2


func _ready() -> void:
	original_location = $Enemies.global_position


func _physics_process(_delta) -> void:
	global_position = player.global_position
	$Enemies.global_position = original_location
