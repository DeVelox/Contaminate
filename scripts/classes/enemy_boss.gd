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
	var vignette := get_node("/root/Main/Shaders/Vignette")
	var player := get_node("/root/Main/Player")
	player.queue_free()
	var tween := create_tween()
	tween.tween_property(vignette.material, "shader_parameter/vignette_intensity", 50.0, 2.0)
	await get_tree().create_timer(2.1).timeout
	get_tree().change_scene_to_file("res://ending.tscn")
