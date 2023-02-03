class_name BuildingLink
extends Resource

@export var from: Building

@export var to: Building

var distance: float

func _init(from: Building, to: Building):
	self.from = from
	self.to = to
	distance = from.position.distance_to(to.position)
