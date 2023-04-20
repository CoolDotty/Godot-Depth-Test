@tool
extends MultiMeshInstance3D
class_name SpriteStackIso

const SHADER = preload("./SpriteStack.gdshader")


const PX = 0.01


@export_category("SpriteStackIso")
@export var sprite_sheet: Texture = null :
	get:
		return sprite_sheet
	set(value):
		sprite_sheet = value
		generate_mesh()
# Row and column limits are arbitrary.
# Feel free to go higher but watch out for the max texture size of 16384×16384
# See Image.MAX_WIDTH and Image.MAX_HEIGHT
@export_range (1, 64) var rows: int = 1 :
	get:
		return rows
	set(value):
		rows = value
		calc_total_sprites()
		generate_mesh()
@export_range (1, 64) var columns: int = 1 :
	get:
		return columns
	set(value):
		columns = value
		calc_total_sprites()
		generate_mesh()
# Manually setting total_sprites can be helpful to avoid rendering padding
# in the spritesheet.
# Ex: 4 columns, 2 rows, but only 6 slices have content 
# |1|2|3|4|
# |5|6|X|X|
@export_range (1, 4096) var total_sprites: int = 1 :
	get:
		return total_sprites
	set(value):
		total_sprites = value
		generate_mesh()
# Mainly helpful for MagicaVoxel exports
# which are 1 column, n rows, Bottom to Top
@export_enum("Top to Bottom", "Bottom to Top") var layer_order: int = 0 :
	get:
		return layer_order
	set(value):
		layer_order = value
		generate_mesh()
@export_range(0, 360, 0.01, "radians") var yaw: float = 0.0 :
	get:
		return yaw
	set(value):
		yaw = value
		generate_mesh()
@export_range(0, 16, 0.1, "suffix:px") var pitch: float = 1.0 :
	get:
		return pitch
	set(value):
		pitch = value
		generate_mesh()
@export var static_yaw: bool = false :
	get:
		return static_yaw
	set(value):
		static_yaw = value
		generate_mesh()


func calc_total_sprites():
	total_sprites = rows * columns


func generate_mesh():
	multimesh = null
	if not is_instance_valid(sprite_sheet):
		return
	
	# Create a new mesh the size of a sprite.
	var sheet_width = (sprite_sheet.get_size().x as float)
	var sheet_height = (sprite_sheet.get_size().y as float)
	var slice_width = sheet_width / columns
	var slice_height = sheet_height / rows
	
	var uv_width = slice_width / 2.0 * PX
	var uv_height = slice_height / 2.0 * PX
	print(slice_width, ' ', slice_height)
	var surface_tool = SurfaceTool.new();
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES);
	
	# Top left.
	surface_tool.set_uv(Vector2(1, 0))
	surface_tool.add_vertex(Vector3(-uv_width, uv_height, 0));
	
	# Bottom left
	surface_tool.set_uv(Vector2(1, 1))
	surface_tool.add_vertex(Vector3(-uv_width, -uv_height, 0));
	
	# Bottom right.
	surface_tool.set_uv(Vector2(0, 1))
	surface_tool.add_vertex(Vector3(uv_width, -uv_height, 0));
	
	# Top right.
	surface_tool.set_uv(Vector2(0, 0))
	surface_tool.add_vertex(Vector3(uv_width, uv_height, 0));

	# Add the indices to the surface tool.
	# Because a face is made of up two triangles, we'll need to add six indices.
	# First triangle
	surface_tool.add_index(0);
	surface_tool.add_index(1);
	surface_tool.add_index(2);
	# Second triangle
	surface_tool.add_index(0);
	surface_tool.add_index(2);
	surface_tool.add_index(3);

	# Get the resulting mesh from the surface tool, and apply it to the MeshInstance.
	var slice_mesh = surface_tool.commit();
	
	var depth_renderer = ShaderMaterial.new()
	depth_renderer.shader = SHADER
	depth_renderer.set_shader_parameter("albedo_texture", sprite_sheet)
	depth_renderer.set_shader_parameter("size", Vector2i(columns, rows))
	depth_renderer.set_shader_parameter("total_sprites", total_sprites)
	slice_mesh.surface_set_material(0, depth_renderer)
	
	multimesh = MultiMesh.new()
	multimesh.use_custom_data = true
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.instance_count = total_sprites
	
	multimesh.mesh = slice_mesh
	
	for i in range(0, total_sprites):
		var layer = i if layer_order == 0 else total_sprites - i - 1
		multimesh.set_instance_custom_data(layer, Color(i, 0.0, 0.0))
		multimesh.set_instance_transform(
				layer, 
				Transform3D.IDENTITY.translated(Vector3(0, PX * i, 0)))
	


func _ready() -> void:
	pass


func _process(_delta) -> void:
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	var up_vector = Vector3(0, PX, 0).rotated(Vector3(0, 0, 1), -camera.global_rotation.z)
	for i in range(0, total_sprites):
		multimesh.set_instance_transform(
				i,
				Transform3D.IDENTITY.translated(up_vector * i * 2))
