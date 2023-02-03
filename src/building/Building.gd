class_name Building
extends Node3D

@onready var game: Game = get_node("/root/game")

@export var team: Const.Team

## How much this building affects the change of each currency every game tick
@export var currency_change: Array[CurrencyChange] = []

func _ready():
	game.building_placed.emit(self)

func _process(delta: float):
	pass

func get_or_create_currency_change(currency: Const.Currency) -> CurrencyChange:
	var existing = currency_change[currency]
	if existing:
		return existing

	var instance = CurrencyChange.new()
	instance.currency = currency
	currency_change[currency] = instance
	return instance

func set_currency_change(currency: Const.Currency, change_per_tick: float):
	get_or_create_currency_change(currency).change = change_per_tick
