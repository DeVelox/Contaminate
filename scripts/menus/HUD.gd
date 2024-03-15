extends MarginContainer

func update_health(health: int, max_health: int) -> void:
	if health <= 0:
		%HUD.hide()
	%Hearts.custom_minimum_size.x = health * 64
	%MaxHearts.custom_minimum_size.x = max_health * 64

func update_upgrade_list(upgrade: String) -> void:
	var upgrade_icon := TextureRect.new()
	upgrade_icon.texture = load(upgrade)
	upgrade_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	upgrade_icon.use_parent_material = true
	%Upgrades.add_child(upgrade_icon)

func reset_upgrade_list() -> void:
	for i in %Upgrades.get_children():
		i.queue_free()

func pause_game() -> void:
	%PauseMenu.toggled = true
	get_tree().paused = true
	%PauseMenu.show()

func _process(_delta: float) -> void:
	%FPS.text = str(Engine.get_frames_per_second())
