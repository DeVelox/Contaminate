extends Node2D

@onready var main_menu = get_node("/root/Start/Menus/MainMenu")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundManager.crossfade(SoundManager.MUSIC_MENU)
	main_menu.show()
