class_name LinkView
extends Node3D

var _from : Vector3
var _to : Vector3

func _ready() -> void:
	var follow := $"Path3D/PathFollow3D"
	follow.set_progress_ratio(0.5)
	var distance : float = _from.distance_to(_to)
	$"Path3D/PathFollow3D/log".set_scale(Vector3(3.0, 3.0, distance/3.0))

func build_curve(from: Vector3, to: Vector3) -> void:
	var path : Path3D = $"Path3D"
	var curve : Curve3D = path.get_curve()
	_from = from
	_to = to
	curve.clear_points()
	curve.add_point(from)
	curve.add_point(to)
