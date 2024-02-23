extends Node2D

@onready var pause_menu = get_node("/root/Main/Menus/PauseMenu")

func _ready() -> void:
	SoundManager.crossfade(SoundManager.MUSIC_NORMAL)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		get_tree().paused = true
		pause_menu.show()
