class_name Hub
extends "res://src/building/Building.gd"

var currency_amount = {}

func _ready():
	pass

func _process(delta):
	pass

func get_currency_amount(currency: Const.Currency) -> float:
	return currency_amount[currency]

func increment_currency_amount(currency: Const.Currency, delta: float) -> float:
	var amount = currency_amount[currency] + delta
	currency_amount[currency] = amount
	return amount
