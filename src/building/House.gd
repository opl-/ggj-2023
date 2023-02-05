class_name House
extends Building

@export var ammo_currency: Const.Currency
@export var max_ammo: float = 10.0
@export var pollution_tick_cd: float = 0.5
var magazine: float = 0.0
var cd: float = 0.0

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


func _process_pollution(delta: float) -> void:
	var pollution: float = game.pollution.get_around_at_world(global_position)
	if magazine > 0.0 and pollution > 0.5:
		cd += delta
		if cd >= pollution_tick_cd:
			cd = 0.0
			magazine = clampf(magazine - 1.0, 0.0, max_ammo)
			game.pollution.increment_around_at_world(global_position, team_data.house_power * pollution_tick_cd)
			_update_ammo_bar()
			request_currency.emit(self, ammo_currency, 1.0)
	else:
		cd = 0.0


func receive_currency(currency: Const.Currency, amount: float) -> bool:
	if super.receive_currency(currency, amount):
		return true
	if currency == ammo_currency and magazine < max_ammo:
		magazine = clampf(magazine + amount, 0.0, max_ammo)
		_update_ammo_bar()
		return true
	return false
