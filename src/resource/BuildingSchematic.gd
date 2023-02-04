## Describes a building which can be placed by a player, and the resources it requires.
class_name BuildingSchematic
extends Resource

@export var cost := CurrencyStore.new()

@export var name: String

## Scene showing the building during construction. Script will be replaced by a ConstructionSite building, until it's completed.
@export var scene_construction: PackedScene

## Scene the building evolves to once completed. Root node must have a script extending Building.
@export var scene_completed: PackedScene
