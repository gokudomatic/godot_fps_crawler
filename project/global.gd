
extends Node

var player_class=preload("res://Player.gd")

var player_data

func _ready():
	_center_window()
	
	player_data=player_class.new()
	set_fixed_process(true)

func _fixed_process(delta):
	player_data._fixed_process(delta)

func _center_window():
	var screen_size = OS.get_screen_size(0)
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)

func end_level():
	get_tree().quit()