
extends Node

var catalogue=[]

const MAX_ENTRIES=3 # must be minimum 2 (corridor)

func _init():
	
#	catalogue.append({
#		id="room-4-1",
#		file="room-4-1.scn",
#		size=1,
#		max_npc=4,
#		connectors=["connector-E1","connector-S1","connector-W1","connector-N1"],
#		spawn_points=["spawn-1","spawn-2","spawn-3","spawn-4","spawn-5"]
#	})

#	catalogue.append({
#		id="room-4-2",
#		file="room-4-2.scn",
#		size=1,
#		max_npc=1,
#		connectors=["connector-1","connector-2","connector-3","connector-4"],
#		spawn_points=["spawn-1"]
#	})
	
	catalogue.append({
		id="room-3-1",
		file="room-3-1.scn",
		size=1,
		max_npc=1,
		connectors=["connector-E1","connector-S1","connector-W1"],
		spawn_points=["spawn-1"]
	})

#	catalogue.append({
#		id="room-3-4",
#		file="room-3-4.scn",
#		size=1,
#		max_npc=1,
#		connectors=["connector-E1","connector-E2","connector-E3"],
#		spawn_points=["spawn-1"]
#	})

#	catalogue.append({
#		id="room-2-1",
#		file="room-2-1.scn",
#		size=1,
#		max_npc=1,
#		connectors=["connector-E1","connector-W1"],
#		spawn_points=["spawn-1"]
#	})
#	catalogue.append({
#		id="room-2-2",
#		file="room-2-2.scn",
#		size=1,
#		max_npc=1,
#		connectors=["connector-E1","connector-S1"],
#		spawn_points=["spawn-1"]
#	})
#	catalogue.append({
#		id="room-2-3",
#		file="room-2-3.scn",
#		size=1,
#		max_npc=1,
#		connectors=["connector-E1","connector-W1"],
#		spawn_points=["spawn-1"]
#	})
#	catalogue.append({
#		id="room-2-4",
#		file="room-2-4.scn",
#		size=1,
#		max_npc=1,
#		connectors=["connector-E1","connector-W1"],
#		spawn_points=["spawn-1"]
#	})

	catalogue.append({
		id="room-1-1",
		file="room-1-1.scn",
		size=1,
		max_npc=1,
		connectors=["connector-E1"],
		spawn_points=["spawn-1"]
	})

	catalogue.append({
		id="tiled-room-1-1",
		file="tiled-room-1-1.tscn",
		size=1,
		max_npc=1,
		connectors=["connector-S1"],
		spawn_points=["spawn-1"]
	})

	catalogue.append({
		id="tiled-room-1-2",
		file="tiled-room-1-2.tscn",
		size=1,
		max_npc=1,
		connectors=["connector-S1"],
		spawn_points=["spawn-1"]
	})

	catalogue.append({
		id="tiled-room-1-3",
		file="tiled-room-1-3.tscn",
		size=1,
		max_npc=1,
		connectors=["connector-S1"],
		spawn_points=["spawn-1"]
	})

	catalogue.append({
		id="tiled-room-1-4",
		file="tiled-room-1-4.tscn",
		size=1,
		max_npc=1,
		connectors=["connector-S1"],
		spawn_points=["spawn-1"]
	})

	catalogue.append({
		id="tiled-room-1-5",
		file="tiled-room-1-5.tscn",
		size=1,
		max_npc=1,
		connectors=["connector-S1"],
		spawn_points=["spawn-1","spawn-2","spawn-3"]
	})





#	catalogue.append({
#		id="room-1-3",
#		file="room-1-3.scn",
#		size=1,
#		max_npc=1,
#		connectors=["connector-1"],
#		spawn_points=["spawn-1"]
#	})


	catalogue.append({
		id="corridor-1",
		file="corridor-1.scn",
		size=0,
		max_npc=0,
		connectors=["connector-E1","connector-W1"],
		spawn_points=[]
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
