@tool
extends Node2D
var upgrade: String = "Lightning"

var threshold: Array[int] = [1, 10, 50, 100, 200, 500, 1000]
static var count: int

func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	if Engine.is_editor_hint():
		var hint_string: String = ""
		for i in UpgradeManager.upgrades:
			hint_string += i + ","
		properties.append(
			{
				"name": "upgrade",
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": hint_string
			}
		)
	return properties


func activate() -> void:
	count += 1
	if threshold.has(count):
		var upgrade_popup := get_node("/root/Main/Menus/UpgradeSelect")
		upgrade_popup.upgrade_select()
		upgrade_popup.currently_selecting = true
	queue_free()
