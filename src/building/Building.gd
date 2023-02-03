class_name Building
extends Node3D

@onready var game: Game = get_node("/root/game")

@export var team: Const.Team

func _ready():
	game.building_placed.emit(self)

func _process(delta: float):
	pass
