class_name TeamData

@export var currency_amount = {}

@export var hub: Hub

func get_currency_amount(currency: Const.Currency) -> float:
	return currency_amount[currency]

func increment_currency_amount(currency: Const.Currency, delta: float) -> float:
	var amount = currency_amount[currency] + delta
	currency_amount[currency] = amount
	return delta
