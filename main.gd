extends Spatial

var current_room=null
var contingent_rooms=[]
var loaded_rooms=[]
var loaded_rooms_data=[]

var loaded_templates={}

var map_rooms=[]
var map_doors={}
var test1={}

const map_builder_class=preload("res://map_builder.gd")

var door_template = preload("res://door-1.scn")


func _ready():
	
	_generate_map()
	#_create_map()
	
	for m in map_rooms:
		if not m.resource in loaded_templates:
			loaded_templates[m.resource]=load("res://"+m.resource)
	
	load_first_room()

func _generate_map():
	var builder=map_builder_class.new()
	map_rooms=builder.generate()
	print("map size: ",map_rooms.size())


func _create_map():
	for i in range(10):
		var res="corridor-1.scn"
		if i%2==0:
			res="room-4-1.scn"
		var room={
			id=i,
			resource=res,
			entries=[]
		}
		map_rooms.append(room)
		
	for i in range(9):
		var edge={
			room1=map_rooms[i],
			room2=map_rooms[i+1],
			connector1="connector-W1",
			connector2="connector-E1"
		}
		
		edge.room1.entries.append(edge)
		edge.room2.entries.append(edge)
	
	var first_room=map_rooms[0]
	var roomS={
		id="FS",
		resource="corridor-1.scn",
		entries=[]
	}
	map_rooms.append(roomS)
	var roomN={
		id="FN",
		resource="room-1-1.scn",
		entries=[]
	}
	map_rooms.append(roomN)
	var roomE={
		id="FE",
		resource="corridor-1.scn",
		entries=[]
	}
	map_rooms.append(roomE)
	make_edge(first_room,roomS,"connector-S1","connector-E1")
	make_edge(first_room,roomN,"connector-N1","connector-E1")
	make_edge(first_room,roomE,"connector-E1","connector-W1")

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
	return loaded_templates[type].instance()

func load_first_room():
	var room_data=map_rooms[0]
	var room_node=_create_room_from_type(room_data.resource)
	current_room=room_node
	current_room.map_data=room_data
	loaded_rooms.append(current_room)
	loaded_rooms_data.append(room_data)
	add_child(room_node)
	_load_contingent_rooms(room_node)
	load_room_doors(room_node)

func load_room_doors(room):
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
		

func _load_contingent_rooms(origin_room):
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
		for e in node.map_data.entries:
			if e.id in map_doors and not (e.room1 in loaded_rooms_data and e.room2 in loaded_rooms_data):
				map_doors[e.id].queue_free()
				map_doors.erase(e.id)
		
		contingent_rooms.erase(node)
		loaded_rooms.erase(node)
		loaded_rooms_data.erase(node.map_data)
		node.queue_free()

func player_enter_room(room):
	if room!=current_room:
		_load_contingent_rooms(room)
		_remove_far_rooms(current_room,room)
		contingent_rooms.append(current_room)
		current_room=room
		contingent_rooms.erase(room)