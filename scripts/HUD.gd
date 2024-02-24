extends MarginContainer


func update_health(health: int) -> void:
	%Hearts.custom_minimum_size.x = health * 48


func update_upgrade_list(upgrade: String) -> void:
	var upgrade_icon := TextureRect.new()
	upgrade_icon.texture = load(upgrade)
	upgrade_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	print_debug(upgrade_icon)
	%Upgrades.add_child(upgrade_icon)
	
func reset_upgrade_list() -> void:
	for i in %Upgrades.get_children():
		i.queue_free()
