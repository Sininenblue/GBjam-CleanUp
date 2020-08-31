extends KinematicBody2D

var input = Vector2.ZERO
var velocity = Vector2.ZERO
var speed = 16 * 3
var speed_weight = .3

func _physics_process(delta):
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	velocity.x = lerp(velocity.x, input.x * speed, speed_weight)
	velocity.y = lerp(velocity.y, input.y * speed, speed_weight)
	velocity = move_and_slide(velocity)
