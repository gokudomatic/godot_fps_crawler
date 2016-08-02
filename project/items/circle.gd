tool
extends Quad

func _ready():
	
	var mat=get_material_override().duplicate()
	
#	var mat=FixedMaterial.new()
#	mat.set_fixed_flag(FixedMaterial.FLAG_USE_ALPHA,true)
#	mat.set_flag(Material.FLAG_DOUBLE_SIDED,true)
#	mat.set_flag(Material.FLAG_UNSHADED,true)
	
	set_material_override(mat)
	
	pass

func set_alpha(value):
	var mat=get_material_override()
	var color=mat.get_parameter(FixedMaterial.PARAM_DIFFUSE)
	color.a=value
	mat.set_parameter(FixedMaterial.PARAM_DIFFUSE,color)
