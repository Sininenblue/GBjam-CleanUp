extends Navigation2D

var PLAYER = preload("res://Player/Player.tscn")
var CAMERA = preload("res://Objects/Camera/Camera.tscn")

var FATGOBLIN = preload("res://Enemies/FatGoblin.tscn")

export(int) var max_enemies = 5
var current_enemies = 0
var steps_since_spawn = 0
var enemies = [] setget set_enemies

var borders = Rect2(1, 1, 30, 14 )

onready var tiles = $TileMap
onready var Main = $Main

func _ready():
	randomize()
	_generate_level()


func set_enemies(new_value):
	enemies = new_value
	
	if enemies.size() == 1:
		pass
	elif enemies.size() == 0:
		pass


func _generate_level():
	var walker = Walker.new(Vector2(15, 13), borders)
	var map = walker.walk(150)
	walker.queue_free()
	
	spawn_player(map[0])
	spawn_fat_goblin(map[6])
	
	for location in map:
		tiles.set_cellv(location, 5)
		
		steps_since_spawn += 1
		if randf() <= 0.05 and steps_since_spawn >= 20 and current_enemies < max_enemies:
			pass #spawn enemeis here
		
	tiles.update_bitmask_region(borders.position, borders.end)
	tiles.update_dirty_quadrants()


func spawn_player(location):
	var player = PLAYER.instance()
	player.position = location * 16
	Main.add_child(player)


#func spawn_goblin(location):
#	var goblin = GOBLIN.instance()
#	goblin.position = location
#	add_child(goblin)
#
#	enemies.append(goblin)
#	current_enemies += 1
#	steps_since_spawn = 0

func spawn_fat_goblin(location):
	var fatgoblin = FATGOBLIN.instance()
	fatgoblin.position = location * 16
	Main.add_child(fatgoblin)

	enemies.append(fatgoblin)
	current_enemies += 1
	steps_since_spawn = 0

#func _spawn_level_portal():
#	var portal = PORTAL.instance()
#	portal.position = portal_position
#	get_parent().add_child(portal)
