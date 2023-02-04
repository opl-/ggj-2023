class_name Building
extends Node3D

@onready var game: Game = $"/root/game"

@export var team: Const.Team

## How much the building can produce.
@export var currency_modifier := CurrencyStore.new()

## Squared maximum distance for the links this building supports.
var max_link_length_sq: float = 5 * 5

## Stores all links to other buildings.
var links: Array[BuildingLink] = []

signal request_currency(currency: Const.Currency, amount: float)

func _ready():
	var team_data := game.get_team(team)

	team_data.building_placed.emit(self)
	team_data.building_placed.connect(on_building_placed)
	team_data.building_destroyed.connect(on_building_destroyed)

func _process(_delta: float):
	pass

func on_building_placed(other_building: Building):
	# Check if the other building is in range.
	var distance_sq = position.distance_squared_to(other_building.position)
	if (distance_sq > max_link_length_sq):
		return

	# Create a link both ways - the other building doesn't populate its own links.
	#links.push_back(BuildingLink.new(self, other_building))
#other_building.links.push_back(BuildingLink.new(other_building, self))
	
func on_building_destroyed(other_building: Building):
	for link_index in links.size():
		var link := links[link_index]
		if link.to == other_building:
			links.remove_at(link_index)
			break

## Called when the building is supposed to obtain currency. Custom building types should override this function.
## If false is returned, the currency is rejected, and presumably could go back to some pool.
func receive_currency(_currency: Const.Currency, _amount: float) -> bool:
	return false
