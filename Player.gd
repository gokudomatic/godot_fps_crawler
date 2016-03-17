
extends Node

var life=3
var shield=100
var shield_damage_factor=1
var shield_regen_speed=50
var no_shield_timeout=0
var no_shield_max_timeout=5
var walk_speed=15
var jump_strength=9
var hit_invincibility_timeout=0
var hit_invincibility_max_timeout=1

var attack_regen_speed=1
var attack_frequency=0.1
var attack_capacity=1
var attack_damage_factor=1

var shield_hud

func _fixed_process(delta):
	
	if hit_invincibility_timeout>0:
		hit_invincibility_timeout-=delta
	
	var old_shield=shield
	if no_shield_timeout>0:
		no_shield_timeout-=delta
	else:
		if shield<100:
			shield+=delta*shield_regen_speed
	
	if shield_hud != null and old_shield!=shield:
		shield_hud.value=shield

func hit(damage):
	
	if shield>0:
		shield-=damage*shield_damage_factor
	else:
		if hit_invincibility_timeout<=0:
			hit_invincibility_timeout=hit_invincibility_max_timeout
			life-=1
	
	no_shield_timeout=no_shield_max_timeout
	
	if shield<=0:
		shield=0
	
	if life<1:
		life=0
		print("game over")

	if shield_hud != null:
		shield_hud.value=shield
		shield_hud.lifes=life
