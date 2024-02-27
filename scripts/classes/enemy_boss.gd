class_name Boss extends Enemy


func set_aggro(aggro: bool) -> void:
	# I'm always angry, that's my secret.
	if aggro:
		add_to_group("aggro")
		reparent.call_deferred(enemies)
		$Sprite2D.show()
		set_physics_process(true)


func play_ending() -> void:
	# Remember to call when the final boss dies
	get_tree().paused = true
	get_tree().change_scene_to_file("res://ending.tscn")
