extends CenterContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func weapon_select() -> void:
	get_tree().paused = true
	show()


func _on_rifle_pressed() -> void:
	get_tree().paused = false
	hide()


func _on_shotgun_pressed() -> void:
	get_tree().paused = false
	hide()


func _on_explosive_pressed() -> void:
	get_tree().paused = false
	hide()
