class_name LinkView
extends Node3D

func _ready() -> void:
	var follow := $"Path3D/PathFollow3D"
	follow.set_progress_ratio(0.5)

func build_curve(from: Vector3, to: Vector3) -> void:
	var path : Path3D = $"Path3D"
	var curve : Curve3D = path.get_curve()
	curve.clear_points()
	curve.add_point(from)
	curve.add_point(to)
