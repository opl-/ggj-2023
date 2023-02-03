class_name GameCamera
extends Node3D

const DEADZONE : float = 0.05
const MOVEMENT_AXIS_X = JOY_AXIS_LEFT_X
const MOVEMENT_AXIS_Y = JOY_AXIS_LEFT_Y
const CAMERA_AXIS_X = JOY_AXIS_RIGHT_X
const CAMERA_AXIS_Y = JOY_AXIS_RIGHT_Y
const CAMERA_AXIS_ZOOM_IN = JOY_AXIS_TRIGGER_RIGHT
const CAMERA_AXIS_ZOOM_OUT = JOY_AXIS_TRIGGER_LEFT

@export var device_id : int = 0
@export var rotate_speed : int = 100
@export var zoom_speed : int = 20
@export var move_speed : int = 50
@export var mouse_zoom_step : float = 2.0
@export var camera_min_deg : int = -70
@export var camera_max_deg : int = -15
@export var camera_distance_min : int = 5
@export var camera_distance_max : int = 35

@export var camera_space_size : int = 500

@onready var camera_pivot : Node3D = $"pivot"
@onready var camera_arm : Node3D = $"pivot/arm"
@onready var camera_lens : Camera3D = $"pivot/arm/camera"

var camera_angle_y : float = 0
var _camera_angle_y : float = 0

var camera_angle_x : float = 0
var _camera_angle_x : float = 0

var camera_distance : float = 0
var _camera_distance : float = 0

var mouse_drag : bool = false

func _ready() -> void:
	var current_rotation = self.camera_pivot.get_rotation_degrees()
	camera_angle_y = current_rotation.y
	_camera_angle_y = current_rotation.y

	current_rotation = self.camera_arm.get_rotation_degrees()
	camera_angle_x = current_rotation.x
	_camera_angle_x = current_rotation.x

	current_rotation = self.camera_lens.get_position()
	camera_distance = current_rotation.z
	_camera_distance = current_rotation.z

func _input(event) -> void:
	if event.is_action_pressed("mouse_zoom_in"):
		self._mouse_zoom_in()
	if event.is_action_pressed("mouse_zoom_out"):
		self._mouse_zoom_out()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			self.mouse_drag = true
		else:
			self.mouse_drag = false
	elif event is InputEventMouseMotion:
		if self.mouse_drag:
			self._mouse_shift_camera(event.relative)

func _process(_delta) -> void:
	if camera_angle_y != _camera_angle_y:
		_camera_angle_y = camera_angle_y
		self.camera_pivot.set_rotation_degrees(Vector3(0, _camera_angle_y, 0))

	if camera_angle_x != _camera_angle_x:
		_camera_angle_x = camera_angle_x
		self.camera_arm.set_rotation_degrees(Vector3(_camera_angle_x, 0, 0))

	if camera_distance != _camera_distance:
		_camera_distance = camera_distance
		self.camera_lens.set_position(Vector3(0, 0, _camera_distance))


func _physics_process(delta) -> void:
	self.process_free_camera_input(delta)
	self.process_movement_input(delta)

func process_free_camera_input(delta):
	var axis_value = Vector2()
	axis_value.x = Input.get_joy_axis(self.device_id, CAMERA_AXIS_X)
	axis_value.y = Input.get_joy_axis(self.device_id, CAMERA_AXIS_Y)

	var zoom_value = Vector2()
	zoom_value.x = Input.get_joy_axis(self.device_id, CAMERA_AXIS_ZOOM_IN)
	zoom_value.y = Input.get_joy_axis(self.device_id, CAMERA_AXIS_ZOOM_OUT)

	if abs(axis_value.x) > DEADZONE:
		camera_angle_y -= self.rotate_speed * axis_value.x * delta

	if camera_angle_y > 360.0:
		camera_angle_y -= 360.0
	if camera_angle_y < 0.0:
		camera_angle_y += 360.0

	if abs(axis_value.y) > DEADZONE:
		camera_angle_x += self.rotate_speed * axis_value.y * delta
		camera_angle_x = clamp(camera_angle_x, self.camera_min_deg, self.camera_max_deg)

	if abs(zoom_value.x) > DEADZONE:
		zoom_value.y = 0.0
		camera_distance += self.zoom_speed * -zoom_value.x * delta
		camera_distance = clamp(camera_distance, self.camera_distance_min, self.camera_distance_max)

	if abs(zoom_value.y) > DEADZONE:
		camera_distance += self.zoom_speed * zoom_value.y * delta
		camera_distance = clamp(camera_distance, self.camera_distance_min, self.camera_distance_max)

func process_movement_input(delta) -> void:
	var axis_value = Vector2()

	axis_value.x = -Input.get_joy_axis(self.device_id, MOVEMENT_AXIS_X)
	axis_value.y = -Input.get_joy_axis(self.device_id, MOVEMENT_AXIS_Y)
	axis_value = axis_value.rotated(deg_to_rad(-self.camera_angle_y))

	if axis_value.length() > self.DEADZONE:
		var current_position = self.get_position()
		current_position.x -= axis_value.x * self.move_speed * delta
		current_position.z -= axis_value.y * self.move_speed * delta
		current_position.x = clamp(current_position.x, -self.camera_space_size, self.camera_space_size)
		current_position.z = clamp(current_position.z, -self.camera_space_size, self.camera_space_size)
		self.set_position(current_position)



func _shift_camera_translation(offset) -> void:
	var current_position = self.get_position()
	current_position.x += offset.x
	current_position.z += offset.y
	current_position.x = clamp(current_position.x, -self.camera_space_size, self.camera_space_size)
	current_position.z = clamp(current_position.z, -self.camera_space_size, self.camera_space_size)
	self.set_position(current_position)

func _mouse_zoom_in():
	camera_distance -= self.mouse_zoom_step
	camera_distance = clamp(camera_distance, self.camera_distance_min, self.camera_distance_max)


func _mouse_zoom_out():
	camera_distance += self.mouse_zoom_step
	camera_distance = clamp(camera_distance, self.camera_distance_min, self.camera_distance_max)

func _mouse_shift_camera(relative_offset) -> void:
	var camera_fraction
	camera_fraction = self.camera_distance / self.camera_distance_max
	relative_offset = relative_offset * camera_fraction * 0.25
	relative_offset = relative_offset.rotated(deg_to_rad(-self.camera_angle_y))
	self._shift_camera_translation(-relative_offset)
