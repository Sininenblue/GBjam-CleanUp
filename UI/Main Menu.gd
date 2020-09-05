extends Control

export(String, FILE) var Play

func _on_Button_button_down():
	$Press.play()
	get_tree().change_scene(Play)
