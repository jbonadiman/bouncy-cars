extends Node
class_name Types

enum screens {
	none,
	menu,
	new_game,
	play
}

enum cells {
	none,
	grass,
	road,
	player_1_start,
	player_2_start,
	waypoint,
}

enum segment_types {
	top_left,
	top_right,
	bottom_left,
	bottom_right,
}

const cell_colors := {
	cells.grass: "38a169",
	cells.road: "4a5568",
	cells.player_1_start: "f687b3",
	cells.player_2_start: "f6ad55",
	cells.waypoint: "4fd1c5",
}

const segment_width := 10
const segment_height := 7
const number_of_segments := 6

@export var menu_scene: PackedScene
@export var new_game_scene: PackedScene
@export var play_scene: PackedScene

@onready var screen_scenes := {
	screens.menu: menu_scene,
	screens.new_game: new_game_scene,
	screens.play: play_scene,
}
