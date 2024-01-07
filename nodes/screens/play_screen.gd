extends GameScreen

var map: Dictionary

@export var digger_scene: PackedScene
@export var fire_truck_scene: PackedScene
@export var monster_truck_scene: PackedScene

@onready var _tiles := $Tiles as TileMap

var player_1_vehicle: GamePlayer
var player_2_vehicle: GamePlayer

func _ready():
	reset()


func reset() -> void:
	map = Generation.get_map(Variables.current_phrase)

	draw_map()
	draw_players()

	calculate_waypoints()


func draw_map() -> void:
	for cell in map.cells:
		var roads: Array[Vector2i] = []

		if [
			Types.cells.road,
			Types.cells.player_1_start,
			Types.cells.player_2_start,
			Types.cells.waypoint
			].has(cell.type):

			roads.append(Vector2i(cell.x, cell.y))

			_tiles.set_cells_terrain_connect(0, roads, 0, 0, false)


func draw_players() -> Dictionary:
	var start_cells := get_start_cells()

	var vehicle_scenes := [digger_scene, fire_truck_scene, monster_truck_scene]

	var player_1_tile_position: Vector2 = _tiles.map_to_local(Vector2(start_cells.player_1.x, start_cells.player_1.y))
	var player_1_start_position: Vector2 = player_1_tile_position + _tiles.position
	var player_1_vehicle_index: int = map.generator.randi() % vehicle_scenes.size()

	player_1_vehicle = vehicle_scenes[player_1_vehicle_index].instantiate()
	add_child(player_1_vehicle)
	player_1_vehicle.position = player_1_start_position

	vehicle_scenes.remove_at(player_1_vehicle_index)

	var player_2_tile_position: Vector2 = \
		_tiles.map_to_local(Vector2(start_cells.player_2.x, start_cells.player_2.y))
	var player_2_start_position: Vector2 = player_2_tile_position + _tiles.position

	player_2_vehicle = \
		vehicle_scenes[map.generator.randi() % vehicle_scenes.size()].instantiate()
	add_child(player_2_vehicle)
	player_2_vehicle.position = player_2_start_position

	var degrees := rotate_players(start_cells.player_1)

	return {
		"start_cells": start_cells,
		"degrees": degrees
	}


func rotate_players(player_1: Dictionary) -> int:
	var degrees := 0

	if (player_1.x < 5 and map.clockwise) or (player_1.x > 15 and not map.clockwise):
		degrees = -90

	if (player_1.x < 5 and not map.clockwise) or (player_1.x > 15 and map.clockwise):
		degrees = 90

	if (player_1.y < 5 and map.clockwise) or (player_1.y > 15 and not map.clockwise):
		degrees = 0

	if (player_1.y < 5 and not map.clockwise) or (player_1.y > 15 and map.clockwise):
		degrees = 180

	player_1_vehicle.rotation = deg_to_rad(degrees)
	player_2_vehicle.rotation = deg_to_rad(degrees)

	return degrees


func calculate_waypoints() -> void:
	pass


func get_start_cells() -> Dictionary:
	var start_cells = []

	for cell in map.cells:
		if cell.type == Types.cells.player_1_start:
			start_cells.push_back(cell)

	var player_1: Dictionary = start_cells[map.generator.randi() % start_cells.size()]
	var player_2: Dictionary

	for cell in map.cells:
		if cell.type == Types.cells.player_2_start:
			player_2 = cell
			break

	return {
		"player_1" = player_1,
		"player_2" = player_2,
	}


func cells_are_closed(player_1: Dictionary, player_2: Dictionary) -> bool:
	if player_1.x == player_2.x \
	and (player_1.y == player_2.y - 1 or player_1.y == player_2.y + 1):
		return true

	if player_1.y == player_2.y \
	and (player_1.x == player_2.x - 1 or player_1.x == player_2.x + 1):
		return true

	return false
