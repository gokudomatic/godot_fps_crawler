
extends Node

var items={
	"autoaim":preload("autoaim.tscn"),
	"ballbeam":preload("ballbeam.tscn"),
	"bigger_attack":preload("bigger_attack.tscn"),
	"zoom":preload("binoculars.tscn"),
	"elemental_acid":preload("elemental_acid.tscn"),
	"elemental_flame":preload("elemental_flame.tscn"),
	"elemental_explosion":preload("elemental_explosion.tscn"),
	"flamethrower":preload("flamethrower.tscn"),
	"grenade":preload("grenade.tscn"),
	"homing":preload("homing.tscn"),
	"jumpUp":preload("jumpUp.tscn"),
	"lifeUp":preload("lifeUp.tscn"),
	"missile":preload("missile.tscn"),
	"multijump":preload("multijump.tscn"),
	"needle":preload("needle.tscn"),
	"pistol":preload("pistol.tscn"),
	"shieldUp":preload("shieldUp.tscn"),
	"speedUp":preload("speedUp.tscn"),
	"split":preload("split_attack.tscn"),
	"sticky_grenade":preload("sticky_grenade.tscn")
}

func _ready():
	pass

func get_item(type):
	if type in items:
		return items[type].instance()
	else:
		return null