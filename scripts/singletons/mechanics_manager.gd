extends Node

signal stat_changed(stat)

enum BuffBucket { SHOCK, KNEE_CAP, BOOST, ROLL, MISC }
enum BuffType { SPEED, HEALTH, DAMAGE, CRIT_CHANCE }

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


func _ready() -> void:
	stat_changed.connect(_stat_calc)


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


func apply_buff(
	body: Node2D,
	duration: float,
	amount: float,
	buff_type: BuffType,
	multi: bool = false,
	group = BuffBucket.MISC
) -> void:
	if group == BuffBucket.MISC:
		if multi:
			body.buff_dict[buff_type]["multi"][group] += amount / 100.0
			stat_changed.emit(body, buff_type)
			await get_tree().create_timer(duration).timeout
			body.buff_dict[buff_type]["multi"][group] -= amount / 100.0
			stat_changed.emit(body, buff_type)
		else:
			body.buff_dict[buff_type]["flat"][group] += amount
			stat_changed.emit(body, buff_type)
			await get_tree().create_timer(duration).timeout
			body.buff_dict[buff_type]["flat"][group] -= amount
			stat_changed.emit(body, buff_type)
	else:
		if multi and absf(amount / 100.0) > absf(body.buff_dict[buff_type]["multi"][group]):
			body.buff_dict[buff_type]["multi"][group] = amount / 100.0
			stat_changed.emit(body, buff_type)
			await get_tree().create_timer(duration).timeout
			body.buff_dict[buff_type]["multi"][group] = 0.0
			stat_changed.emit(body, buff_type)
		elif absf(amount) > absf(body.buff_dict[buff_type]["flat"][group]):
			body.buff_dict[buff_type]["flat"][group] = amount
			stat_changed.emit(body, buff_type)
			await get_tree().create_timer(duration).timeout
			body.buff_dict[buff_type]["flat"][group] = 0.0
			stat_changed.emit(body, buff_type)


func _sum(a: float, b: float) -> float:
	return a + b


func _stat_calc(body: Node2D, buff_type: BuffType) -> void:
	body.buff_dict[buff_type]["multi_calc"] = body.buff_dict[buff_type]["multi"].reduce(_sum)
	body.buff_dict[buff_type]["flat_calc"] = body.buff_dict[buff_type]["flat"].reduce(_sum)
