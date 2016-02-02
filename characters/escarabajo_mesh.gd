tool
extends Spatial

export(float,0,1,0.01) var walk_speed=0 setget set_walk_speed

var tree=null

func _ready():
	# Initialization here
	tree=get_node("AnimationTreePlayer")


func set_walk_speed(val):
	walk_speed=val
	if tree!=null:
		tree.blend2_node_set_amount('walk',val)

func attack(atk_type):
	set_walk_speed(0)
	tree.mix_node_set_amount("attack",1)
	tree.transition_node_set_current("attack_type",atk_type)