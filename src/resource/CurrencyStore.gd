class_name CurrencyStore
extends Resource

@export var currency_amount: Array[CurrencyAmount] = []

func get_currency(currency: Const.Currency) -> CurrencyAmount:
	return currency_amount[currency]

func get_or_create_currency(currency: Const.Currency) -> CurrencyAmount:
	var instance = get_currency_amount(currency)
	if instance != null:
		return instance
	instance = CurrencyAmount.new(currency)
	currency_amount[currency] = instance
	return instance

func get_currency_amount(currency: Const.Currency) -> float:
	var instance = get_currency(currency)
	return instance.amount if (instance != null) else 0

func set_currency_amount(currency: Const.Currency, amount: float) -> float:
	get_or_create_currency(currency).amount = amount
	return amount

func increment_currency_amount(currency: Const.Currency, delta: float) -> float:
	var instance := get_or_create_currency(currency)
	var amount = instance.amount + delta
	instance.amount = amount
	return amount
