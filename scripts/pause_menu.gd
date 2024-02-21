extends CenterContainer

var toggled: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		if is_visible() and toggled:
			toggled = false
			get_tree().paused = false
			hide()
		else:
			toggled = true
			get_tree().paused = true
			show()
	pass


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_options_pressed() -> void:
	%PauseMenu.hide()
	%Options.show()
