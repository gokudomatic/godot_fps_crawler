
extends Spatial

var player_class = preload("res://actor.gd")

func _ready():
	# Initialization here
	pass

func open_door():
	get_node("anim").queue("open")

func close_door():
	get_node("anim").queue("close")

func _on_sensor_body_enter( body ):
	if body extends player_class:
		open_door()

func _on_sensor_body_exit( body ):
	if body extends player_class:
		close_door()
