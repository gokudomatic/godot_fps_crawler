tool

extends Spatial

var player_class=preload("res://actor.gd")

var circle_class=preload("res://items/circle.tscn")
export(float) var duration=5
export(float) var frequency=1.0
export(int) var distance=100

var timer=0

func _ready():
	set_process(true)
	
func _process(delta):
	if timer<=0:
		timer=frequency+randf()*0.5
		
		var t=Tween.new()
		add_child(t)
		var c=circle_class.instance()
		add_child(c)
		
		t.interpolate_property(c,"transform/translation",Vector3(0,0,0),Vector3(0,distance,0), duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		t.interpolate_method(c,"set_alpha",0.5,0,duration,Tween.TRANS_CUBIC, Tween.EASE_OUT)
		t.interpolate_callback(self,duration,"end_circle",t,c)
		
		t.start()
	else:
		timer-=delta

func end_circle(t,c):
	c.queue_free()
	t.queue_free()

func _on_Area_body_enter( body ):
	if body extends player_class:
		get_node("/root/global").end_level()
	
