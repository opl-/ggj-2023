class_name ConstructionSite
extends Building

var schematic: BuildingSchematic

var request_countdown: float = 0

var remaining_costs := CurrencyStore.new()

var building_scene : Node3D

func _ready():
	super._ready()

	building_scene.set_scale(Vector3(1.0, 0.1, 1.0))
	for cost in schematic.cost.get_existing():
		remaining_costs.set_currency_amount(cost.currency, cost.amount)

	if remaining_costs.currency_amounts.size() == 0:
		finish_construction()

func _process(delta: float):
	super._process(delta)

	request_countdown -= delta
	if request_countdown <= 0:
		request_countdown = 2
		for remaining_cost in remaining_costs.get_existing():
			if remaining_cost.amount > 0:
				request_currency.emit(remaining_cost.currency, clamp(remaining_cost.amount, 0, 1))

	var total_cost : float = 0.0
	var required_costs : float = 0.0
	for cost in schematic.cost.get_existing():
		total_cost += cost.amount
	for remaining_cost in remaining_costs.get_existing():
		required_costs += remaining_cost.amount

	if total_cost > 0:
		var progress : float = float(total_cost - required_costs) / float(total_cost)
		building_scene.set_scale(Vector3(1.0, 0.1 + progress * 0.9, 1.0))


func receive_currency(currency: Const.Currency, amount: float) -> bool:
	var remaining_amount := remaining_costs.get_currency_amount(currency)
	if remaining_amount > 0:
		remaining_costs.increment_currency_amount(currency, -amount)
		for remaining_cost in remaining_costs.get_existing():
			if remaining_cost.amount > 0:
				return true
		finish_construction()
		return true

	return false

func finish_construction():
	var team_data := game.get_team(team)
	var building: Building = schematic.scene_completed.instantiate()
	building.team = team
	building.global_transform = global_transform
	get_parent().add_child(building)
	team_data.building_destroyed.emit(self)
	queue_free()
