tool

extends Spatial

signal body_enter(body)

export(Color) var Modulate=Color(1,1,1,1) setget _set_modulate
export(float,-1,1,0.001) var rot_circles_x_speed=0.03
export(float,-5,5,0.01) var rot_circle1_z_speed=0.1
export(float,-5,5,0.01) var rot_circle2_z_speed=-0.15
export(float,-1,1,0.001) var rot_circle1_y_speed=-0.01
export(float,-1,1,0.001) var rot_circle2_y_speed=0.005

var rot_circles_x=0
var rot_circle1_z=0
var rot_circle2_z=0
var rot_circle1_y=0
var rot_circle2_y=0


func _ready():
	set_process(true)

func _process(delta):
	rot_circles_x=fposmod(rot_circles_x+rot_circles_x_speed,2*PI)
	get_node("circles").set_rotation(Vector3(rot_circles_x,0,0))
	
	rot_circle1_z=fposmod(rot_circle1_z+rot_circle1_z_speed,2*PI)
	rot_circle2_z=fposmod(rot_circle2_z+rot_circle2_z_speed,2*PI)

	get_node("circles/circle1/Sprite3D").set_rotation(Vector3(0,0,rot_circle1_z))
	get_node("circles/circle2/Sprite3D").set_rotation(Vector3(0,0,rot_circle2_z))
	
	rot_circle1_y=fposmod(rot_circle1_y+rot_circle1_y_speed,2*PI)
	rot_circle2_y=fposmod(rot_circle2_y+rot_circle2_y_speed,2*PI)

	get_node("circles/circle1").set_rotation(Vector3(130,rot_circle1_y,0))
	get_node("circles/circle2").set_rotation(Vector3(-130,rot_circle2_y,0))

func _set_modulate(value):
	Modulate=value
	
	if has_node("circles"):
		get_node("circles/circle1/Sprite3D").set_modulate(value)
		get_node("circles/circle2/Sprite3D").set_modulate(value)
		get_node("sphere").set_modulate(value)

func _on_Area_body_enter( body ):
	emit_signal("body_enter",body)
