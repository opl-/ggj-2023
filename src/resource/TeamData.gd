class_name TeamData
extends Resource

var game: Game

@export var hub: Hub

var links: Array[BuildingLink] = []

## Sent when a new building owned by this team appears on the map.
signal building_placed(building: Building)

## Sent when a building owned by this team is destroyed,
signal building_destroyed(building: Building)

func _init(game: Game):
	self.game = game

	building_placed.connect(on_building_placed)
	building_destroyed.connect(on_building_destroyed)

func on_building_placed(building: Building):
	# TODO: dev code - immediately grant requsted currency
	building.connect(
		"request_currency",
		func(currency: Const.Currency, amount: float):
			building.receive_currency(currency, amount)
	)

	game.building_placed.emit(building)

func on_building_destroyed(building: Building):
	game.building_destroyed.emit(building)
