extends Area2D


func _ready():
	$AnimatedSprite.play("default")
	


func _on_Portal_body_entered(body):
	get_parent()._play_transition()
	call_deferred("queue_free")
