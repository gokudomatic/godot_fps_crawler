
extends KinematicBody


var velocity=Vector3()
var view_sensitivity = 0.3
var yaw = 0
var pitch = 0
var is_moving=false
var on_floor=false
var jump_timeout=0
var attack_timeout=0
var fly_mode=false
var alive=true
var current_target=null
var current_target_2d_pos=null
var multijump=0
var is_using_accessory=false

var bullet_regen=0

var weapon_base=null

onready var bullet_factory=get_node("/root/Projectile_Factory") 
onready var player_data=get_node("/root/global").player_data
onready var camera=get_node("yaw/camera")

var aim_offset=Vector3(0,1.5,0)

const ACCEL= 2
const DEACCEL= 4 
const FLY_SPEED=100
const FLY_ACCEL=4
const GRAVITY=-9.8*3
const MAX_JUMP_TIMEOUT=0.2
const MAX_ATTACK_TIMEOUT=0.2
const MAX_SLOPE_ANGLE = 40
const STAIR_RAYCAST_HEIGHT=0.75
const STAIR_RAYCAST_DISTANCE=0.58
const STAIR_JUMP_SPEED=5
const STAIR_JUMP_TIMEOUT=0.1
const ZOOM_SPEED=150

func _input(ie):
	if ie.type == InputEvent.MOUSE_MOTION:
		yaw = fmod(yaw - ie.relative_x * view_sensitivity, 360)
		pitch = max(min(pitch - ie.relative_y * view_sensitivity, 90), -90)
		get_node("yaw").set_rotation(Vector3(0, deg2rad(yaw), 0))
		get_node("yaw/camera").set_rotation(Vector3(deg2rad(pitch), 0, 0))
	
	if ie.type == InputEvent.KEY:
		if Input.is_action_pressed("use"):
			var ray=get_node("yaw/camera/actionRay")
			if ray.is_colliding():
				var obj=ray.get_collider()
	

func _fixed_process(delta):
	
	refresh_current_target()
	
	if player_data.refresh_bullet_pool:
		player_data.refresh_bullet_pool=false
		
		if player_data.refresh_weapon_base:
			player_data.refresh_weapon_base=false
			weapon_base.queue_free()
			weapon_base=bullet_factory.get_base(player_data.weapon_base_type)
			get_node("yaw/camera/weapon/shoot-point").add_child(weapon_base)
			weapon_base.owner=self
		
		weapon_base.reset()
		weapon_base.regenerate()
	elif bullet_regen>0:
		bullet_regen-=delta
	else:
		weapon_base.regenerate()
		bullet_regen=1
	
	if fly_mode:
		_fly(delta)
	else:
		_walk(delta)

func _ready():
	
	weapon_base=bullet_factory.get_base(player_data.weapon_base_type)
	get_node("yaw/camera/weapon/shoot-point").add_child(weapon_base)
	weapon_base.owner=self
	
	get_node("yaw/camera/actionRay").add_exception(self)
	
	set_fixed_process(true)
	set_process_input(true)

