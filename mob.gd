extends CharacterBody3D

# Emitted when the player jumped on the mob.
signal squashed

## Minimum speed of the mob in meters per second.
@export var min_speed = 10
## Maximum speed of the mob in meters per second.
@export var max_speed = 18

# Tipos de enemigos
enum MobType { NORMAL, FAST_RED, RARE_PURPLE }
var mob_type: MobType = MobType.NORMAL
var point_value = 1


func _physics_process(_delta):
	move_and_slide()


func initialize(start_position, player_position, type: MobType = MobType.NORMAL):
	mob_type = type
	
	# Configurar según tipo
	if mob_type == MobType.FAST_RED:
		min_speed = 18
		max_speed = 28
		point_value = 1
		print("🔴 Creep ROJO rápido spawneado")
	elif mob_type == MobType.RARE_PURPLE:
		min_speed = 12
		max_speed = 20
		point_value = 2
		print("💜 Creep MORADO (doble puntos) spawneado")
	
	# Ignore the player's height, so that the mob's orientation is not slightly
	# shifted if the mob spawns while the player is jumping.
	var target = Vector3(player_position.x, start_position.y, player_position.z)
	look_at_from_position(start_position, target, Vector3.UP)

	# Rotate this mob randomly within range of -45 and +45 degrees,
	# so that it doesn't move directly towards the player.
	rotate_y(randf_range(-PI / 4, PI / 4))

	var random_speed = randf_range(min_speed, max_speed)
	# We calculate a forward velocity first, which represents the speed.
	velocity = Vector3.FORWARD * random_speed
	# We then rotate the vector based on the mob's Y rotation to move in the direction it's looking.
	velocity = velocity.rotated(Vector3.UP, rotation.y)

	$AnimationPlayer.speed_scale = random_speed / min_speed


func squash():
	squashed.emit(point_value, mob_type)
	queue_free()


func _on_visible_on_screen_notifier_screen_exited():
	queue_free()
