extends Navigation2D

var PLAYER = preload("res://Player/Player.tscn")
var CAMERA = preload("res://Objects/Camera/Camera.tscn")

var FATGOBLIN = preload("res://Enemies/FatGoblin.tscn")
var GOBLIN = preload("res://Enemies/Goblin.tscn")

var PORTAL = preload("res://Worlds/Portal.tscn")
var portal_location = Vector2.ZERO


export(int) var max_enemies = 5
var current_enemies = 0
var steps_since_spawn = 0
var enemies = []
var enemy_amount setget set_enemies

var borders = Rect2(1, 1, 30, 14 )

onready var tiles = $TileMap
onready var Main = $Main

func _ready():
	randomize()
	_generate_level()

func set_enemies(new_value):
	if enemy_amount != null and enemy_amount > new_value:
		get_parent().kills += 1
	
	enemy_amount = new_value
	
	if enemy_amount == 0:
		portal_location = enemies[0].position
		var portal = PORTAL.instance()
		portal.position = portal_location
		get_parent().add_child(portal)


func _generate_level():
	var walker = Walker.new(Vector2(15, 13), borders)
	var map = walker.walk(150)
	walker.queue_free()
	
	spawn_player(map[0])
	
	for location in map:
		tiles.set_cellv(location, 5)
		
		steps_since_spawn += 1
		if randf() <= 0.05 and steps_since_spawn >= 20 and current_enemies < max_enemies:
			if randf() <= .5:
				spawn_goblin(location)
			else:
				spawn_fat_goblin(location)
		
	
	self.enemy_amount = enemies.size()
	tiles.update_bitmask_region(borders.position, borders.end)


func spawn_player(location):
	var player = PLAYER.instance()
	player.position = location * 16
	Main.add_child(player)

func spawn_goblin(location):
	var goblin = GOBLIN.instance()
	goblin.position = location * 16
	Main.add_child(goblin)
	
	enemies.append(goblin)
	current_enemies += 1
	steps_since_spawn = 0

func spawn_fat_goblin(location):
	var fatgoblin = FATGOBLIN.instance()
	fatgoblin.position = location * 16
	Main.add_child(fatgoblin)

	enemies.append(fatgoblin)
	current_enemies += 1
	steps_since_spawn = 0
