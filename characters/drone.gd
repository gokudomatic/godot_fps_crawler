
extends RigidBody

var bullet_class=preload("res://projectiles/Basic.tscn")
onready var bullet_factory=get_node("/root/Projectile_Factory") 


const ANGULAR_SPEED=4
const VELOCITY_MAX=10
const VELOCITY_ACCEL=0.05
const TARGET_DISTANCE=4
const SHOOT_RECHARGE_TIME=1
const MAXIMUM_SHOOTS=3
const MAXIMUM_DODGES=5
const MAX_LIFE=100

const shoot_points=["yaw/shoot_point_1","yaw/shoot_point_2","yaw/shoot_point_3","yaw/shoot_point_4"]

var going_backward=false
var aiming_at_target=false
var target_ray=null
var collision_ray=null
var current_target=null
var player=null
var action_timeout=0
var can_see_target=false
var remaining_shots=0
var current_direction=Vector3()
var distance_to_collision=0
var alive=true
var remaining_dodges=MAXIMUM_DODGES
var no_move=false
var hit_quotas=Dictionary()

const random_angle_a=float(355284801)/float(256000000)


var aim_offset=Vector3()

var life=MAX_LIFE
var current_action={
	name="",
	shoot=false,
	move=true,
	follow_target=false
}

func _ready():
	# Initialization here
	player=get_parent().get_node("player")
	#current_target=get_parent().get_node("player")
	target_ray=get_node("target_ray")
	target_ray.add_exception_rid(get_rid())
	collision_ray=get_node("collision_ray")
	collision_ray.add_exception_rid(get_rid())
	
	for n in get_tree().get_nodes_in_group("npc-wall"):
		target_ray.add_exception_rid(n.get_rid())

func _integrate_forces(state):
	if not alive:
		return
	
	if target_ray.is_colliding():
		distance_to_collision=(target_ray.get_collision_point()-target_ray.get_global_transform().origin).length()
	else:
		distance_to_collision=-1
	
	var yaw_t=get_node("yaw").get_global_transform()
	if current_target!=null:
		# target ray
		if target_ray.is_colliding() and target_ray.get_collider()==current_target:
			# target in sight
			can_see_target=true
		else:
			can_see_target=false
		
		var target_transform=yaw_t.looking_at(current_target.get_global_transform().origin+current_target.aim_offset,Vector3(0,1,0)).orthonormalized()
		target_ray.set_global_transform(target_transform)
		if not current_target.alive:
			current_target=player
	else:
		can_see_target=false
		var target_transform=yaw_t.looking_at(player.get_global_transform().origin+player.aim_offset,Vector3(0,1,0)).orthonormalized()
		target_ray.set_rotation(Vector3(0,0,0))
		var v=target_transform.basis.z-yaw_t.basis.z
		if v.length()<0.53:
			print("player in sight")
			current_target=player
	
	if action_timeout<=0 and remaining_shots<=0:
		change_action(state)
	else:
		action_timeout-=state.get_step()
	
	do_current_action(state)

func shoot():
	if current_target!=null:
		var bullet=bullet_factory.get_basic_projectile()
		var shoot_point=shoot_points[randi()%4]
		var transform=get_node(shoot_point).get_global_transform()
		bullet.set_transform(transform.looking_at(current_target.get_global_transform().origin+current_target.aim_offset,Vector3(0,1,0)).orthonormalized())
		bullet.owner=self
		bullet.speed=40
		get_parent_spatial().add_child(bullet)


func hit(source):
	if remaining_dodges>=1 and not no_move:
		dodge(source)
		remaining_dodges-=1
	else:
		if not no_move:
			set_linear_velocity(get_linear_velocity()+source.velocity.normalized()*10)
		if alive:
			life=life-20
			if life<=0:
				# die
				die()
			else:
				# hurt
				#change quota
				create_sleep_action()
	
	var culprit=source.owner
	if culprit!=current_target:
		if culprit in hit_quotas:
			hit_quotas[culprit]+=source.power
			if hit_quotas[culprit]>MAX_LIFE/4:
				current_target=culprit
				hit_quotas.clear()
		else:
			if current_target==null:
				print(get_name()," attaqued by ",culprit.get_name())
				current_target=culprit
			else:
				hit_quotas[culprit]=source.power

