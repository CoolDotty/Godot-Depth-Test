@tool
extends MeshInstance3D
class_name SpriteIso


const SHADER = preload("./Sprite.gdshader")


@export_category("SpriteIso")
@export var texture: Texture = null :
	get:
		return texture
	set(value):
		texture = value
		generate_mesh()


const PX = 0.01


func generate_mesh():
	mesh = null
	if not is_instance_valid(texture):
		return
	
	# Create a new mesh the size of a sprite.
	var uv_width = (texture.get_size().x as float) / 2.0 * PX
	var uv_height = (texture.get_size().y as float) / 2.0 * PX
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
	mesh = surface_tool.commit();
	
	var depth_renderer = ShaderMaterial.new()
	depth_renderer.shader = SHADER
	depth_renderer.set_shader_parameter("albedo_texture", texture)
	mesh.surface_set_material(0, depth_renderer)


func _ready() -> void:
	pass


func _process(_delta) -> void:
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	rotation = Vector3(0, 0, -camera.global_rotation.z)
	

func _draw():
	pass
