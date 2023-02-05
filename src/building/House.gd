class_name House
extends Building

@export var ammo_currency: Const.Currency
@export var max_ammo: float = 10.0
var magazine: float = 0.0

func _ready() -> void:
	super._ready()
	request_currency.emit(self, ammo_currency, max_ammo)


func receive_currency(currency: Const.Currency, amount: float) -> bool:
	if currency == ammo_currency and magazine < max_ammo:
		magazine = clampf(magazine + amount, 0.0, max_ammo)
		return true
	return false
