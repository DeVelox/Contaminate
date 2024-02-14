extends Node
@export var player: CharacterBody2D
@export var enemy: PackedScene
@export var timer: float = 1.0;

var timer_running: float
var enemies: Array[StaticBody2D]
var stop_moving: bool
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer_running = timer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer_running > 0:
		timer_running -= delta
	else:
		var enemy_instance := enemy.instantiate()
		var new_position := player.position + Vector2.ONE.normalized().rotated(randf_range(0, 2*PI)) * randf_range(190, 300)
		
		enemy_instance.position = new_position
		add_child(enemy_instance)
		timer_running = timer
		enemies.append(enemy_instance)
	for i in enemies:
		if i.position.distance_squared_to(player.position) < pow(190, 2):
			stop_moving = true
		else:
			i.position = lerp(i.position, player.position, 0.1 * delta)
		
