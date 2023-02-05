class_name Hub
extends Building

@onready var pathfinder : Pathfinder = Pathfinder.new()

var refresh_paths : bool = true

func _ready():
	super._ready()

func _process(delta: float):
	super._process(delta)

	if self.refresh_paths:
		self.refresh_paths = false
		self.pathfinder.retrace(self)

func on_building_placed(other_building: Building):
	super.on_building_placed(other_building)
	self.refresh_paths = true

func on_building_destroyed(other_building: Building):
	super.on_building_destroyed(other_building)
	if not other_building is ConstructionSite:
		self.refresh_paths = true
