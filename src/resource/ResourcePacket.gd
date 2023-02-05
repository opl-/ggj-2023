class_name ResourcePacket
extends Node3D

var payload: CurrencyAmount
var path: Dictionary
var destination: Building
var speed: float = 10.0

func _ready() -> void:
	_build_path()

func _process(delta: float) -> void:
	var follow := $"Path3D/PathFollow3D"
	follow.set_progress(follow.get_progress() + speed * delta)
	$"Path3D/PathFollow3D/mesh".show()

	if follow.get_progress_ratio() >= 1.0:
		_deliver()

func _build_path() -> void:
	var path3d : Path3D = $"Path3D"
	var curve : Curve3D = Curve3D.new()
	curve.clear_points()

	for point in path["path"]:
		curve.add_point(point)
	path3d.set_curve(curve)

func _deliver() -> void:
	destination.receive_currency(payload.currency, payload.amount)
	queue_free()

func on_building_destroyed(other_building: Building) -> void:
	if destination == other_building:
		queue_free()
