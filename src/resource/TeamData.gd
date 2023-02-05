class_name TeamData
extends Resource

var game: Game

@export var hub: Hub

var links: Array[BuildingLink] = []

## Stores a list of all existing buildings owned by this team.
var buildings: Array[Building] = []
var cycles: Dictionary = {}
var transport_speed: float = 10.0
var house_power: float = -1.0
var resource_produced: int = 1
var hp_multiplier: int = 1

var stats: Dictionary = {}

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

	# Check win/lose conditions
	if building == hub:
		var ui := game.find_child("ui")
		var scene_path := ""
		match hub.team:
			Const.Team.PLAYER:
				scene_path = "res://scenes/PlayerLose.tscn"
			Const.Team.ENEMY:
				scene_path = "res://scenes/PlayerWin.tscn"
		if scene_path.length() > 0:
			ui.add_child((load(scene_path) as PackedScene).instantiate())

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


func get_stat_level(stat: Const.Upgrade) -> int:
	if not stats.has(stat):
		stats[stat] = {
			"level": 1,
			"progress": 0,
			"required": 0,
		}
	return stats[stat]["level"]

func upgrade_stat(stat: Const.Upgrade) -> void:
	var current_level = get_stat_level(stat)
	if stats[stat]["required"] > 0:
		return
	stats[stat]["required"] = current_level * 1000

func get_stat_progress(stat: Const.Upgrade) -> Array[int]:
	if not stats.has(stat):
		stats[stat] = {
			"level": 1,
			"progress": 0,
			"required": 0,
		}
	return [stats[stat]["progress"], stats[stat]["required"]]

func update_stats() -> void:
	var base_value: float

	base_value = 10.0
	for i in get_stat_level(Const.Upgrade.SPEED):
		base_value *= 1.1
	transport_speed = base_value

	base_value = -1.0
	for i in get_stat_level(Const.Upgrade.POWER):
		base_value *= 1.1
	house_power = base_value

	resource_produced = get_stat_level(Const.Upgrade.RESOURCE)
	hp_multiplier = get_stat_level(Const.Upgrade.HP)
