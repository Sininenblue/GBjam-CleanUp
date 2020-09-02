extends KinematicBody2D

var BULLET = preload("res://Combat/Bullets/SpearBullet.tscn")

export(int) var max_health = 3
var health = max_health
var alive = true

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
onready var anim = $AnimationTree.get("parameters/playback")


func _ready():
	randomize()

func _physics_process(delta):
	_handle_animation()
	_targeting()
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, .3)
			
			_restart_timer([WANDER, ATTACK])
			
		WANDER:
			velocity = velocity.move_toward(direction * speed, .5)
			
			_restart_timer([IDLE, ATTACK])
			
		ATTACK:
			if $AttackTimer.time_left == 0:
				anim.travel("Attack")
				$AttackTimer.start(.5)
			
			_restart_timer([WANDER])
	
	velocity = velocity.move_toward(Vector2.ZERO, .3)
	velocity = move_and_slide(velocity)


func _handle_animation():
	if alive:
		if velocity != Vector2.ZERO:
			anim.travel("Run")
		else:
			anim.travel("Idle")
	else:
		anim.travel("Death")


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
		alive = false
		if "Dungeon" in get_parent().name:
			get_parent().enemies.erase(self)



func _dead():
	velocity = Vector2.ZERO
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)
	set_physics_process(false)
