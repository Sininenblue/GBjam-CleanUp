extends KinematicBody2D

export(int) var damage = 1
export var rotating = false

export(PackedScene) var BULLET

export(int) var max_health = 5
var health
var alive = true

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
	$Sprite.flip_h = abs(weapon.rotation_degrees) > 90
	_targeting()
	
	if alive:
		match state:
			IDLE:
				anim.travel("Idle")
				
				velocity = velocity.move_toward(Vector2.ZERO, .5)
				
				if stimer.time_left == 0:
					state = _random_state([WANDER, ATTACK])
			WANDER:
				anim.travel("Run")
				
				velocity = velocity.move_toward(wander_target * speed,.5)
				if wtimer.time_left == 0:
					wander_target = _get_wander_target()
				
				if stimer.time_left == 0:
					state = _random_state([IDLE, ATTACK])
			ATTACK:
				if target == null:
					state = _random_state([WANDER])
				else:
					
					anim.travel("Attack")
					
					if stimer.time_left == 0: #do this when animation finishes instead
						state = _random_state([IDLE, ATTACK])
		
		velocity = velocity.move_toward(Vector2.ZERO, .2)
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
	bullet.damage = damage
	
	get_parent().add_child(bullet)





func _on_Detection_body_entered(body):
	target = body

func _on_Detection_body_exited(body):
	target = null


func _on_Hurtbox_area_entered(area):
	health -= area.damage
	anim.travel("Hit")
	
	if health <= 0:
		alive = false
		anim.travel("Death")


func _dead():
	get_parent().get_parent().enemy_amount -= 1
	get_parent().get_parent().enemies.erase(self)
	
	velocity = Vector2.ZERO
	$Weapon.visible = false
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)
	set_physics_process(false)
