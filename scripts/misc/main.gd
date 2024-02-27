extends Node2D

@onready var pause_menu := get_node("/root/Main/Menus/PauseMenu")
@onready var weapon_popup := get_node("/root/Main/Menus/WeaponSelect")
@onready var hud = get_node("/root/Main/Menus/HUD")


func _ready() -> void:
	get_tree().paused = false
	SoundManager.crossfade(SoundManager.MUSIC_NORMAL)
	weapon_popup.weapon_select()
	hud.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		get_tree().paused = true
		pause_menu.show()
