extends CenterContainer



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not get_tree().current_scene.name == "Start":
		return
	if Input.is_action_just_pressed("menu"):
		show()


func _on_start_game_pressed() -> void:
	# Reset static variables
	var zone_class: Zone = load("res://scripts/misc/zone.gd").new()
	var drop_class: Node2D = load("res://scripts/misc/pickup.gd").new()
	zone_class.loaded = null
	zone_class.count = 0
	drop_class.count = 0
	UpgradeManager.reset_upgrades()

	get_tree().paused = false
	if OS.is_debug_build():
		get_tree().change_scene_to_file("res://main.tscn")
	else:
		get_tree().change_scene_to_file("res://intro.tscn")
	%MainMenu.hide()


func _on_options_pressed() -> void:
	%MainMenu.hide()
	%Options.show()
