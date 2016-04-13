
extends Node

var owner=null
var _mesh=null

func _ready():
	if _get_child()!=null:
		_get_child().parent=self
		set_ready()

func _get_child():
	return _mesh

func add_mesh(mesh):
	_mesh=mesh
	add_child(mesh)
	mesh.parent=self
	set_ready()

func set_ready():
	pass