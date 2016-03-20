
extends Spatial

onready var global=get_node("/root/global")

func _on_item_body_enter( body ):
	if body.has_method("get_item"):
		body.get_item(self)
		queue_free()

func execute():
	pass