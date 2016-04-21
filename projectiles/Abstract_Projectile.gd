
extends Node

var owner=null setget set_owner
var _mesh=null

var delayed_timer=0.5
var copies=null setget set_copies

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

func set_owner(value):
	owner=value
	delayed_timer=get_modifier("attack.split_delay")

func set_ready():
	pass

func set_copies(value):
	copies=value
	
	if copies!=null:
		set_fixed_process(true)

func get_modifier(key):
	return owner.get_data().get_modifier(key)
	
func _fixed_process(delta):
	if delayed_timer>0:
		delayed_timer-=delta
	else:
		split()

func split():
	set_fixed_process(false)
	var t=get_projectile_transform()
	var is_right=true
	var up=Vector3(0,1,0)
	var delta_angle=0
	for c in copies:
		if is_right:
			delta_angle=-delta_angle+PI/8
		else:
			delta_angle=-delta_angle
		is_right=!is_right
		var t1=t.rotated(up,delta_angle)
		
		c.set_projectile_transform(self,t1)
		get_parent_spatial().add_child(c)

func get_projectile_transform():
	return get_transform()

func set_projectile_transform(src,t):
	set_transform(t)