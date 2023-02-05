class_name House
extends Building

@export var ammo_currency: Const.Currency
@export var max_ammo: float = 10.0
var magazine: float = 0.0

var ammo_bar: BuildingInfoPanel

func _ready() -> void:
	super._ready()
	request_currency.emit(self, ammo_currency, max_ammo)
	ammo_bar = preload("res://object/BuildingInfoPanel.tscn").instantiate()
	ammo_bar.building = self
	ammo_bar.position.y = 13
	ammo_bar.autoupdate = false
	add_child(ammo_bar)


func _update_ammo_bar() -> void:
	ammo_bar._update(int(magazine), int(max_ammo))

func receive_currency(currency: Const.Currency, amount: float) -> bool:
	if currency == ammo_currency and magazine < max_ammo:
		magazine = clampf(magazine + amount, 0.0, max_ammo)
		_update_ammo_bar()
		return true
	return false
