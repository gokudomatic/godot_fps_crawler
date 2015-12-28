
extends Area

func _ready():
	set_process(true)
	
func _process(delta):
	var aim = get_global_transform().basis
	var direction=Vector3()
	direction+=aim[2]
	direction = direction.normalized()
	var velocity=direction*40
	
	var motion=velocity*delta
	set_translation(get_translation()+motion)

func _on_bullet_body_enter( body ):
	if not body extends preload("res://actor.gd"):
		queue_free()
