extends Node2D

var DUNGEON = preload("res://Worlds/Dungeon.tscn")

var current_max = 0

var kills = 0

func _ready():
	_spawn_dungeon(current_max + 5, 1)




func _process(delta):
	$UI/Label.text = str(kills)


func _update_enemy_kills():
	kills += 1


func _finish_level():
	get_child(1).call_deferred("queue_free")
	
	current_max += 1
	_spawn_dungeon(current_max + 5, 2)


func _spawn_dungeon(max_enemies, enemy_types):
	var dungeon = DUNGEON.instance()
	
	dungeon.max_enemies = max_enemies
	add_child(dungeon)
