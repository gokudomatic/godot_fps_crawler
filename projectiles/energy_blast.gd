
extends Area

var parent=null

func _on_bullet_body_enter( body ):
	print("t")
	parent._on_body_enter(body)
	
