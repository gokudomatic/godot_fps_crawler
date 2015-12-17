
extends Node

var catalogue=[]

const MAX_ENTRIES=4

func _init():
	
	catalogue.append({
		id="room-4-1",
		file="room-4-1.scn",
		size=1,
		connectors=["connector-E1","connector-S1","connector-W1","connector-N1"]
	})
	
	catalogue.append({
		id="room-3-1",
		file="room-3-1.scn",
		size=1,
		connectors=["connector-E1","connector-S1","connector-W1"]
	})

	catalogue.append({
		id="room-2-1",
		file="room-2-1.scn",
		size=1,
		connectors=["connector-E1","connector-W1"]
	})
	catalogue.append({
		id="room-2-2",
		file="room-2-2.scn",
		size=1,
		connectors=["connector-E1","connector-S1"]
	})

	catalogue.append({
		id="room-1-1",
		file="room-1-1.scn",
		size=1,
		connectors=["connector-E1"]
	})

	catalogue.append({
		id="corridor-1",
		file="corridor-1.scn",
		size=0,
		connectors=["connector-E1","connector-W1"]
	})

func get_random_room(nb_entries):
	var candidates=[]
	for t in catalogue:
		if t.connectors.size()==nb_entries:
			candidates.append(t)
	
	var i=randi() % candidates.size()
	return candidates[i]
	

func get_random_corridor():
	var candidates=[]
	for t in catalogue:
		if t.connectors.size()==2 and t.size==0:
			candidates.append(t)
	
	var i=randi() % candidates.size()
	return candidates[i]
