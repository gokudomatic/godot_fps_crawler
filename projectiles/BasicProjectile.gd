
extends "Abstract_Projectile.gd"

var velocity=Vector3() setget _set_velocity
var speed=40
var power=20

func set_ready():
	set_process(true)
	
func _process(delta):
	var aim = get_global_transform().basis
	var direction=Vector3()
	direction-=aim[2]
	direction = direction.normalized()
	velocity=direction*speed
	
	var motion=velocity*delta
	set_translation(get_translation()+motion)

	
func _set_velocity(value):
	velocity=value
	_get_child().velocity=value
	
func _on_body_enter(body):
	if body!=owner and not (body in get_tree().get_nodes_in_group("npc-wall")):
		if body.has_method("hit"): 
			body.hit(self)
		queue_free()

func set_owner(value):
	.set_owner(value)
	var size=get_modifier("attack.size")
	_mesh.rescale(size)