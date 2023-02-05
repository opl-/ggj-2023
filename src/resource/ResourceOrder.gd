class_name ResourceOrder
extends Resource

var destination : Building
var resource : CurrencyAmount
var valid: bool = true

func _init(_destination : Building, _resource : CurrencyAmount):
	destination = _destination
	resource = _resource
	