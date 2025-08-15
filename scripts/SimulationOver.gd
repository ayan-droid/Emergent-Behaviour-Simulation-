extends Control

func _ready():
	global.game_over.connect(_game_over)

func _game_over(time):
	$Panel/Time_Survived.text = "Time survived: " + str(int(time))
