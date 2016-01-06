
extends RigidBody

var bullet_class=preload("res://projectiles/energy_blast.scn")

const ANGULAR_SPEED=4
const VELOCITY_MAX=10
const VELOCITY_ACCEL=0.05
const TARGET_DISTANCE=4

const shoot_points=["yaw/shoot_point_1","yaw/shoot_point_2","yaw/shoot_point_3","yaw/shoot_point_4"]

var going_backward=false
var aiming_at_target=false
var target_ray=null
var current_target=null
var action_timeout=0
var can_see_target=false

var life=100
var current_action={
	name="",
	shoot=false,
	move=true,
	follow_target=false,
	destination=Vector3()
}

func _ready():
	# Initialization here
	current_target=get_parent().get_node("player")
	target_ray=get_node("target_ray")
	target_ray.add_exception_rid(get_rid())
	

func _integrate_forces(state):
	
	var delta = state.get_step()
	
	if current_target!=null:
		# target ray
		if target_ray.is_colliding() and target_ray.get_collider()==current_target:
			# target in sight
			can_see_target=true
		else:
			can_see_target=false
		
		var target_transform=get_node("yaw").get_global_transform().looking_at(current_target.get_global_transform().origin+Vector3(0,1.5,0),Vector3(0,1,0)).orthonormalized()
		target_ray.set_global_transform(target_transform)
	else:
		can_see_target=false
		target_ray.set_rotation(Vector3(0,0,0))
	
	if action_timeout<=0:
		change_action()
	else:
		action_timeout-=delta
	
	do_current_action(state)
	
	
	
func shoot():
	#print(current_target)
	var bullet=bullet_class.instance()
	var shoot_point=shoot_points[randi()%4]
	var transform=get_node(shoot_point).get_global_transform()
	bullet.set_transform(transform.looking_at(current_target.get_global_transform().origin+Vector3(0,1.5,0),Vector3(0,1,0)).orthonormalized())
	bullet.owner=self
	get_parent_spatial().add_child(bullet)
	
func hit(source):
	print("being hit")


func do_current_action(state):
	var schedule_change_action=false
	var lv = state.get_linear_velocity()
	
	var current_t=get_node("yaw").get_global_transform()
	var current_z=current_t.basis.z
	
	var destination=current_action.destination
	if str(destination)=='target':
		destination=current_target.get_global_transform().origin+Vector3(0,1.5,0)
	
	# moving
	if current_action.move:
		#move to destination
		var t=current_t.looking_at(destination,Vector3(0,1,0)).orthonormalized()
		var speed=min(lv.length()+VELOCITY_ACCEL,VELOCITY_MAX)
		set_linear_velocity(-t.basis.z*speed)
		
		var limit=0.5
		if current_action.follow_target:
			limit=TARGET_DISTANCE
		if (destination-current_t.origin).length()<limit:
			schedule_change_action=true
	else:
		#slow down to halt
		if lv.length()>0.1:
			lv*=0.9
		else:
			lv=Vector3()
		set_linear_velocity(lv)
	
	# rotation
	var target_z
	if current_action.follow_target:
		target_z=target_ray.get_global_transform().basis.z
	else:
		target_z=current_t.looking_at(destination,Vector3(0,1,0)).basis.z
	
	var vx=Vector2(current_z.x,current_z.z).angle_to(Vector2(target_z.x,target_z.z))
	
	aiming_at_target=(abs(vx)<0.3)
	
	# shoot 
	if aiming_at_target and can_see_target:
		
		if randi()%20==0 and current_action.shoot:
			shoot()
	else:
		vx=sign(vx)
	
	state.set_angular_velocity(Vector3(0,vx*ANGULAR_SPEED,0))
	get_node("yaw").set_rotation(Vector3(Vector2(1,0).angle_to(Vector2(1,target_z.y)),0,0))
	
	if schedule_change_action:
		change_action()

func change_action():
	if current_target==null:
		create_random_move_action()
	else:
		var old_action_name=current_action.name
		
		while current_action.name==old_action_name: # prevent doing the same action twice
			var i=randi()%3
			if i==0:
				create_random_move_action()
			elif i==1 and can_see_target:
				create_attack_target_action()
			else:
				create_move_to_target_action()


func create_random_move_action():
	print("random move action")
	current_action={
		name="random move",
		shoot=false,
		move=true,
		follow_target=false,
		destination=get_translation()+Vector3(randf()-0.5,0,randf()-0.5).normalized()*5
	}
	action_timeout=1
	
func create_move_to_target_action():
	print("move to target action")
	var target_pos=current_target.get_global_transform().origin
	if get_translation().distance_to(target_pos)>TARGET_DISTANCE:
		current_action={
			name="move to target",
			shoot=false,
			move=true,
			follow_target=true,
			destination='target'
		}
		action_timeout=1
	else:
		create_random_move_action()

func create_attack_target_action():
	current_action={
		name="attack",
		shoot=true,
		move=false,
		follow_target=true,
		destination=get_translation()
	}
	action_timeout=2

func create_dodge_action():
	var t=get_global_transform().basis
	current_action={
		name="dodge",
		shoot=true,
		move=true,
		follow_target=true,
		destination=get_translation()+(randi()%2)*t.x+(randi()%2)*t.y
	}
	action_timeout=2
