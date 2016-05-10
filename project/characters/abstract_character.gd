
extends RigidBody

const MAX_LIFE=100
const ELEMENTAL_MAX_FREQUENCY=0.5

onready var life=MAX_LIFE
var alive=true
var current_target=null
var hit_quotas=Dictionary()
var buff=Dictionary()
var elemental_timeout=0
var elemental_frequency=0

var modifiers= {
	"attack.size":1,
	"attack.split_delay":0,
	"projectile.homing":false
}

func get_data():
	return self

func get_modifier(key):
	return modifiers[key]

func set_modifier(key,value):
	modifiers[key]=value

func hit(source,special=false):
	if alive:
		life=life-source.power
		if life<=0:
			# die
			die()
		else:
			# hurt
			#change quota
			create_sleep_action()
			
		change_target(source)
		hit_special(source,special)

func hit_special(source,special,factor=1):
	elemental_timeout=15
	if special:
		var mod=source.get_modifier("attack.elemental_impact")
		var power=source.get_modifier("attack.elemental_power")
		if mod=="fire":
			ignite(power*factor)
		elif mod=="acide":
			melt(power*factor)

func change_target(source):
	var culprit=source.owner
	if culprit!=current_target:
		if culprit in hit_quotas:
			hit_quotas[culprit]+=source.power
			if hit_quotas[culprit]>MAX_LIFE/4:
				current_target=culprit
				hit_quotas.clear()
		else:
			if current_target==null:
				current_target=culprit
			else:
				hit_quotas[culprit]=source.power

func explosion_blown(explosion,strength,special=false):
	var t0=explosion.get_global_transform()
	var t1=get_global_transform()
	var blown_direction=t1.origin-t0.origin
	var velocity=blown_direction.normalized()*(strength)
	apply_impulse(t1.origin,velocity)
	
	if alive:
		life=life-explosion.power
		if life<=0:
			# die
			die()
		else:
			# hurt
			#change quota
			create_sleep_action()
	
	change_target(explosion)
	
	if alive:
		hit_special(explosion,special,3)

func trigger_explosion():
	return true

func create_sleep_action():
	pass

func die():
	alive=false
	stop_elemental()

# elementals

func _process_elemental(delta):
	if elemental_timeout>0:
		elemental_timeout-=delta
		if elemental_frequency>0:
			elemental_frequency-=delta
		else:
			elemental_frequency=ELEMENTAL_MAX_FREQUENCY
			
			if buff.has("damage.fire"):
				_burn(buff["damage.fire"])
			elif buff.has("damage.acide"):
				_corrode(buff["damage.acide"])
		
		if elemental_timeout<=0:
			stop_elemental()

func ignite(amount):
	if buff.has("damage.fire"):
		buff["damage.fire"]=buff["damage.fire"]+amount
	else:
		buff["damage.fire"]=max(1,amount)

func melt(amount):
	if buff.has("damage.acide"):
		buff["damage.acide"]=buff["damage.acide"]+amount
	else:
		buff["damage.acide"]=max(1,amount)

func stop_elemental():
	buff.clear()

func _burn(amount):
	dec_life(amount)

func _corrode(amount):
	dec_life(amount)

func dec_life(amount):
	if alive:
		life=life-amount
		if life<=0:
			# die
			die()