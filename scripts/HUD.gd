extends MarginContainer

signal health_change(health: int)
signal upgrade_change(upgrade: String)


func _update_health(health: int) -> void:
	%Hearts.custom_minimum_size.x = health * 48
