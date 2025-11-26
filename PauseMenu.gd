extends ColorRect


func _on_resume_button_pressed():
	get_tree().paused = false
	get_parent().get_parent().game_paused = false
	visible = false
	print("▶️ Juego reanudado")


func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	print("🔄 Reiniciando juego")
