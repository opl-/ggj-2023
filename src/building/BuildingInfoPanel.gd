class_name BuildingInfoPanel
extends Node3D

@export var building: Building

@onready var health_bar: TextureProgressBar = $"Sprite3D/SubViewport/container/healthBar"

var autoupdate: bool = true

func _ready() -> void:
	($"Sprite3D" as Sprite3D).texture = ($"Sprite3D/SubViewport" as SubViewport).get_texture()
	health_bar.hide()

func _process(_delta) -> void:
	if not autoupdate:
		return
	_update(building.hp, building.max_hp)

func _update(hp: int, max_hp: int) -> void:
	if hp == max_hp:
		health_bar.hide()
	else:
		health_bar.show()
		health_bar.max_value = max_hp
		health_bar.value = hp
