extends KinematicBody2D

export(int) var damage = 1
export var rotating = false
export(int) var bulletspeed = 5

export(PackedScene) var BULLET

export(int) var max_health = 5
var health
var alive = true
var hit = false


export(int) var speed = 3
var velocity = Vector2.ZERO

var target

var wander_target = Vector2.ZERO

var state = IDLE
enum{
	IDLE,
	WANDER,
	ATTACK
}

onready var wtimer = $WanderTimer
onready var stimer = $StateTimer
onready var weapon = $Weapon
onready var anim = $AnimationTree.get("parameters/playback")


func _ready():
	health = max_health
	
	randomize()
	speed *= 16
	wander_target = _get_wander_target()


func _physics_process(delta):
	_handle_animation()
	_targeting()
	
	if alive:
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
					if stimer.time_left == 0:
						state = _random_state([IDLE, ATTACK])
		
		velocity = velocity.move_toward(Vector2.ZERO, .2)
		velocity = move_and_slide(velocity)


func _handle_animation():
	$Sprite.flip_h = abs(weapon.rotation_degrees) > 90
	
	
	if alive == false:
		anim.travel("Death")
	else:
		if hit == true:
			$Sprite.frame = 14
		else:
			match state:
				IDLE:
					anim.travel("Idle")
				WANDER:
					anim.travel("Run")
				ATTACK:
					if target != null:
						if $AttackTimer.time_left == 0:
							anim.travel("Attack")
							$AttackTimer.start(.5)


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
	weapon.global_rotation += rand_range(-.15, .15)
	
	var bullet = BULLET.instance()
	bullet.start($Weapon/Muzzle.global_transform, bulletspeed)
	bullet.rotating = rotating
	bullet.damage = damage
	
	get_parent().add_child(bullet)





func _on_Detection_body_entered(body):
	target = body

func _on_Detection_body_exited(body):
	target = null


func _on_Hurtbox_area_entered(area):
	velocity = velocity.move_toward(-position.direction_to(area.position) * 5, .5)
	
	health -= area.damage
	
	hit = true
	$HitTimer.start(.1)
	
	if health <= 0:
		alive = false


func _dead():
	get_parent().get_parent().enemy_amount -= 1
	get_parent().get_parent().enemies.erase(self)
	
	velocity = Vector2.ZERO
	$Weapon.visible = false
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)
	set_physics_process(false)


func _on_HitTimer_timeout():
	$Sprite.frame = 0
	hit = false
