tool
extends Node2D

var img=preload("res://textures/hud/shield_bar.png")
export(int,100) var value=100 setget _set_value
var texture

func _ready():
	value=100
	var new_img=img.get_data()
	texture=ImageTexture.new()
	texture.create_from_image(new_img)
	update()

func _draw():
	var ratio=1
	if(value!=null):
		ratio=float(value)/100
	var r=Rect2(1,0,(texture.get_width()-1)*ratio,texture.get_height()-1)
	draw_texture_rect_region(texture, r,r)

func _set_value(val):
	value=val
	update()