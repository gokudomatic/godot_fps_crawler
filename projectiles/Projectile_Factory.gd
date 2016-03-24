
extends Node

const basic_projectile=preload("res://projectiles/Basic.tscn")
const basic_laser=preload("res://projectiles/energy_blast.scn")
const basic_ball=preload("res://projectiles/energy_ball.tscn")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func get_basic_projectile():
	var bullet=basic_projectile.instance()
	var mesh=basic_ball.instance()
	bullet.add_mesh(mesh)
	
	return bullet
