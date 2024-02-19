@tool
extends Node2D
var upgrade: String


func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary]
	var hint_string: String
	for i in OmniManager.upgrades:
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
	OmniManager.add_upgrade(upgrade)
	queue_free()
