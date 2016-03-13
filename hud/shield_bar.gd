tool
extends Control

var img=preload("res://textures/hud/shield_bar.png")
var img_life=preload("res://textures/hud/life_bar.png")
export(int,100) var value=100 setget _set_value
export(int) var lifes=3 setget _set_life

export(int, "Left", "Center", "Right") var halign=0 setget _set_halign
var texture
var texture_life

export(Color) var color_shield=Color(1,1,1,1) setget _set_color_shield
export(Color) var color_life=Color(1,1,1,1) setget _set_color_life

func _ready():
	#value=100
	texture=ImageTexture.new()
	texture.create_from_image(img.get_data())
	texture_life=ImageTexture.new()
	texture_life.create_from_image(img_life.get_data())
	
	set_custom_minimum_size( Vector2(texture.get_width(),texture.get_height()) )
	update()

func _draw():
	var x_offset=0
	if(halign==1):
		x_offset=texture.get_width()/2
	elif(halign==2):
		x_offset=texture.get_width()
	
	var ratio=1
	if(value!=null):
		ratio=float(value)/100
	var r_dst=Rect2(1-x_offset,0,(texture.get_width()-1)*ratio,texture.get_height()-1)
	var r_src=Rect2(1,0,(texture.get_width()-1)*ratio,texture.get_height()-1)
	draw_texture_rect_region(texture, r_dst,r_src,color_shield)
	
	var row=0
	var col=0
	var life_width=texture_life.get_width()+10
	var life_height=texture_life.get_height()+10
	for l in range(lifes):
		draw_texture(texture_life,Vector2(col*life_width-x_offset+1,row*life_height+40),color_life)
		col+=1
		if (col>=6 and row==0) or col>=8:
			col=0
			row+=1

func _set_value(val):
	value=val
	update()

func _set_life(val):
	lifes=val
	update()

func _set_halign(val):
	halign=val
	update()

func _set_color_shield(val):
	color_shield=val
	update()

func _set_color_life(val):
	color_life=val
	update()
