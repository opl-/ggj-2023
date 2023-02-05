class_name Pathfinder

var paths : Dictionary = {}

func can_reach(destination: Building) -> bool:
	return paths.has(destination.get_instance_id())

func get_path(destination: Building) -> Dictionary:
	if not can_reach(destination):
		return  {
			"distance" : 0.0,
			"path": []
		}

	return paths[destination.get_instance_id()]

func retrace(hub: Hub) -> void:
	var new_paths : Dictionary = {
		hub.get_instance_id() : {
			"distance" : 0.0,
			"path": [hub.position]
		}
	}

	for link in hub.links:
		_traverse_link(link, new_paths)

	paths = new_paths

func _traverse_link(link: BuildingLink, new_paths: Dictionary) -> void:
	var current_path : Dictionary = new_paths[link.from.get_instance_id()]
	var new_path : Dictionary =  {
		"distance" : current_path["distance"] + link.distance,
		"path": []
	}
	for path_part in current_path["path"]:
		new_path["path"].append(path_part)
	new_path["path"].append(link.to.position)


	if new_paths.has(link.to.get_instance_id()):
		var old_path : Dictionary = new_paths[link.to.get_instance_id()]

		if new_path.distance < old_path.distance:
			new_paths[link.to.get_instance_id()] = new_path
		else:
			return
	else:
		new_paths[link.to.get_instance_id()] = new_path

	for next_link in link.to.links:
		_traverse_link(next_link, new_paths)
