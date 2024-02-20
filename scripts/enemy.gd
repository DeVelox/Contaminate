class_name Enemy extends StaticBody2D

@export var health := 3
@export var speed := 100.0
@export var cost := 1
var direction := Vector2.ZERO
var motion := Vector2.ZERO
var velocity := Vector2.ZERO
var physics := true


func _physics_process(delta: float) -> void:
	motion = (direction * speed * delta)
	velocity = lerp(velocity, motion, 0.1)
	move_and_collide(velocity, false, 1.0)


func _process(_delta: float) -> void:
	set_physics_process(physics)


func damage() -> void:
	if health > 0:
		health -= 1
	else:
		var drop = load("res://entities/upgrades/pickup.tscn").instantiate()
		drop.position = global_position
		get_tree().root.add_child.call_deferred(drop)
		
		UpgradeManager.on_kill.emit(self)
		get_parent().enemy_instances.erase(self)
		queue_free()


func disable_physics() -> void:
	physics = false


func enable_physics() -> void:
	physics = true
