extends Node2D

var IMPACT = preload("res://Particles/Impact.tscn")

export var rotating = false
export(int) var damage setget _set_damage

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO

onready var ground = $Floor

var speed

func _set_damage(new_value):
	$Hitbox.damage = new_value


func start(_transform, new_speed):
	speed = new_speed * 16
	global_transform = _transform
	velocity = transform.x * speed


func _physics_process(delta):
	velocity += acceleration * delta
	velocity = velocity.clamped(speed)
	if rotating == false:
		rotation = velocity.angle()
	else:
		rotation += .2
	position += velocity * delta
	
	ground.rotation = -rotation


func _on_Hitbox_area_entered(area):
	_spawn_impact()
	queue_free()


func _on_Floor_body_entered(body):
	$WallHit.play()
	_spawn_impact()
	
	velocity = Vector2.ZERO
	$Sprite.visible = false
	yield($WallHit, "finished")
	queue_free()


func _spawn_impact():
	var impact = IMPACT.instance()
	impact.position = position
	get_parent().add_child(impact)
