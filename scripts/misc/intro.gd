extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in %Label.text.length():
		%Label.visible_characters += 1
		await get_tree().create_timer(0.05).timeout
	await get_tree().create_timer(3).timeout
	get_tree().change_scene_to_file("res://main_tutorial.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		get_tree().change_scene_to_file("res://main_tutorial.tscn")
