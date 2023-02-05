class_name Upgrades
extends Control

@onready var options: Control = $"options"

func _on_panel_toggle_button_pressed():
	options.visible = not options.visible
