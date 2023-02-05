class_name TeamData
extends Resource

var game: Game

@export var hub: Hub

var links: Array[BuildingLink] = []

## Stores a list of all existing buildings owned by this team.
var buildings: Array[Building] = []
var cycles: Dictionary = {}

## Sent when a new building owned by this team appears on the map.
signal building_placed(building: Building)

## Sent when a building owned by this team is destroyed,
signal building_destroyed(building: Building)

func _init(_game: Game):
	self.game = _game

	building_placed.connect(on_building_placed)
	building_destroyed.connect(on_building_destroyed)
	_refresh_cycles()


func _refresh_cycles() -> void:
	for currency in Const.Currency.values():
		cycles[currency] = _get_resource_cycle_time(currency)

func on_building_placed(building: Building):
	buildings.push_back(building)
	building.request_currency.connect(_on_resource_requested)
	game.building_placed.emit(building)
	_refresh_cycles()


func on_building_destroyed(building: Building):
	game.building_destroyed.emit(building)
	buildings.remove_at(buildings.find(building))
	_refresh_cycles()

func _on_resource_requested(building: Building, currency: Const.Currency, amount: float):
	hub.place_order(building, currency, amount)

func _get_resource_cycle_time(currency: Const.Currency) -> float:
	var cycle: float = 1.0

	for building in buildings:
		for modifier in building.currency_modifier.currency_amounts:
			if modifier.currency == currency:
				#cycle *=  modifier.amount
				cycle *= 0.95

	return cycle
