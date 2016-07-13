
extends Spatial

var player_class = preload("res://actor.gd")

var is_open=false

var is_locked setget set_lock

func _ready():
	# Initialization here
	pass

func open_door():
	get_node("anim").queue("open")
	is_open=true

func close_door():
	get_node("anim").queue("close")
	is_open=false

func _on_sensor_body_enter( body ):
	if body extends player_class and not is_locked and not is_open:
		open_door()

func _on_sensor_body_exit( body ):
	if body extends player_class and is_open:
		close_door()

func set_lock(new_value):
	is_locked=new_value
	
	if new_value and is_open:
		close_door()