
extends "projectile_abstract.gd"

const laser_class=preload("res://projectiles/laser.tscn")
const SPLIT_STEP=PI/64

onready var direction=get_node("direction")
var rays=[]

var looking_away=false
var power=1
var velocity=Vector3()

func set_owner(value):
	.set_owner(value)

func shoot():
	var special=false
#	if explosion_class != null and randi()%data.get_modifier("attack.elemental_chance") ==0 :
#		special=true
	
	for r in rays:
		_shoot_ray(r,special)
	
	return true

func _shoot_ray(r,special):
	r.activate(true)
	
	if r.is_colliding():
		var object=r.get_collider()
		var p=r.get_collision_point()
		if object.has_method("hit"):
			object.hit(self,special)

func stop_shoot():
	for r in rays:
		r.activate(false)

func reset():
	if data.get_modifier("attack.elemental_impact")=="explosion":
		data.set_modifier("attack.elemental_impact","fire")

		
	var i=rays.size()

	var is_right=true
	var delta_angle=-i/2*SPLIT_STEP

	while i<data.get_modifier("attack.split_factor")+1:
		if i>0:
			if is_right:
				delta_angle=-delta_angle+SPLIT_STEP
			else:
				delta_angle=-delta_angle
			is_right=!is_right
		
		var r=laser_class.instance()
		r.owner=owner
		rays.append(r)
		r.add_exception_rid(owner)
		direction.add_child(r)
		if i>0:
			r.rotate_y(delta_angle)
		i+=1

	if data.get_modifier("attack.autoaim") or data.get_modifier("projectile.homing"):
		set_process(true)
	else:
		set_process(false)
		direction.set_transform(Transform())

func _process(delta):
	if owner.current_target!=null:
		var t=direction.get_global_transform()
		direction.set_global_transform(t.looking_at(owner.current_target.get_global_transform().origin,Vector3(0,1,0)))
		looking_away=true
	elif looking_away:
		direction.set_transform(Transform())
		looking_away=false