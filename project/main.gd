extends Spatial

var current_room=null
var contingent_rooms=[]
var loaded_rooms=[]
var loaded_rooms_data=[]

var loaded_templates={}

var map_rooms=[]
var map_doors={}
var test1={}

var current_nb_npc=0

const map_builder_class=preload("res://rooms/map_builder.gd")
const drone_class=preload("res://characters/drone.scn")
const walker_class=preload("res://characters/actor_escarabajo.scn")

var door_template = preload("res://rooms/door-1.scn")


func _ready():
	print("start")
	
	get_node("/root/global").player_data.shield_hud=get_node("CanvasLayer/shield_bar")
	
	_generate_map()
	
	for m in map_rooms:
		if not m.resource in loaded_templates:
			loaded_templates[m.resource]=load("res://rooms/"+m.resource)
			print("res://rooms/"+m.resource)
	
	load_first_room()
	
	var data=global.player_data
	data.set_modifier("attack.elemental_impact","explosion")
	data.set_modifier("attack.elemental_chance",1)
	data.set_modifier("projectile.homing",true)
	data.set_modifier("attack.autoaim",true)
	data.set_modifier("multijump",5)
	data.bullet_shape = 1
	data.refresh_bullet_pool=true
	
	print("is ready")

func _generate_map():
	var builder=map_builder_class.new()
	map_rooms=builder.generate()
	print("map size: ",map_rooms.size())


func make_edge(room1,room2,conn1,conn2):
	var edge={
		room1=room1,
		room2=room2,
		connector1=conn1,
		connector2=conn2
	}
	edge.room1.entries.append(edge)
	edge.room2.entries.append(edge)


func _create_room_from_type(type):
	print("create room")
	return loaded_templates[type].instance()

func load_first_room():
	print("load first room")
	var room_data=map_rooms[0]
	var room_node=_create_room_from_type(room_data.resource)
	current_room=room_node
	current_room.map_data=room_data
	loaded_rooms.append(current_room)
	loaded_rooms_data.append(room_data)
	add_child(room_node)
	_load_contingent_rooms(room_node)
	load_room_doors(room_node)
	load_room_npc(room_node)

func load_room_doors(room):
	print("load doors")
	var room_data=room.map_data
	for e in room_data.entries:
		if e.id in map_doors:
			continue
		var is_room1=(e.room1==room_data)
		var door=door_template.instance()
		var connector_room=e.connector1
		if not is_room1:
			connector_room=e.connector2
		add_child(door)
		recenter_node(room,connector_room,door,"connector")
		
		map_doors[e.id]=door
		

func load_room_npc(room):
	print("load npc")
	var room_data=room.map_data
	var spawn_points=room_data.spawn_points
	var available_points=[]
	for i in spawn_points:
		available_points.append(i)
	var nb_npc=room_data.nb_npc
	
	var npc_grid={}
	
	for i in range(nb_npc):
		var navmesh=room.get_navmesh()
		var npc
		if navmesh!=null:
			if randi()%2==0 or true:
				print("will create walker")
				npc=walker_class.instance()
			else:
				print("will create drone")
				npc=drone_class.instance()
			npc.navmesh=navmesh
		else:
			npc=drone_class.instance()
			
		room.npc_list.append(npc)
		var id=randi()%available_points.size()
		var sp_name=available_points[id]
		available_points.remove(id)
		var sp=room.get_node(sp_name)
		if sp.has_method("get_shape"):
			var d=randf()*sp.get_shape().get_radius()
			var pos_npc
			if navmesh!=null:
				var pos_npc1=null
				# as long as the distance between the point and the map are different, search another spot
				var iteration=0
				while iteration<20 and (pos_npc1==null or sqrt(pow(pos_npc.x-pos_npc1.x,2)+pow(pos_npc.z-pos_npc1.z,2))!=0):
					var v=Vector3(0,0,d).rotated(Vector3(0,1,0),randf()*2*PI)
					pos_npc=sp.get_translation()-navmesh.get_translation()+v
					pos_npc.x=floor(pos_npc.x/4)*4+2
					pos_npc.z=floor(pos_npc.z/4)*4+2
					pos_npc1=navmesh.get_closest_point(pos_npc)
					iteration+=1
					
				if iteration>=20:
					pos_npc=sp.get_global_transform().origin
				else:
					pos_npc=room.get_global_transform().xform(pos_npc1)
			else:
				var v=Vector3(0,0,d).rotated(Vector3(0,1,0),randf()*2*PI)
				pos_npc=sp.get_global_transform().origin+v
			
			npc.set_global_transform(Transform(Matrix3(),pos_npc))
		else:
			npc.set_global_transform(Transform(Matrix3(),sp.get_global_transform().origin))
		add_child(npc)

