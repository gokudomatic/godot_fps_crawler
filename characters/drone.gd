
extends RigidBody

const ANGULAR_SPEED=4
const VELOCITY_MAX=10
const VELOCITY_ACCEL=0.1
const TARGET_DISTANCE=4

var going_backward=false

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
	
	var current_t=get_node("yaw").get_global_transform()
	var current_pos=current_t.origin
	var current_z=current_t.basis.z
	
	var target=get_parent().get_node("player").get_global_transform().origin+Vector3(0,2,0)
	var diff=current_pos-target
	
	var target_z=Transform().looking_at(diff,Vector3(0,1,0)).orthonormalized().basis.z
	
	var vx=Vector2(current_z.x,current_z.z).angle_to(Vector2(target_z.x,target_z.z))
	
	state.set_angular_velocity(Vector3(0,vx*ANGULAR_SPEED,0))
	get_node("yaw").set_rotation(Vector3(Vector2(1,0).angle_to(Vector2(1,target_z.y)),0,0))
	
	var speed=lv.length()
	if going_backward:
		speed=-speed
	print(speed,"   ",diff.length())
	if diff.length()>TARGET_DISTANCE:
		speed=min(speed+VELOCITY_ACCEL,VELOCITY_MAX)
		going_backward=false
	elif diff.length()<TARGET_DISTANCE-2:
		speed=max(speed-VELOCITY_ACCEL,-VELOCITY_MAX)
		going_backward=true
	elif abs(speed)>0.1:
		speed*=0.9
	else:
		speed=0
	
	set_linear_velocity(current_z*speed)
	