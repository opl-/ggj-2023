class_name Tooltip
extends Control

@onready var label_container: MarginContainer = $"padding"
@onready var label: Label = $"padding/Label"

@export var text: String:
	get:
		if label != null:
			return label.text
		return ""
	set(value):
		if label != null:
			label.text = value
		visible = value != null && value.length() > 0

func _process(_delta):
	size = label_container.size + Vector2(24, 24)
	pass
