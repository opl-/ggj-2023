class_name Building
extends Node3D

const RANGE : int = 50

@onready var game: Game = $"/root/game"

@export var team: Const.Team

## How much the building can produce.
@export var currency_modifier := CurrencyStore.new()

## Squared maximum distance for the links this building supports.
var max_link_length_sq: float = RANGE * RANGE
var link_view_template := preload("res://object/building/Link.tscn")

## Stores all links to other buildings.
var links: Array[BuildingLink] = []

## Amount by which this building chanages the pollution in the chunk it resides in.
@export var pollution_change: float = 0.0

var info_panel: BuildingInfoPanel

@export var max_hp: int = 100
@export var hp: int = 100

signal request_currency(building: Building, currency: Const.Currency, amount: float)

func _ready():
	var team_data := game.get_team(team)

	team_data.building_placed.emit(self)
	team_data.building_placed.connect(on_building_placed)
	team_data.building_destroyed.connect(on_building_destroyed)

	# Create building info panel
	info_panel = preload("res://object/BuildingInfoPanel.tscn").instantiate()
	info_panel.building = self
	info_panel.position.y = 15
	add_child(info_panel)

func _process(_delta: float):
	pass

func _physics_process(delta: float):
	if pollution_change != 0:
		game.pollution.increment_at_world(global_position, pollution_change * delta)

func destroy():
	game.get_team(team).building_destroyed.emit(self)
	queue_free()

func on_building_placed(other_building: Building):
	# Check if the other building is in range.
	var distance_sq := position.distance_squared_to(other_building.position)
	if (distance_sq > max_link_length_sq or distance_sq < 1.0):
		return

	# Create a link both ways - the other building doesn't populate its own links.
	var link_view: Node3D = self.link_view_template.instantiate()
	links.push_back(BuildingLink.new(self, other_building, link_view))
	other_building.links.push_back(BuildingLink.new(other_building, self, link_view))
	link_view.build_curve(self.global_position, other_building.global_position)
	game.anchor.add_child(link_view)

func on_building_destroyed(other_building: Building):
	for link_index in links.size():
		var link := links[link_index]
		if link.to == other_building:
			links.remove_at(link_index)
			link.view.queue_free()
			break

## Called when the building is supposed to obtain currency. Custom building types should override this function.
## If false is returned, the currency is rejected, and presumably could go back to some pool.
func receive_currency(_currency: Const.Currency, _amount: float) -> bool:
	return false
