class_name Game
extends Node

@onready var anchor : Node3D = $"buildings"

var team_data = {
	Const.Team.PLAYER: TeamData.new(self),
	Const.Team.ENEMY: TeamData.new(self),
}

@onready var tooltip: Tooltip = $"ui/Tooltip"

var pollution := PollutionMap.new()

## Time until next pollution propagation.
var pollution_propagation_delay: float = 0

## Sent when a new building appears on the map
signal building_placed(building: Building)

## Sent when a building is destroyed
signal building_destroyed(building: Building)

func _ready():
	load_map()

	bind_hubs()

func _physics_process(delta: float):
	pollution_propagation_delay -= delta
	if pollution_propagation_delay <= 0:
		pollution_propagation_delay += 0.5
		pollution.propagate()

func load_map():
	add_child(preload("res://scenes/map.tscn").instantiate())

func bind_hubs():
	# Find team hubs from map data
	var hubs := find_children("*", "Hub", true, false)
	for hub in hubs:
		var hub_team := get_team(hub.team)
		if hub_team.hub != null:
			printerr("Found duplicate hub for team " + str(hub.team) + " at " + str(hub.get_path()))
		else:
			hub_team.hub = hub

	# Ensure all teams have a hub
	for team in team_data:
		if team_data[team].hub == null:
			printerr("Team " + str(team) + " has no hub")

func _process(_delta: float):
	pass

func get_team(team: Const.Team) -> TeamData:
	return team_data[team]
