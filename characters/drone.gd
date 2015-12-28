
extends RigidBody

const ANGULAR_SPEED=4

func _ready():
	# Initialization here
	pass

func _integrate_forces(state):
	
	var delta = state.get_step()
	var lv = state.get_linear_velocity()
	var av = state.get_angular_velocity()
	var g = state.get_total_gravity()

	#lv += g*delta # Apply gravity
	var up = -g.normalized()
	
	var current_t=state.get_transform()
	var current_pos=current_t.origin

	var target=get_parent().get_node("player").get_translation()
	var diff_v=(target+Vector3(0,2,0)-current_pos).normalized()
	
	var angle_y=Vector2(1,current_t.basis[2].y).angle_to(Vector2(1,diff_v.y))
	var angle_x=Vector2(current_t.basis[2].x,current_t.basis[2].z).angle_to(Vector2(diff_v.x,diff_v.z))
	
	
	if angle_x<-ANGULAR_SPEED*delta:
		angle_x=-ANGULAR_SPEED
	elif angle_x>ANGULAR_SPEED*delta:
		angle_x=ANGULAR_SPEED
	
	var target_t=Transform().looking_at(-diff_v,Vector3(0,1,0))
	target_t.origin=current_pos
	
#	set_transform(target_t)
	
	#lv=diff_v
	#state.set_linear_velocity(Vector3(0,0,1))
	av.y=angle_x
	av.x=angle_y
	state.set_angular_velocity(av*delta*50)

	
	