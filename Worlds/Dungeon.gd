extends Node2D

var borders = Rect2(1, 1, 30, 14 )

onready var tiles = $TileMap

func _ready():
	randomize()
	_generate_level()


func _generate_level():
	var walker = Walker.new(Vector2(15, 7), borders)
	
	var map = walker.walk(350)
	walker.queue_free()
	
	for location in map:
		tiles.set_cellv(location, -1)
	
	tiles.update_bitmask_region(borders.position, borders.end)


func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
