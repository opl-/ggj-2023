extends Control

const TEXT_INVALID_PLACEMENT := "Invalid placement location"

@onready var game:  = $"/root/game"

@onready var game_camera: GameCamera = game.find_child("camera")

var site_template := preload("res://object/building/ConstructionSiteTemplate.tscn")

## Team assigned to the buildings after construction.
@export var team: Const.Team = Const.Team.PLAYER

## Buildings available for placement.
@export var schematics: Array[BuildingSchematic] = []

## Stores the buttons used to select a schematic.
var schematic_buttons: Array[Button]

var selected_schematic: BuildingSchematic:
	get:
		return selected_schematic
	set(value):
		if selected_schematic == value:
			return

		placement_valid = false

		# Update button press status.
		if selected_schematic != null:
			schematic_buttons[schematics.find(selected_schematic)].release_focus()
		if value != null:
			schematic_buttons[schematics.find(value)].grab_focus()

		if placement_ghost != null:
			placement_ghost.queue_free()
			game.tooltip.text = ""
			placement_ghost = null
		placement_ghost_collider = null
		if value != null:
			# Create ghost
			placement_ghost = value.scene_construction.instantiate()
			var areas := placement_ghost.find_children("*", "Area3D")
			if areas.size() > 0:
				placement_ghost_collider = areas[0] as Area3D
				placement_ghost_collider.monitoring = true
			game.anchor.add_child(placement_ghost)

		selected_schematic = value

## Stores a reference to the ghosted thing the player is currently trying to place, if any. Also used as the object which gets converted into a construction site.
var placement_ghost: Node3D
var placement_ghost_collider: Area3D
var placement_valid: bool = false

var placement_ray_origin: Vector3
var placement_ray_end: Vector3

func _ready():
	update_buttons()

func _input(event):
	# TODO: support controller input (raycast from screen center)
	if event is InputEventMouseMotion:
		var camera := game_camera.camera_lens

		placement_ray_origin = camera.project_ray_origin(event.position)
		placement_ray_end = placement_ray_origin + camera.project_ray_normal(event.position) * 750

		if selected_schematic == null || placement_valid:
			var hovering_button := false
			# Set tooltip text to the description of the schematic the player is hovering over.
			for button_index in schematic_buttons.size():
				var button := schematic_buttons[button_index]
				if button.is_hovered():
					var schematic := schematics[button_index]
					game.tooltip.text = schematic.name + "\n\n" + schematic.description
					hovering_button = true
					break

			if !hovering_button:
				game.tooltip.text = ""

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		selected_schematic = null
		get_viewport().set_input_as_handled()

	if placement_valid && placement_ghost != null && event.is_action_pressed("place"):
		get_viewport().set_input_as_handled()

		# Convert ghost into the construction site
		var site: ConstructionSite = site_template.instantiate()
		site.schematic = selected_schematic
		site.team = team

		# Move transform from ghost to construction site to make it easier to copy later to the constructed building.
		site.transform = placement_ghost.transform
		placement_ghost.transform = Transform3D.IDENTITY

		placement_ghost.get_parent().remove_child(placement_ghost)
		site.add_child(placement_ghost)
		site.building_scene = placement_ghost
		game.anchor.add_child(site)

		# Drop reference to the ghost to make sure it doesn't get deleted
		placement_ghost = null
		placement_ghost_collider.monitoring = false
		placement_ghost_collider = null
		var stored_schematic := selected_schematic
		selected_schematic = null

		# TODO: support on controllers
		if Input.is_action_pressed("place_multiple"):
			selected_schematic = stored_schematic

func _physics_process(_delta: float):
	if placement_ghost != null:
		update_placement_ghost()

func update_placement_ghost():
	# Always assume the placement position is valid until proven otherwise.
	placement_valid = true

	if placement_ray_origin != null:
		var space_state: PhysicsDirectSpaceState3D = game.get_world_3d().direct_space_state

		var query := PhysicsRayQueryParameters3D.create(placement_ray_origin, placement_ray_end, Const.Collision3D.TERRAIN)
		var result := space_state.intersect_ray(query)

		if result:
			placement_ghost.position = result.position
			placement_ghost.visible = true
		else:
			placement_ghost.visible = false
			placement_valid = false

	# Make sure the placement location doesn't overlap anything else, but only if the cursor is over land, and the building has a collider.
	if placement_valid && placement_ghost_collider != null && placement_ghost_collider.has_overlapping_areas():
		placement_valid = false

	if !placement_valid:
		game.tooltip.text = TEXT_INVALID_PLACEMENT
	elif game.tooltip.text == TEXT_INVALID_PLACEMENT:
		game.tooltip.text = ""

func update_buttons():
	for child in schematic_buttons:
		child.queue_free()
		remove_child(child)

	schematic_buttons.resize(schematics.size())

	for schematic_index in schematics.size():
		var schematic := schematics[schematic_index]
		var button := Button.new()
		button.text = schematic.name
		button.pressed.connect(
			func():
				if selected_schematic == schematic:
					selected_schematic = null
				else:
					selected_schematic = schematic
		)
		schematic_buttons[schematic_index] = button
		add_child(button)
