class_name BuildingInfoPanel
extends Node3D

@export var building: Building

@onready var health_bar: TextureProgressBar = $"Sprite3D/SubViewport/container/healthBar"

func _ready():
	($"Sprite3D" as Sprite3D).texture = ($"Sprite3D/SubViewport" as SubViewport).get_texture()

func _update():
	health_bar.max_value = 100
	health_bar.value = 50