func _enter_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _fly(delta):
	# read the rotation of the camera
	var aim = get_node("yaw/camera").get_global_transform().basis
	# calculate the direction where the player want to move
	var direction = Vector3()
	if Input.is_action_pressed("move_forwards"):
		direction -= aim[2]
		print("forward")
	if Input.is_action_pressed("move_backwards"):
		direction += aim[2]
		print("backwards")
	if Input.is_action_pressed("move_left"):
		direction -= aim[0]
		print("left")
	if Input.is_action_pressed("move_right"):
		direction += aim[0]
		print("right")
	if Input.is_action_pressed("quit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()
	
	direction = direction.normalized()
		
	# calculate the target where the player want to move
	var target=direction*FLY_SPEED
	
	# calculate the velocity to move the player toward the target
	velocity=Vector3().linear_interpolate(target,FLY_ACCEL*delta)
	
	# move the node
	var motion=velocity*delta
	motion=move(motion)
	
	# slide until it doesn't need to slide anymore, or after n times
	var original_vel=velocity
	var attempts=4 # number of attempts to slide the node
	
	while(attempts and is_colliding()):
		var n=get_collision_normal()
		motion=n.slide(motion)
		velocity=n.slide(velocity)
		# check that the resulting velocity is not opposite to the original velocity, which would mean moving backward.
		if(original_vel.dot(velocity)>0):
			motion=move(motion)
			if (motion.length()<0.001):
				break
		attempts-=1

func _walk(delta):
	
	# process timers
	if jump_timeout>0:
		jump_timeout-=delta
	if attack_timeout>0:
		attack_timeout-=delta
	
	var ray = get_node("ray")
	var step_ray=get_node("stepRay")
	
	# read the rotation of the camera
	var aim = get_node("yaw/camera").get_global_transform().basis
	# calculate the direction where the player want to move
	var direction = Vector3()
	if Input.is_action_pressed("move_forwards"):
		direction -= aim[2]
	if Input.is_action_pressed("move_backwards"):
		direction += aim[2]
	if Input.is_action_pressed("move_left"):
		direction -= aim[0]
	if Input.is_action_pressed("move_right"):
		direction += aim[0]
	if Input.is_action_pressed("quit"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().quit()
	if Input.is_action_pressed("attack") and attack_timeout<=0:
		shoot()
	
	is_using_accessory=Input.is_action_pressed("do_accessory")

	if player_data.accessory=="zoom":
		var fovy=camera.get_fov()
		if is_using_accessory and fovy>10:
			fovy=max(fovy-delta*ZOOM_SPEED,10)
			camera.set_perspective(fovy,camera.get_znear(),camera.get_zfar())
		elif not is_using_accessory and fovy<60:
			fovy=min(fovy+delta*ZOOM_SPEED,60)
			camera.set_perspective(fovy,camera.get_znear(),camera.get_zfar())


	
	#reset the flag for actor's movement state
	is_moving=(direction.length()>0)
	
	direction.y=0
	direction = direction.normalized()
	
	# clamp to ground if not jumping. Check only the first time a collision is detected (landing from a fall)
	var is_ray_colliding=ray.is_colliding()
	if !on_floor and jump_timeout<=0 and is_ray_colliding:
		set_translation(ray.get_collision_point())
		on_floor=true
	elif on_floor and not is_ray_colliding:
		# check that flag on_floor still reflects the state of the ray.
		on_floor=false
	
	if on_floor:
		# if on floor move along the floor. To do so, we calculate the velocity perpendicular to the normal of the floor.
		var n=ray.get_collision_normal()
		velocity=velocity-velocity.dot(n)*n
		
		# if the character is in front of a stair, and if the step is flat enough, jump to the step.
		if is_moving and step_ray.is_colliding():
			var step_normal=step_ray.get_collision_normal()
			if (rad2deg(acos(step_normal.dot(Vector3(0,1,0))))< MAX_SLOPE_ANGLE):
				velocity.y=STAIR_JUMP_SPEED
				jump_timeout=STAIR_JUMP_TIMEOUT
		
		# apply gravity if on a slope too steep
		if (rad2deg(acos(n.dot(Vector3(0,1,0))))> MAX_SLOPE_ANGLE):
			velocity.y+=delta*GRAVITY
	else:
		# apply gravity if falling
		velocity.y+=delta*GRAVITY
	
	# calculate the target where the player want to move
	var target=direction*player_data.walk_speed
	# if the character is moving, he must accelerate. Otherwise he deccelerates.
	var accel=DEACCEL
	if is_moving:
		accel=ACCEL
	
	# calculate velocity's change
	var hvel=velocity
	hvel.y=0
	
	# calculate the velocity to move toward the target, but only on the horizontal plane XZ
	hvel=hvel.linear_interpolate(target,accel*delta)
	velocity.x=hvel.x
	velocity.z=hvel.z
	
	
	# move the node
	var motion=velocity*delta
	motion=move(motion)
	
	# slide until it doesn't need to slide anymore, or after n times
	var original_vel=velocity
	if(motion.length()>0 and is_colliding()):
		var n=get_collision_normal()
		motion=n.slide(motion)
		velocity=n.slide(velocity)
		# check that the resulting velocity is not opposite to the original velocity, which would mean moving backward.
		if(original_vel.dot(velocity)>0):
			motion=move(motion)
	
	if on_floor:
		# move with floor but don't change the velocity.
		var floor_velocity=_get_floor_velocity(ray,delta)
		if floor_velocity.length()!=0:
			move(floor_velocity*delta)
	
		# jump
		if Input.is_action_pressed("jump"):
			velocity.y=player_data.jump_strength
			jump_timeout=MAX_JUMP_TIMEOUT
			on_floor=false
			multijump=player_data.get_modifier("multijump")
	elif Input.is_action_pressed("jump") and multijump>0 and jump_timeout<=0:
		velocity.y=player_data.jump_strength
		jump_timeout=MAX_JUMP_TIMEOUT
		on_floor=false
		multijump-=1
		print("jumps:",multijump)
	
	# update the position of the raycast for stairs to where the character is trying to go, so it will cast the ray at the next loop.
	if is_moving:
		var sensor_position=Vector3(direction.z,0,-direction.x)*STAIR_RAYCAST_DISTANCE
		sensor_position.y=STAIR_RAYCAST_HEIGHT
		step_ray.set_translation(sensor_position)

func _get_floor_velocity(ray,delta):
	var floor_velocity=Vector3()
	# only static or rigid bodies are considered as floor. If the character is on top of another character, he can be ignored.
	var object = ray.get_collider()
	if object extends RigidBody or object extends StaticBody:
		var point = ray.get_collision_point() - object.get_translation()
		var floor_angular_vel = Vector3()
		# get the floor velocity and rotation depending on the kind of floor
		if object extends RigidBody:
			floor_velocity = object.get_linear_velocity()
			floor_angular_vel = object.get_angular_velocity()
		elif object extends StaticBody:
			floor_velocity = object.get_constant_linear_velocity()
			floor_angular_vel = object.get_constant_angular_velocity()
		# if there's an angular velocity, the floor velocity take it in account too.
		if(floor_angular_vel.length()>0):
			var transform = Matrix3(Vector3(1, 0, 0), floor_angular_vel.x)
			transform = transform.rotated(Vector3(0, 1, 0), floor_angular_vel.y)
			transform = transform.rotated(Vector3(0, 0, 1), floor_angular_vel.z)
			floor_velocity += transform.xform_inv(point) - point
			
			# if the floor has an angular velocity (rotation force), the character must rotate too.
			yaw = fmod(yaw + rad2deg(floor_angular_vel.y) * delta, 360)
			get_node("yaw").set_rotation(Vector3(0, deg2rad(yaw), 0))
	return floor_velocity


func _on_ladders_body_enter( body ):
	if body==self:
		fly_mode=true

func _on_ladders_body_exit( body ):
	if body==self:
		fly_mode=false

func shoot():
	if weapon_base.shoot():
		attack_timeout=1.0/player_data.fire_rate

func hit(source,special=false):
	player_data.hit(30)

func get_item(item):
	player_data.get_item(item)

func explosion_blown(explosion,strength,special):
	var t0=explosion.get_global_transform()
	var t1=get_global_transform()
	var blown_direction=t1.origin-t0.origin
	velocity+=blown_direction.normalized()*strength

func get_data():
	return player_data

func refresh_current_target():
	var camera=get_node("yaw/camera")
	var screen_center=get_viewport().get_rect().size/2
	
	var pt=get_global_transform().origin
	var closest_enemy=null
	var closest_enemy_dist=-1
	
	var enemies=get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		var et=enemy.get_global_transform().origin+enemy.aim_offset
		var pos=camera.unproject_position(et)
		if screen_center.distance_to(pos)<50:
			var ed=et.distance_to(pt)
			if closest_enemy==null or ed<closest_enemy_dist:
				closest_enemy=enemy
				closest_enemy_dist=ed
				current_target_2d_pos=pos
	
	current_target=closest_enemy
	