class_name PollutionMap
extends Resource

var pollution: Array[float] = []

var temp_pollution: Array[float] = []

var width: int = 0
var height: int = 0

func _init(_width: int, _height: int):
	width = _width
	height = _height

	pollution.resize(width * height)
	temp_pollution.resize(pollution.size())

func get_index(x: int, z: int) -> int:
	if x < 0 || x >= width || z < 0 || z >= height:
		return -1
	return x * width + z

func world_to_index(x: float, z: float) -> int:
	return get_index(floor(x), floor(z))

func world_position_to_index(vector: Vector3) -> int:
	return world_to_index(vector.x, vector.z)

func get_at_index(index: int) -> float:
	if index == -1:
		return 0.0
	return pollution[index]

func set_at_index(index: int, value: float) -> float:
	if index == -1:
		return 0.0
	pollution[index] = value
	return value

func set_at(x: float, z: float, value: float) -> float:
	return set_at_index(get_index(floor(x), floor(z)), value)

func get_at(x: float, z: float) -> float:
	return get_at_index(get_index(floor(x), floor(z)))

func increment_at(x: float, z: float, change: float) -> float:
	var index := get_index(floor(x), floor(z))
	return set_at_index(index, get_at_index(index) + change)

func get_at_world(position: Vector3) -> float:
	return get_at_index(world_position_to_index(position))

func set_at_world(position: Vector3, value: float) -> float:
	return set_at_index(world_position_to_index(position), value)

func increment_at_world(position: Vector3, change: float) -> float:
	var index := world_position_to_index(position)
	return set_at_index(index, get_at_index(index) + change)

const sides := [[-1, 0], [1, 0, [0, -1], [0, 1]]]

func propagate():
	# The n prefix stands for neighbor.
	for x in width:
		for z in height:
			var index := get_index(x, z)
			var value := get_at_index(index)
			for side in sides:
				var nx: int = x + side[0]
				var nz: int = z + side[1]
				var nindex := get_index(nx, nz)
				var nvalue := get_at_index(nindex)

				# If the current tile has more than 50% more pollution, make it take 10% of pollution from the neighbor.
				if nvalue > 0 && value / nvalue < 0.5:
					var change = nvalue * 0.1
					temp_pollution[nindex] -= change
					temp_pollution[index] += change

	# Write the new values to the real pollution array. This is to prevent making the propagation sided, depending on which side is checked first.
	pollution.assign(temp_pollution)
