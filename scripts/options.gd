extends CenterContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Master.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	%Music.value = db_to_linear(AudioServer.get_bus_volume_db(1))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_master_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))


func _on_music_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(value))
