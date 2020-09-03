extends Node2D

var current_max = 5
var DUNGEON = preload("res://Worlds/Dungeon.tscn")

var kills = 0 setget set_kills

func _ready():
	_spawn_dungeon(current_max)


func set_kills(new_value):
	kills = new_value
	$UI/Label.text = str(kills)


func _finish_level():
	var children = get_children()
	for child in children:
		if "Dungeon" in child.name:
			child.call_deferred("queue_free")
	
	current_max += 1
	call_deferred("_spawn_dungeon", current_max)


func _spawn_dungeon(max_enemies):
	var dungeon = DUNGEON.instance()

	dungeon.max_enemies = max_enemies
	add_child(dungeon)
