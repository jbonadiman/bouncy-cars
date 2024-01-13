extends GameScreen

var map: Dictionary

@export var digger_scene: PackedScene
@export var fire_truck_scene: PackedScene
@export var monster_truck_scene: PackedScene

@onready var _tiles := $Tiles as TileMap

var player_1_vehicle: GamePlayer
var player_1_next_waypoint_index: int
var player_2_vehicle: GamePlayer
var ordered_waypoint_positions: Array[Vector2] = []


func _ready():
	reset()


func reset() -> void:
	map = Generation.get_map(Variables.current_phrase)

	draw_map()
	var player_positions = draw_players()
	calculate_waypoints(player_positions)
	player_1_next_waypoint_index = 0


func _physics_process(_delta: float) -> void:
	var player_1_next_waypoint = ordered_waypoint_positions[player_1_next_waypoint_index]

	var player_1_next_waypoint_position := _tiles.map_to_local(Vector2(player_1_next_waypoint.x, player_1_next_waypoint.y))

	if player_1_vehicle.global_position.distance_to(player_1_next_waypoint_position) < 100:
		player_1_vehicle.show_waypoint = false

		if player_1_vehicle.global_position.distance_to(player_1_next_waypoint_position) < 50:
			player_1_next_waypoint_index += 1

			if player_1_next_waypoint_index >= ordered_waypoint_positions.size():
				player_1_next_waypoint_index = 0

			return
	else:
		player_1_vehicle.show_waypoint = true
		player_1_vehicle.waypoint_position = player_1_next_waypoint_position


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

	player_2_vehicle.controls = {
		"left": "ui_cancel",
		"right": "ui_cancel",
		"accelerate": "ui_cancel",
		"slow": "ui_cancel"
	}

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


func calculate_waypoints(player_positions: Dictionary) -> void:
	var unordered_waypoints = map.waypoints.duplicate() as Array
	var start_position: Vector2

	while unordered_waypoints.size() > 0:
		if ordered_waypoint_positions.size() == 0:
			start_position = Vector2(
				player_positions.start_cells.player_1.x,
				player_positions.start_cells.player_1.y)
		else:
			start_position = ordered_waypoint_positions[ordered_waypoint_positions.size() - 1]

		var nearest_waypoint = unordered_waypoints[0]
		var nearest_waypoint_position = Vector2(
			nearest_waypoint.x,
			nearest_waypoint.y)

		for waypoint in unordered_waypoints:
			if ordered_waypoint_positions.size() < 2:
				if player_positions.degrees == 0 and waypoint.x < player_positions.start_cells.player_1.x:
					continue

				if player_positions.degrees == 90 and waypoint.y < player_positions.start_cells.player_1.y:
					continue

				if player_positions.degrees == 180 and waypoint.x > player_positions.start_cells.player_1.x:
					continue

				if player_positions.degrees == -90 and waypoint.y > player_positions.start_cells.player_1.y:
					continue

			var waypoint_position = Vector2(waypoint.x, waypoint.y)

			if waypoint_position.distance_squared_to(start_position) < \
				nearest_waypoint_position.distance_squared_to(start_position):

				nearest_waypoint = waypoint
				nearest_waypoint_position = waypoint_position

		ordered_waypoint_positions.append(nearest_waypoint_position)
		unordered_waypoints.erase(nearest_waypoint)


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


func cells_are_close(player_1: Dictionary, player_2: Dictionary) -> bool:
	if player_1.x == player_2.x \
	and (player_1.y == player_2.y - 1 or player_1.y == player_2.y + 1):
		return true

	if player_1.y == player_2.y \
	and (player_1.x == player_2.x - 1 or player_1.x == player_2.x + 1):
		return true

	return false
