extends CenterContainer

const TOOL = preload("res://entities/weapons/tool.tscn")
const RIFLE = preload("res://entities/weapons/rifle.tscn")
const SHOTGUN = preload("res://entities/weapons/shotgun.tscn")
const EXPLOSIVE = preload("res://entities/weapons/explosive.tscn")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func weapon_select() -> void:
	get_tree().paused = true
	show()


func _on_rifle_pressed() -> void:
	_swap_gun(RIFLE)
	get_tree().paused = false
	hide()


func _on_shotgun_pressed() -> void:
	_swap_gun(SHOTGUN)
	get_tree().paused = false
	hide()


func _on_explosive_pressed() -> void:
	_swap_gun(EXPLOSIVE)
	get_tree().paused = false
	hide()


func _swap_gun(gun: PackedScene) -> void:
	var player: Player = get_node("/root/Main/Player")
	var current_gun := player.get_child(3)
	current_gun.add_sibling(gun.instantiate())
	player.remove_child.call_deferred(current_gun)
	current_gun.queue_free()
