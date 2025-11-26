extends Area3D

enum PowerUpType { BLUE_DOUBLE_JUMP, YELLOW_SHIELD, RED_HEALTH }

@export var powerup_type: PowerUpType = PowerUpType.BLUE_DOUBLE_JUMP

var rotation_speed = 3.0
var float_amplitude = 0.3
var float_speed = 3.0
var time = 0.0
var initial_y = 1.5


func _ready():
	position.y = initial_y
	body_entered.connect(_on_body_entered)
	update_appearance()


func update_appearance():
	var mesh_instance = $MeshInstance3D
	var material = mesh_instance.get_active_material(0).duplicate()
	
	match powerup_type:
		PowerUpType.BLUE_DOUBLE_JUMP:
			# Azul - Doble Salto
			material.albedo_color = Color(0.2, 0.5, 1.0, 1)
			material.emission = Color(0.2, 0.5, 1.0, 1)
		PowerUpType.YELLOW_SHIELD:
			# Amarillo - Escudo/Inmunidad
			material.albedo_color = Color(1.0, 0.9, 0.2, 1)
			material.emission = Color(1.0, 0.9, 0.2, 1)
		PowerUpType.RED_HEALTH:
			# Rojo - Vida
			material.albedo_color = Color(1.0, 0.2, 0.2, 1)
			material.emission = Color(1.0, 0.2, 0.2, 1)
	
	mesh_instance.set_surface_override_material(0, material)


func _process(delta):
	time += delta
	rotate_y(rotation_speed * delta)
	position.y = initial_y + sin(time * float_speed) * float_amplitude


func _on_body_entered(body):
	if body.name == "Player":
		match powerup_type:
			PowerUpType.BLUE_DOUBLE_JUMP:
				body.activate_double_jump()
				print("🔵 Power-Up AZUL: Doble Salto por 10 segundos")
			PowerUpType.YELLOW_SHIELD:
				body.activate_shield()
				print("🟡 Power-Up AMARILLO: Inmunidad por 5 segundos")
			PowerUpType.RED_HEALTH:
				body.heal()
				print("🔴 Power-Up ROJO: +1 Vida restaurada")
		queue_free()
