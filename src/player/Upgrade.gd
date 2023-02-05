class_name Upgrade
extends Control

@export var stat: Const.Upgrade

@onready var game:  = $"/root/game"
@onready var button: Button = $Button
@onready var bar: ProgressBar = $ProgressBar

func _ready() -> void:
	_update_label()

func _process(_delta) -> void:
	var progress: Array[int] = game.get_team(Const.Team.PLAYER).get_stat_progress(stat)

	if progress[1] > 0:
		bar.show()
		bar.max_value = progress[1]
		bar.value = progress[0]
	else:
		bar.hide()
		button.set_disabled(false)
		_update_label()


func _update_label() -> void:
	for stat_text in Const.Upgrade:
		if Const.Upgrade[stat_text] == stat:
			button.set_text(stat_text + " Lv." + str(game.get_team(Const.Team.PLAYER).get_stat_level(stat)))

func _on_button_pressed() -> void:
	button.set_disabled(true)
	game.get_team(Const.Team.PLAYER).upgrade_stat(stat)
