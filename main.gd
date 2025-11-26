extends Node

@export var mob_scene: PackedScene
var game_paused = false
var mobs_spawned = 0
var purple_spawned_this_wave = false
var wave_size = 10  # Cada 10 mobs = 1 oleada


func _ready():
	if RenderingServer.get_current_rendering_method() == "gl_compatibility":
		# Use PCF13 shadow filtering to improve quality (Medium maps to PCF5 instead).
		RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)

		# Darken the light's energy to compensate for sRGB blending (without affecting sky rendering).
		$DirectionalLight3D.sky_mode = DirectionalLight3D.SKY_MODE_SKY_ONLY
		var new_light: DirectionalLight3D = $DirectionalLight3D.duplicate()
		new_light.light_energy = 0.35
		new_light.sky_mode = DirectionalLight3D.SKY_MODE_LIGHT_ONLY
		add_child(new_light)


	$UserInterface/Retry.hide()


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
	
	if event.is_action_pressed("ui_accept") and $UserInterface/Retry.visible:
		get_tree().reload_current_scene()


func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()
	
	# Determinar tipo de mob
	var mob_type = 0  # NORMAL por defecto
	var type_name = "Normal"
	
	# Cada 10 mobs, resetear oleada
	if mobs_spawned % wave_size == 0:
		purple_spawned_this_wave = false
		print("🌊 Nueva oleada iniciada")
	
	# 15% probabilidad de Creep ROJO (rápido)
	var rand = randf()
	if rand < 0.15:
		mob_type = 1  # FAST_RED
		type_name = "ROJO RÁPIDO"
	# 1 Creep MORADO por oleada (doble puntos)
	elif !purple_spawned_this_wave and (mobs_spawned % wave_size) == 5:
		mob_type = 2  # RARE_PURPLE
		type_name = "MORADO RARO"
		purple_spawned_this_wave = true
	
	mobs_spawned += 1

	# Choose a random location on the SpawnPath.
	var mob_spawn_location = get_node(^"SpawnPath/SpawnLocation")
	mob_spawn_location.progress_ratio = randf()

	# Communicate the spawn location and the player's location to the mob.
	var player_position = $Player.position
	mob.initialize(mob_spawn_location.position, player_position, mob_type)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)
	# We connect the mob to the score label to update the score upon squashing a mob.
	mob.squashed.connect($UserInterface/ScoreLabel._on_Mob_squashed)
	
	if mob_type > 0:
		print("👾 Spawn: ", type_name)


func _on_player_hit():
	$MobTimer.stop()
	$BlueDoubleJumpTimer.stop()
	$YellowShieldTimer.stop()
	$RedHealthTimer.stop()
	$UserInterface/Retry.show()
	# Reset variables de oleada
	mobs_spawned = 0
	purple_spawned_this_wave = false


func _on_player_health_changed(new_health):
	print("🎮 Main recibió cambio de vida: ", new_health)
	$UserInterface/HealthBar.update_health(new_health)


func _on_player_damage_taken():
	# Efecto de sacudida de cámara
	var camera = $CameraPivot/Camera
	var shake_intensity = 0.3
	var shake_duration = 0.3
	
	for i in range(6):  # 6 sacudidas rápidas
		var offset_x = randf_range(-shake_intensity, shake_intensity)
		var offset_y = randf_range(-shake_intensity, shake_intensity)
		camera.h_offset = offset_x
		camera.v_offset = offset_y
		await get_tree().create_timer(shake_duration / 6.0).timeout
	
	# Restaurar posición original
	camera.h_offset = 0
	camera.v_offset = 0
	print("📳 Screen shake ejecutado")


func toggle_pause():
	game_paused = !game_paused
	get_tree().paused = game_paused
	$UserInterface/PauseMenu.visible = game_paused
	print("⏸️ Juego pausado: ", game_paused)


func spawn_powerup(powerup_type: int):
	var powerup = preload("res://PowerUp.tscn").instantiate()
	
	# Posición aleatoria en el área de juego
	var random_x = randf_range(-10, 10)
	var random_z = randf_range(-10, 10)
	powerup.position = Vector3(random_x, 0, random_z)
	
	powerup.powerup_type = powerup_type
	
	add_child(powerup)
	
	var type_name = ""
	match powerup_type:
		0: type_name = "AZUL (Doble Salto)"
		1: type_name = "AMARILLO (Inmunidad)"
		2: type_name = "ROJO (Vida)"
	
	print("✨ Power-up ", type_name, " apareció en: ", powerup.position)


func _on_blue_double_jump_timer_timeout():
	spawn_powerup(0)  # BLUE_DOUBLE_JUMP


func _on_yellow_shield_timer_timeout():
	spawn_powerup(1)  # YELLOW_SHIELD


func _on_red_health_timer_timeout():
	spawn_powerup(2)  # RED_HEALTH
