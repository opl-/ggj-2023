class_name Hub
extends Building

@onready var pathfinder : Pathfinder = Pathfinder.new()
var refresh_paths : bool = true

var currency_generators : Dictionary = {}
var currency_orders : Dictionary = {}

var resource_packet_template := preload("res://object/building/ResourcePacket.tscn")

func _ready() -> void:
	super._ready()

	for currency in Const.Currency.values():
		currency_generators[currency] = ResourceGenerator.new(team_data, currency)
	_process_pollution(1.0)

func _process(delta: float) -> void:
	super._process(delta)

	if self.refresh_paths:
		self.refresh_paths = false
		self.pathfinder.retrace(self)
	_process_resource_generation(delta)
	_process_resource_dispatch(delta)
	_process_upgrades(delta)

func _process_resource_generation(delta: float) -> void:
	for generator in currency_generators.values():
		generator._process(delta, team_data.resource_produced)

func _process_resource_dispatch(_delta: float) -> void:
	var generator: ResourceGenerator
	var order: ResourceOrder

	var unreachable_orders: Array[ResourceOrder]

	for currency in currency_orders:
		unreachable_orders = []
		if currency_orders[currency].size() > 0:
			generator = currency_generators[currency]
			while generator.resource_available > 0 and currency_orders[currency].size() > 0:
				order = currency_orders[currency].pop_front()

				if not order.valid:
					continue

				if pathfinder.can_reach(order.destination):
					generator.resource_available -= 1
					_dispatch_order(order)
				else:
					unreachable_orders.append(order)

		# return unreachable orders to the pool
		for unreachable_order in unreachable_orders:
			currency_orders[currency].append(unreachable_order)


func _dispatch_order(order: ResourceOrder) -> void:
	var packet: ResourcePacket = resource_packet_template.instantiate()

	packet.payload = order.resource
	packet.path = pathfinder.get_path(order.destination)
	packet.destination = order.destination
	get_parent().add_child(packet)

	packet.speed = team_data.transport_speed
	team_data.building_destroyed.connect(packet.on_building_destroyed)

func _process_upgrades(_delta: float) -> void:
	for stat in team_data.stats:
		if team_data.stats[stat]["required"] > 0:
			if currency_generators[Const.Currency.PEOPLE].resource_available > 0:
				team_data.stats[stat]["progress"] += currency_generators[Const.Currency.PEOPLE].resource_available
				currency_generators[Const.Currency.PEOPLE].resource_available = 0
				if team_data.stats[stat]["progress"] >= team_data.stats[stat]["required"]:
					team_data.stats[stat]["progress"] = 0
					team_data.stats[stat]["required"] = 0
					team_data.stats[stat]["level"] += 1
					team_data.update_stats()

func on_building_placed(other_building: Building) -> void:
	super.on_building_placed(other_building)
	self.refresh_paths = true

func on_building_destroyed(other_building: Building) -> void:
	super.on_building_destroyed(other_building)
	if not other_building is ConstructionSite:
		self.refresh_paths = true

	for order_list in currency_orders.values():
		for order in order_list:
			if order.destination == other_building:
				order.valid = false


func place_order(destination: Building, currency: Const.Currency, amount: float) -> void:
	if not currency_orders.has(currency):
		currency_orders[currency] = []

	var currency_amount : CurrencyAmount
	for i in range(amount):
		currency_amount = CurrencyAmount.new()
		currency_amount.currency = currency
		currency_amount.amount = 1.0
		currency_orders[currency].append(ResourceOrder.new(
			destination,
			currency_amount
		))

func _process_damage(delta: float) -> void:
	if team == Const.Team.PLAYER:
		super._process_damage(delta)
	else:
		var pollution: float = game.pollution.get_at_world(global_position)
		if pollution < 1.0:
			hp = clampf(hp - 5.0 * delta, 0.0, max_hp)

		if hp <= 0.0:
			destroy()
