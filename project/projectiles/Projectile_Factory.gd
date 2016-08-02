
extends Node

const basic_projectile=preload("res://projectiles/Basic.tscn")
const basic_laser=preload("res://projectiles/energy_blast.scn")
const basic_ball=preload("res://projectiles/energy_ball.tscn")
const basic_bomb=preload("res://projectiles/bomb.tscn")
const grenade=preload("res://projectiles/grenade.scn")
const basic_rocket=preload("res://projectiles/rocket.tscn")
const missile=preload("res://projectiles/missile.scn")
const needle=preload("res://projectiles/needle.tscn")

const explosion1=preload("res://explosions/Explosion1.tscn")
const explosion_fire1=preload("res://explosions/Explosion_fire1.tscn")
const explosion_acide1=preload("res://explosions/Explosion_acide.tscn")

const impact_class=preload("res://explosions/impact.tscn")

const base_projectile=preload("res://weapon_base/projectile_base.tscn")
const base_instant=preload("res://weapon_base/instant_base.tscn")
const base_flamethrower=preload("res://weapon_base/flamethrower_base.tscn")
const base_laser=preload("res://weapon_base/laser_base.tscn")

const laser_class=preload("res://projectiles/laser.tscn")
const bolt_class=preload("res://projectiles/thunderbolt.tscn")


func _ready():
	pass

func get_base(type):
	if type==1:
		return base_instant.instance()
	elif type==2:
		return base_flamethrower.instance()
	elif type==3:
		return base_laser.instance()
	else:
		return base_projectile.instance()

func get_projectiles(type,shape,amount=1):
	if type==1:
		return get_bomb(shape,amount)
	elif type==2:
		return get_rocket(shape,amount)
	else:
		return get_basic_projectiles(shape,amount)

func get_basic_projectiles(type,amount=1):
	var result=[]
	var meshes=[]
	
	var clazz=basic_laser
	if type==1:
		clazz=basic_ball

	for i in range(amount):
		var p=basic_projectile.instance()
		
		p.add_mesh(clazz.instance())
		result.append(p)
	
	return result

func get_bomb(type,amount=1):
	var result=[]
	var meshes=[]
	
	var clazz=grenade
	var explosion_clazz=explosion1
#	if explosion_type!=null and explosion_type!="":
#		explosion_clazz=get_impact_explosion_class(explosion_type)

	for i in range(amount):
		var p=basic_bomb.instance()
		p.add_mesh(clazz.instance())
		p.add_explosion(explosion_clazz.instance())
		result.append(p)
	
	return result

func get_rocket(type,amount=1):
	var result=[]
	var meshes=[]
	
	var clazz=missile
	var explosion_clazz=explosion1
	
	if type==1:
		clazz=needle

	for i in range(amount):
		var p=basic_rocket.instance()
		p.add_mesh(clazz.instance())
		p.add_explosion(explosion_clazz.instance())
		result.append(p)
	
	return result

func get_impact():
	return impact_class.instance()

func get_impact_explosion_class(type):
	if type=="fire":
		return explosion_fire1
	elif type=="acide":
		return explosion_acide1
	elif type=="explosion":
		return explosion1
	else:
		return null

func get_laser_class(type):
	if type==1:
		return bolt_class
	else:
		return laser_class

func get_shoot_sound(base,type,shape):
	var sounds
	
	if base==0:
		if type==1:
			sounds=["grenade01"]
		elif type==2:
			sounds=["missile01"]
		else:
			if shape==1:
				sounds=["laser04"]
			else:
				sounds=["laser01","laser02","laser03"]
	
	if sounds.size()>1:
		var i=randi() % sounds.size()
		return sounds[i]
	else:
		return sounds[0]

func get_impact_sound(base,type,shape,elemental,is_special=true):
	var sounds
	print(str(is_special))
	
	if base==0:
		if type==1 or type==2:
			sounds=["explosion01","explosion02"]
		else:
			if is_special:
				if elemental=="explosion":
					sounds=["explosion03"]
				else:
					sounds=["thud03"]
			else:
				sounds=["thud03"]
	
	if sounds.size()>1:
		var i=randi() % sounds.size()
		return sounds[i]
	else:
		return sounds[0]