func _load_contingent_rooms(origin_room):
	print("load rooms")
	var room_data=origin_room.map_data
	for e in room_data.entries:
		var is_room1=(e.room1==room_data)
		if is_room1 and e.room2 in loaded_rooms_data:
			continue
		if !is_room1 and e.room1 in loaded_rooms_data:
			continue
		
		var new_room
		if is_room1:
			new_room=_create_room_from_type(e.room2.resource)
			add_child(new_room)
			recenter_node(origin_room,e.connector1,new_room,e.connector2)
			new_room.map_data=e.room2
		else:
			new_room=_create_room_from_type(e.room1.resource)
			add_child(new_room)
			recenter_node(origin_room,e.connector2,new_room,e.connector1)
			new_room.map_data=e.room1
		contingent_rooms.append(new_room)
		loaded_rooms.append(new_room)
		loaded_rooms_data.append(new_room.map_data)
		
		load_room_doors(new_room)
		load_room_npc(new_room)


func recenter_node(origin_node,origin_connector_name,dest_node,dest_connector_name):
	var connector1=origin_node.get_node(origin_connector_name)
	var connector2=dest_node.get_node(dest_connector_name)
	
	var t1=connector1.get_global_transform()
	var t2=connector2.get_transform()
	var diff_angle=Vector2(t2.basis[2].x,-t2.basis[2].z).angle_to(Vector2(t1.basis[2].x,-t1.basis[2].z))+PI
	while diff_angle>PI:
		diff_angle-=2*PI
	dest_node.rotate_y(diff_angle)
	dest_node.set_translation(t1.origin-connector2.get_global_transform().origin)

func _remove_far_rooms(previous_room,new_room):
	var previous_data=previous_room.map_data
	var new_data=new_room.map_data
	var to_remove=[]
	
	for e in previous_data.entries:
		var r1=e.room1
		var r2=e.room2
		
		if r1==new_data or r2==new_data:
			continue
		
		if r1!=previous_data and to_remove.find(r1)==-1:
			to_remove.append(r1)
		if r2!=previous_data and to_remove.find(r2)==-1:
			to_remove.append(r2)
	
	var nodes_to_remove=[]
	for node in contingent_rooms:
		if node!=previous_room and node!=new_room:
			if to_remove.find(node.map_data)>-1:
				nodes_to_remove.append(node)
	
	for node in nodes_to_remove:
		
		for npc in node.npc_list:
			npc.queue_free()
		
		for e in node.map_data.entries:
			if e.id in map_doors and not (e.room1 in loaded_rooms_data and e.room2 in loaded_rooms_data):
				map_doors[e.id].queue_free()
				map_doors.erase(e.id)
		
		contingent_rooms.erase(node)
		loaded_rooms.erase(node)
		loaded_rooms_data.erase(node.map_data)
		node.queue_free()

func player_enter_room(room):
	print("----------------------")
	print(OS.get_ticks_msec(),"   enter room")
	if room!=current_room:
		_load_contingent_rooms(room)
		_remove_far_rooms(current_room,room)
		contingent_rooms.append(current_room)
		current_room=room
		contingent_rooms.erase(room)
		if not room.map_data.cleared:
			_set_doors_lock(true)
			current_nb_npc=room.map_data.nb_npc
	print("######################")

func _set_doors_lock(is_locked):
	for i in map_doors:
		var d=map_doors[i]
		d.set_lock(is_locked)

func dec_nb_npc():
	current_nb_npc-=1
	if current_nb_npc<=0:
		_set_doors_lock(false)
		current_room.map_data.nb_npc=0
		current_room.map_data.cleared=true