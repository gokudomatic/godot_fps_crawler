
extends "projectile_abstract.gd"

onready var ray=get_node("RayCast")

onready var explosion_class=null

var power=1
var velocity=Vector3()

func set_owner(value):
	.set_owner(value)
	power=5
	ray.add_exception_rid(owner)

func shoot():
	if ray.is_colliding():
		var object=ray.get_collider()
		var special=false
		if explosion_class != null and randi()%data.get_modifier("attack.elemental_chance") ==0 :
			special=true
		var p=ray.get_collision_point()
		if object.has_method("hit"):
			object.hit(self,special)
		var instance=bullet_factory.get_impact()    #impact_class.instance()
		instance.set_translation(p)
		owner.get_parent_spatial().add_child(instance)
		if special :
			var explosion=explosion_class.instance()
			explosion.owner=owner
			var t=Transform()
			t.origin=p
			explosion.set_transform(t)
			explosion.rescale(0.2*data.get_modifier("attack.size"))
			owner.get_parent_spatial().add_child(explosion)
			
	return true

func reset():
	print("modifier:",data.get_modifier("attack.elemental_impact"))
	explosion_class=bullet_factory.get_impact_explosion_class(data.get_modifier("attack.elemental_impact"))