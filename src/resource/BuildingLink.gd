class_name BuildingLink
extends Resource

@export var from: Building

@export var to: Building

var distance: float
var view: Node3D = null

func _init(_from: Building, _to: Building, _view: Node3D):
	self.from = _from
	self.to = _to
	self.view = _view
	distance = from.position.distance_to(to.position)
