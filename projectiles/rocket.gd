
extends "Abstract_Projectile.gd"

var velocity=Vector3() setget _set_velocity
var speed=40
var sleep=false
var timeout=5

var explosion=null

func set_ready():
	set_process(true)

func _process(delta):
	if timeout>0:
		timeout-=delta
	else:
		explode()
	
	if not sleep:
		var aim = get_global_transform().basis
		var direction=Vector3()
		direction-=aim[2]
		direction = direction.normalized()
		velocity=direction*speed
		
		var motion=velocity*delta
		set_translation(get_translation()+motion)

func set_owner(value):
	.set_owner(value)
	var size=get_modifier("attack.size")
	_mesh.rescale(size)

func _set_velocity(value):
	velocity=value
	_get_child().velocity=value


func _on_body_enter(body):
	if explosion != null and body!=owner and not (body in get_tree().get_nodes_in_group("npc-wall")):
		if get_modifier("bomb.sticky"):
			sleep=true
			if body.has_method("trigger_explosion"):
				remove_child(_mesh)
				body.add_child(_mesh)
				_mesh.set_translation(Vector3())
		else:
			explode()
		

func explode():
	set_process(false)
	
	if explosion != null:
		explosion.owner=owner
		explosion.source=self
		var t=Transform()
		t.origin=_mesh.get_global_transform().origin
		explosion.set_global_transform(t)
		explosion.rescale(get_modifier("attack.size"))
		owner.get_parent_spatial().add_child(explosion)
	_mesh.queue_free()
	
	

func add_explosion(e):
	explosion=e

func get_projectile_transform():
	if get_child_count()>0:
		return _mesh.get_global_transform()
	else:
		return null

func set_projectile_transform(src,t):
	set_global_transform(t)

func set_elemental(value):
	if explosion.has_method("set_elemental"):
		explosion.set_elemental(value)
