extends KinematicBody2D

var BULLET = preload("res://Combat/Bullets/SwordBullet.tscn")

export(int) var health = 5

var input = Vector2.ZERO
var velocity = Vector2.ZERO
var speed = 16 * 3
var speed_weight = .3

var targets = []

onready var weapon = $Weapon
onready var anim = $AnimationTree.get("parameters/playback")


func _physics_process(delta):
	_handle_animation()
	_targeting()
	
	if Input.is_action_just_pressed("Shoot"):
		anim.travel("Attack")
	
	
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	
	velocity.x = lerp(velocity.x, input.x * speed, speed_weight)
	velocity.y = lerp(velocity.y, input.y * speed, speed_weight)
	velocity = move_and_slide(velocity)


func _handle_animation():
	if input != Vector2.ZERO:
		anim.travel("Run")
	else:
		anim.travel("Idle")


func _targeting():
	targets.sort_custom(self, "sort_closest")
	
	if targets.size() != 0:
		var target_vec = targets[0].global_position - global_position
		var actual_target = atan2(target_vec.y, target_vec.x)
		weapon.global_rotation = lerp_angle(weapon.global_rotation, actual_target, .5)

func sort_closest(a, b):
	if position.distance_to(a.position) < position.distance_to(b.position):
		return true
	return false

func _shoot():
	$Camera.add_trauma(.08)
	
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
	
	if health <= 0:
		#kill effect
		call_deferred("queue_free")
