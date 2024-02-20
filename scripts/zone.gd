class_name Zone extends Node2D

enum Tier {ONE = 1, TWO = 2, THREE = 3, FOUR = 4, FIVE = 5}
enum Rarity { COMMON, RARE, UNIQUE }

@export var tier: Tier
@export var rarity: Rarity


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
