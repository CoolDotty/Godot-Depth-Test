@tool
class_name ShaderStacker3D
extends EditorPlugin


func _enter_tree():
	add_custom_type(
			"SpriteStackIso", "MultiMeshInstance3D",
			preload("res://addons/ShaderStacker3D/SpriteStackIso/SpriteStackIso.gd"), 
			preload("res://addons/ShaderStacker3D/SpriteStackIso/icon.svg"))
	add_custom_type(
			"CameraIso", "Camera3D",
			preload("res://addons/ShaderStacker3D/CameraIso/CameraIso.gd"), 
			preload("res://addons/ShaderStacker3D/CameraIso/icon.svg"))
	add_custom_type(
			"SpriteIso", "MeshInstance3D",
			preload("res://addons/ShaderStacker3D/SpriteIso/SpriteIso.gd"), 
			preload("res://addons/ShaderStacker3D/SpriteIso/icon.svg"))


func _exit_tree():
	remove_custom_type("SpriteStackIso")
	remove_custom_type("CameraIso")
	remove_custom_type("SpriteIso")
