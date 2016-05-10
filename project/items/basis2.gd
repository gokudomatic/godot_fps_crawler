tool

extends Spatial

signal body_enter(body)

func _ready():
	pass

func _on_Area_body_enter( body ):
	emit_signal("body_enter",body)