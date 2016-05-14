
extends Spatial

onready var global=get_node("/root/global")

var enable=false

func _ready():
	var t=Timer.new()
	add_child(t)
	t.connect("timeout",self,"activate")
	t.set_wait_time(1)
	t.start()

func _on_item_body_enter( body ):
	if body.has_method("get_item") and enable:
		body.get_item(self)
		queue_free()

func execute():
	pass

func set_position(value):
	get_children()[0].set_global_transform(value)

func set_velocity(value):
	var z=(get_global_transform().basis.z*Vector3(1,0,1)).normalized()
	
	get_children()[0].set_linear_velocity((-z+Vector3(0,0.3,0))*value)

func activate():
	enable=true