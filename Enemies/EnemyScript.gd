extends KinematicBody2D

export var rotating = false

var BULLET = preload("res://Combat/Hammer.tscn")

export(int) var max_health = 5
var health = max_health
var alive = true

export(int) var speed = 3
var velocity = Vector2.ZERO

var target

var wander_target = Vector2.ZERO

var state = WANDER
enum{
	IDLE,
	WANDER,
	ATTACK
}

onready var wtimer = $WanderTimer
onready var stimer = $StateTimer
onready var weapon = $Weapon

func _ready():
	randomize()
	speed *= 16
	wander_target = _get_wander_target()


func _physics_process(delta):
	_targeting()
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, .5)
			
			if stimer.time_left == 0:
				state = _random_state([WANDER, ATTACK])
		WANDER:
			velocity = velocity.move_toward(wander_target * speed,.5)
			if wtimer.time_left == 0:
				wander_target = _get_wander_target()
			
			if stimer.time_left == 0:
				state = _random_state([IDLE, ATTACK])
		ATTACK:
			if target == null:
				state = _random_state([WANDER])
			else:
				
				_shoot()
				
				if stimer.time_left == 0: #do this when animation finishes instead
					state = _random_state([IDLE, ATTACK])
	
	velocity = move_and_slide(velocity)


func _random_state(list):
	stimer.start(rand_range(1,3))
	list.shuffle()
	return list.pop_front()

func _get_wander_target():
	wtimer.start(rand_range(1, 3))
	return Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()


func _targeting():
	if target != null:
		var target_vec = target.global_position - global_position
		var actual_target = atan2(target_vec.y, target_vec.x)
		weapon.global_rotation = lerp_angle(weapon.global_rotation, actual_target, .5)


func _shoot():
	var bullet = BULLET.instance()
	bullet.start($Weapon/Muzzle.global_transform)
	bullet.rotating = rotating
	
	get_parent().add_child(bullet)


#func _dead():
#	velocity = Vector2.ZERO
#	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
#	$CollisionShape2D.set_deferred("disabled", true)
#	set_physics_process(false)


func _on_Detection_body_entered(body):
	target = body

func _on_Detection_body_exited(body):
	target = null
