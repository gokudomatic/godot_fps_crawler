
extends Area

var owner=null
var power=20

var velocity=Vector3()

func _ready():
	set_process(true)
	
func _process(delta):
	var aim = get_global_transform().basis
	var direction=Vector3()
	direction-=aim[2]
	direction = direction.normalized()
	velocity=direction*40
	
	var motion=velocity*delta
	set_translation(get_translation()+motion)

func _on_bullet_body_enter( body ):
	if body!=owner and not (body in get_tree().get_nodes_in_group("npc-wall")):
		if body.has_method("hit"): 
			body.hit(self)
		queue_free()