func do_current_action(state):
	
	var lv = state.get_linear_velocity()
	
	var current_t=get_node("yaw").get_global_transform()
	var current_z=current_t.basis.z
	
	# moving
	if current_action.move and not no_move:
		#move to destination
		var lv1=lv-current_direction*VELOCITY_ACCEL
		if lv1.length()>VELOCITY_MAX:
			lv1=lv1.normalized()*VELOCITY_MAX
		
		if state.get_contact_count()>0:
			var normal=state.get_contact_local_normal(0)
			lv1=normal.slide(lv1)
		
		set_linear_velocity(lv1)
	else:
		#slow down to halt
		if lv.length()>0.1:
			lv*=0.96
		else:
			lv=Vector3()
		set_linear_velocity(lv)
	
	# rotation
	var target_z
	if current_action.follow_target:
		target_z=target_ray.get_global_transform().basis.z
	else:
		target_z=current_direction
	
	var vx=Vector2(current_z.x,current_z.z).angle_to(Vector2(target_z.x,target_z.z))
	
	aiming_at_target=(abs(vx)<0.3)
	 
	if not aiming_at_target:
		vx=sign(vx)
	
	state.set_angular_velocity(Vector3(0,vx*ANGULAR_SPEED,0))
	get_node("yaw").set_rotation(Vector3(Vector2(1,0).angle_to(Vector2(1,target_z.y)),0,0))
	
	if current_action.move and collision_ray.is_colliding():
		avoid_collision(state)


	# shoot
	if remaining_shots>0:
		if action_timeout>0:
			action_timeout-=state.get_step()
		elif aiming_at_target:
			action_timeout=SHOOT_RECHARGE_TIME
			remaining_shots-=1
			shoot()
			if remaining_shots<=0:
				change_action(state)


func calculate_destination():
	if current_target!=null:
		current_direction=get_global_transform().looking_at(current_target.get_global_transform().origin+current_target.aim_offset,Vector3(0,1,0)).orthonormalized().basis.z
	else:
		current_direction=get_global_transform().basis.z
	
	var angle_x=randf()*PI
	var y=random_angle_a/(angle_x+0.3926875)-0.3426875
	if y<0.17:
		y=0
	else:
		if randi()%2==1:
			y=-y
	var angle_diff=y
	
	current_direction=current_direction.rotated(Vector3(0,1,0),angle_diff)

func avoid_collision(state):
	if collision_ray.get_collider()==current_target:
		invert_direction(state)
	else:
		slide_wall(state)

func invert_direction(state):
	current_direction=-current_direction
	set_transform(get_transform().rotated(Vector3(0,1,0),PI))
	state.set_transform(state.get_transform().rotated(Vector3(0,1,0),PI))
	set_linear_velocity(Vector3())

func slide_wall(state):
	var normal=collision_ray.get_collision_normal()
	var new_direction=normal.slide(current_direction)
	current_direction=new_direction.normalized()
	set_linear_velocity(new_direction)

func change_action(state):

	if remaining_dodges<MAXIMUM_DODGES:
		remaining_dodges+=0.1
	
	if current_target==null:
		if randi()%3==0:
			create_move_action(state)
		else:
			create_sleep_action()
	else:
		if current_action.name=="move" and can_see_target:
			create_attack_target_action()
		else:
			create_move_action(state)

func create_sleep_action():
	current_action={
		name="sleep",
		shoot=false,
		move=false,
		follow_target=false
	}
	action_timeout=0.2

func create_move_action(state):
	calculate_destination()
	current_action={
		name="move",
		shoot=false,
		move=true,
		follow_target=false
	}
	action_timeout=2
	if current_target!=null and get_translation().distance_to(current_target.get_global_transform().origin)<TARGET_DISTANCE:
		avoid_collision(state)


func create_attack_target_action():
	current_action={
		name="attack",
		shoot=true,
		move=false,
		follow_target=true
	}
	remaining_shots=randi()%MAXIMUM_SHOOTS+1

func die():
	set_mode(MODE_RIGID)
	set_use_custom_integrator(false)
	get_node("yaw/reactor").set_emitting(false)
	alive=false
	
func dodge(source):
	var factor=1
	if randi()%2==0:
		factor=-1
	set_linear_velocity(get_linear_velocity()+source.velocity.rotated(Vector3(0,1,0),factor*PI/2).normalized()*30)
	create_attack_target_action()