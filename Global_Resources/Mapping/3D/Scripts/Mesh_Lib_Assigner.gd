@tool
extends Node3D

@export_dir var _e_dir = ""
@export_category("Debug")
@export var _e_assign_button: bool:
	set(value):
		_assign_meshes()
@export var _e_rename_button: bool:
	set(value):
		_rename_mesh_instances()

func _assign_meshes():
	for child in get_tree().get_nodes_in_group("Assign"):
		var mesh_instance = child.get_child(0)
		var mesh_name = mesh_instance.get_name()
		var mesh_path = "%s/Mesh_Lib_%s.res" % [_e_dir, mesh_name]
		var mesh = load(mesh_path)
		mesh_instance.set_mesh(mesh)

func _rename_mesh_instances():
	for child in get_children():
		var child_name = child.get_name()
		var mesh_instance = child.get_child(0)
		mesh_instance.set_name(child_name)
