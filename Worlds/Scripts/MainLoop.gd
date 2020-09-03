extends Node2D

var DUNGEON = preload("res://Worlds/Dungeon.tscn")
var current_dungeon

var current_max = 0

var kills = 0

func _ready():
	_spawn_dungeon(current_max + 5)


func _process(delta):
	$UI/Label.text = str(kills)


func _update_enemy_kills():
	kills += 1


func _finish_level():
	var children = get_children()
	for child in children:
		if "Dungeon" in child.name:
			current_dungeon = child
		if "LevelPortal" in child.name:
			child.call_deferred("queue_free")
	
	current_dungeon.call_deferred("queue_free")
	current_max += 1
	call_deferred("_spawn_dungeon", current_max + 5)


func _spawn_dungeon(max_enemies):
	var dungeon = DUNGEON.instance()
	
	dungeon.max_enemies = max_enemies
	add_child(dungeon)
