
extends RigidBody

var parent=null
var timer=0
var speed=2

func _ready():
	get_node("AnimationPlayer").set_speed(speed)
	set_process(true)

func _process(delta):
	timer+=delta
	if timer>5:
		parent.explode()
	elif timer>4 and speed<4:
		speed=5
		get_node("AnimationPlayer").set_speed(speed)

func explosion_blown(explosion,strength):
	parent.explode()