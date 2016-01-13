
extends Spatial

var player_class = preload("res://actor.gd")
var map_data=null
var npc_list=[]

func _on_entry_body_enter( body ):
	if body extends player_class:
		get_node("/root/world").player_enter_room(self)