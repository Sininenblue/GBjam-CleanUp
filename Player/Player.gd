extends KinematicBody2D

#var PARTICLES = preload("res://Particles/SwordParticles.tscn")
var BULLET = preload("res://Combat/Bullets/SwordBullet.tscn")

export(int) var max_health = 5
var health = max_health

var input = Vector2.ZERO
var velocity = Vector2.ZERO
var dash_vector = Vector2.RIGHT
var speed = 16 * 3
var speed_weight = .3


var targets = []

var state = MOVE
enum{
	MOVE,
	DASH
}

onready var weapon = $Weapon
onready var anim = $AnimationTree.get("parameters/playback")


func _physics_process(delta):
	_handle_animation()
	_targeting()
	
	match state:
		MOVE:
			_move_state()
			
			if Input.is_action_just_pressed("Ability") and $DashCooldown.time_left == 0:
				$Camera.add_trauma(.1)
				$DashCooldown.start()
				state = DASH
		DASH:
			_dash_state()
	
	velocity = move_and_slide(velocity)


func _move_state():
	if Input.is_action_just_pressed("Shoot"):
		anim.travel("Attack")
	
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input = input.normalized()
	
	if input != Vector2.ZERO:
		dash_vector = input
	
	velocity.x = lerp(velocity.x, input.x * speed, speed_weight)
	velocity.y = lerp(velocity.y, input.y * speed, speed_weight)


func _dash_state():
	velocity = dash_vector * (speed * 3)
	$Hurtbox/CollisionShape2D.disabled = true
	yield(get_tree().create_timer(.2), "timeout")
	$Hurtbox/CollisionShape2D.disabled = false
	state = MOVE


func _handle_animation():
	if input != Vector2.ZERO:
		anim.travel("Run")
	else:
		anim.travel("Idle")


func _targeting():
	targets.sort_custom(self, "sort_closest")
	
	if targets.size() != 0:
		if targets[0].alive == true:
			var target_vec = targets[0].global_position - global_position
			var actual_target = atan2(target_vec.y, target_vec.x)
			weapon.global_rotation = lerp_angle(weapon.global_rotation, actual_target, .5)

func sort_closest(a, b):
	if position.distance_to(a.position) < position.distance_to(b.position):
		return true
	return false

func _shoot():
	$Camera.add_trauma(.1)
	
	var bullet = BULLET.instance()
	bullet.start($Weapon/Muzzle.global_transform)
	get_parent().add_child(bullet)

func _on_Detection_body_entered(body):
	targets.append(body)

func _on_Detection_body_exited(body):
	targets.erase(body)


func _on_Hurtbox_area_entered(area):
	health -= 1
	$Camera.add_trauma(.15)
	
	$"CanvasLayer/Player UI/Health".max_value = max_health
	$"CanvasLayer/Player UI/Health".value = health
	
	if health <= 0:
		#kill effect
		anim.travel("Dead")
		set_physics_process(false)

#func _produce_particles():
#	var particles = PARTICLES.instance()
#	particles.emitting = true
#	particles.position = position
#	get_parent().add_child(particles)
#	yield(get_tree().create_timer(1), "timeout")
#	particles.call_deferred("queue_free")


func _on_Timer_timeout():
	if state == DASH:
		var ghost = preload("res://Particles/Ghost.tscn").instance()
		get_parent().add_child(ghost)
		ghost.position = position
		ghost.texture = $Sprite.texture
		ghost.hframes = $Sprite.hframes
		ghost.frame = $Sprite.frame
		ghost.flip_h = $Sprite.flip_h
