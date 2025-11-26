@tool
extends EditorScript

# Script para generar imágenes de corazones como placeholders
# Ejecútalo desde el editor: File → Run Script

func _run():
	print("Generando imágenes de corazones...")
	
	# Crear corazón lleno (rojo)
	var heart_full = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	heart_full.fill(Color(0, 0, 0, 0))  # Transparente
	
	# Dibujar corazón rojo (forma simplificada)
	for y in range(8, 28):
		for x in range(4, 28):
			var dx = x - 16
			var dy = y - 12
			var distance = sqrt(dx * dx + dy * dy)
			if distance < 12:
				heart_full.set_pixel(x, y, Color(1, 0, 0, 1))
	
	# Guardar
	var err = heart_full.save_png("res://ui/heart_full.png")
	if err == OK:
		print("✓ heart_full.png creado")
	else:
		print("✗ Error al crear heart_full.png")
	
	# Crear corazón vacío (gris)
	var heart_empty = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	heart_empty.fill(Color(0, 0, 0, 0))
	
	# Dibujar corazón gris
	for y in range(8, 28):
		for x in range(4, 28):
			var dx = x - 16
			var dy = y - 12
			var distance = sqrt(dx * dx + dy * dy)
			if distance < 12:
				heart_empty.set_pixel(x, y, Color(0.5, 0.5, 0.5, 1))
	
	err = heart_empty.save_png("res://ui/heart_empty.png")
	if err == OK:
		print("✓ heart_empty.png creado")
	else:
		print("✗ Error al crear heart_empty.png")
	
	print("¡Imágenes generadas! Reimporta los archivos en el FileSystem.")
	print("Nota: Son placeholders simples. Para mejor calidad, usa sprites de:")
	print("  - https://kenney.nl/assets/ui-pack")
	print("  - https://opengameart.org/")
