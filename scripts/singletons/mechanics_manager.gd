extends Node

#TODO: Change to const after values are locked in
@export var _base_infection_damage: int = 3
@export var _base_infection_count: int = 3
@export var _base_infection_rate: float = 1.0

@export var _base_shock_damage: int = 6
@export var _base_shock_slow: float = 0.5
@export var _base_shock_duration: float = 0.5

var _infection_damage: int = _base_infection_damage
var _infection_count: int = _base_infection_count
var _infection_rate: float = 1.0

var _shock_damage: int = _base_shock_damage
var _shock_slow: float = _base_shock_slow
var _shock_duration: float = _base_shock_duration


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


func get_base_infection_damage() -> int:
	return _base_infection_damage


func get_infection_damage() -> int:
	return _infection_damage


func set_infection_damage(damage) -> int:
	_infection_damage = damage
	return _infection_damage


func get_base_infection_count() -> int:
	return _base_infection_count


func get_infection_count() -> int:
	return _infection_count


func set_infection_count(count) -> int:
	_infection_count = count
	return _infection_count


func get_base_infection_rate() -> float:
	return _base_infection_rate


func get_infection_rate() -> float:
	return _infection_rate


func set_infection_rate(rate) -> float:
	_infection_rate = rate
	return _infection_rate


func get_base_shock_damage() -> int:
	return _base_shock_damage


func get_shock_damage() -> int:
	return _shock_damage


func set_shock_damage(damage) -> int:
	_shock_damage = damage
	return _shock_damage


func get_base_shock_slow() -> float:
	return _base_shock_slow


func get_shock_slow() -> float:
	return _shock_slow


func set_shock_slow(slow) -> float:
	_shock_slow = slow
	return _shock_slow


func get_base_shock_duration() -> float:
	return _base_shock_duration


func get_shock_duration() -> float:
	return _shock_duration


func set_shock_duration(duration) -> float:
	_shock_duration = duration
	return _shock_duration


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
