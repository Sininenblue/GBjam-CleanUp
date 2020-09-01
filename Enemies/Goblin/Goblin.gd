extends KinematicBody2D

var BULLET = preload("res://Combat/Bullets/SpearBullet.tscn")

export var health = 3

var velocity = Vector2.ZERO
var speed = 16 * 5
onready var start_point = global_position
var direction

var target

var state = IDLE
enum{
	IDLE,
	WANDER,
	ATTACK
}

onready var weapon = $Weapon
onready var stimer = $StateTimer

func _ready():
	randomize()

func _physics_process(delta):
	_targeting()
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, .3)
			
			_restart_timer([WANDER, ATTACK])
			
		WANDER:
			velocity = velocity.move_toward(direction * speed, .5)
			
			_restart_timer([IDLE, ATTACK])
			
		ATTACK:
			$AnimationPlayer.play("Attack")
			
			_restart_timer([WANDER, ATTACK])
	
	velocity = velocity.move_toward(Vector2.ZERO, .3)
	velocity = move_and_slide(velocity)


func _targeting():
	if target != null:
		var target_vec = target.global_position - global_position
		var actual_target = atan2(target_vec.y, target_vec.x)
		weapon.global_rotation = lerp_angle(weapon.global_rotation, actual_target, .5)


func _shoot():
	var bullet = BULLET.instance()
	bullet.start($Weapon/Muzzle.global_transform)
	get_parent().add_child(bullet)


func _on_Detection_body_entered(body):
	target = body


func _on_Detection_body_exited(body):
	target = null


func _restart_timer(list):
	if stimer.time_left == 0:
		direction = global_position.direction_to(start_point + Vector2(rand_range(-16, 16),rand_range(-16, 16)))
		stimer.start(rand_range(1,3))
		state = _random_state(list)

func _random_state(list):
	list.shuffle()
	return list.pop_front()


func _on_Hurtbox_area_entered(area):
	health -= 1
	
	if health <= 0:
		#kill effect
		call_deferred("queue_free")
