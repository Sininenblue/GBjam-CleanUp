extends Sprite


func _ready():
	$Alpha.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), .5, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Alpha.start()


func _on_Alpha_tween_all_completed():
	call_deferred("queue_free")
