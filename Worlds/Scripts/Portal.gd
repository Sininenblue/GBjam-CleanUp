extends Area2D


func _ready():
	pass


func _on_Portal_body_entered(body):
	get_parent()._finish_level()
	call_deferred("queue_free")
