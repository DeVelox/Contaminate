class_name Zone extends Node2D

enum Tier { ONE = 1, TWO = 2, THREE = 3, FOUR = 4, FIVE = 5 }
enum Rarity { COMMON = 1, RARE = 2, UNIQUE = 3 }

const ZONE_SIZE = 1920
const MAP_SIZE = 100

@export var min_tier: Tier = Tier.ONE
@export var max_tier: Tier = Tier.ONE
@export var min_rarity: Rarity = Rarity.COMMON
@export var max_rarity: Rarity = Rarity.COMMON

var map_location: Vector2i
var bounds := Rect2i(0, 0, MAP_SIZE, MAP_SIZE)

@onready var zone_current: Zone = $"."
@onready var zone_container := get_node("/root/Main/Zones")
@onready var player: Player = get_node("/root/Main/Player")
@onready var chunk_loader: VisibleOnScreenNotifier2D = $ChunkLoader

static var loaded: BitMap
static var count: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chunk_loader.reparent.call_deferred(zone_container)

	if not loaded:
		var matrix = BitMap.new()
		matrix.create(Vector2i(MAP_SIZE, MAP_SIZE))
		loaded = matrix

	if not map_location:
		@warning_ignore("integer_division")
		map_location = Vector2i(MAP_SIZE / 2, MAP_SIZE / 2)
		loaded.set_bitv(map_location, true)

	count += 1


func _load_zone(direction: StringName) -> void:
	var tier := "t" + str(randi_range(min_tier, max_tier))
	var rarity := "r" + str(randi_range(min_rarity, max_rarity))
	var zone := "res://zones/" + tier + rarity + ".tscn"
	if ResourceLoader.exists(zone):
		match direction:
			"north":
				_instantiate_zone(zone, Vector2i.UP)
			"south":
				_instantiate_zone(zone, Vector2i.DOWN)
			"west":
				_instantiate_zone(zone, Vector2i.LEFT)
			"east":
				_instantiate_zone(zone, Vector2i.RIGHT)
			"northwest":
				_instantiate_zone(zone, Vector2i.UP + Vector2i.LEFT)
			"northeast":
				_instantiate_zone(zone, Vector2i.UP + Vector2i.RIGHT)
			"southwest":
				_instantiate_zone(zone, Vector2i.DOWN + Vector2i.LEFT)
			"southeast":
				_instantiate_zone(zone, Vector2i.DOWN + Vector2i.RIGHT)


func _instantiate_zone(zone: String, direction: Vector2i) -> void:
	if not bounds.has_point(map_location + direction):
		return
	if not loaded.get_bitv(map_location + direction):
		var load_zone := load(zone).instantiate() as Zone
		var new_map_location = map_location + direction
		var offset := Vector2i(ZONE_SIZE, ZONE_SIZE)
		load_zone.map_location = new_map_location
		load_zone.loaded.set_bitv(new_map_location, true)
		load_zone.position = global_position + Vector2(direction * offset)
		zone_container.add_child.call_deferred(load_zone)


# I don't know if this actually helps with anything
func _on_chunk_loader_screen_entered() -> void:
	if zone_current.get_parent() != zone_container:
		zone_container.add_child(zone_current)


func _on_chunk_loader_screen_exited() -> void:
	if zone_current.get_parent() == zone_container:
		zone_container.remove_child(zone_current)
