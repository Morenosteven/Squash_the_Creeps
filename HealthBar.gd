extends HBoxContainer

@onready var heart1 = $Heart1
@onready var heart2 = $Heart2
@onready var heart3 = $Heart3

var hearts = []


func _ready():
	hearts = [heart1, heart2, heart3]
	update_health(3)


func update_health(health: int):
	for i in range(3):
		if i < health:
			hearts[i].text = "❤️"
		else:
			hearts[i].text = "🖤"
