extends CharacterBody3D

signal hit
signal health_changed(new_health)
signal damage_taken

## How fast the player moves in meters per second.
@export var speed = 14
## Vertical impulse applied to the character upon jumping in meters per second.
@export var jump_impulse = 20
## Vertical impulse applied to the character upon bouncing over a mob in meters per second.
@export var bounce_impulse = 16
## The downward acceleration when in the air, in meters per second.
@export var fall_acceleration = 75

# Sistema de vida
var max_health = 3
var current_health = 3
var is_invulnerable = false
var invulnerability_duration = 1.0  # 1 segundo de invencibilidad

# Sistema de Power-Ups
var has_shield = false
var can_double_jump = false
var has_double_jumped = false


func _physics_process(delta):
	var direction = Vector3.ZERO
	if Input.is_action_pressed(&"move_right"):
		direction.x += 1
	if Input.is_action_pressed(&"move_left"):
		direction.x -= 1
	if Input.is_action_pressed(&"move_back"):
		direction.z += 1
	if Input.is_action_pressed(&"move_forward"):
		direction.z -= 1

	if direction != Vector3.ZERO:
		# In the lines below, we turn the character when moving and make the animation play faster.
		direction = direction.normalized()
		# Setting the basis property will affect the rotation of the node.
		basis = Basis.looking_at(direction)
		$AnimationPlayer.speed_scale = 4
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		$AnimationPlayer.speed_scale = 1
		velocity.x = 0
		velocity.z = 0

	# Jumping.
	if is_on_floor():
		has_double_jumped = false
		if Input.is_action_just_pressed(&"jump"):
			velocity.y = jump_impulse
	elif can_double_jump and !has_double_jumped and Input.is_action_just_pressed(&"jump"):
		velocity.y = jump_impulse
		has_double_jumped = true
		print("🚀 ¡Doble salto!")

	# We apply gravity every frame so the character always collides with the ground when moving.
	# This is necessary for the is_on_floor() function to work as a body can always detect
	# the floor, walls, etc. when a collision happens the same frame.
	velocity.y -= fall_acceleration * delta
	move_and_slide()

	# Here, we check if we landed on top of a mob and if so, we kill it and bounce.
	# With move_and_slide(), Godot makes the body move sometimes multiple times in a row to
	# smooth out the character's motion. So we have to loop over all collisions that may have
	# happened.
	# If there are no "slides" this frame, the loop below won't run.
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		if collision.get_collider().is_in_group(&"mob"):
			var mob = collision.get_collider()
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				mob.squash()
				velocity.y = bounce_impulse
				# Prevent this block from running more than once,
				# which would award the player more than 1 point for squashing a single mob.
				break

	# This makes the character follow a nice arc when jumping
	rotation.x = PI / 6 * velocity.y / jump_impulse


func die():
	hit.emit()
	queue_free()


func take_damage():
	if is_invulnerable:
		return  # No recibir daño si está en invencibilidad
	
	if has_shield:
		print("🛡️ ¡Escudo absorbió el daño!")
		return
	
	current_health -= 1
	health_changed.emit(current_health)
	damage_taken.emit()  # Emitir señal para screen shake
	print("💔 Vida: ", current_health, "/", max_health)
	
	# Activar invencibilidad temporal
	is_invulnerable = true
	print("✨ Invencibilidad activada por ", invulnerability_duration, " segundo")
	await get_tree().create_timer(invulnerability_duration).timeout
	is_invulnerable = false
	print("✨ Invencibilidad desactivada")
	
	if current_health <= 0:
		die()


func _on_MobDetector_body_entered(_body):
	take_damage()


func activate_double_jump():
	can_double_jump = true
	print("🔵 ¡Doble Salto activado por 10 segundos!")
	await get_tree().create_timer(10.0).timeout
	can_double_jump = false
	has_double_jumped = false
	print("🔵 Doble Salto desactivado")


func activate_shield():
	has_shield = true
	print("🟡 ¡Inmunidad activada por 5 segundos!")
	await get_tree().create_timer(5.0).timeout
	has_shield = false
	print("🟡 Inmunidad desactivada")


func heal():
	if current_health < max_health:
		current_health += 1
		health_changed.emit(current_health)
		print("🔴 ¡Vida restaurada! Vida: ", current_health, "/", max_health)
	else:
		print("🔴 Vida ya está al máximo")
