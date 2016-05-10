tool
extends Spatial

export(float,0,1,0.01) var walk_speed=0 setget set_walk_speed

var owner=null
var tree=null
var power=50

func _ready():
	# Initialization here
	tree=get_node("AnimationTreePlayer")


func set_walk_speed(val):
	walk_speed=val
	if tree!=null:
		tree.blend2_node_set_amount('walk',val)

func attack(atk_type):
	special(atk_type)

func special(spe_type):
	set_walk_speed(0)
	tree.mix_node_set_amount("specialMix",1)
	tree.transition_node_set_current("specialType",spe_type)
	tree.timeseek_node_seek("specialSeek",0)

func hit():
	special(2)

func die():
	special(3)

func end_attack():
	tree.mix_node_set_amount("specialMix",0)
	owner.end_attack()

func _on_hit_area_body_enter( body ):
	if body!=owner and body.has_method("hit"): 
		body.hit(self)
		
func end_hit():
	tree.mix_node_set_amount("specialMix",0)

func end_die():
	print("dead")
	get_node("AnimationTreePlayer").set_active(false)
	get_node("AnimationPlayer").set_active(false)