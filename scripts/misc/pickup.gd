extends Node2D

var threshold: Array[int] = [1, 10, 50, 100, 200, 500, 1000]

@onready var upgrade_popup := get_node("/root/Main/Menus/UpgradeSelect")

static var count: int

func activate() -> void:
	count += 1
	if threshold.has(count):
		upgrade_popup.upgrade_select()
		upgrade_popup.currently_selecting = true
	queue_free()