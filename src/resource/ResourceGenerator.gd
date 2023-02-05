class_name ResourceGenerator

var currency: Const.Currency
var team: TeamData

var production_cycle: float = 1.0
var production_progress: float = 0.0

var is_resource_available : bool = true

func _init(_team: TeamData, _currency: Const.Currency) -> void:
	team = _team
	currency = _currency

func _process(delta) -> void:
	if is_resource_available:
		production_progress = 0.0
		return

	production_progress += delta
	if production_progress >= production_cycle:
		is_resource_available = true
		production_progress = 0.0
