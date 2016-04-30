
extends Spatial

onready var bullet_factory=get_node("/root/Projectile_Factory") 

var owner=null setget set_owner
var data=null

func set_owner(value):
	owner=value
	data=owner.get_data()

func shoot():
	return false

func regenerate():
	pass

func reset():
	pass

func get_modifier(key):
	return owner.get_data().get_modifier(key)
