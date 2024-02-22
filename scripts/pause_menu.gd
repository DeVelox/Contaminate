extends CenterContainer

var toggled: bool
var zone_class: Zone = load("res://scripts/zone.gd").new()


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


func _on_restart_pressed() -> void:
	zone_class.loaded = null
	zone_class.count = 0
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_options_pressed() -> void:
	%PauseMenu.hide()
	%Options.show()
