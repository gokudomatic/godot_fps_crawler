
extends Node

var player_class=preload("res://Player.gd")

var player_data

func _ready():
	player_data=player_class.new()
	set_fixed_process(true)

func _fixed_process(delta):
	player_data._fixed_process(delta)
