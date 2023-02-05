class_name PollutionOverlay
extends MeshInstance3D

var pollution_map: PollutionMap

var image: Image
var image_texture: ImageTexture

func _ready():
	pollution_map = ($"/root/game" as Game).pollution

	create()

func create():
	(mesh as QuadMesh).size = Vector2(pollution_map.width * PollutionMap.CHUNK_SIDE, pollution_map.height * PollutionMap.CHUNK_SIDE)
	position.x = (pollution_map.width * PollutionMap.CHUNK_SIDE) / 2
	position.y = 1
	position.z = (pollution_map.height * PollutionMap.CHUNK_SIDE) / 2

	image = Image.create(pollution_map.width, pollution_map.height, false, Image.FORMAT_RGBA8)

	image_texture = ImageTexture.create_from_image(image)
	(mesh.material as StandardMaterial3D).albedo_texture = image_texture

	update_image()

func update_image():
	for x in pollution_map.width:
		for z in pollution_map.height:
			var value := int(clamp(pollution_map.get_at(x, z) * 128, 0, 255))
			image.set_pixel(x, z, Color.hex(0xffffff00 + value))

	image_texture.update(image)
