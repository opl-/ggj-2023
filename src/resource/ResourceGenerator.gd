class_name ResourceGenerator

var currency: Const.Currency
var team: TeamData

var production_cycle: float = 1.0
var production_progress: float = 0.0

var resource_available : int = 1

func _init(_team: TeamData, _currency: Const.Currency) -> void:
	team = _team
	currency = _currency

func _process(delta, resource_produced: int) -> void:
	if resource_available == resource_produced:
		production_progress = 0.0
		return

	production_cycle = team.cycles[currency]

	production_progress += delta
	if production_progress >= production_cycle:
		resource_available = resource_produced
		production_progress = 0.0
