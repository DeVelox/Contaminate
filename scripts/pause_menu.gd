extends CenterContainer

var toggled: bool
var zone_class: Zone = load("res://scripts/zone.gd").new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if get_tree().current_scene.name == "Start":
		return
	if %WeaponSelect.is_visible():
		return

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
	UpgradeManager.reset_upgrades()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_options_pressed() -> void:
	%PauseMenu.hide()
	%Options.show()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://start.tscn")
	%PauseMenu.hide()
	%HUD.hide()


func _on_upgrades_pressed() -> void:
	%PauseMenu.hide()
	%UpgradeSelect.upgrade_select(true)
