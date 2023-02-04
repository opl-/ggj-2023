class_name BuildingLink
extends Resource

@export var from: Building

@export var to: Building

var distance: float

func _init(_from: Building, _to: Building):
	self.from = _from
	self.to = _to
	distance = from.position.distance_to(to.position)
