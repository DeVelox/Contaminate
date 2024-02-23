extends CenterContainer

const PISTOL = preload("res://entities/weapons/pistol.tscn")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func weapon_select() -> void:
	get_tree().paused = true
	show()


func _on_rifle_pressed() -> void:
	var player: Player = get_node("/root/Main/Player")
	var current_gun := player.get_child(3)
	current_gun.add_sibling(PISTOL.instantiate())
	player.remove_child.call_deferred(current_gun)
	current_gun.queue_free()
	get_tree().paused = false
	hide()


func _on_shotgun_pressed() -> void:
	get_tree().paused = false
	hide()


func _on_explosive_pressed() -> void:
	get_tree().paused = false
	hide()
