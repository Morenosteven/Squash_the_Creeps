extends Label

var score = 0
var combo_count = 0
var combo_timer = 0.0
var combo_window = 2.0  # 2 segundos para mantener combo
var last_kill_time = 0.0


func _process(delta):
	if combo_count > 0:
		combo_timer += delta
		if combo_timer > combo_window:
			# Se acabó el tiempo del combo
			if combo_count >= 3:
				print("🎉 ¡COMBO TERMINADO! x", combo_count, " enemigos")
			combo_count = 0
			combo_timer = 0.0


func _on_Mob_squashed(points_earned = 1, mob_type = 0):
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# Verificar si está dentro de la ventana de combo
	if current_time - last_kill_time <= combo_window:
		combo_count += 1
		combo_timer = 0.0  # Resetear el timer del combo
	else:
		# Combo roto, empezar nuevo
		combo_count = 1
		combo_timer = 0.0
	
	last_kill_time = current_time
	
	# Calcular puntos con multiplicador
	var points = points_earned
	var multiplier = 1
	
	if combo_count >= 3:
		multiplier = combo_count  # x3, x4, x5, etc.
		points = points_earned * multiplier
		print("🔥 COMBO x", multiplier, "! +", points, " puntos")
	elif combo_count == 2:
		points = points_earned * 2
		print("💥 Combo x2! +", points, " puntos")
	else:
		if points_earned > 1:
			print("💜 MORADO! +", points_earned, " puntos")
	
	score += points
	
	# Actualizar texto con combo si existe
	if combo_count >= 2:
		text = "Score: %s (COMBO x%s)" % [score, combo_count]
	else:
		text = "Score: %s" % score
