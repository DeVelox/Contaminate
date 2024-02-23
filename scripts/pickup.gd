@tool
extends Node2D
var upgrade: String = "Lightning"


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
	var weapon_select = get_node("/root/Main/Menus/UpgradeSelect")
	weapon_select.upgrade_select()
	UpgradeManager.add_upgrade(upgrade)
	queue_free()
