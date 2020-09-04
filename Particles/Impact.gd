extends AnimatedSprite

func _ready():
	$CPUParticles2D.emitting = true
	rotation_degrees = rand_range(0, 360)
	play("Hit")
	yield(get_tree().create_timer(.8), "timeout")
	call_deferred("queue_free")
