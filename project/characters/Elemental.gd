tool

extends Spatial

export(int,"None","Fire","Acide") var mode=0 setget set_mode
export(int,1,20) var strength=1 setget set_strenght
export(Vector3) var extend=Vector3(1,1,1) setget set_extend

onready var sfx=get_node("sfx")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func set_mode(value):
	mode=value
	if has_node("fire"):
		get_node("fire").set_emitting(value==1)
		get_node("acide").set_emitting(value==2)
		
		if sfx!=null:
			sfx.stop_all()
		if value==1:
			sfx.play("fire02")
		elif value==2:
			sfx.play("fire03")

func set_strenght(value):
	strength=value
	set_values(get_node("fire"),value,13.0/60*value-1.0/6)
	set_values(get_node("acide"),0.5,59.0/180*value-5.0/18)

func set_extend(value):
	extend=value
	if has_node("fire"):
		get_node("fire").set_emission_half_extents(value)
		get_node("acide").set_emission_half_extents(value)

func set_values(node,gravity,size):
	if node!=null:
		node.set_variable(Particles.VAR_FINAL_SIZE,size)
		node.set_variable(Particles.VAR_GRAVITY,gravity)
