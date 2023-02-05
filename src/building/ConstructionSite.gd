class_name ConstructionSite
extends Building

var schematic: BuildingSchematic

var remaining_costs := CurrencyStore.new()

var building_scene : Node3D

var building_progress: BuildingInfoPanel

func _ready():
	super._ready()
	# Create building info panel
	building_progress = preload("res://object/BuildingInfoPanel.tscn").instantiate()
	building_progress.building = self
	building_progress.position.y = 13
	building_progress.autoupdate = false
	add_child(building_progress)

	building_scene.set_scale(Vector3(1.0, 0.1, 1.0))
	for cost in schematic.cost.get_existing():
		remaining_costs.set_currency_amount(cost.currency, cost.amount)
		request_currency.emit(self, cost.currency, cost.amount)

	if remaining_costs.currency_amounts.size() == 0:
		finish_construction()

func _process(delta: float):
	super._process(delta)
	_grow_building_model()


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
	var building: Building = schematic.scene_completed.instantiate()
	building.team = team
	building.global_transform = global_transform
	get_parent().add_child(building)
	destroy()

func _grow_building_model() -> void:
	var total_cost : float = 0.0
	var required_costs : float = 0.0
	for cost in schematic.cost.get_existing():
		total_cost += cost.amount
	for remaining_cost in remaining_costs.get_existing():
		required_costs += remaining_cost.amount

	if total_cost > 0:
		var progress : float = float(total_cost - required_costs) / float(total_cost)
		building_scene.set_scale(Vector3(1.0, 0.1 + progress * 0.9, 1.0))
		building_progress._update(int(total_cost - required_costs), int(total_cost))
