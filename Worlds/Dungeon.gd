extends Node2D

var PLAYER = preload("res://Player/Player.tscn")
var GOBLIN = preload("res://Enemies/Goblin/Goblin.tscn")

export(int) var max_enemies = 5
var current_enemies = 0
var steps_since_spawn = 0

var enemies = []

var borders = Rect2(1, 1, 30, 14 )

onready var tiles = $TileMap

func _ready():
	randomize()
	_generate_level()


func _process(delta):
	$UI/Label.text = str(current_enemies - enemies.size())


func _generate_level():
	var walker = Walker.new(Vector2(15, 13), borders)
	
	var map = walker.walk(150)
	walker.queue_free()
	
	spawn_player(map[0] * 16)
	
	#enemy spawns
	for location in map:
		steps_since_spawn += 1
		if randf() <= 0.25 and steps_since_spawn >= 20 and current_enemies < max_enemies:
			spawn_goblin(location * 16)
	
	#set cells
	for location in map:
		tiles.set_cellv(location, -1)
	tiles.update_bitmask_region(borders.position, borders.end)


func spawn_player(location):
	var player = PLAYER.instance()
	player.position = location
	add_child(player)

func spawn_goblin(location):
	var goblin = GOBLIN.instance()
	goblin.position = location
	add_child(goblin)
	
	enemies.append(goblin)
	current_enemies += 1
	steps_since_spawn = 0
