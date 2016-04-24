
extends Node

const basic_projectile=preload("res://projectiles/Basic.tscn")
const basic_laser=preload("res://projectiles/energy_blast.scn")
const basic_ball=preload("res://projectiles/energy_ball.tscn")
const basic_bomb=preload("res://projectiles/bomb.tscn")
const grenade=preload("res://projectiles/grenade.scn")
const explosion1=preload("res://explosions/Explosion1.tscn")

const base_projectile=preload("res://weapon_base/projectile_base.tscn")
const base_instant=preload("res://weapon_base/instant_base.tscn")

func _ready():
	pass

func get_base(type):
	#return base_projectile.instance()
	return base_instant.instance()

func get_projectiles(type,shape,amount=1):
	if type==1:
		return get_bomb(shape,amount)
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
#	if type==1:
#		clazz=basic_ball

	for i in range(amount):
		var p=basic_bomb.instance()
		p.add_mesh(clazz.instance())
		p.add_explosion(explosion_clazz.instance())
		result.append(p)
	
	return result
	