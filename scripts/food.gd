extends Node2D

#https://forum.godotengine.org/t/how-do-i-make-a-custom-signal/4039

# Called w1hen the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass 
	


func _on_area_2d_body_entered(body):
	if "FoodGatherer" in body.get_parent().name:
		global.foodate.emit(body)
		queue_free()


