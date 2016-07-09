
extends Spatial

var player_class = preload("res://actor.gd")
var map_data=null
var npc_list=[]

func _on_entry_body_enter( body ):
	if body extends player_class and get_node("/root/world")!=null:
		get_node("/root/world").player_enter_room(self)

func get_navmesh():
	if get_node("nav")!=null:
		return get_node("nav")
	elif get_node("Navigation")!=null:
		return get_node("Navigation")
	else:
		return null;