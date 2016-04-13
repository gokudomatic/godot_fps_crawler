
extends "Abstract_Projectile.gd"

var explosion=null

func set_ready():
	var aim = get_global_transform().basis
	var direction=Vector3()
	direction-=aim[2]
	direction = direction.normalized()
	
	_mesh.set_linear_velocity(direction*20)

func explode():
	if explosion != null:
		explosion.owner=owner
		var t=Transform()
		t.origin=_mesh.get_transform().origin
		explosion.set_transform(t)
		add_child(explosion)
	_mesh.queue_free()

func add_explosion(e):
	explosion=e