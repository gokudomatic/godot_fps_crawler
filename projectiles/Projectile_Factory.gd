
extends Node

const basic_projectile=preload("res://projectiles/Basic.tscn")
const basic_laser=preload("res://projectiles/energy_blast.scn")
const basic_ball=preload("res://projectiles/energy_ball.tscn")

func _ready():
	pass

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
