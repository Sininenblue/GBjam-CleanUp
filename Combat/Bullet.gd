extends Node2D

export var rotating = false
export(int) var damage setget _set_damage

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO

onready var ground = $Floor

export var speed = 16 * 5

func _set_damage(new_value):
	$Hitbox.damage = new_value

func start(_transform):
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
	queue_free()


func _on_Floor_body_entered(body):
	queue_free()
