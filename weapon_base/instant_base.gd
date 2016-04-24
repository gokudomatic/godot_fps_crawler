
extends "projectile_abstract.gd"

onready var ray=get_node("RayCast")

const impact_class=preload("res://explosions/impact.tscn")

var power=0
var velocity=Vector3()

func set_owner(value):
	.set_owner(value)
	power=5
	ray.add_exception_rid(owner)

func shoot():
	if ray.is_colliding():
		var object=ray.get_collider()
		print(object)
		var p=ray.get_collision_point()
		if object.has_method("hit"):
			object.hit(self)
		var instance=impact_class.instance()
		instance.set_translation(p)
		owner.get_parent_spatial().add_child(instance)
		print(owner.get_translation())
		print(p)
	return true
