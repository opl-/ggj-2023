class_name CurrencyStore
extends Resource

@export var currency_amounts: Array[CurrencyAmount] = []

func get_currency(currency: Const.Currency) -> CurrencyAmount:
	return currency_amounts[currency] if (currency < currency_amounts.size()) else null

func get_or_create_currency(currency: Const.Currency) -> CurrencyAmount:
	var instance = get_currency(currency)
	if instance != null:
		return instance
	instance = CurrencyAmount.new()
	instance.currency = currency
	currency_amounts.resize(max(currency_amounts.size(), currency + 1))
	currency_amounts[currency] = instance
	return instance

func get_existing() -> Array[CurrencyAmount]:
	var out: Array[CurrencyAmount] = []
	for currency_amount in currency_amounts:
		if currency_amount != null && currency_amount.amount != 0:
			out.push_back(currency_amount)
	return out

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
