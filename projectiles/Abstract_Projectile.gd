
extends Node

var owner=null

func _ready():
	if _get_child()!=null:
		_get_child().parent=self
		set_ready()

func _get_child():
	return null

func add_mesh(mesh):
	add_child(mesh)
	mesh.parent=self
	set_ready()

func set_ready():
	pass