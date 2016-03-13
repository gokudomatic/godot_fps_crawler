
extends Node

const catalogue_class=preload("res://rooms/room_catalogue.gd")
var catalogue=catalogue_class.new()

var nb_rooms=0

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
	nb_rooms=0
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
		var n_npc=0
		if room_template.max_npc>0:
			n_npc=randi()%(room_template.max_npc+1)
		var free_connectors=[]
		for c in room_template.connectors:
			free_connectors.append(c)
		temp_map[room.id]={
			id=room_template.id,
			resource=room_template.file,
			entries=[],
			nb_npc=n_npc,
			free_connectors=free_connectors,
			spawn_points=room_template.spawn_points
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
			
			if(randi()%2==0):
				# direct link
				var edge={id=edge_id,room1=temp_room,room2=temp_r,connector1=connector1,connector2=connector2}
				edge_id+=1
				edge.room1.entries.append(edge)
				edge.room2.entries.append(edge)
				
			else:
				# joint link
				
				nb_rooms+=1
				var joint_room_template=catalogue.get_random_corridor()
				var joint_connectors=[]
				for c in joint_room_template.connectors:
					joint_connectors.append(c)
				var temp_link={
					id=nb_rooms,
					resource=joint_room_template.file,
					entries=[],
					nb_npc=0,
					free_connectors=joint_connectors,
					spawn_points=[]
				}
				final_map.append(temp_link)
				
				var edge={id=edge_id,room1=temp_room,room2=temp_link,connector1=connector1,connector2=joint_connectors[0]}
				edge_id+=1
				edge.room1.entries.append(edge)
				edge.room2.entries.append(edge)
				
				var edge2={id=edge_id,room1=temp_link,room2=temp_r,connector1=joint_connectors[1],connector2=connector2}
				edge_id+=1
				edge2.room1.entries.append(edge2)
				edge2.room2.entries.append(edge2)
				
	return final_map

	

