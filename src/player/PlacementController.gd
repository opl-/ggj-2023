extends Control

@onready var game: Game = $"/root/game"

@onready var game_camera: GameCamera = game.find_child("camera")

## Team assigned to the buildings after construction.
@export var team: Const.Team = Const.Team.PLAYER

## Buildings available for placement.
@export var schematics: Array[BuildingSchematic] = []

var selected_schematic: BuildingSchematic:
	get:
		return selected_schematic
	set(value):
		if value == null:
			if placement_ghost != null:
				placement_ghost.queue_free()
				placement_ghost = null
		else:
			# Create ghost
			placement_ghost = value.scene_construction.instantiate()
			game.add_child(placement_ghost)

		selected_schematic = value

## Stores a reference to the ghosted thing the player is currently trying to place, if any. Also used as the obejct which gets converted into a construction site.
var placement_ghost: Node3D

var placement_ray_origin: Vector3
var placement_ray_end: Vector3

func _ready():
	update_buttons()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		selected_schematic = null

	# TODO: support controller input (raycast from screen center)
	if event is InputEventMouseMotion:
		var camera := game_camera.camera_lens

		placement_ray_origin = camera.project_ray_origin(event.position)
		placement_ray_end = placement_ray_origin + camera.project_ray_normal(event.position) * 150

func _physics_process(_delta: float):
	if placement_ghost != null && placement_ray_origin != null:
		var space_state: PhysicsDirectSpaceState3D = game.get_world_3d().direct_space_state

		var query := PhysicsRayQueryParameters3D.create(placement_ray_origin, placement_ray_end, Const.Collision3D.TERRAIN)
		var result := space_state.intersect_ray(query)

		if result:
			placement_ghost.position = result.position
			placement_ghost.visible = true
		else:
			placement_ghost.visible = false

	if placement_ghost != null && placement_ghost.visible && Input.is_action_just_pressed("place"):
		# Convert ghost into the construction site
		var site: ConstructionSite = preload("res://object/building/ConstructionSiteTemplate.tscn").instantiate()
		site.schematic = selected_schematic
		site.team = team

		# Move transform from ghost to construction site to make it easier to copy later to the constructed building.
		site.transform = placement_ghost.transform
		placement_ghost.transform = Transform3D.IDENTITY

		placement_ghost.get_parent().remove_child(placement_ghost)
		site.add_child(placement_ghost)
		game.add_child(site)

		# Drop reference to the ghost to make sure it doesn't get deleted
		placement_ghost = null
		var stored_schematic := selected_schematic
		selected_schematic = null

		# TODO: support on controllers
		if Input.is_action_pressed("place_multiple"):
			selected_schematic = stored_schematic

func update_buttons():
	for child in get_children():
		remove_child(child)

	for schematic in schematics:
		var button := Button.new()
		button.text = schematic.name
		button.pressed.connect(
			func():
				selected_schematic = schematic
		)
		add_child(button)
