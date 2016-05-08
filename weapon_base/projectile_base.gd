
extends "projectile_abstract.gd"

var bullet_pool=[]

func shoot():
	if bullet_pool.size()>0:
		var bullet=bullet_pool[0]
		bullet_pool.pop_front()
		var transform=get_global_transform()
		bullet.set_transform(transform.orthonormalized())
		bullet.reset_target()
		owner.get_parent_spatial().add_child(bullet)
		return true
	else:
		return false

func regenerate():
	if bullet_pool.size()<60:
		
		var elemental=data.get_modifier("attack.elemental_impact")
		var is_special=elemental!=null and elemental!=""
		
		var bullets=bullet_factory.get_projectiles(data.bullet_type,data.bullet_shape,5)
		var impact_class=bullet_factory.get_impact_explosion_class(elemental)
		for b in bullets:
			b.owner=owner
			b.explosion_class=impact_class
			b.set_elemental(is_special)
			bullet_pool.append(b)
			var split_factor=data.get_modifier("attack.split_factor")
			if split_factor>0:
				var sub_bullets=bullet_factory.get_projectiles(data.bullet_type,data.bullet_shape,split_factor)
				for sb in sub_bullets:
					sb.owner=owner
					sb.explosion_class=impact_class
					sb.set_elemental(is_special)
				b.copies=sub_bullets

func reset():
	for b in bullet_pool:
		b.queue_free()
	bullet_pool.clear()