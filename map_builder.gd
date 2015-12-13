
extends Node

const catalogue_class=preload("res://room_catalogue.gd")
var catalogue=catalogue_class.new()

var max_rooms=100

var map = []
var generated_map=null

func _ready():
	pass

func generate():
	randomize()
	var map_seed=randf()
	#seed(map_seed)
	step1()
	generated_map=step2()
	return generated_map
	
func step1():
	
	var nb_rooms=0
	
	var first_room={id=nb_rooms,linked=[]}
	map.append(first_room)
	var nb_entries=randi() % (catalogue.MAX_ENTRIES-1) + 1
	
	var to_process=[]
	for r in range(nb_entries):
		if(nb_rooms>=max_rooms):
			break
		nb_rooms+=1
		var room={id=nb_rooms,linked=[first_room]}
		first_room.linked.append(room)
		map.append(room)
		to_process.append(room)
	
	while(not to_process.empty() and nb_rooms<max_rooms):
		var room=to_process[0]
		to_process.pop_front()
		
		var nb_entries1=randi() % (catalogue.MAX_ENTRIES)
		for r in range(nb_entries1):
			if(nb_rooms>=max_rooms):
				break
			nb_rooms+=1
			var new_room={id=nb_rooms,linked=[room]}
			room.linked.append(new_room)
			map.append(new_room)
			to_process.append(new_room)
			
	
	# TODO add special rooms
	
	

func step2():
	var temp_map={}
	var final_map=[]
	
	var edge_id=0
	
	var processed_rooms=[]
	var to_process=[map[0]]
	
	for room in map:
		var room_template=catalogue.get_random_room(room.linked.size())
		var free_connectors=[]
		for c in room_template.connectors:
			free_connectors.append(c)
		temp_map[room.id]={
			id=room_template.id,
			resource=room_template.file,
			entries=[],
			free_connectors=free_connectors
		}
		
	while to_process.size()>0:
		var room=to_process[0]
		to_process.pop_front()
		
		processed_rooms.append(room)
		var temp_room=temp_map[room.id]
		final_map.append(temp_room)
		
		for r in room.linked:
			if r in processed_rooms:
				continue
			
			to_process.push_back(r)
			var temp_r=temp_map[r.id]
			
			var iconn1=randi() % temp_room.free_connectors.size()
			var iconn2=randi() % temp_r.free_connectors.size()
			var connector1=temp_room.free_connectors[iconn1]
			temp_room.free_connectors.erase(connector1)
			var connector2=temp_r.free_connectors[iconn2]
			temp_r.free_connectors.erase(connector2)
			
			var edge={
				id=edge_id,
				room1=temp_room,
				room2=temp_r,
				connector1=connector1,
				connector2=connector2
			}
			edge_id+=1
			
			edge.room1.entries.append(edge)
			edge.room2.entries.append(edge)
	
	return final_map