extends CharacterBody2D
class_name GamePlayer

@export var wheel_base := 30.0
@export var steering_angle := 90.0
@export var engine_power := 400.0
@export var friction := -0.9
@export var drag := -0.0015
@export var braking := -450.0
@export var max_speed_reverse := 150.0

var steer_angle: float
var acceleration := Vector2.ZERO
var show_waypoint := false
var waypoint_position: Vector2

@onready var _arrow := $Arrow as Sprite2D

var controls := {
	"left": "ui_left",
	"right": "ui_right",
	"accelerate": "ui_up",
	"slow": "ui_down",
}


func _physics_process(delta: float) -> void:
	if show_waypoint:
		_arrow.rotation = lerp(_arrow.rotation, get_angle_to(waypoint_position) + PI / 2, 1)
		_arrow.global_position = global_position.move_toward(waypoint_position, 20)
		_arrow.visible = true
	else:
		_arrow.visible = false

	acceleration = Vector2.ZERO

	get_input()
	apply_friction()
	calculate_steering(delta)

	velocity += acceleration * delta
	var collided := move_and_slide()


func get_input() -> void:
	var turn = 0

	if Input.is_action_pressed(controls.left):
		turn -= 1

	if Input.is_action_pressed(controls.right):
		turn += 1

	steer_angle = turn * deg_to_rad(steering_angle)

	if Input.is_action_pressed(controls.accelerate):
		acceleration = transform.x * engine_power

	if Input.is_action_pressed(controls.slow):
		acceleration = transform.x * braking


func apply_friction() -> void:
	if velocity.length() < 5:
		velocity = Vector2.ZERO

	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag

	if velocity.length() < 100:
		friction_force *= 3

	acceleration += drag_force + friction_force


func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0

	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_angle) * delta

	var new_heading = (front_wheel - rear_wheel).normalized()

	var d = new_heading.dot(velocity.normalized())

	if d > 0:
		velocity = new_heading * velocity.length()

	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)

	rotation = new_heading.angle()
