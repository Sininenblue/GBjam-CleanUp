extends Node2D

var PORTAL = preload("res://Worlds/LevelPortal.tscn")
var do_once = false

var PLAYER = preload("res://Player/Player.tscn")
var GOBLIN = preload("res://Enemies/Goblin/Goblin.tscn")

export(int) var max_enemies = 5
var current_enemies = 0
var steps_since_spawn = 0

var enemies = []
var portal_position = Vector2.ZERO

var borders = Rect2(1, 1, 30, 14 )

onready var tiles = $TileMap

func _ready():
	randomize()
	_generate_level()


func _process(delta):
	if enemies.size() == 1:
		portal_position = enemies[0].position
	
	print(enemies.size())
	
	if enemies.size() == 0:
		#have a delay
		if do_once == false:
			_spawn_level_portal()
			do_once = true



func _generate_level():
	var walker = Walker.new(Vector2(15, 13), borders)
	var map = walker.walk(150)
	walker.queue_free()
	
	spawn_player(map[0] * 16)
	
	#enemy spawns
	for location in map:
		steps_since_spawn += 1
		if randf() <= 0.05 and steps_since_spawn >= 20 and current_enemies < max_enemies:
			spawn_goblin(location * 16)
	
	#set cells
	for location in map:
		tiles.set_cellv(location, 5)
	tiles.update_bitmask_region(borders.position, borders.end)


func _spawn_level_portal():
	var portal = PORTAL.instance()
	portal.position = portal_position
	get_parent().add_child(portal)


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
