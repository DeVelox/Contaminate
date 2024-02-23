extends CenterContainer

const UPGRADE = preload("res://entities/prefabs/upgrade.tscn")

@onready var hbox: HBoxContainer = $PanelContainer/MarginContainer/CenterContainer/HBoxContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func upgrade_select() -> void:
	var upgrade_selection := UpgradeManager.random_upgrades() as Array[Upgrade]
	if upgrade_selection.is_empty():
		return
	get_tree().paused = true
	for i in upgrade_selection:
		var selection := UPGRADE.instantiate()
		selection.uicon = i.icon
		selection.uname = i.uname
		selection.udesc = i.description
		selection.pressed.connect(_close)
		hbox.add_child.call_deferred(selection)
	show()
	
func _close() -> void:
	get_tree().paused = false
	hide()
	for i in hbox.get_children():
		hbox.remove_child.call_deferred(i)
		i.queue_free()
